class 'Pet_SQL'
function Pet_SQL:__init()
	SQL:Execute("CREATE TABLE IF NOT EXISTS PetData (steamID INTEGER UNIQUE, Exp INTEGER, Level INTEGER, Name VARCHAR)")
	petData = {} --owner steamid.id, tbl
	Events:Subscribe("ClientModuleLoad", self, self.PlayerJoin)
	Events:Subscribe("Pets_InsertSQL", self, self.FirstTimePetUser)
end
function Pet_SQL:FirstTimePetUser(player)
	local cmd5 = SQL:Query('SELECT steamID FROM PetData WHERE steamID = ?')
	cmd5:Bind(1, player:GetSteamId().id)
	local result5 = cmd5:Execute(), nil
	if result5[1] ~= nil then return end
	local personality = tonumber(player:GetValue("Personality"))
	if not personality then return end
	local name = "Tonic Personification"
	if personality < 0 then
		name = "Animosity Incarnation"
	end
	local cmd = SQL:Command('INSERT INTO PetData (steamID, Exp, Level, Name) VALUES (?, ?, ?, ?)')
	cmd:Bind(1, player:GetSteamId().id)
	cmd:Bind(2, 0)
	cmd:Bind(3, 1)
	cmd:Bind(4, name)
	cmd:Execute()
	petData[tostring(player:GetSteamId().id)] = {
		experience = 0,
		level = 1,
		name = name
		}
end
function Pet_SQL:PlayerJoin(args)
	local steamID = args.player:GetSteamId()
	local steamID_num2 = steamID.id
	local cmd5 = SQL:Query('SELECT steamID FROM PetData WHERE steamID = ?')
	cmd5:Bind(1, steamID_num2)
	local result5 = cmd5:Execute(), nil
	if result5[1] == nil then return end
	local queryData = SQL:Query('SELECT steamID, Exp, Level, Name FROM PetData WHERE steamID = ? LIMIT 1')
	queryData:Bind(1, steamID_num2)
	local result = queryData:Execute()
	local steamID_PD = result[1].steamID
	local Exp_PD = result[1].Exp
	local Level_PD = result[1].Level
	local Name_PD = result[1].Name
	if steamID_PD ~= steamID_num2 then
		Chat:Send(args.player, "Error 309, please contact an admin!", Color(255,0,0))
		return
	end
	args.player:SetNetworkValue("Pet_Enabled", true)
	petData[tostring(args.player:GetSteamId().id)] = {
		experience = Exp_PD,
		level = Level_PD,
		name = Name_PD
		}
	Network:Send(args.player, "LoadPetStatsSQL_Client", petData[tostring(args.player:GetSteamId().id)])
end
function Pet_SQL:UpdateSQL(player)
	local steamID = player:GetSteamId()
	local steamID_num2 = steamID.id
	local cmd2 = SQL:Command('UPDATE PetData SET Exp = ?, Level = ?, Name = ? WHERE steamID = ?')
	cmd2:Bind(4, steamID_num2)
	cmd2:Bind(1, petData[tostring(steamID_num2)].experience)
	cmd2:Bind(2, petData[tostring(steamID_num2)].level)
	cmd2:Bind(3, petData[tostring(steamID_num2)].name)
	cmd2:Execute()
end
function ModuleLoad()
	Pet_SQL = Pet_SQL()
end
Events:Subscribe("ModuleLoad", ModuleLoad)