class 'Meteor'

function Meteor:__init()
	iclock = Timer()
	meteors = {}
	zone_players = {}
	spawn_frequency_min = 20 -- minimum meteor respawn delay time in seconds
	spawn_frequency_max = 25 -- maximum meteor respawn delay time in seconds
	y_rand = 1.0
	x_rand = .85
	z_rand = .85
	meteor_height = 650 -- meters above base pos meteors spawn
	meteor_count = 90 -- amount of meteors per cursed zone
	--
	-- basepos + math.random(-radius, radius)
	-- basepos is ground position
	local current_time = iclock:GetSeconds()
	
	for _, itable in pairs(cursed_locations) do
		--local meteorNum = itable.radius / 7.2
		local meteorNum = itable.radius / 7
		for i = 1, meteorNum do
			iWNO = WorldNetworkObject.Create({position = itable.position, angle = Angle(0, (3 * math.pi) / 2, 0)})
			iWNO:SetNetworkValue("Meteor", 1) -- meteor type
			iWNO:SetNetworkValue("Spawn", true)
			iWNO:SetStreamDistance(2500)
			meteors[iWNO:GetId()] = {itime = current_time + math.random(1, 10), base = itable.position, radius = itable.radius}
		end
		zone_players[tostring(itable.position)] = {}
	end
end

function Meteor:Spawn(args)
	local current_time = iclock:GetSeconds()
	local rand = math.random
	for wno_id, itable in pairs(meteors) do
		--print("current_time: " .. tostring(current_time))
		--print("time: " .. time)
		if current_time >= itable.itime then
			local iWNO = WorldNetworkObject.GetById(wno_id)
			if iWNO and IsValid(iWNO) then
				iWNO:SetPosition(Vector3(itable.base.x + rand(-itable.radius, itable.radius), itable.base.y + meteor_height, itable.base.z + rand(-itable.radius, itable.radius))) -- pos randomization
				-- angle randomization
				local itarget = rand(0, 2) -- 50% chance . config chance of targetted meteor here
				if itarget < 2 then
					local plus_min = rand(0, 1)
					if plus_min == 0 then
						iWNO:SetAngle(Angle(rand() * x_rand, ((3 * math.pi) / 2) + (rand() * y_rand), rand() * z_rand)) -- 270 degrees + 0-25 degree random
					else
						iWNO:SetAngle(Angle(rand() * x_rand, ((3 * math.pi) / 2) - (rand() * y_rand), rand() * z_rand)) -- 270 degrees - 0-25 degree random
					end
				else -- targetted meteor
					if table.count(zone_players[tostring(itable.base)]) > 0 then
						local targets = {}
						for id, bool in pairs(zone_players[tostring(itable.base)]) do
							table.insert(targets, id)
						end
						local target = Player.GetById(table.randomvalue(targets))
						if target and IsValid(target) then
							--local angleyaw = Angle.FromVectors(Vector3.Forward, (target:GetPosition()) - iWNO:GetPosition()).yaw
							--local anglepitch = Angle.FromVectors(Vector3.Forward, (target:GetPosition()) - iWNO:GetPosition()).pitch
							local angleyaw = Angle.FromVectors(Vector3.Forward, (target:GetPosition() + Vector3(rand() * rand(-55, 55), rand() * rand(-55, 55), rand() * rand(-55, 55))) - iWNO:GetPosition()).yaw
							local anglepitch = Angle.FromVectors(Vector3.Forward, (target:GetPosition() + Vector3(rand() * rand(-55, 55), rand() * rand(-55, 55), rand() * rand(-55, 55))) - iWNO:GetPosition()).pitch
							iWNO:SetAngle(Angle(angleyaw, anglepitch, 0))
						end
					end
				end
				-- end angle randomization
				iWNO:SetNetworkValue("Spawn", not iWNO:GetValue("Spawn"))
				meteors[wno_id].itime = current_time + rand(spawn_frequency_min, spawn_frequency_max) + rand() * .75
			end
		end
	end
end

function Meteor:ClientEnterMeteorZone(args, player) -- receives pos(string)
	player:SetWeatherSeverity(2)
	local id = player:GetId()
	if zone_players[args.pos] then
		zone_players[args.pos][id] = true
		print("entered in table")
	end
end

function Meteor:ClientExitMeteorZone(args, player) -- receives pos(string)
	player:SetWeatherSeverity(DefaultWorld:GetWeatherSeverity())
	local id = player:GetId()
	if zone_players[args.pos] then
		if zone_players[args.pos][id] then
			zone_players[args.pos][id] = nil
		end
	end
end

function Meteor:MeteorHit(args, player)
	player:Damage(args.dmg)
end

function Meteor:PlayerQuit(args)
	local ply_id = args.player:GetId()
	for pos, id_table in pairs(zone_players) do
		for id, bool in pairs(id_table) do
			if ply_id == id then
				zone_players[pos][id] = nil
			end
		end
	end
end

function Meteor:Unload()
	for wno_id, itable in pairs(meteors) do
		local iWNO = WorldNetworkObject.GetById(wno_id)
		if iWNO and IsValid(iWNO) then
			iWNO:Remove()
		end
	end
end

meteor = Meteor()

Events:Subscribe("ModuleUnload", meteor, meteor.Unload)
Events:Subscribe("PostTick", meteor, meteor.Spawn)
Events:Subscribe("PlayerQuit", meteor, meteor.PlayerQuit)
--
Network:Subscribe("ClientEnterMeteorZone", meteor, meteor.ClientEnterMeteorZone)
Network:Subscribe("ClientExitMeteorZone", meteor, meteor.ClientExitMeteorZone)
Network:Subscribe("MeteorHit", meteor, meteor.MeteorHit)