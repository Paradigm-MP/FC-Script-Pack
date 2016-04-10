class 'HungerThirst'
function HungerThirst:__init()
	SQL:Execute("CREATE TABLE IF NOT EXISTS HungerThirst (steamID INTEGER UNIQUE, hunger FLOAT, thirst FLOAT)")
	thirstyPlayers = {}
	hungryPlayers = {}
	Events:Subscribe("ClientModuleLoad", self, self.Join)
	Events:Subscribe("PlayerQuit", self, self.Quit)
	Events:Subscribe("ModuleUnload", self, self.Unload)
	Events:Subscribe("SecondTick", self, self.HurtPlayers)
	Events:Subscribe("PlayerDeath", self, self.Death)
	Network:Subscribe("HT_Sync", self, self.Sync)
end
function HungerThirst:Death(args)
	if thirstyPlayers[args.player:GetId()] then
		thirstyPlayers[args.player:GetId()] = nil
	end
	if hungryPlayers[args.player:GetId()] then
		hungryPlayers[args.player:GetId()] = nil
	end
end
function HungerThirst:HurtPlayers()
	for id, tbl in pairs(thirstyPlayers) do
		if IsValid(tbl.p) then
			tbl.p:Damage(tbl.amt)
			thirstyPlayers[id].amt = tbl.amt * 1.2
		else
			thirstyPlayers[id] = nil
		end
	end
	for id, tbl in pairs(hungryPlayers) do
		if IsValid(tbl.p) then
			tbl.p:Damage(tbl.amt)
			hungryPlayers[id].amt = tbl.amt * 1.2
		else
			hungryPlayers[id] = nil
		end
	end
end
function HungerThirst:Join(args)
	local cmd = SQL:Query('SELECT steamID FROM HungerThirst WHERE steamID = ?')
	cmd:Bind(1, args.player:GetSteamId().id)
	local result = cmd:Execute(), nil
	if result[1] == nil then
		--COST VALUES HERE
		local cmd2 = SQL:Command('INSERT INTO HungerThirst (steamID, hunger, thirst) VALUES (?, ?, ?)')
		cmd2:Bind(1, args.player:GetSteamId().id)
		cmd2:Bind(2, 100)
		cmd2:Bind(3, 100)
		cmd2:Execute()
	end
	local query = SQL:Query('SELECT steamID, hunger, thirst FROM HungerThirst WHERE steamID = ? LIMIT 1')
	query:Bind(1, args.player:GetSteamId().id)
	local result2 = query:Execute()
	local args2 = {}
	args2.hunger = result2[1].hunger
	args2.thirst = result2[1].thirst
	Network:Send(args.player, "HT_Join", args2)
	args.player:SetNetworkValue("Hunger", result2[1].hunger)
	args.player:SetNetworkValue("Thirst", result2[1].thirst)
	CheckHT(args.player)
end
function HungerThirst:Quit(args)
	local cmd = SQL:Command('UPDATE HungerThirst set hunger=?, thirst=? WHERE steamId = ?')
	local thirst = tonumber(args.player:GetValue("Thirst")) if not thirst then thirst = 25 end
	local hunger = tonumber(args.player:GetValue("Hunger")) if not hunger then hunger = 25 end
	cmd:Bind(1, hunger)
	cmd:Bind(2, thirst)
	cmd:Bind(3, args.player:GetSteamId().id)
	cmd:Execute()
	CheckRemoveFromTableH(player)
	CheckRemoveFromTableT(player)
end
function HungerThirst:Unload()
	for p in Server:GetPlayers() do
		local cmd = SQL:Command('UPDATE HungerThirst set hunger=?, thirst=? WHERE steamId = ?')
		local thirst = tonumber(p:GetValue("Thirst")) if not thirst then thirst = 0 end
		local hunger = tonumber(p:GetValue("Hunger")) if not hunger then hunger = 0 end
		cmd:Bind(1, hunger)
		cmd:Bind(2, thirst)
		cmd:Bind(3, tonumber(p:GetSteamId().id))
		cmd:Execute()
	end
end
function CheckHT(player)
	local hunger = player:GetValue("Hunger")
	local thirst = player:GetValue("Thirst")
	--print(string.format("%.0f", hunger))
	--print(string.format("%.0f", thirst))
	if tonumber(string.format("%.0f", hunger)) == 0 then
		hungryPlayers[player:GetId()] = {p = player, amt = 0.002}
	else
		CheckRemoveFromTableH(player)
	end
	if tonumber(string.format("%.0f", thirst)) == 0 then
		thirstyPlayers[player:GetId()] = {p = player, amt = 0.01}
		--print("thirst")
	else
		CheckRemoveFromTableT(player)
	end
end
function CheckRemoveFromTableT(player)
	for id, tbl in pairs(thirstyPlayers) do
		if player == tbl.p then
			thirstyPlayers[id] = nil
		end
	end
end
function CheckRemoveFromTableH(player)
	for id, tbl in pairs(hungryPlayers) do
		if player == tbl.p then
			hungryPlayers[id] = nil
		end
	end
end
function HungerThirst:Sync(args, sender)
	sender:SetValue("Hunger", args.hunger)
	sender:SetValue("Thirst", args.thirst)
	if args.hunger == 0 then
		hungryPlayers[sender:GetId()] = {p = sender, amt = 0.002}
	end
	if args.thirst == 0 then
		thirstyPlayers[sender:GetId()] = {p = sender, amt = 0.01}
	end
	CheckHT(sender)
end
HungerThirst = HungerThirst()