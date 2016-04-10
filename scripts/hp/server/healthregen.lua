class 'Hp'
function Hp:__init()
	SQL:Execute("CREATE TABLE IF NOT EXISTS hp (steamID INTEGER UNIQUE, health FLOAT)")
	players = {}
	timers = {}
	dead = {}
	t = {}
	Events:Subscribe("PlayerJoin", self, self.Join)
	Events:Subscribe("PlayerQuit", self, self.Quit)
	Events:Subscribe("ModuleUnload", self, self.Unload)
	Events:Subscribe("PlayerChat", self, self.Chat)
	Events:Subscribe("ModuleLoad", self, self.Load)
	Events:Subscribe("SecondTick", self, self.Regen)
	--Events:Subscribe("PreTick", self, self.StreamDist)
	Events:Subscribe("SecondTick", self, self.CheckForDamage)
	--Events:Subscribe("PlayerDeath", self, self.Death)
end
function Hp:Chat(args)
	if args.text == "/suicide" then
		args.player:SetHealth(0)
	end
end
function Hp:Death(args)
	dead[args.player:GetId()] = args.player
	t[args.player:GetId()] = os.time()
end
function Hp:StreamDist()
	for id, player in pairs(dead) do
		if os.time() - t[id] > 7 and os.time() - t[id] < 15 then
			if not IsValid(player) then return end
			player:SetStreamDistance(0)
		elseif os.time() - t[id] > 15 then
			player:SetStreamDistance(500)
			dead[id] = nil
			t[id] = nil
		end
	end
end
function Hp:CheckForDamage()
	for id, player in pairs(players) do
		if not IsValid(player) then return end
		if not player:GetValue("HealthRegen") then return end
		if player:GetHealth() >= 1 then return end
		if player:GetHealth() <= 0 then return end
		if tonumber(string.format("%.4f", player:GetHealth())) < tonumber(string.format("%.4f", player:GetValue("HP"))) then
			timers[id]:Restart()
			--Chat:Send(player, "restart", Color.Red)
			player:SetValue("HP", player:GetHealth())
		end
	end
end
function Hp:Load()
	for p in Server:GetPlayers() do
		players[p:GetId()] = p
		timers[p:GetId()] = Timer()
		p:SetValue("HP", p:GetHealth())
	end
end
function Hp:Regen()
	for id, player in pairs(players) do
		if not IsValid(player) then return end
		if not player:GetValue("HealthRegen") then return end
		if player:GetHealth() >= 1 then return end
		if player:GetHealth() <= 0 then return end
		local regen = tonumber(player:GetValue("HealthRegen")) / 2500
		if timers[id]:GetSeconds() >= 15 then
			--Chat:Send(player, "regen", Color.Green)
			if player:GetHealth() > 0 then
				player:Damage(-regen)
			end
			player:SetValue("HP", player:GetHealth())
		end
	end
end
function Hp:Join(args)
	local cmd = SQL:Query('SELECT steamID FROM hp WHERE steamID = ?')
	cmd:Bind(1, args.player:GetSteamId().id)
	local result = cmd:Execute(), nil
	if result[1] == nil then
		local cmd2 = SQL:Command('INSERT INTO hp (steamID, health) VALUES (?, ?)')
		cmd2:Bind(1, args.player:GetSteamId().id)
		cmd2:Bind(2, 1)
		cmd2:Execute()
	end
	local query = SQL:Query('SELECT steamID, health FROM hp WHERE steamID = ? LIMIT 1')
	query:Bind(1, args.player:GetSteamId().id)
	local result2 = query:Execute()
	local hp = tonumber(result2[1].health)
	args.player:SetHealth(hp)
	--print(result2[1].health)
	players[args.player:GetId()] = args.player
	timers[args.player:GetId()] = Timer()
	args.player:SetValue("HP", hp)
end
function Hp:Quit(args)
	local cmd = SQL:Command('UPDATE hp set health=? WHERE steamId = ?')
	--print(args.player:GetHealth())
	cmd:Bind(1, args.player:GetHealth())
	cmd:Bind(2, args.player:GetSteamId().id)
	cmd:Execute()
	players[args.player:GetId()] = nil
	timers[args.player:GetId()] = nil
end
function Hp:Unload()
	for p in Server:GetPlayers() do
		p:SetStreamDistance(500)
		local cmd = SQL:Command('UPDATE hp set health=? WHERE steamId = ?')
		cmd:Bind(1, p:GetHealth())
		cmd:Bind(2, p:GetSteamId().id)
		cmd:Execute()
	end
end
Hp = Hp()