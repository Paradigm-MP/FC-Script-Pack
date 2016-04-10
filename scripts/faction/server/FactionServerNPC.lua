class 'FactionNPC'

function FactionNPC:__init()
	SQL:Execute("CREATE TABLE IF NOT EXISTS FactionNPCs (faction VARCHAR, position VARCHAR, mode INTEGER, name VARCHAR)")
	--
	npc_names = {"jaxm", "Trix", "Philpax", "SinisterRectus", "Dev_34", "Lord_Farquaad", "{c4} Cobra", "TheStuffJunky", "Ice Cream Man", "TheeDoctor", "Bliss", "__init__"}
	actor_streaming_distance = 300
	actor_aggro_distance = 250
	actor_respawn_time = 30 -- in seconds
	--
	local qry = SQL:Query("SELECT faction, position, mode FROM FactionNPCs")
	local spawn_timer = Timer()
	local SQL_npcs = qry:Execute()
	fnpcs = {}
	for index, itable in pairs(SQL_npcs) do
		local pos = string.split(tostring(itable.position), ",")
		local iWNO = WorldNetworkObject.Create({position = Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3])), angle = Angle(0, 0, 0)})
		iWNO:SetNetworkValue("fFaction", tostring(itable.faction))
		iWNO:SetNetworkValue("M_ID", 42)
		iWNO:SetNetworkValue("Aggro", tonumber(itable.mode))
		iWNO:SetNetworkValue("Alive", true)
		iWNO:SetNetworkValue("Name", table.randomvalue(npc_names))
		iWNO:SetStreamDistance(actor_streaming_distance)
		fnpcs[iWNO:GetId()] = iWNO
	end
	local fnpc_count = table.count(fnpcs)
	print("Took " .. tostring(spawn_timer:GetSeconds()) .. " to initialize " .. tostring(fnpc_count) .. " faction NPCs")
    --
	actorspawn = {}
	actorspawn[1] = Vector3(-6304.31, 210, -3204.6)
	actorspawn[2] = Vector3(-6300.7, 210, -3205.63)
	actorspawn[3] = Vector3(-6305.37, 210, -3201.28)
	WNOs = {}
	ReviveQueue = {}
	--for index, pos in pairs(actorspawn) do
		--local WNO = WorldNetworkObject.Create(pos)
		--WNO:SetNetworkValue("M_ID", 42) -- model id
		--WNO:SetNetworkValue("Aggro", true) -- aggressive boolean
		--WNO:SetNetworkValue("Alive", true)
		--WNO:SetNetworkValue("Name", table.randomvalue(npc_names))
		--WNO:SetStreamDistance(actor_streaming_distance)
		--WNOs[WNO:GetId()] = WNO
	--end
	------------------
	------------------
	-- Remove start, spaces
	--local file = io.open( "snipers.txt", "r" )
	--if file ~= nil then
		---for line in file:lines() do
			--if line ~= "" then
				--line = line:gsub( "S", "" )
				--line = line:gsub( " ", "" )

				-- Split into tokens
				--local tokens        = line:split( "," )
				-- Create table containing appropriate strings
				--local pos_str       = { tokens[1], tokens[2], tokens[3], tokens[4] }
				-- Create vector
				--vector        = Vector3(   tonumber( pos_str[1] ), 
												--tonumber( pos_str[2] ),
												--tonumber( pos_str[3] ) )
				--local obj = WorldNetworkObject.Create(vector)
				--obj:SetNetworkValue("M_ID", 42)
				--obj:SetNetworkValue("Aggro", false)
				--obj:SetNetworkValue("Alive", true)
				--obj:SetNetworkValue("Name", table.randomvalue(npc_names))
				--WNOs[obj:GetId()] = obj
			--end
	--	end
	--end
end

function FactionNPC:Targetting()
	local players = {}
	for ply in Server:GetPlayers() do
		players[ply:GetPosition()] = ply:GetId()
	end
	--
	for id, WNO in pairs(fnpcs) do
		if IsValid(WNO) then
			if WNO:GetValue("Aggro") == 1 then
				local wno_pos = WNO:GetPosition()
				local targets = {}
				for ply_pos, id in pairs(players) do
					if Vector3.Distance(ply_pos, wno_pos) < actor_aggro_distance then
						local ply = Player.GetById(id)
						if ply:GetValue("Faction") ~= WNO:GetValue("fFaction") then
							table.insert(targets, id)
						end
					end
				end
				if #targets == 0 then
					WNO:SetNetworkValue("Target", nil)
				else
					WNO:SetNetworkValue("Target", table.randomvalue(targets)) -- target is set as a player id
					--Chat:Broadcast("Set Target: " .. tostring(Player.GetById(WNO:GetValue("Target"))), Color(0, 255, 0))
				end
			end
		end
	end
end

function FactionNPC:KillActor(args) -- receives id
	local WNO = WorldNetworkObject.GetById(args.id)
	if WNO then
		WNO:SetNetworkValue("Alive", false)
		ReviveQueue[args.id] = os.clock()
	end
end

