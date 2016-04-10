class 'Turret'

function Turret:__init()
	guns = {}
	
	turret_range = 450
	fire_interval = 2.5
	
	turret_timer = Timer()
end

function Turret:ReceiveTurrets(args)
	print("Mortar Module Received " .. tostring(table.count(args.statics)) .. " mortars")
	for _, static in pairs(args.statics) do
		if IsValid(static) and not guns[static:GetId()] then
			self:PlaceTurret(static)
		end
	end
	--print("received turrets")
end

function Turret:PlaceTurret(static_object) -- receives static_object
	guns[static_object:GetId()] = static_object
	
	local steam_id = static_object:GetValue("SteamIDid") -- .id
	
	static_object:SetNetworkValue("PlayerMortar", steam_id)
	static_object:SetNetworkValue("Aggro", 1)
	static_object:SetValue("LastShot", 0)
	static_object:SetStreamDistance(750)
	static_object:SetNetworkValue("MortarFriends", Turret:GetMortarFriends(steam_id) or "")
	--Chat:Broadcast("MortarFriends: " .. static_object:GetValue("MortarFriends"), Color.Green)
	--print("initialized a turret @ " .. tostring(static_object:GetPosition()))
end

function Turret:GetMortarFriends(steamid) -- .id
	local qry = SQL:Query("SELECT Friends FROM FriendTable WHERE steamID = (?) LIMIT 1")
	qry:Bind(1, steamid)
	local result = qry:Execute()
	if result[1].Friends then
		return tostring(result[1].Friends)
	else
		return nil
	end
end
	
function Turret:Target()
	local players = {}
	for ply in Server:GetPlayers() do
		if ply:GetValue("CanHit") == true and not ply:GetValue("Invincible") then
			players[ply:GetPosition()] = {id = ply:GetId(), friends = tostring(ply:GetValue("Friends")), steamid = ply:GetSteamId().id}
		end
	end
	--
	--print(table.count(guns))
	for index, turret in pairs(guns) do
		if IsValid(turret) then
			local owner = tostring(turret:GetValue("PlayerMortar"))
			local targets = {}
			for ply_pos, itable in pairs(players) do
				if Vector3.Distance(ply_pos, turret:GetPosition()) < turret_range then
					--Chat:Broadcast("In Range", Color.Red)
					--Chat:Broadcast("Friends of turret: " .. tostring(itable.friends), Color.Red)
					--print("picked target")
					if not itable.friends:find(owner) and owner ~= itable.steamid then
						--Chat:Broadcast("Not Friend", Color.Green)
						table.insert(targets, itable.id)
					end
				end
			end
			if #targets == 0 then
				turret:SetNetworkValue("iTarget", nil)
			else
				turret:SetNetworkValue("iTarget", table.randomvalue(targets)) -- stores id, not player object
				--Chat:Broadcast("Set Target: " .. tostring(Player.GetById(turret:GetValue("iTarget"))), Color(0, 255, 0))
			end
		else
			guns[index] = nil
		end
	end
end

function Turret:Fire() -- sync mortar firing
	local current_time = turret_timer:GetSeconds()
	local counter = 0
	for index, turret in pairs(guns) do
		if IsValid(turret) then
			local itarget = turret:GetValue("iTarget")
			if itarget then
				--print("has target ")
				local target = Player.GetById(itarget)
				if IsValid(target) then
					if turret:GetValue("LastShot") < current_time then
						turret:SetNetworkValue("FireMortarShell", math.random(1, 999999))
						turret:SetValue("LastShot", current_time + fire_interval + math.random())
						--print("FIRED MORTAR SHELL at " .. tostring(Player.GetById(turret:GetValue("iTarget"))))
					end
				end
			end
		else
			guns[index] = nil
		end
	end
end

function Turret:MinuteTick()
	for index, turret in pairs(guns) do
		local steamid = turret:GetValue("SteamIDid")
		if IsValid(turret) and steamid then
			turret:SetNetworkValue("MortarFriends", Turret:GetMortarFriends(steamid) or "")
		end
	end
end

function Turret:Unload()
	--for index, obj in pairs(guns) do
	--	if IsValid(obj) then obj:Remove() end
	--end
end

turret = Turret()

Events:Subscribe("SendFreebuildTurrets", turret, turret.ReceiveTurrets)
--Events:Subscribe("ModuleUnload", turret, turret.Unload)
Events:Subscribe("SecondTick", turret, turret.Target)
Events:Subscribe("MinuteTick", turret, turret.MinuteTick)
Events:Subscribe("PreTick", turret, turret.Fire)