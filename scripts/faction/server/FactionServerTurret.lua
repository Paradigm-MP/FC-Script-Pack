class 'FactionTurret'

function FactionTurret:__init()
	SQL:Execute("CREATE TABLE IF NOT EXISTS FactionTurrets (faction VARCHAR, position VARCHAR, mode INTEGER)")
	--
	gunargs = {}
	gunargs.model = "22x19.flz/wea34-f.lod"
	gunargs.collision = "22x19.flz/wea34_lod1-f_col.pfx"
	gunargs.angle = Angle(0, 0, 0)
	--
	stickargs = {}
	stickargs.model = "f2s04emp.flz/key040_1-part_b.lod"
	stickargs.collision = "f2s04emp.flz/key040_1_lod1-part_b_col.pfx"
	stickargs.angle = Angle(0, 0, 0)
	--
	sticks = {}
	guns = {}
	--
	turret_range = 450
	--
	local qry = SQL:Query("SELECT faction, position, mode FROM FactionTurrets")
	local spawn_timer_turret = Timer()
	local SQL_turrets = qry:Execute()
	--
	for index, itable in pairs(SQL_turrets) do
		local pos = string.split(tostring(itable.position), ",")
		local static_gun = StaticObject.Create({position = Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3])), angle = Angle(0, 0, 0), model = "22x19.flz/wea34-f.lod", collision = "22x19.flz/wea34_lod1-f_col.pfx"})
		local static_stick = StaticObject.Create({position = Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3])) - Vector3(0, 6.0, 0), angle = Angle(0, 0, 0), model = "f2s04emp.flz/key040_1-part_b.lod", collision = "f2s04emp.flz/key040_1_lod1-part_b_col.pfx"})
		static_gun:SetNetworkValue("fFaction", tostring(itable.faction))
		static_stick:SetNetworkValue("fFaction", tostring(itable.faction))
		static_gun:SetNetworkValue("Aggro", tonumber(itable.mode))
		static_gun:SetNetworkValue("Alive", true)
		static_gun:SetStreamDistance(750)
		static_stick:SetStreamDistance(750)
		guns[static_gun:GetId()] = static_gun
		sticks[static_stick:GetId()] = static_stick
	end
	local turret_count = table.count(guns)
	print("Took " .. tostring(spawn_timer_turret:GetSeconds()) .. " to initialize " .. tostring(turret_count) .. " faction turrets")
	spawn_timer_turret = nil
end

function FactionTurret:PlaceFactionTurret(args) -- receives pos, ply
	if not IsValid(args.ply) then return end
	local command = SQL:Command("INSERT INTO FactionTurrets (faction, position, mode) VALUES (?, ?, ?)")
	command:Bind(1, args.ply:GetValue("Faction"))
	command:Bind(2, tostring(args.pos))
	command:Bind(3, 1) -- aggresive
	command:Execute()
	--
	local static_gun = StaticObject.Create({position = args.pos + Vector3(0, 6.0, 0), angle = Angle(0, 0, 0), model = "22x19.flz/wea34-f.lod", collision = "22x19.flz/wea34_lod1-f_col.pfx"})
	local static_stick = StaticObject.Create({position = args.pos, angle = Angle(0, 0, 0), model = "f2s04emp.flz/key040_1-part_b.lod", collision = "f2s04emp.flz/key040_1_lod1-part_b_col.pfx"})
	guns[static_gun:GetId()] = static_gun
	sticks[static_stick:GetId()] = static_stick
	--
	static_gun:SetNetworkValue("fFaction", tostring(args.ply:GetValue("Faction")))
	static_gun:SetNetworkValue("Aggro", 1)
	static_gun:SetNetworkValue("Alive", true)
	static_gun:SetStreamDistance(750)
	static_stick:SetStreamDistance(750)
	static_stick:SetNetworkValue("fFaction", tostring(args.ply:GetValue("Faction")))
end

function FactionTurret:Target()
	for id, turret in pairs(guns) do
		if IsValid(turret) then
			if turret:GetValue("Aggro") == 1 then
				local targets = {}
				local players = {}
				for ply in turret:GetStreamedPlayers() do
					players[ply:GetPosition()] = ply:GetId()
				end
				for ply_pos, id in pairs(players) do
					if Vector3.Distance(ply_pos, turret:GetPosition()) < turret_range then
						local ply = Player.GetById(id)
						if IsValid(ply) then
							if ply:GetValue("Faction") ~= turret:GetValue("fFaction") then
								table.insert(targets, id)
							end
						end
					end
				end
				if #targets == 0 then
					turret:SetNetworkValue("iTarget", nil)
				else
					turret:SetNetworkValue("iTarget", table.randomvalue(targets)) -- stores id, not player object
					--Chat:Broadcast("Set Target: " .. tostring(Player.GetById(turret:GetValue("iTarget"))), Color(0, 255, 0))
				end
			end
		end
	end
