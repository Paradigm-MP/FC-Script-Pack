class 'Mines'

function Mines:__init()
	mines = {}
	SQL:Execute("CREATE TABLE IF NOT EXISTS mines (position VARCHAR, steamid VARCHAR, time_placed DATETIME DEFAULT CURRENT_TIMESTAMP)")
	local mine_spawn_timer = Timer()
	local qry = SQL:Query("SELECT position, steamid FROM mines")
	local mines_sql = qry:Execute()
	for index, itable in pairs(mines_sql) do
		local pos = string.split(tostring(itable.position), ",")
		local iWNO = WorldNetworkObject.Create(Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3])), {ItemUse_Mine = tostring(itable.steamid)})
		iWNO:SetAngle(Angle(0, 0, 0))
		iWNO:SetStreamDistance(250)
		mines[iWNO:GetId()] = iWNO
	end
	local mine_count = table.count(mines_sql)
	print("Took " .. tostring(mine_spawn_timer:GetSeconds()) .. " seconds to initialize " .. tostring(mine_count) .. " mines from database")
	mine_spawn_timer = nil
end

function Mines:PlaceMine(args, player)
	local steamid = tostring(player:GetSteamId().id)
	local iWNO = WorldNetworkObject.Create(args.pos, {ItemUse_Mine = steamid})
	iWNO:SetAngle(args.ang)
	mines[iWNO:GetId()] = iWNO
	local qry = SQL:Query("INSERT INTO mines (position, steamid) VALUES (?, ?)")
	qry:Bind(1, tostring(args.pos))
	qry:Bind(2, steamid)
	qry:Execute()
end

function Mines:ExplodeMine(args, player) -- receives wno_id
	local pos
	if player:GetValue("Invincible") or player:GetStreamDistance() == 0 then return end
	if mines[args.wno_id] then
		if IsValid(mines[args.wno_id]) then
			pos = mines[args.wno_id]:GetPosition()
			local cmd = SQL:Command("DELETE FROM mines WHERE position = (?)")
			cmd:Bind(1, tostring(pos))
			cmd:Execute()
			mines[args.wno_id]:Remove()
		end
		mines[args.wno_id] = nil
		for p in Server:GetPlayers() do
			if p ~= player then
				if Vector3.Distance(pos, p:GetPosition()) < 500 then
					Network:Send(p, "ServerExplodeMine", {position = pos, id = args.wno_id})
				end
			end
		end
	end
end

function Mines:DamagePly(args, player)
	player:Damage(args.dmg, DamageEntity.Explosion)
end

function Mines:Unload()
	for id, iWNO in pairs(mines) do
		if IsValid(iWNO) then
			iWNO:Remove()
		end
		mines[id] = nil
	end
end

mine = Mines()

Network:Subscribe("ClientPlaceMine", mine, mine.PlaceMine)
Network:Subscribe("MineDamagePly", mine, mine.DamagePly)
Network:Subscribe("ExplodeMine", mine, mine.ExplodeMine)
--
Events:Subscribe("ModuleUnload", mine, mine.Unload)
