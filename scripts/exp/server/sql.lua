class 'Exp_Sql'
function Exp_Sql:__init()
	SQL:Execute("CREATE TABLE IF NOT EXISTS playerExpLvl (steamID INTEGER UNIQUE, level INTEGER, experience INTEGER)")
	Events:Subscribe("PlayerJoin", self,  self.PlayerJoin)
	Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
end
function Exp_Sql:PlayerJoin(args)
	local steamID = args.player:GetSteamId()
	local steamID_num2 = steamID.id
	local cmd5 = SQL:Query('SELECT steamID FROM  playerExpLvl WHERE steamID = ?')
	cmd5:Bind(1, steamID_num2)
	local result5 = cmd5:Execute(), nil
	
	if result5[1] == nil then
		local cmd2 = SQL:Command('INSERT INTO playerExpLvl (steamID, level, experience) VALUES (?, ?, ?)')
		cmd2:Bind(1, steamID_num2)
		cmd2:Bind(2, 1)
		cmd2:Bind(3, 0)
		cmd2:Execute()
		--print(tostring(args.player).." is a new player, loaded default values in SQL")
	end
	local queryData = SQL:Query('SELECT steamID, level, experience FROM playerExpLvl WHERE steamID = ? LIMIT 1')
	queryData:Bind(1, steamID_num2)
	local result = queryData:Execute()
	local steamID_PD = result[1].steamID
	local level_PD = result[1].level
	local experience_PD = result[1].experience
	if steamID_PD ~= steamID_num2 then
		Chat:Send(args.player, "Error 302, please contact an admin!", Color(255,0,0))
		return
	end
	local maxExp = CalcMaxExp:Calculate(level_PD)
	args.player:SetNetworkValue("Level", level_PD)
	args.player:SetNetworkValue("Experience", experience_PD)
	args.player:SetNetworkValue("ExperienceMax", maxExp)
	args.player:SetValue("Exp_SQL_Loaded", 1)
	--print("Loaded "..tostring(experience_PD).." experience for "..tostring(args.player).." [Level "..tostring(level_PD).."]")
end
function Exp_Sql:PlayerQuit(args)
	local steamID = args.player:GetSteamId()
	local steamID_num2 = steamID.id
	local cmd2 = SQL:Command('INSERT OR REPLACE INTO playerExpLvl (steamID, level, experience) VALUES (?, ?, ?)')
	cmd2:Bind(1, steamID_num2)
	cmd2:Bind(2, args.player:GetValue("Level"))
	cmd2:Bind(3, args.player:GetValue("Experience"))
	cmd2:Execute()

	--print("Recorded "..tostring(args.player:GetValue("Experience")).." exp and level data to SQL for "..tostring(args.player).." [Level "..tostring(args.player:GetValue("Level")).."] on leave")
end
function ModuleLoad()
	Exp_Sql = Exp_Sql()
end
Events:Subscribe("ModuleLoad", ModuleLoad)