function FactionNPC:ReviveActor()
	local new_time = os.clock()
	for wno_id, old_time in pairs(ReviveQueue) do
		if new_time - old_time > actor_respawn_time then
			local WNO = WorldNetworkObject.GetById(wno_id)
			if IsValid(WNO) then
				WNO:SetNetworkValue("Alive", true)
			end
			ReviveQueue[wno_id] = nil
		end
	end
end

function FactionNPC:AddActor(args, player) -- receives pos
	Chat:Broadcast("Entered", Color(255, 0, 0))
	local str = "\nS "..tostring(args.pos)
	local file = io.open("snipers.txt", "a")
	file:write(str)
	file:close()
	Chat:Broadcast("Added Actor", Color(255, 0, 0))
end

function FactionNPC:PlaceFactionGuard(args) -- receives pos and ply
	if not IsValid(args.ply) then return end
	local command = SQL:Command("INSERT INTO FactionNPCs (faction, position, mode, name) VALUES (?, ?, ?, ?)")
	command:Bind(1, args.ply:GetValue("Faction"))
	command:Bind(2, tostring(args.pos))
	command:Bind(3, 1) -- aggresive
	command:Bind(4, "John")
	command:Execute()
	--
	local iWNO = WorldNetworkObject.Create({position = args.pos, angle = Angle(0, 0, 0)})
	iWNO:SetNetworkValue("fFaction", tostring(args.ply:GetValue("Faction")))
	iWNO:SetNetworkValue("M_ID", 42)
	iWNO:SetNetworkValue("Aggro", 1)
	iWNO:SetNetworkValue("Alive", true)
	iWNO:SetNetworkValue("Name", "John")
	iWNO:SetStreamDistance(actor_streaming_distance)
	fnpcs[iWNO:GetId()] = iWNO
end

function FactionNPC:DeleteGuard(args, player) -- receives wno_id
	local iWNO = WorldNetworkObject.GetById(args.wno_id)
	if IsValid(iWNO) then
		local wno_faction = iWNO:GetValue("fFaction")
		local ply_faction = player:GetValue("Faction")
		if ply_faction == wno_faction then
			local command = SQL:Command("DELETE FROM FactionNPCs WHERE position = (?)")
			command:Bind(1, tostring(iWNO:GetPosition()))
			command:Execute()
			--
			local id = iWNO:GetId()
			iWNO:Remove()
			fnpcs[id] = nil
			print(tostring(player:GetName()) .. " deleted faction guard for " .. tostring(player:GetValue("Faction")))
		end
	end
end

function FactionNPC:FactionDeleteNPCs(args) -- receives fact
	local command = SQL:Command("DELETE FROM FactionNPCs WHERE faction = (?)")
	command:Bind(1, args.fact)
	command:Execute()
	for id, iWNO in pairs(fnpcs) do
		if IsValid(iWNO) then
			if iWNO:GetValue("fFaction") == args.fact then
				iWNO:Remove()
			end
		end
	end
end

function FactionNPC:SetGuardAggressive(args, player) -- receives wno_id
	local iWNO = WorldNetworkObject.GetById(args.wno_id)
	if IsValid(iWNO) then
		iWNO:SetNetworkValue("Aggro", 1)
		local command = SQL:Command("UPDATE FactionNPCs SET mode = (?) WHERE position = (?)")
		command:Bind(1, 1)
		command:Bind(2, tostring(iWNO:GetPosition()))
		command:Execute()
		player:SendChatMessage("Guard set to aggressive", Color(0, 255, 0, 200))
	end
end

function FactionNPC:SetGuardPassive(args, player) -- receives wno_id
	local iWNO = WorldNetworkObject.GetById(args.wno_id)
	if IsValid(iWNO) then
		iWNO:SetNetworkValue("Aggro", 0)
		local command = SQL:Command("UPDATE FactionNPCs SET mode = (?) WHERE position = (?)")
		command:Bind(1, 0)
		command:Bind(2, tostring(iWNO:GetPosition()))
		command:Execute()
		player:SendChatMessage("Guard set to passive", Color(0, 255, 0, 200))
	end
end

function FactionNPC:ModuleUnload()
	for wno_id, wno in pairs(WNOs) do
		if IsValid(wno) then wno:Remove() end
	end
	for wno_id, wno in pairs(fnpcs) do
		if IsValid(wno) then wno:Remove() end
	end
end

fnpc = FactionNPC()

-------- START CONVENIENCE FUNCTIONS ----------

-------- END CONVENIENCE FUNCTIONS ------------

Events:Subscribe("SecondTick", fnpc, fnpc.Targetting)
Events:Subscribe("SecondTick", fnpc, fnpc.ReviveActor)
Events:Subscribe("ModuleUnload", fnpc, fnpc.ModuleUnload)
Events:Subscribe("PlaceFactionGuardServer", fnpc, fnpc.PlaceFactionGuard)
Events:Subscribe("FactionDeleteNPCs", fnpc, fnpc.FactionDeleteNPCs)
--
Network:Subscribe("KillActor", fnpc, fnpc.KillActor)
Network:Subscribe("AddActor", fnpc, fnpc.AddActor)
Network:Subscribe("DeleteGuard", fnpc, fnpc.DeleteGuard)
Network:Subscribe("SetGuardAggressive", fnpc, fnpc.SetGuardAggressive)
Network:Subscribe("SetGuardPassive", fnpc, fnpc.SetGuardPassive)