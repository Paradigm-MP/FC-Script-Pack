class 'Ip_Stat_Updater'
function Ip_Stat_Updater:__init()
	self.changeperincrease = 2
	Network:Subscribe("IP_Save", self, self.SaveChanges)
	Network:Subscribe("IP_Reset", self, self.Reset)
end
function Ip_Stat_Updater:SaveChanges(args, sender)
	--[[
	
	Here's some info on what all these
	values mean.  The main "IP" is how
	many total IP the player has to
	spend on raising skills.  Each time
	a skill is raised by a "stage" (could
	be 1, 0.1, etc depending on skill),
	the amount of IP needed to raise it
	by a stage again goes up by 2.  That's
	where the IP_x comes in.  Each one of
	these corresponds to a value that can
	be raised via IP.  Each time it is
	raised, the IP_x value for that skill
	goes up by two, and therefore you need
	two more IP then before to raise it again.
	The IP_x always goes up by two except
	the first time, which is one.
	
	--]]
	local IP_1 = sender:GetValue("IP_1")
	local IP_2 = sender:GetValue("IP_2")
	local IP_3 = sender:GetValue("IP_3")
	local IP_4 = sender:GetValue("IP_4")
	local IP_5 = sender:GetValue("IP_5")
	local IP_6 = sender:GetValue("IP_6")
	local IP_7 = sender:GetValue("IP_7")
	local IP_8 = sender:GetValue("IP_8")
	local IP_9 = sender:GetValue("IP_9")
	local IP_10 = sender:GetValue("IP_10")
	local IP_11 = sender:GetValue("IP_11")
	local IP_12 = sender:GetValue("IP_12")
	local IP_13 = sender:GetValue("IP_13")
	local IP_14 = sender:GetValue("IP_14")
	local IP_15 = sender:GetValue("IP_15")
	local IP_16 = sender:GetValue("IP_16")
	local IP_17 = sender:GetValue("IP_17")
	local IP_18 = sender:GetValue("IP_18")
	local IP_19 = sender:GetValue("IP_19")
	local IP_20 = sender:GetValue("IP_20")
	local IP = tonumber(sender:GetValue("IP"))
	local Melee_Dmg_1 = tonumber(sender:GetValue("Melee_Dmg_1"))
	local Melee_Dmg_2 = tonumber(sender:GetValue("Melee_Dmg_2"))
	local Melee_Sta_1 = tonumber(sender:GetValue("Melee_Sta_1"))
	local Melee_Sta_2 = tonumber(sender:GetValue("Melee_Sta_2"))
	local StaminaRegen = tonumber(sender:GetValue("StaminaRegen"))
	local MaxHealth = tonumber(sender:GetValue("MaxHealth"))
	local CraftingLevel = tonumber(sender:GetValue("CraftingLevel"))
	print("CraftingLevel ", CraftingLevel)
	local HealthRegen = tonumber(sender:GetValue("HealthRegen"))
	local sprintEnergy = tonumber(sender:GetValue("SprintEnergy"))
	local stuntEnergy = tonumber(sender:GetValue("StuntEnergy"))
	local Concealment = tonumber(sender:GetValue("Concealment"))
	local Perception = tonumber(sender:GetValue("Perception"))
	local StaminaSwim = tonumber(sender:GetValue("StaminaSwim"))
	local StaminaMax = tonumber(sender:GetValue("StaminaMax"))
	local IP_new = tonumber(args.IP)
	if IP_new < 0 then
		print("[ERROR] "..tostring(sender).." has created an IP error")
		Chat:Send(sender, "IP error 156! Please contact an admin!", Color(255,0,0))
		return
	end
	
	
	
	
	-----------------------------------------------------------
	-----------------stamina max caluclations
	local staminaMaxNew = tonumber(args.staminaMax) --upgraded skill value
	if args.staminaMax and tonumber(args.staminaMax) > 0 then
		local staminaMaxChange = 1 --how much the skill goes up each time the button is pressed
		local staminaMaxDiff = staminaMaxNew - StaminaMax --how much the value has changed
		local staminaMaxChangeDiff = staminaMaxDiff / staminaMaxChange --how much IP was spent
		if staminaMaxChangeDiff < 0 then return end
		for i = 1, staminaMaxChangeDiff do --for 1 to the total change of the value...summation
			IP = IP - IP_1
			if tonumber(IP_1) < 2 then --if first time, keep it even
				IP_1 = IP_1 + (self.changeperincrease / self.changeperincrease)
				print("IP_1 firsttime ", IP_1)
			else --otherwise add 2 to the cost each time
				IP_1 = IP_1 + self.changeperincrease
				print("IP_1 ", IP_1)
			end
			print("IPmax ", IP)
			if IP < 0 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
			if i > 500 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
		end
	end
	
	
	
	-------------------------------------------------------------------
	-----------------stamina regen caluclations
	local staminaRegenNew = tonumber(args.staminaRegen) --upgraded skill value
	if args.staminaRegen and tonumber(args.staminaRegen) > 0 then
		local staminaRegenChange = 1 --how much the skill goes up each time the button is pressed
		local staminaRegenDiff = staminaRegenNew - StaminaRegen --how much the value has changed
		local staminaRegenChangeDiff = staminaRegenDiff / staminaRegenChange --how much IP was spent
		if staminaRegenChangeDiff < 0 then return end
		for i = 1, staminaRegenChangeDiff do --for 1 to the total change of the value...summation
			IP = IP - IP_2
			if tonumber(IP_2) < 2 then --if first time, keep it even
				IP_2 = IP_2 + (self.changeperincrease / self.changeperincrease)
				print("IP_2 firsttime ", IP_2)
			else --otherwise add 2 to the cost each time
				IP_2 = IP_2 + self.changeperincrease
				print("IP_2 ", IP_2)
			end
			print("IPregen ", IP)
			if IP < 0 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
			if i > 500 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
		end
	end
	
	
	-------------------------------------------------------------------
	-----------------stamina swim caluclations
	local staminaSwimNew = tonumber(args.staminaSwim) --upgraded skill value
	if args.staminaSwim and tonumber(args.staminaSwim) > 0 then
		local staminaSwimChange = 1 --how much the skill goes up each time the button is pressed
		local staminaSwimDiff = staminaSwimNew - StaminaSwim --how much the value has changed
		local staminaSwimChangeDiff = staminaSwimDiff / staminaSwimChange --how much IP was spent
		if staminaSwimChangeDiff < 0 then return end
		for i = 1, staminaSwimChangeDiff do --for 1 to the total change of the value...summation
			IP = IP - IP_3
			if tonumber(IP_3) < 2 then --if first time, keep it even
				IP_3 = IP_3 + (self.changeperincrease / self.changeperincrease)
				print("IP_3 firsttime ", IP_3)
			else --otherwise add 2 to the cost each time
				IP_3 = IP_3 + self.changeperincrease
				print("IP_3 ", IP_3)
			end
			print("IPswim ", IP)
			if IP < 0 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
			if i > 500 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
		end
	end
	
	-------------------------------------------------------------------
	-----------------sprint energy caluclations
	local sprintEnergyNew = tonumber(args.sprintEnergy) --upgraded skill value
	if args.sprintEnergy and tonumber(args.sprintEnergy) > 0 then
		local sprintEnergyChange = 1 --how much the skill goes up each time the button is pressed
		local sprintEnergyDiff = sprintEnergyNew - sprintEnergy --how much the value has changed
		local sprintEnergyChangeDiff = sprintEnergyDiff / sprintEnergyChange --how much IP was spent
		if sprintEnergyChangeDiff < 0 then return end
		for i = 1, sprintEnergyChangeDiff do --for 1 to the total change of the value...summation
			IP = IP - IP_4
			if tonumber(IP_4) < 2 then --if first time, keep it even
				IP_4 = IP_4 + (self.changeperincrease / self.changeperincrease)
				print("IP_4 firsttime ", IP_4)
			else --otherwise add 2 to the cost each time
				IP_4 = IP_4 + self.changeperincrease
				print("IP_4 ", IP_4)
			end
			print("IPsprintEnergy ", IP)
			if IP < 0 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
			if i > 500 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
		end
	end
	
	-------------------------------------------------------------------
	-----------------stunt energy caluclations
	local stuntEnergyNew = tonumber(args.stuntEnergy) --upgraded skill value
	if args.stuntEnergy and tonumber(args.stuntEnergy) > 0 then
		local stuntEnergyChange = 1 --how much the skill goes up each time the button is pressed
		local stuntEnergyDiff = stuntEnergyNew - stuntEnergy --how much the value has changed
		local stuntEnergyChangeDiff = stuntEnergyDiff / stuntEnergyChange --how much IP was spent
		if stuntEnergyChangeDiff < 0 then return end
		for i = 1, stuntEnergyChangeDiff do --for 1 to the total change of the value...summation
			IP = IP - IP_5
			if tonumber(IP_5) < 2 then --if first time, keep it even
				IP_5 = IP_5 + (self.changeperincrease / self.changeperincrease)
				print("IP_5 firsttime ", IP_5)
			else --otherwise add 2 to the cost each time
				IP_5 = IP_5 + self.changeperincrease
				print("IP_5 ", IP_5)
			end
			print("IPstuntEnergy ", IP)
			if IP < 0 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
			if i > 500 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
		end
	end
	
	-------------------------------------------------------------------
	-----------------hp regen caluclations
	local HealthRegenNew = tonumber(args.HealthRegen) --upgraded skill value
	if args.HealthRegen and tonumber(args.HealthRegen) > 0 then
		local HealthRegenChange = 1 --how much the skill goes up each time the button is pressed
		local HealthRegenDiff = HealthRegenNew - HealthRegen --how much the value has changed
		local HealthRegenChangeDiff = HealthRegenDiff / HealthRegenChange --how much IP was spent
		if HealthRegenChangeDiff < 0 then return end
		for i = 1, HealthRegenChangeDiff do --for 1 to the total change of the value...summation
			IP = IP - IP_6
			if tonumber(IP_6) < 2 then --if first time, keep it even
				IP_6 = IP_6 + (self.changeperincrease / self.changeperincrease)
				print("IP_6 firsttime ", IP_6)
			else --otherwise add 2 to the cost each time
				IP_6 = IP_6 + self.changeperincrease
				print("IP_6 ", IP_6)
			end
			print("IPHealthRegen ", IP)
			if IP < 0 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
			if i > 500 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
		end
	end
	
	-------------------------------------------------------------------
	-----------------crafting level caluclations
	print("args.CraftingLevel ", args.CraftingLevel)
	local CraftingLevelNew = tonumber(args.CraftingLevel) --upgraded skill value
	if args.CraftingLevel and tonumber(args.CraftingLevel) > 0 then
		local CraftingLevelChange = 1 --how much the skill goes up each time the button is pressed
		local CraftingLevelDiff = CraftingLevelNew - CraftingLevel --how much the value has changed
		local CraftingLevelChangeDiff = CraftingLevelDiff / CraftingLevelChange --how much IP was spent
		if CraftingLevelChangeDiff < 0 then return end
		for i = 1, CraftingLevelChangeDiff do --for 1 to the total change of the value...summation
			IP = IP - IP_7
			if tonumber(IP_7) < 2 then --if first time, keep it even
				IP_7 = IP_7 + (self.changeperincrease / self.changeperincrease)
				print("IP_7 firsttime ", IP_7)
			else --otherwise add 2 to the cost each time
				IP_7 = IP_7 + self.changeperincrease
				print("IP_7 ", IP_7)
			end
			print("IPCraftingLevel ", IP)
			if IP < 0 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
			if i > 500 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
		end
	end
	
	-------------------------------------------------------------------
	-----------------kick 1 dmg caluclations
	local Melee_Dmg_1New = tonumber(args.Melee_Dmg_1) --upgraded skill value
	if args.Melee_Dmg_1 and tonumber(args.Melee_Dmg_1) > 0 then
		local Melee_Dmg_1Change = 1 --how much the skill goes up each time the button is pressed
		local Melee_Dmg_1Diff = Melee_Dmg_1New - Melee_Dmg_1 --how much the value has changed
		local Melee_Dmg_1ChangeDiff = Melee_Dmg_1Diff / Melee_Dmg_1Change --how much IP was spent
		if Melee_Dmg_1ChangeDiff < 0 then return end
		for i = 1, Melee_Dmg_1ChangeDiff do --for 1 to the total change of the value...summation
			IP = IP - IP_8
			if tonumber(IP_8) < 2 then --if first time, keep it even
				IP_8 = IP_8 + (self.changeperincrease / self.changeperincrease)
				print("IP_8 firsttime ", IP_8)
			else --otherwise add 2 to the cost each time
				IP_8 = IP_8 + self.changeperincrease
				print("IP_8 ", IP_8)
			end
			print("IPMelee_Dmg_1 ", IP)
			if IP < 0 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
			if i > 500 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
		end
	end
	
	-------------------------------------------------------------------
	-----------------kick 1 stamina caluclations
	local Melee_Sta_1New = tonumber(args.Melee_Sta_1) --upgraded skill value
	if args.Melee_Sta_1 and tonumber(args.Melee_Sta_1) > 0 then
		local Melee_Sta_1Change = 1 --how much the skill goes up each time the button is pressed
		local Melee_Sta_1Diff = Melee_Sta_1New - Melee_Sta_1 --how much the value has changed
		local Melee_Sta_1ChangeDiff = Melee_Sta_1Diff / Melee_Sta_1Change --how much IP was spent
		if Melee_Sta_1ChangeDiff < 0 then return end
		for i = 1, Melee_Sta_1ChangeDiff do --for 1 to the total change of the value...summation
			IP = IP - IP_9
			if tonumber(IP_9) < 2 then --if first time, keep it even
				IP_9 = IP_9 + (self.changeperincrease / self.changeperincrease)
				print("IP_9 firsttime ", IP_9)
			else --otherwise add 2 to the cost each time
				IP_9 = IP_9 + self.changeperincrease
				print("IP_9 ", IP_9)
			end
			print("IPMelee_Sta_1 ", IP)
			if IP < 0 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
			if i > 500 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
		end
	end
	
	-------------------------------------------------------------------
	-----------------kick 2 dmg caluclations
	local Melee_Dmg_2New = tonumber(args.Melee_Dmg_2) --upgraded skill value
	if args.Melee_Dmg_2 and tonumber(args.Melee_Dmg_2) > 0 then
		local Melee_Dmg_2Change = 1 --how much the skill goes up each time the button is pressed
		local Melee_Dmg_2Diff = Melee_Dmg_2New - Melee_Dmg_2 --how much the value has changed
		local Melee_Dmg_2ChangeDiff = Melee_Dmg_2Diff / Melee_Dmg_2Change --how much IP was spent
		if Melee_Dmg_2ChangeDiff < 0 then return end
		for i = 1, Melee_Dmg_2ChangeDiff do --for 1 to the total change of the value...summation
			IP = IP - IP_10
			if tonumber(IP_10) < 2 then --if first time, keep it even
				IP_10 = IP_10 + (self.changeperincrease / self.changeperincrease)
				print("IP_10 firsttime ", IP_10)
			else --otherwise add 2 to the cost each time
				IP_10 = IP_10 + self.changeperincrease
				print("IP_10 ", IP_10)
			end
			print("IPMelee_Dmg_2 ", IP)
			if IP < 0 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
			if i > 500 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
		end
	end
	
	-------------------------------------------------------------------
	-----------------kick 2 stamina caluclations
	local Melee_Sta_2New = tonumber(args.Melee_Sta_2) --upgraded skill value
	if args.Melee_Sta_2 and tonumber(args.Melee_Sta_2) > 0 then
		local Melee_Sta_2Change = 1 --how much the skill goes up each time the button is pressed
		local Melee_Sta_2Diff = Melee_Sta_2New - Melee_Sta_2 --how much the value has changed
		local Melee_Sta_2ChangeDiff = Melee_Sta_2Diff / Melee_Sta_2Change --how much IP was spent
		if Melee_Sta_2ChangeDiff < 0 then return end
		for i = 1, Melee_Sta_2ChangeDiff do --for 1 to the total change of the value...summation
			IP = IP - IP_11
			if tonumber(IP_11) < 2 then --if first time, keep it even
				IP_11 = IP_11 + (self.changeperincrease / self.changeperincrease)
				print("IP_11 firsttime ", IP_11)
			else --otherwise add 2 to the cost each time
				IP_11 = IP_11 + self.changeperincrease
				print("IP_11 ", IP_11)
			end
			print("IPMelee_Sta_2 ", IP)
			if IP < 0 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
			if i > 500 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
		end
	end
	
	------------------see if they actually changed anything
	if StaminaMax == staminaMaxNew
	and StaminaRegen == staminaRegenNew
	and StaminaSwim == staminaSwimNew 
	and sprintEnergy == sprintEnergyNew 
	and HealthRegen == HealthRegenNew 
	and CraftingLevel == CraftingLevelNew 
	and Melee_Dmg_1 == Melee_Dmg_1New 
	and Melee_Sta_1 == Melee_Sta_1New 
	and Melee_Dmg_2 == Melee_Dmg_2New 
	and Melee_Sta_2 == Melee_Sta_2New 
	and stuntEnergy == stuntEnergyNew then
		Chat:Send(sender, "You must have changes to save!", Color(255,0,0))
		return
	end
	print("IP ", IP)
	print("IP_new ", IP_new)
	if IP >= 0 and IP_new >= 0 and IP == IP_new then --check if they have enough ip to do the changes
		if StaminaMax ~= staminaMaxNew then
			sender:SetValue("IP_1", IP_1)
			sender:SetValue("StaminaMax", staminaMaxNew)
			print("[INFO] Set "..tostring(sender).."'s Maximum Stamina to "..tostring(staminaMaxNew).." from "..tostring(StaminaMax))
		end
		if StaminaRegen ~= staminaRegenNew then
			sender:SetValue("IP_2", IP_2)
			sender:SetValue("StaminaRegen", staminaRegenNew)
			print("[INFO] Set "..tostring(sender).."'s Stamina Regeneration to "..tostring(staminaRegenNew).." from "..tostring(StaminaRegen))
		end
		if StaminaSwim ~= staminaSwimNew then
			sender:SetValue("IP_3", IP_3)
			sender:SetValue("StaminaSwim", staminaSwimNew)
			print("[INFO] Set "..tostring(sender).."'s Stamina Swimming to "..tostring(staminaSwimNew).." from "..tostring(StaminaSwim))
		end
		if sprintEnergy ~= sprintEnergyNew then
			sender:SetValue("IP_4", IP_4)
			sender:SetValue("SprintEnergy", sprintEnergyNew)
			print("[INFO] Set "..tostring(sender).."'s Sprint Energy to "..tostring(sprintEnergyNew).." from "..tostring(sprintEnergy))
		end
		if stuntEnergy ~= stuntEnergyNew then
			sender:SetValue("IP_5", IP_5)
			sender:SetValue("StuntEnergy", stuntEnergyNew)
			print("[INFO] Set "..tostring(sender).."'s Stunt Energy to "..tostring(stuntEnergyNew).." from "..tostring(stuntEnergy))
		end
		if MaxHealth ~= HealthRegenNew then
			sender:SetValue("IP_6", IP_6)
			sender:SetValue("HealthRegen", HealthRegenNew)
			print("[INFO] Set "..tostring(sender).."'s Health Regeneration to "..tostring(HealthRegenNew).." from "..tostring(HealthRegen))
		end
		if CraftingLevel ~= CraftingLevelNew then
			sender:SetValue("IP_7", IP_7)
			sender:SetValue("CraftingLevel", CraftingLevelNew)
			print("[INFO] Set "..tostring(sender).."'s Crafting Level to "..tostring(CraftingLevelNew).." from "..tostring(CraftingLevel))
		end
		if Melee_Dmg_1 ~= Melee_Dmg_1New then
			sender:SetValue("IP_8", IP_8)
			sender:SetValue("Melee_Dmg_1", Melee_Dmg_1New)
			print("[INFO] Set "..tostring(sender).."'s Melee Kick 1 Damage to "..tostring(Melee_Dmg_1New).." from "..tostring(Melee_Dmg_1))
		end
		if Melee_Sta_1 ~= Melee_Sta_1New then
			sender:SetValue("IP_9", IP_9)
			sender:SetValue("Melee_Sta_1", Melee_Sta_1New)
			print("[INFO] Set "..tostring(sender).."'s Melee Kick 1 Stamina to "..tostring(Melee_Sta_1New).." from "..tostring(Melee_Sta_1))
		end
		if Melee_Dmg_2 ~= Melee_Dmg_2New then
			sender:SetValue("IP_10", IP_10)
			sender:SetValue("Melee_Dmg_2", Melee_Dmg_2New)
			print("[INFO] Set "..tostring(sender).."'s Melee Kick 2 Damage to "..tostring(Melee_Dmg_2New).." from "..tostring(Melee_Dmg_2))
		end
		if Melee_Sta_2 ~= Melee_Sta_2New then
			sender:SetValue("IP_11", IP_11)
			sender:SetValue("Melee_Sta_2", Melee_Sta_2New)
			print("[INFO] Set "..tostring(sender).."'s Melee Kick 2 Stamina to "..tostring(Melee_Sta_2New).." from "..tostring(Melee_Sta_2))
		end
		local argz = {}
		argz.IP = IP
		argz.IP_1 = IP_1
		argz.IP_2 = IP_2
		argz.IP_3 = IP_3
		argz.IP_4 = IP_4
		argz.IP_5 = IP_5
		argz.IP_6 = IP_6
		argz.IP_7 = IP_7
		argz.IP_8 = IP_8
		argz.IP_9 = IP_9
		argz.IP_10 = IP_10
		argz.IP_11 = IP_11
		argz.IP_12 = IP_12
		argz.IP_13 = IP_13
		argz.IP_14 = IP_14
		argz.IP_15 = IP_15
		argz.IP_16 = IP_16
		argz.IP_17 = IP_17
		argz.IP_18 = IP_18
		argz.IP_19 = IP_19
		argz.IP_20 = IP_20
		argz.Melee_Dmg_1 = sender:GetValue("Melee_Dmg_1")
		argz.staminaMax = sender:GetValue("StaminaMax")
		argz.Melee_Dmg_2 = sender:GetValue("Melee_Dmg_2")
		argz.Melee_Sta_1 = sender:GetValue("Melee_Sta_1")
		argz.Melee_Sta_2 = sender:GetValue("Melee_Sta_2")
		argz.StaminaRegen = sender:GetValue("StaminaRegen")
		--argz.MaxHealth = sender:GetValue("MaxHealth")
		argz.CraftingLevel = sender:GetValue("CraftingLevel")
		argz.HealthRegen = sender:GetValue("HealthRegen")
		argz.StuntEnergy = sender:GetValue("StuntEnergy")
		argz.SprintEnergy = sender:GetValue("SprintEnergy")
		argz.Concealment = sender:GetValue("Concealment")
		argz.Perception = sender:GetValue("Perception")
		argz.StaminaSwim = sender:GetValue("StaminaSwim")
		sender:SetValue("IP", IP)
		Network:Send(sender, "IP_Change", argz)
		Events:Fire("IP_Sql_Update", sender)
		Chat:Send(sender, "Successfully saved changes.", Color(0,255,255))
	else
		print("[ERROR] "..tostring(sender).." has created an IP error")
		Chat:Send(sender, "IP error 157! Please contact an admin!", Color(255,0,0))
		return
	end
