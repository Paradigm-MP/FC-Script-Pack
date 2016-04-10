class 'PosManager'
-- ALL SQL QUERIES RETURN STRINGS - MUST COERCE WITH TONUMBER()
function PosManager:__init()
	nogo = {} --steamid, player, people who have not spawned yet
	SQL:Execute("CREATE TABLE IF NOT EXISTS players (steamID VARCHAR UNIQUE, posX REAL, posY REAL, posZ REAL, homeX REAL, homeY REAL, homeZ REAL)")
	trade_zones = {}
	trade_zones[1] = Vector3(-9098.20, 585.9965, 4187.05)
	trade_zones[2] = Vector3(-7502.546, 206.96, -4128.777)
	trade_zones[3] = Vector3(1087.676, 202.54, 1125.976)
	trade_zones[4] = Vector3(10813.279, 202.77, -8506.759)
	trade_zones[5] = Vector3(7247.078, 822.935, -1166.325)
	trade_zones[6] = Vector3(-4927.674, 214.876, 3050.660)
	-- SQL table with steamID column
end

function PosManager:PlayerJoin(args)
	nogo[args.player:GetSteamId()] = args.player
	local steamid = tostring(args.player:GetSteamId())
	--
	local qry = SQL:Query("SELECT steamID FROM players WHERE steamID = (?) LIMIT 1") -- return steamID and pos'es from 1 row with this steamID
	qry:Bind(1, steamid)
	local result = qry:Execute()
	if #result > 0 then
		-- Chat:Broadcast("Already in DB", Color(255, 0, 0))
		print("Already in DB")
		local qry = SQL:Query("SELECT posX, posY, posZ, homeX, homeY, homeZ FROM players WHERE steamID = (?) LIMIT 1")
		qry:Bind(1, steamid)
		local postable = qry:Execute()
		local plypos = Vector3(tonumber(postable[1].posX), tonumber(postable[1].posY), tonumber(postable[1].posZ)) -- fired too soon
		--
		DelayedSpawn(plypos, args.player:GetId(), steamid, 5) -- task instance class
		--
		args.player:SetPosition(plypos)
		if tonumber(postable[1].homeX) ~= 0
		and tonumber(postable[1].homeY) ~= 0
		and tonumber(postable[1].homeZ) ~= 0 then
			local vector = Vector3(tonumber(postable[1].homeX),tonumber(postable[1].homeY),tonumber(postable[1].homeZ))
			args.player:SetNetworkValue("HomePosition", vector)
		end
	else -- if first join
		local command = SQL:Command("INSERT INTO players (steamID, posX, posY, posZ, homeX, homeY, homeZ) VALUES (?, ?, ?, ?, ?, ?, ?)")
		local position = noobislandpos
		command:Bind(1, steamid)
		command:Bind(2, position.x)
		command:Bind(3, position.y)
		command:Bind(4, position.z)
		command:Bind(5, 0)
		command:Bind(6, 0)
		command:Bind(7, 0)
		command:Execute() -- execute the SQL statement after binding parameters
		DelayedSpawn(noobislandpos, args.player:GetId(), steamid, 5)
		args.player:SetAngle(noobislandangle)
	end
end

function PosManager:PlayerLeave(args)
	if not nogo[args.player:GetSteamId()] then
		local steamid = tostring(args.player:GetSteamId())
		if args.player:GetValue("Dead") then
			if args.player:GetValue("HomePosition") then
				local update = SQL:Command("UPDATE players SET posX = ?, posY = ?, posZ = ? WHERE steamID = (?)")
				update:Bind(1, args.player:GetValue("HomePosition").x)
				update:Bind(2, args.player:GetValue("HomePosition").y)
				update:Bind(3, args.player:GetValue("HomePosition").z)
				update:Bind(4, tostring(args.player:GetSteamId()))
				update:Execute()
			else
				local pos = table.randomvalue(trade_zones)
				local update = SQL:Command("UPDATE players SET posX = ?, posY = ?, posZ = ? WHERE steamID = (?)")
				update:Bind(1, pos.x)
				update:Bind(2, pos.y)
				update:Bind(3, pos.z)
				update:Bind(4, tostring(args.player:GetSteamId()))
				update:Execute()
			end
		else
			local position = args.player:GetPosition() -- this returns a Vector3
			local update = SQL:Command("UPDATE players SET posX = ?, posY = ?, posZ = ? WHERE steamID = (?)")
			update:Bind(1, position.x)
			update:Bind(2, position.y)
			update:Bind(3, position.z)
			update:Bind(4, steamid)
			update:Execute()
		end
	end
