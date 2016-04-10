class 'Ip_Sql'
function Ip_Sql:__init()
	SQL:Execute("CREATE TABLE IF NOT EXISTS playerIp (steamID INTEGER UNIQUE, IP_1 INTEGER, IP_2 INTEGER, IP_3 INTEGER, IP_4 INTEGER, IP_5 INTEGER, IP_6 INTEGER, IP_7 INTEGER, IP_8 INTEGER, IP_9 INTEGER, IP_10 INTEGER, IP_11 INTEGER, IP_12 INTEGER, IP_13 INTEGER, IP_14 INTEGER, IP_15 INTEGER, IP_16 INTEGER, IP_17 INTEGER, IP_18 INTEGER, IP_19 INTEGER, IP_20 INTEGER, IP INTEGER, IP_Resets INTEGER)")
	SQL:Execute("CREATE TABLE IF NOT EXISTS playerSkills (steamID INTEGER UNIQUE, Melee_Dmg_1 INTEGER, Melee_Dmg_2 INTEGER, Melee_Sta_1 INTEGER, Melee_Sta_2 INTEGER, StaminaRegen INTEGER, MaxHealth INTEGER, CraftingLevel INTEGER, HealthRegen INTEGER, SprintEnergy INTEGER, StuntEnergy INTEGER, Concealment INTEGER, Perception INTEGER, StaminaSwim INTEGER, StaminaMax INTEGER, Placeholder4 INTEGER, Placeholder5 INTEGER, Placeholder6 INTEGER, Placeholder7 INTEGER, Placeholder8 INTEGER, Placeholder9 INTEGER)")
	Events:Subscribe("ClientModuleLoad", self,  self.PlayerJoin)
	Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
	Events:Subscribe("IP_Sql_Update", self, self.PlayerSaveIP)
	Events:Subscribe("IP_Sql_Reset", self, self.Reset)
	--Events:Subscribe("SecondTick", self, self.SendPlayersData)
	--ps = {}