end
function Ip_Stat_Updater:Reset(args, sender)
	if tonumber(sender:GetValue("StaminaMax")) ~= 100 
	or tonumber(sender:GetValue("StaminaRegen")) ~= 0
	or tonumber(sender:GetValue("StaminaSwim")) ~= 0
	or tonumber(sender:GetValue("SprintEnergy")) ~= 0
	or tonumber(sender:GetValue("HealthRegen")) ~= 0
	or tonumber(sender:GetValue("CraftingLevel")) ~= 0
	or tonumber(sender:GetValue("Melee_Dmg_1")) ~= 0
	or tonumber(sender:GetValue("Melee_Sta_1")) ~= 0
	or tonumber(sender:GetValue("Melee_Dmg_2")) ~= 0
	or tonumber(sender:GetValue("Melee_Sta_2")) ~= 0 then
		local resets = tonumber(sender:GetValue("IP_Resets"))
		if resets < 1 then
			Chat:Send(sender, "IP error 329!  Please contact an admin!", Color(255,0,0))
			return
		end
		local level = sender:GetValue("Level")
		local ip = 0
		for i = 1, level do
			ip = ip + i
			if i > 500 then Chat:Send(sender, "FATAL ERROR", Color.Red) print("ERROR:::INFINITE LOOP") break end
		end
		print("ip ", ip)
		sender:SetValue("IP_Resets", resets - 1)
		sender:SetValue("IP", ip)
		sender:SetValue("IP_1", 1)
		sender:SetValue("IP_2", 1)
		sender:SetValue("IP_3", 1)
		sender:SetValue("IP_4", 1)
		sender:SetValue("IP_5", 1)
		sender:SetValue("IP_6", 1)
		sender:SetValue("IP_7", 1)
		sender:SetValue("IP_8", 1)
		sender:SetValue("IP_9", 1)
		sender:SetValue("IP_10", 1)
		sender:SetValue("IP_11", 1)
		sender:SetValue("IP_12", 1)
		sender:SetValue("IP_13", 1)
		sender:SetValue("IP_14", 1)
		sender:SetValue("IP_15", 1)
		sender:SetValue("IP_16", 1)
		sender:SetValue("IP_17", 1)
		sender:SetValue("IP_18", 1)
		sender:SetValue("IP_19", 1)
		sender:SetValue("IP_20", 1)
		sender:SetValue("StaminaMax", 100)
		sender:SetValue("StaminaRegen", 0)
		sender:SetValue("CraftingLevel", 0)
		sender:SetValue("StuntEnergy", 0)
		sender:SetValue("SprintEnergy", 0)
		sender:SetValue("StaminaSwim", 0)
		sender:SetValue("HealthRegen", 0)
		sender:SetValue("Melee_Dmg_1", 0)
		sender:SetValue("Melee_Dmg_2", 0)
		sender:SetValue("Melee_Sta_1", 0)
		sender:SetValue("Melee_Sta_2", 0)
		Events:Fire("IP_Sql_Reset", sender)
		local argz = {}
		argz.IP_Resets = sender:GetValue("IP_Resets")
		argz.IP = ip
		argz.IP_1 = 1
		argz.IP_2 = 1
		argz.IP_3 = 1
		argz.IP_4 = 1
		argz.IP_5 = 1
		argz.IP_6 = 1
		argz.IP_7 = 1
		argz.IP_8 = 1
		argz.IP_9 = 1
		argz.IP_10 = 1
		argz.IP_11 = 1
		argz.IP_12 = 1
		argz.IP_13 = 1
		argz.IP_14 = 1
		argz.IP_15 = 1
		argz.IP_16 = 1
		argz.IP_17 = 1
		argz.IP_18 = 1
		argz.IP_19 = 1
		argz.IP_20 = 1
		argz.Melee_Dmg_1 = 0
		argz.staminaMax = 100
		argz.Melee_Dmg_2 = 0
		argz.Melee_Sta_1 = 0
		argz.Melee_Sta_2 = 0
		argz.StaminaRegen = 0
		argz.CraftingLevel = 0
		argz.HealthRegen = 0
		argz.StuntEnergy = 0
		argz.SprintEnergy = 0
		argz.Concealment = 0
		argz.Perception = 0
		argz.StaminaSwim = 0
		Chat:Send(sender, "Successfully reset IP.", Color(0,255,183))
		Network:Send(sender, "IP_Change", argz)
	else
		Chat:Send(sender, "You must makes changes in order to use the reset!", Color(255,0,0))
	end
end
function ModuleLoad()
	Ip_Stat_Updater = Ip_Stat_Updater()
end
Events:Subscribe("ModuleLoad", ModuleLoad)
function giveip(args)
	if args.text == "give me ip" then
		if args.player:GetValue("IP") then
			args.player:SetValue("IP", args.player:GetValue("IP") + 5000)
			Network:Send(args.player, "IP_Hax", args.player:GetValue("IP"))
		end
		return false
	end
end
Events:Subscribe("PlayerChat", giveip)