end

function FactionTurret:AngleAdjust() -- adjust angle
	local current_time = os.clock()
	for id, turret in pairs(guns) do
		if IsValid(turret) and turret:GetValue("iTarget") then
			local target = Player.GetById(turret:GetValue("iTarget"))
			if IsValid(target) then
				local angleyaw = Angle.FromVectors(Vector3.Forward, (target:GetPosition() + Vector3(math.random(-.10, .10), math.random(.20, .60), math.random(-.10, .10))) - turret:GetPosition()).yaw
				local anglepitch = Angle.FromVectors(Vector3.Forward, (target:GetPosition() + Vector3(0, math.random(.20, .60), 0)) - turret:GetPosition()).pitch
				turret:SetAngle(Angle(angleyaw, anglepitch, 0) * Angle(math.pi, 0, 0)) -- aim at target
			end
		end
	end
end

function FactionTurret:DeleteTurret(args, player) -- receives static_id1, static_id2
	local static1 = StaticObject.GetById(args.static_id1)
	local static2 = StaticObject.GetById(args.static_id2)
	if IsValid(static1) and IsValid(static2) then
		local wno_faction = static1:GetValue("fFaction") or static2:GetValue("fFaction")
		local ply_faction = player:GetValue("Faction")
		if ply_faction == wno_faction then
			local command = SQL:Command("DELETE FROM FactionTurrets WHERE position = (?) OR position = (?)")
			command:Bind(1, tostring(static1:GetPosition()))
			command:Bind(2, tostring(static2:GetPosition()))
			command:Execute()
			--
			static1:Remove()
			static2:Remove()
			if guns[args.static_id1] then guns[args.static_id1] = nil end
			if guns[args.static_id2] then guns[args.static_id2] = nil end
			if sticks[args.static_id1] then sticks[args.static_id1] = nil end
			if sticks[args.static_id2] then sticks[args.static_id2] = nil end
			print(tostring(player:GetName()) .. " deleted faction turret for " .. tostring(player:GetValue("Faction")))
		end
	end
end

function FactionTurret:DeleteTurrets(args) -- receives fact
	local command = SQL:Command("DELETE FROM FactionTurrets WHERE faction = (?)")
	command:Bind(1, args.fact)
	command:Execute()
	for id, gun in pairs(guns) do
		if IsValid(gun) then
			if gun:GetValue("fFaction") == args.fact then
				gun:Remove()
			end
		end
	end
	for id, stick in pairs(sticks) do
		if IsValid(stick) then
			if stick:GetValue("fFaction") == args.fact then
				stick:Remove()
			end
		end
	end
end

function FactionTurret:SetTurretAggressive(args, player) -- receives static_id
	local static = StaticObject.GetById(args.static_id)
	if IsValid(static) then
		static:SetNetworkValue("Aggro", 1)
		local command = SQL:Command("UPDATE FactionTurrets SET mode = (?) WHERE position = (?)")
		command:Bind(1, 1)
		command:Bind(2, tostring(static:GetPosition()))
		command:Execute()
		player:SendChatMessage("Turret set to aggressive", Color(0, 255, 0, 200))
	end
end

function FactionTurret:SetTurretPassive(args, player)
	local static = StaticObject.GetById(args.static_id)
	if IsValid(static) then
		static:SetNetworkValue("Aggro", 0)
		static:SetNetworkValue("iTarget", nil)
		local command = SQL:Command("UPDATE FactionTurrets SET mode = (?) WHERE position = (?)")
		command:Bind(1, 0)
		command:Bind(2, tostring(static:GetPosition()))
		command:Execute()
		print(static:GetPosition())
		player:SendChatMessage("Turret set to passive", Color(0, 255, 0, 200))
	end
end

function FactionTurret:ModuleUnload()
	for id, gun in pairs(guns) do
		if IsValid(gun) then gun:Remove() end
	end
	for id, stick in pairs(sticks) do
		if IsValid(stick) then stick:Remove() end
	end
end

ft = FactionTurret()

Events:Subscribe("PlaceFactionTurretServer", ft, ft.PlaceFactionTurret)
Events:Subscribe("FactionDeleteTurrets", ft, ft.DeleteTurrets)
--
Events:Subscribe("SecondTick", ft, ft.Target)
Events:Subscribe("ModuleUnload", ft, ft.ModuleUnload)
Events:Subscribe("PreTick", ft, ft.AngleAdjust) -- change to render?
--
Network:Subscribe("DeleteTurret", ft, ft.DeleteTurret)
Network:Subscribe("SetTurretAggressive", ft, ft.SetTurretAggressive)
Network:Subscribe("SetTurretPassive", ft, ft.SetTurretPassive)