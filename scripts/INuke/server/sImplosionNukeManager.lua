class "INukeAdmin"

function INukeAdmin:__init()

	self.WNOs = {}
	self.Timers = {}
	
	local infile = io.open("ImplosionNukes.txt", "rb")
	print(infile)
	if infile then
		instr = infile:read("*a")
		infile:close()
		
		local new_name = os.date("%y-%m-%d-ImplosionNukes.txt")
		print("Backing up ImplosionNukes.txt to " .. new_name)
		outfile = io.open(new_name, "wb")
		outfile:write(instr)
		outfile:close()
	
		for line in io.lines("ImplosionNukes.txt") do
			local parts = line:split("|")
			local steamid = SteamId(parts[1])
			local position_parts = parts[2]:split(" ")
			local position = Vector3(tonumber(position_parts[1]), tonumber(position_parts[2]), tonumber(position_parts[3]))
			local angle_parts = parts[3]:split(" ")
			local angle = Angle(tonumber(angle_parts[1]), tonumber(angle_parts[2]), tonumber(angle_parts[3]))
			self:CreateTrap(position, angle, steamid.id)
		end
	end
	
	Events:Subscribe("PreTick", self, self.PreTick)
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
	Events:Subscribe("ClientModuleLoad", self, self.ClientModuleLoad)
	Network:Subscribe("ImplosionTrapCreate", self, self.ImplosionTrapCreate)
	Network:Subscribe("ImplosionTrapActivated", self, self.ImplosionTrapActivated)
end

function INukeAdmin:PreTick()
	local removes = {}
	for id, timer in pairs(self.Timers) do
		if timer:GetSeconds() >= DETONATION_DURATION then
			self.WNOs[id]:Remove()
			self.WNOs[id] = nil
			table.insert(removes, id)
		end
	end
	for _, id in pairs(removes) do
		self.Timers[id] = nil
	end
end

function INukeAdmin:ImplosionTrapActivated(args)
	local wno = self.WNOs[args.id]
	if not wno then return end
	if not wno:GetValue("activated") then
		self.Timers[args.id] = Timer() --add pretick to handle all of these and check against config option
		wno:SetNetworkValue("activated", true)
	end
end

function INukeAdmin:ModuleUnload()
	file = io.open("ImplosionNukes.txt", "wb")
	for _, wno in pairs(self.WNOs) do
		local wno_pos = wno:GetPosition()
		local wno_angle = wno:GetAngle()
		local pos_str = tostring(wno_pos.x) .. " " .. tostring(wno_pos.y) .. " " .. tostring(wno_pos.z)
		local angle_str = tostring(wno_angle.yaw) .. " " .. tostring(wno_angle.pitch) .. " " .. tostring(wno_angle.roll)
		file:write(wno:GetValue("setter") .. "|" .. pos_str .. "|" .. angle_str)
	end
	file:close()
end

function INukeAdmin:ClientModuleLoad(args)
	local player_pos = args.player:GetPosition()
	local ids = {}
	for _, wno in pairs(self.WNOs) do
		if Vector3.Distance(wno:GetPosition(), player_pos) <= wno:GetStreamDistance() then
			table.insert(ids, wno:GetId())
		end
	end
	if next(ids) then
		Network:Send(args.player, "NearbyTrapsOnSpawn", ids)
	end
end

function INukeAdmin:ImplosionTrapCreate(args, player)
	self:CreateTrap(args.position, args.angle, tostring(player:GetSteamId().id))
end

function INukeAdmin:CreateTrap(position, angle, steamid)
	local wno = WorldNetworkObject.Create({position = position, angle = angle})
	wno:SetNetworkValue("setter", tostring(steamid))
	wno:SetNetworkValue("type", "ImplosionTrap")
	wno:SetNetworkValue("is_detonating", false)
	wno:SetNetworkValue("activated", false)
	self.WNOs[wno:GetId()] = wno
end

INA = INukeAdmin()