end
function Ip_Sql:PlayerJoin(args)
	local steamID = args.player:GetSteamId()
	local steamID_num2 = steamID.id
	local cmd5 = SQL:Query('SELECT steamID FROM playerIp WHERE steamID = ?')
	cmd5:Bind(1, steamID_num2)
	local result5 = cmd5:Execute(), nil
	if result5[1] == nil then
		--COST VALUES HERE
		local cmd2 = SQL:Command('INSERT INTO playerIp (steamID, IP_1, IP_2, IP_3, IP_4, IP_5, IP_6, IP_7, IP_8, IP_9, IP_10, IP_11, IP_12, IP_13, IP_14, IP_15, IP_16, IP_17, IP_18, IP_19, IP_20, IP, IP_Resets) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
		cmd2:Bind(1, steamID_num2)
		cmd2:Bind(2, 1)
		cmd2:Bind(3, 1)
		cmd2:Bind(4, 1)
		cmd2:Bind(5, 1)
		cmd2:Bind(6, 1)
		cmd2:Bind(7, 1)
		cmd2:Bind(8, 1)
		cmd2:Bind(9, 1)
		cmd2:Bind(10, 1)
		cmd2:Bind(11, 1)
		cmd2:Bind(12, 1)
		cmd2:Bind(13, 1)
		cmd2:Bind(14, 1)
		cmd2:Bind(15, 1)
		cmd2:Bind(16, 1)
		cmd2:Bind(17, 1)
		cmd2:Bind(18, 1)
		cmd2:Bind(19, 1)
		cmd2:Bind(20, 1)
		cmd2:Bind(21, 1)
		cmd2:Bind(22, 1)
		cmd2:Bind(23, 1)
		cmd2:Execute()
	end
	local cmd6 = SQL:Query('SELECT steamID FROM playerSkills WHERE steamID = ?')
	cmd6:Bind(1, steamID_num2)
	local result6 = cmd6:Execute(), nil
	
	if result6[1] == nil then
		--ACTUAL SKILL VALUES HERE
		local cmd2 = SQL:Command('INSERT INTO playerSkills (steamID, Melee_Dmg_1, Melee_Dmg_2, Melee_Sta_1, Melee_Sta_2, StaminaRegen, MaxHealth, CraftingLevel, HealthRegen, SprintEnergy, StuntEnergy, Concealment, Perception, StaminaSwim, StaminaMax, Placeholder4, Placeholder5, Placeholder6, Placeholder7, Placeholder8, Placeholder9) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
		cmd2:Bind(1, steamID_num2)
		cmd2:Bind(2, 0)
		cmd2:Bind(3, 0)
		cmd2:Bind(4, 0)
		cmd2:Bind(5, 0)
		cmd2:Bind(6, 0)
		cmd2:Bind(7, 100)
		cmd2:Bind(8, 0)
		cmd2:Bind(9, 0)
		cmd2:Bind(10, 0)
		cmd2:Bind(11, 0)
		cmd2:Bind(12, 0)
		cmd2:Bind(13, 0)
		cmd2:Bind(14, 0)
		cmd2:Bind(15, 100)
		cmd2:Bind(16, 0)
		cmd2:Bind(17, 0)
		cmd2:Bind(18, 0)
		cmd2:Bind(19, 0)
		cmd2:Bind(20, 0)
		cmd2:Bind(21, 0)
		cmd2:Execute()
		print("new player")
	end
	
	local queryData = SQL:Query('SELECT steamID, IP_1, IP_2, IP_3, IP_4, IP_5, IP_6, IP_7, IP_8, IP_9, IP_10, IP_11, IP_12, IP_13, IP_14, IP_15, IP_16, IP_17, IP_18, IP_19, IP_20, IP, IP_Resets FROM playerIp WHERE steamID = ? LIMIT 1')
	queryData:Bind(1, steamID_num2)
	local result = queryData:Execute()
	local queryData2 = SQL:Query('SELECT steamID, Melee_Dmg_1, Melee_Dmg_2, Melee_Sta_1, Melee_Sta_2, StaminaRegen, MaxHealth, CraftingLevel, HealthRegen, SprintEnergy, StuntEnergy, Concealment, Perception, StaminaSwim, StaminaMax FROM playerSkills WHERE steamID = ? LIMIT 1')
	queryData2:Bind(1, steamID_num2)
	local result2 = queryData2:Execute()
	local steamID_PD = result[1].steamID
	local IP_1_PD = result[1].IP_1
	local IP_2_PD = result[1].IP_2
	local IP_3_PD = result[1].IP_3
	local IP_4_PD = result[1].IP_4
	local IP_5_PD = result[1].IP_5
	local IP_6_PD = result[1].IP_6
	local IP_7_PD = result[1].IP_7
	local IP_8_PD = result[1].IP_8
	local IP_9_PD = result[1].IP_9
	local IP_10_PD = result[1].IP_10
	local IP_11_PD = result[1].IP_11
	local IP_12_PD = result[1].IP_12
	local IP_13_PD = result[1].IP_13
	local IP_14_PD = result[1].IP_14
	local IP_15_PD = result[1].IP_15
	local IP_16_PD = result[1].IP_16
	local IP_17_PD = result[1].IP_17
	local IP_18_PD = result[1].IP_18
	local IP_19_PD = result[1].IP_19
	local IP_20_PD = result[1].IP_20
	local IP_Resets_PD = result[1].IP_Resets
	local IP_PD = result[1].IP
	if steamID_PD ~= steamID_num2 then
		Chat:Send(args.player, "Error 303, please contact an admin!", Color(255,0,0))
		return
	end
	local steamID2_PD = result2[1].steamID
	local Melee_Dmg_1_PD = result2[1].Melee_Dmg_1
	local Melee_Dmg_2_PD = result2[1].Melee_Dmg_2
	local Melee_Sta_1_PD = result2[1].Melee_Sta_1
	local Melee_Sta_2_PD = result2[1].Melee_Sta_2
	local StaminaRegen_PD = result2[1].StaminaRegen
	local MaxHealth_PD = result2[1].MaxHealth
	local CraftingLevel_PD = result2[1].CraftingLevel
	local HealthRegen_PD = result2[1].HealthRegen
	local SprintEnergy_PD = result2[1].SprintEnergy
	local StuntEnergy_PD = result2[1].StuntEnergy
	local Concealment_PD = result2[1].Concealment
	local Perception_PD = result2[1].Perception
	local StaminaSwim_PD = result2[1].StaminaSwim
	local StaminaMax_PD = result2[1].StaminaMax
	--local Placeholder5_PD = result2[1].Placeholder5
	--local Placeholder6_PD = result2[1].Placeholder6
	--local Placeholder7_PD = result2[1].Placeholder7
	--local Placeholder8_PD = result2[1].Placeholder8
	--local Placeholder9_PD = result2[1].Placeholder9
	
	if steamID2_PD ~= steamID_num2 then
		Chat:Send(args.player, "Error 308, please contact an admin!", Color(255,0,0))
		return
	end
	args.player:SetValue("Melee_Dmg_1", Melee_Dmg_1_PD)
	args.player:SetValue("Melee_Dmg_2", Melee_Dmg_2_PD)
	args.player:SetValue("Melee_Sta_1", Melee_Sta_1_PD)
	args.player:SetValue("Melee_Sta_2", Melee_Sta_2_PD)
	args.player:SetValue("StaminaRegen", StaminaRegen_PD)
	args.player:SetValue("StaminaMax", StaminaMax_PD)
	args.player:SetValue("MaxHealth", MaxHealth_PD)
	args.player:SetValue("CraftingLevel", CraftingLevel_PD)
	args.player:SetValue("HealthRegen", HealthRegen_PD)
	args.player:SetValue("StuntEnergy", StuntEnergy_PD)
	args.player:SetValue("SprintEnergy", SprintEnergy_PD)
	args.player:SetValue("Concealment", Concealment_PD)
	args.player:SetValue("Perception", Perception_PD)
	args.player:SetValue("StaminaSwim", StaminaSwim_PD)
	args.player:SetValue("IP_1", IP_1_PD)
	args.player:SetValue("IP_2", IP_2_PD)
	args.player:SetValue("IP_3", IP_3_PD)
	args.player:SetValue("IP_4", IP_4_PD)
	args.player:SetValue("IP_5", IP_5_PD)
	args.player:SetValue("IP_6", IP_6_PD)
	args.player:SetValue("IP_7", IP_7_PD)
	args.player:SetValue("IP_8", IP_8_PD)
	args.player:SetValue("IP_9", IP_9_PD)
	args.player:SetValue("IP_10", IP_10_PD)
	args.player:SetValue("IP_11", IP_11_PD)
	args.player:SetValue("IP_12", IP_12_PD)
	args.player:SetValue("IP_13", IP_13_PD)
	args.player:SetValue("IP_14", IP_14_PD)
	args.player:SetValue("IP_15", IP_15_PD)
	args.player:SetValue("IP_16", IP_16_PD)
	args.player:SetValue("IP_17", IP_17_PD)
	args.player:SetValue("IP_18", IP_18_PD)
	args.player:SetValue("IP_19", IP_19_PD)
	args.player:SetValue("IP_20", IP_20_PD)
	args.player:SetValue("IP_Resets", IP_Resets_PD)
	local sqlArgs = {}
	sqlArgs.IP = IP_PD
	sqlArgs.IP_1 = IP_1_PD
	sqlArgs.IP_2 = IP_2_PD
	sqlArgs.IP_3 = IP_3_PD
	sqlArgs.IP_4 = IP_4_PD
	sqlArgs.IP_5 = IP_5_PD
	sqlArgs.IP_6 = IP_6_PD
	sqlArgs.IP_7 = IP_7_PD
	sqlArgs.IP_8 = IP_8_PD
	sqlArgs.IP_9 = IP_9_PD
	sqlArgs.IP_10 = IP_10_PD
	sqlArgs.IP_11 = IP_11_PD
	sqlArgs.IP_12 = IP_12_PD
	sqlArgs.IP_13 = IP_13_PD
	sqlArgs.IP_14 = IP_14_PD
	sqlArgs.IP_15 = IP_15_PD
	sqlArgs.IP_16 = IP_16_PD
	sqlArgs.IP_17 = IP_17_PD
	sqlArgs.IP_18 = IP_18_PD
	sqlArgs.IP_19 = IP_19_PD
	sqlArgs.IP_20 = IP_20_PD
	sqlArgs.IP_Resets = IP_Resets_PD
	sqlArgs.Melee_Dmg_1 = Melee_Dmg_1_PD
	sqlArgs.staminaMax = StaminaMax_PD
	sqlArgs.Melee_Dmg_2 = Melee_Dmg_2_PD
	sqlArgs.Melee_Sta_1 = Melee_Sta_1_PD
	sqlArgs.Melee_Sta_2 = Melee_Sta_2_PD
	sqlArgs.StaminaRegen = StaminaRegen_PD
	sqlArgs.MaxHealth = MaxHealth_PD
	sqlArgs.CraftingLevel = CraftingLevel_PD
	sqlArgs.HealthRegen = HealthRegen_PD
	sqlArgs.StuntEnergy = StuntEnergy_PD
	sqlArgs.SprintEnergy = SprintEnergy_PD
	sqlArgs.Concealment = Concealment_PD
	sqlArgs.Perception = Perception_PD
	sqlArgs.StaminaSwim = StaminaSwim_PD
	Stamina_PD = StaminaMax_PD / 2
	sqlArgs.Stamina = Stamina_PD
	sqlArgs.regenstill = 4 --if velocity is zero, in stamina gained per second
	sqlArgs.regenwalk = 1.5 --if in walk state, in stamina gained per second
	sqlArgs.regenrun = -6 --if in normal run state, in stamina gained per second
	sqlArgs.regentired = 1 --if negative stamina, PUNISH, in stamina gained per second
	sqlArgs.regenswimsurface = -0.5 --swimming on the surface of the water
	sqlArgs.regenswimunder = -1.25 --swimming under the surface of the water
	sqlArgs.regenstunt = -0.25 --stunt position on an unmoving vehicle
	sqlArgs.regenstuntmove = -1.33 --stunt position on a slowly moving vehicle
	sqlArgs.regenstuntmovefast = -3 --stunt position on a fast moving vehicle
	sqlArgs.regenstuntmoveveryfast = -6 --stunt position on a very fast moving vehicle
	sqlArgs.stuntstamina = 6 --initial stunt position deduction (AKA the jump)
	print("IP_PD", IP_PD)
	sqlArgs.player = args.player
	--ps[os.time()] = sqlArgs
	--Network:Send(args.player, "IP_From_Sql", sqlArgs)
	if not tonumber(IP_PD) then
		IP_PD = 1
		args.player:SetValue("IP", 0)
	else
		args.player:SetValue("IP", IP_PD)
	end
	Network:Send(args.player, "IP_From_Sql", sqlArgs)
	--Events:Fire("IP_SQL_Loaded_Fire", args)
	print("loaded ip")
end
function Ip_Sql:PlayerSaveIP(sender)
	local steamID = sender:GetSteamId()
	local steamID_num2 = steamID.id
	print("saveip")
	local cmd2 = SQL:Command('INSERT OR REPLACE INTO playerIp (steamID, IP_1, IP_2, IP_3, IP_4, IP_5, IP_6, IP_7, IP_8, IP_9, IP_10, IP_11, IP_12, IP_13, IP_14, IP_15, IP_16, IP_17, IP_18, IP_19, IP_20, IP, IP_Resets) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
	cmd2:Bind(1, steamID_num2)
		cmd2:Bind(2, sender:GetValue("IP_1"))
		cmd2:Bind(3, sender:GetValue("IP_2"))
		cmd2:Bind(4, sender:GetValue("IP_3"))
		cmd2:Bind(5, sender:GetValue("IP_4"))
		cmd2:Bind(6, sender:GetValue("IP_5"))
		cmd2:Bind(7, sender:GetValue("IP_6"))
		cmd2:Bind(8, sender:GetValue("IP_7"))
		cmd2:Bind(9, sender:GetValue("IP_8"))
		cmd2:Bind(10, sender:GetValue("IP_9"))
		cmd2:Bind(11, sender:GetValue("IP_10"))
		cmd2:Bind(12, sender:GetValue("IP_11"))
		cmd2:Bind(13, sender:GetValue("IP_12"))
		cmd2:Bind(14, sender:GetValue("IP_13"))
		cmd2:Bind(15, sender:GetValue("IP_14"))
		cmd2:Bind(16, sender:GetValue("IP_15"))
		cmd2:Bind(17, sender:GetValue("IP_16"))
		cmd2:Bind(18, sender:GetValue("IP_17"))
		cmd2:Bind(19, sender:GetValue("IP_18"))
		cmd2:Bind(20, sender:GetValue("IP_19"))
		cmd2:Bind(21, sender:GetValue("IP_20"))
		cmd2:Bind(22, sender:GetValue("IP"))
		cmd2:Bind(23, sender:GetValue("IP"))
	cmd2:Execute()
	--print("IP saved for "..tostring(sender))
		local cmd2 = SQL:Command('INSERT OR REPLACE INTO playerSkills (steamID, Melee_Dmg_1, Melee_Dmg_2, Melee_Sta_1, Melee_Sta_2, StaminaRegen, MaxHealth, CraftingLevel, HealthRegen, SprintEnergy, StuntEnergy, Concealment, Perception, StaminaSwim, StaminaMax, Placeholder5, Placeholder6, Placeholder7, Placeholder8, Placeholder9) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
		cmd2:Bind(1, steamID_num2)
		cmd2:Bind(2, sender:GetValue("Melee_Dmg_1"))
		cmd2:Bind(3, sender:GetValue("Melee_Dmg_2"))
		cmd2:Bind(4, sender:GetValue("Melee_Sta_1"))
		cmd2:Bind(5, sender:GetValue("Melee_Sta_2"))
		cmd2:Bind(6, sender:GetValue("StaminaRegen"))
		cmd2:Bind(7, sender:GetValue("MaxHealth"))
		cmd2:Bind(8, sender:GetValue("CraftingLevel"))
		cmd2:Bind(9, sender:GetValue("HealthRegen"))
		cmd2:Bind(10, sender:GetValue("SprintEnergy"))
		cmd2:Bind(11, sender:GetValue("StuntEnergy"))
		cmd2:Bind(12, sender:GetValue("Concealment"))
		cmd2:Bind(13, sender:GetValue("Perception"))
		cmd2:Bind(14, sender:GetValue("StaminaSwim"))
		cmd2:Bind(15, sender:GetValue("StaminaMax"))
		--cmd2:Bind(17, sender:GetValue("Placeholder5"))
		--cmd2:Bind(18, sender:GetValue("Placeholder6"))
		--cmd2:Bind(19, sender:GetValue("Placeholder7"))
		--cmd2:Bind(20, sender:GetValue("Placeholder8"))
		--cmd2:Bind(21, sender:GetValue("Placeholder9"))
		cmd2:Bind(16, 0)
		cmd2:Bind(17, 0)
		cmd2:Bind(18, 0)
		cmd2:Bind(19, 0)
		cmd2:Bind(20, 0)
		cmd2:Execute()
end
function Ip_Sql:PlayerQuit(args)
	if args.player:GetValue("IP") then
		local steamID = args.player:GetSteamId()
		local steamID_num2 = steamID.id
		local cmd2 = SQL:Command('INSERT OR REPLACE INTO playerIp (steamID, IP_1, IP_2, IP_3, IP_4, IP_5, IP_6, IP_7, IP_8, IP_9, IP_10, IP_11, IP_12, IP_13, IP_14, IP_15, IP_16, IP_17, IP_18, IP_19, IP_20, IP, IP_Resets) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
		cmd2:Bind(1, steamID_num2)
			cmd2:Bind(2, args.player:GetValue("IP_1"))
			cmd2:Bind(3, args.player:GetValue("IP_2"))
			cmd2:Bind(4, args.player:GetValue("IP_3"))
			cmd2:Bind(5, args.player:GetValue("IP_4"))
			cmd2:Bind(6, args.player:GetValue("IP_5"))
			cmd2:Bind(7, args.player:GetValue("IP_6"))
			cmd2:Bind(8, args.player:GetValue("IP_7"))
			cmd2:Bind(9, args.player:GetValue("IP_8"))
			cmd2:Bind(10, args.player:GetValue("IP_9"))
			cmd2:Bind(11, args.player:GetValue("IP_10"))
			cmd2:Bind(12, args.player:GetValue("IP_11"))
			cmd2:Bind(13, args.player:GetValue("IP_12"))
			cmd2:Bind(14, args.player:GetValue("IP_13"))
			cmd2:Bind(15, args.player:GetValue("IP_14"))
			cmd2:Bind(16, args.player:GetValue("IP_15"))
			cmd2:Bind(17, args.player:GetValue("IP_16"))
			cmd2:Bind(18, args.player:GetValue("IP_17"))
			cmd2:Bind(19, args.player:GetValue("IP_18"))
			cmd2:Bind(20, args.player:GetValue("IP_19"))
			cmd2:Bind(21, args.player:GetValue("IP_20"))
			cmd2:Bind(22, args.player:GetValue("IP"))
			cmd2:Bind(23, args.player:GetValue("IP_Resets"))
		cmd2:Execute()
		--print("IP saved for "..tostring(args.player))
			local cmd2 = SQL:Command('INSERT OR REPLACE INTO playerSkills (steamID, Melee_Dmg_1, Melee_Dmg_2, Melee_Sta_1, Melee_Sta_2, StaminaRegen, MaxHealth, CraftingLevel, HealthRegen, SprintEnergy, StuntEnergy, Concealment, Perception, StaminaSwim, StaminaMax) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
			cmd2:Bind(1, steamID_num2)
			cmd2:Bind(2, args.player:GetValue("Melee_Dmg_1"))
			cmd2:Bind(3, args.player:GetValue("Melee_Dmg_2"))
			cmd2:Bind(4, args.player:GetValue("Melee_Sta_1"))
			cmd2:Bind(5, args.player:GetValue("Melee_Sta_2"))
			cmd2:Bind(6, args.player:GetValue("StaminaRegen"))
			cmd2:Bind(7, args.player:GetValue("MaxHealth"))
			cmd2:Bind(8, args.player:GetValue("CraftingLevel"))
			cmd2:Bind(9, args.player:GetValue("HealthRegen"))
			cmd2:Bind(10, args.player:GetValue("SprintEnergy"))
			cmd2:Bind(11, args.player:GetValue("StuntEnergy"))
			cmd2:Bind(12, args.player:GetValue("Concealment"))
			cmd2:Bind(13, args.player:GetValue("Perception"))
			cmd2:Bind(14, args.player:GetValue("StaminaSwim"))
			cmd2:Bind(15, args.player:GetValue("StaminaMax"))
			local stamMax = args.player:GetValue("StaminaMax")
			--cmd2:Bind(17, args.player:GetValue("Placeholder5"))
			--cmd2:Bind(18, args.player:GetValue("Placeholder6"))
			--cmd2:Bind(19, args.player:GetValue("Placeholder7"))
			--cmd2:Bind(20, args.player:GetValue("Placeholder8"))
			--cmd2:Bind(21, args.player:GetValue("Placeholder9"))
			--cmd2:Bind(16, stamMax / 2)
			--cmd2:Bind(17, 0)
			--cmd2:Bind(18, 0)
			--cmd2:Bind(19, 0)
			--cmd2:Bind(20, 0)
			cmd2:Execute()
		--print("IP saved for "..tostring(args.player))
	end
end
function Ip_Sql:Reset(player)
	if player then
		print("reset sql")
		local steamID = player:GetSteamId()
		local steamID_num2 = steamID.id
		local cmd2 = SQL:Command('REPLACE INTO playerIp (steamID, IP_1, IP_2, IP_3, IP_4, IP_5, IP_6, IP_7, IP_8, IP_9, IP_10, IP_11, IP_12, IP_13, IP_14, IP_15, IP_16, IP_17, IP_18, IP_19, IP_20, IP, IP_Resets) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
		cmd2:Bind(1, steamID_num2)
		cmd2:Bind(2, 1)
		cmd2:Bind(3, 1)
		cmd2:Bind(4, 1)
		cmd2:Bind(5, 1)
		cmd2:Bind(6, 1)
		cmd2:Bind(7, 1)
		cmd2:Bind(8, 1)
		cmd2:Bind(9, 1)
		cmd2:Bind(10, 1)
		cmd2:Bind(11, 1)
		cmd2:Bind(12, 1)
		cmd2:Bind(13, 1)
		cmd2:Bind(14, 1)
		cmd2:Bind(15, 1)
		cmd2:Bind(16, 1)
		cmd2:Bind(17, 1)
		cmd2:Bind(18, 1)
		cmd2:Bind(19, 1)
		cmd2:Bind(20, 1)
		cmd2:Bind(21, 1)
		cmd2:Bind(22, player:GetValue("IP"))
		cmd2:Bind(23, player:GetValue("IP_Resets"))
		cmd2:Execute()
		local cmd2 = SQL:Command('REPLACE INTO playerSkills (steamID, Melee_Dmg_1, Melee_Dmg_2, Melee_Sta_1, Melee_Sta_2, StaminaRegen, MaxHealth, CraftingLevel, HealthRegen, SprintEnergy, StuntEnergy, Concealment, Perception, StaminaSwim, StaminaMax) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
		cmd2:Bind(1, steamID_num2)
		cmd2:Bind(2, 0)
		cmd2:Bind(3, 0)
		cmd2:Bind(4, 0)
		cmd2:Bind(5, 0)
		cmd2:Bind(6, 0)
		cmd2:Bind(7, 0)
		cmd2:Bind(8, 0)
		cmd2:Bind(9, 0)
		cmd2:Bind(10, 0)
		cmd2:Bind(11, 0)
		cmd2:Bind(12, 0)
		cmd2:Bind(13, 0)
		cmd2:Bind(14, 0)
		cmd2:Bind(15, 100)
		cmd2:Execute()
	end
end
function ModuleLoad()
	Ip_Sql = Ip_Sql()
end
Events:Subscribe("ModuleLoad", ModuleLoad)