end
function PosManager:UpdateHomePosition(args)
	local steamid = tostring(args.player:GetSteamId())
	local position = args.pos
	local update = SQL:Command("UPDATE players SET homeX = ?, homeY = ?, homeZ = ? WHERE steamID = (?)")
	update:Bind(1, position.x)
	update:Bind(2, position.y)
	update:Bind(3, position.z)
	update:Bind(4, steamid)
	update:Execute()
	args.player:SetNetworkValue("HomePosition", position)
	Chat:Send(args.player, "Home successfully set.", Color.Green)
end
function PosManager:RemoveHomePosition(args)
	local steamid = tostring(args.steamID)
	local position = args.pos
	local qry = SQL:Query("SELECT homeX, homeY, homeZ FROM players WHERE steamID = (?) LIMIT 1")
	qry:Bind(1, steamid)
	local postable = qry:Execute()
	local home = Vector3(tonumber(postable[1].homeX), tonumber(postable[1].homeY), tonumber(postable[1].homeZ))
	if Vector3.Distance(home, args.pos) < 1 then
		local update = SQL:Command("UPDATE players SET homeX = ?, homeY = ?, homeZ = ? WHERE steamID = (?)")
		update:Bind(1, 0)
		update:Bind(2, 0)
		update:Bind(3, 0)
		update:Bind(4, steamid)
		update:Execute()
		for p in Server:GetPlayers() do
			if tostring(p:GetSteamId()) == steamid then
				p:SetNetworkValue("HomePosition", nil)
			end
		end
	end
end
function PosManager:ChatHandle(args)

	if args.text == "/x" then
		local pos = args.player:GetPosition()
		pos.x = pos.x + 3
		args.player:SetPosition(pos)
	elseif args.text == "/y" then
		local pos = args.player:GetPosition()
		pos.y = pos.y + 3
		args.player:SetPosition(pos)
	elseif args.text == "/z" then
		local pos = args.player:GetPosition()
		pos.z = pos.z + 3
		args.player:SetPosition(pos)
	end
	
end
function PosManager:SavePositions()
	for p in Server:GetPlayers() do
		self:PlayerLeave({player = p})
	end
end
function PosManager:LeaveIsland(p)
	p:SetPosition(table.randomvalue(trade_zones))
	p:SetValue("LeftNoobIsland", nil)
end
function PosManager:RepositionPlayer(args, player)
	player:SetPosition(Vector3(-12957.17, 361, -13220.42)) -- spawn
end
noobislandpos = Vector3(-12489.040039, 216.655579, 15064.201172)
noobislandangle = Angle(1.768482, 0.000000, 0.000000)
function PosManager:PlayerSpawn(args)
	--if args.player:GetValue("LeftNoobIsland") then return end
	if args.player:GetValue("HomePosition") and args.player:GetValue("Dead") then
		args.player:SetPosition(args.player:GetValue("HomePosition"))
		args.player:SetValue("Dead", nil)
	elseif args.player:GetValue("Dead") and not args.player:GetValue("Noob") then
		args.player:SetPosition(table.randomvalue(trade_zones))
		args.player:SetValue("Dead", nil)
	elseif args.player:GetValue("Dead") and args.player:GetValue("Noob") then
		args.player:SetPosition(noobislandpos)
		args.player:SetAngle(noobislandangle)
		args.player:SetValue("Dead", nil)
	else
		args.player:SetPosition(table.randomvalue(trade_zones))
	end
	args.player:SetValue("Dead", nil)
	return false
end
function PosManager:PlayerDeath(args)
	args.player:SetValue("Dead", 1)
end
sqlite = PosManager()

Events:Subscribe("LC_DestroyBedSpawn", sqlite, sqlite.RemoveHomePosition)
Events:Subscribe("NI_LeaveNoobIsland", sqlite, sqlite.LeaveIsland)
Events:Subscribe("LC_SetSpawnPosition", sqlite, sqlite.UpdateHomePosition)
Events:Subscribe("PlayerSpawn", sqlite, sqlite.PlayerSpawn)
Events:Subscribe("PlayerDeath", sqlite, sqlite.PlayerDeath)
Events:Subscribe("TimeChange", sqlite, sqlite.SavePositions)
Events:Subscribe("PlayerJoin", sqlite, sqlite.PlayerJoin)
Events:Subscribe("PlayerQuit", sqlite, sqlite.PlayerLeave)
Events:Subscribe("PlayerChat", sqlite, sqlite.ChatHandle)
Network:Subscribe("Reposition", sqlite, sqlite.RepositionPlayer)