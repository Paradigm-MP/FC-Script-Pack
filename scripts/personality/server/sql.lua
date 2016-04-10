class 'Personality_Sql'
function Personality_Sql:__init()
	SQL:Execute("CREATE TABLE IF NOT EXISTS personality (steamID INTEGER UNIQUE, Personality INTEGER)")
	Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
	Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
end
function Personality_Sql:PlayerJoin(args)
	local steamID = args.player:GetSteamId()
	local steamID_num2 = steamID.id
	local cmd5 = SQL:Query('SELECT steamID FROM personality WHERE steamID = ?')
	cmd5:Bind(1, steamID_num2)
	local result5 = cmd5:Execute(), nil
	if result5[1] == nil then
		local cmd2 = SQL:Command('INSERT INTO personality (steamID, Personality) VALUES (?, ?)')
		cmd2:Bind(1, steamID_num2)
		cmd2:Bind(2, -1)
		cmd2:Execute()
	end
	local queryData = SQL:Query('SELECT steamID, Personality FROM personality WHERE steamID = ? LIMIT 1')
	queryData:Bind(1, steamID_num2)
	local result = queryData:Execute()
	local steamID_PD = result[1].steamID
	local Personality_PD = result[1].Personality
	if steamID_PD ~= steamID_num2 then
		Chat:Send(args.player, "Error 308, please contact an admin!", Color(255,0,0))
		return
	end
	args.player:SetNetworkValue("Personality", Personality_PD)
	Network:Send(args.player, "Personality_V", Personality_PD)
	--print("Personality loaded for "..tostring(args.player))
end
function Personality_Sql:PlayerQuit(args)
	if args.player:GetValue("Personality") then
		local add = 0
		if args.player:GetValue("PersonalityChat") then
			add = args.player:GetValue("PersonalityChat")
		else
			add = 1
		end
		local newPersonality = (args.player:GetValue("Personality") + add)
		if newPersonality == 0 then newPersonality = -1 end
		local steamID = args.player:GetSteamId()
		local steamID_num2 = steamID.id
		local cmd2 = SQL:Command('INSERT OR REPLACE INTO personality (steamID, Personality) VALUES (?, ?)')
		cmd2:Bind(1, steamID_num2)
		cmd2:Bind(2, newPersonality)
		cmd2:Execute()
		--print("Personality saved for "..tostring(args.player))
	end
end
function ModuleLoad()
	Personality_Sql = Personality_Sql()
end
Events:Subscribe("ModuleLoad", ModuleLoad)