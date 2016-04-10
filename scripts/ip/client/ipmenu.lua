class 'IP_Menu'
function IP_Menu:__init(args)
	--print("IP Menu loaded")
	self.changeperincrease = 2
	self.green = Color(0,255,0)
	self.white = Color(255,255,255)
	self.red = Color(255,0,0)
	self.lightblue = Color(0,255,255)
	-- CPI is change per increase
	self.moveamountguiY1 = Vector2(0, 0.08)
	self.moveamountguiY = Vector2(0, 0.30)
	self.moveamountguiY2 = Vector2(0, 0.075)
	self.moveamountguiX = Vector2(0.135, 0)
	self.moveamountguiX2 = Vector2(0.275, 0)
	self.Window = Window.Create()
	self.Window:Hide()
	self.sizeX = Render.Size.x
	self.sizeY = Render.Size.y
	self.windowpos = Vector2(self.sizeX / 2, self.sizeY / 2) - Vector2(self.sizeX / 5, self.sizeY / 5)
	self.windowsize = Vector2(self.sizeX / 2.5, self.sizeY / 2.5)
	self.Window:SetSize(self.windowsize)
	self.Window:SetPosition(self.windowpos)
	self.Window:SetTitle("Influence Points Menu (Press 'U' to close)")
	self.WindowPos = self.Window:GetPositionRel()
	----------------------values
	
if args then
	self.IP_Resets = tonumber(args.IP_Resets)
	--print("args.IP_Resets ", args.IP_Resets)
	self.IP = tonumber(args.IP)
	self.IP_1 = tonumber(args.IP_1)
	self.IP_2 = tonumber(args.IP_2)
	self.IP_3 = tonumber(args.IP_3)
	self.IP_4 = tonumber(args.IP_4)
	self.IP_5 = tonumber(args.IP_5)
	self.IP_6 = tonumber(args.IP_6)
	self.IP_7 = tonumber(args.IP_7)
	self.IP_8 = tonumber(args.IP_8)
	self.IP_9 = tonumber(args.IP_9)
	self.IP_10 = tonumber(args.IP_10)
	self.IP_11 = tonumber(args.IP_11)
	self.IP_12 = tonumber(args.IP_12)
	self.IP_13 = tonumber(args.IP_13)
	self.IP_14 = tonumber(args.IP_14)
	self.IP_15 = tonumber(args.IP_15)
	self.IP_16 = tonumber(args.IP_16)
	self.IP_17 = tonumber(args.IP_17)
	self.IP_18 = tonumber(args.IP_18)
	self.IP_19 = tonumber(args.IP_19)
	self.IP_20 = tonumber(args.IP_20)
	self.staminaMax = tonumber(args.staminaMax)
	self.staminaMaxOrig = tonumber(args.staminaMax)
	self.staminaRegen = tonumber(args.StaminaRegen)
	self.staminaRegenOrig = tonumber(args.StaminaRegen)
	self.staminaSwim = tonumber(args.StaminaSwim)
	self.staminaSwimOrig = tonumber(args.StaminaSwim)
	self.sprintEnergy = tonumber(args.SprintEnergy)
	self.sprintEnergyOrig = tonumber(args.SprintEnergy)
	self.stuntEnergy = tonumber(args.StuntEnergy)
	self.stuntEnergyOrig = tonumber(args.StuntEnergy)
	self.HealthRegen = tonumber(args.HealthRegen)
	self.HealthRegenOrig = tonumber(args.HealthRegen)
	self.CraftingLevel = tonumber(args.CraftingLevel)
	self.CraftingLevelOrig = tonumber(args.CraftingLevel)
	
	
	Events:Fire("Stamina_Server_Loaded", args)
	----------setting them lol, spam
	LocalPlayer:SetValue("IP_Resets", self.IP_Resets)
	LocalPlayer:SetValue("IP", self.IP)
	LocalPlayer:SetValue("IP_1", self.IP_1)
	LocalPlayer:SetValue("IP_2", self.IP_2)
	LocalPlayer:SetValue("IP_3", self.IP_3)
	LocalPlayer:SetValue("IP_4", self.IP_4)
	LocalPlayer:SetValue("IP_5", self.IP_5)
	LocalPlayer:SetValue("IP_6", self.IP_6)
	LocalPlayer:SetValue("IP_7", self.IP_7)
	LocalPlayer:SetValue("IP_8", self.IP_8)
	LocalPlayer:SetValue("IP_9", self.IP_9)
	LocalPlayer:SetValue("IP_10", self.IP_10)
	LocalPlayer:SetValue("IP_11", self.IP_11)
	LocalPlayer:SetValue("IP_12", self.IP_12)
	LocalPlayer:SetValue("IP_13", self.IP_13)
	LocalPlayer:SetValue("IP_14", self.IP_14)
	LocalPlayer:SetValue("IP_15", self.IP_15)
	LocalPlayer:SetValue("IP_16", self.IP_16)
	LocalPlayer:SetValue("IP_17", self.IP_17)
	LocalPlayer:SetValue("IP_18", self.IP_18)
	LocalPlayer:SetValue("IP_19", self.IP_19)
	LocalPlayer:SetValue("IP_20", self.IP_20)
	local regenstillE = Encrypt(args.regenstill)
	local regenwalkE = Encrypt(args.regenwalk)
	local regenrunE = Encrypt(args.regenrun)
	local regentiredE = Encrypt(args.regentired)
	local regenswimsurfaceE = Encrypt(args.regenswimsurface)
	local regenswimunderE = Encrypt(args.regenswimunder)
	local regenstuntE = Encrypt(args.regenstunt)
	local regenstuntmoveE = Encrypt(args.regenstuntmove)
	local regenstuntmovefastE = Encrypt(args.regenstuntmovefast)
	local regenstuntmoveveryfastE = Encrypt(args.regenstuntmoveveryfast)
	local stuntstaminaE = Encrypt(args.stuntstamina)
	local staminaMaxE = Encrypt(args.staminaMax)
	local StaminaRegenE = Encrypt(args.StaminaRegen)
	local StaminaSwimE = Encrypt(args.StaminaSwim)
	local Melee_Dmg_1E = Encrypt(args.Melee_Dmg_1)
	local Melee_Dmg_2E = Encrypt(args.Melee_Dmg_2)
	local Melee_Sta_1E = Encrypt(args.Melee_Sta_1)
	local Melee_Sta_2E = Encrypt(args.Melee_Sta_2)
	local MaxHealthE = Encrypt(args.MaxHealth)
	local CraftingLevelE = Encrypt(args.CraftingLevel)
	local HealthRegenE = Encrypt(args.HealthRegen)
	local SprintEnergyE = Encrypt(args.SprintEnergy)
	local StuntEnergyE = Encrypt(args.StuntEnergy)
	local ConcealmentE = Encrypt(args.Concealment)
	local PerceptionE = Encrypt(args.Perception)
	local StaminaE = Encrypt(args.Stamina)
	--print("args.Stamina ", args.Stamina)
	LocalPlayer:SetValue("regenstill", regenstillE)
	LocalPlayer:SetValue("regenwalk", regenwalkE)
	LocalPlayer:SetValue("regenrun", regenrunE)
	LocalPlayer:SetValue("regentired", regentiredE)
	LocalPlayer:SetValue("regenswimsurface", regenswimsurfaceE)
	LocalPlayer:SetValue("regenswimunder", regenswimunderE)
	LocalPlayer:SetValue("regenstunt", regenstuntE)
	LocalPlayer:SetValue("regenstuntmove", regenstuntmoveE)
	LocalPlayer:SetValue("regenstuntmovefast", regenstuntmovefastE)
	LocalPlayer:SetValue("regenstuntmoveveryfast", regenstuntmoveveryfastE)
	LocalPlayer:SetValue("stuntstamina", stuntstaminaE)
	LocalPlayer:SetValue("StaminaMax", staminaMaxE)
	LocalPlayer:SetValue("StaminaRegen", StaminaRegenE)
	LocalPlayer:SetValue("StaminaSwim", StaminaSwimE)
	LocalPlayer:SetValue("Melee_Dmg_1", Melee_Dmg_1E)
	LocalPlayer:SetValue("Melee_Dmg_2", Melee_Dmg_2E)
	LocalPlayer:SetValue("Melee_Sta_1", Melee_Sta_1E)
	LocalPlayer:SetValue("Melee_Sta_2", Melee_Sta_2E)
	LocalPlayer:SetValue("MaxHealth", MaxHealthE)
	LocalPlayer:SetValue("CraftingLevel", CraftingLevelE)
	LocalPlayer:SetValue("HealthRegen", HealthRegenE)
	LocalPlayer:SetValue("SprintEnergy", SprintEnergyE)
	LocalPlayer:SetValue("StuntEnergy", StuntEnergyE)
	LocalPlayer:SetValue("Concealment", ConcealmentE)
	LocalPlayer:SetValue("Perception", PerceptionE)
	LocalPlayer:SetValue("Stamina", StaminaE)
else
	self.IP_Resets = tonumber(LocalPlayer:GetValue("IP_Resets"))
	self.IP = tonumber(LocalPlayer:GetValue("IP"))
	self.IP_1 = tonumber(LocalPlayer:GetValue("IP_1"))
	self.IP_2 = tonumber(LocalPlayer:GetValue("IP_2"))
	self.IP_3 = tonumber(LocalPlayer:GetValue("IP_3"))
	self.IP_4 = tonumber(LocalPlayer:GetValue("IP_4"))
	self.IP_5 = tonumber(LocalPlayer:GetValue("IP_5"))
	self.IP_6 = tonumber(LocalPlayer:GetValue("IP_6"))
	self.IP_7 = tonumber(LocalPlayer:GetValue("IP_7"))
	self.IP_8 = tonumber(LocalPlayer:GetValue("IP_8"))
	self.IP_9 = tonumber(LocalPlayer:GetValue("IP_9"))
	self.IP_10 = tonumber(LocalPlayer:GetValue("IP_10"))
	self.IP_11 = tonumber(LocalPlayer:GetValue("IP_11"))
	self.IP_12 = tonumber(LocalPlayer:GetValue("IP_12"))
	self.IP_13 = tonumber(LocalPlayer:GetValue("IP_13"))
	self.IP_15 = tonumber(LocalPlayer:GetValue("IP_15"))
	self.IP_16 = tonumber(LocalPlayer:GetValue("IP_16"))
	self.IP_17 = tonumber(LocalPlayer:GetValue("IP_17"))
	self.IP_18 = tonumber(LocalPlayer:GetValue("IP_18"))
	self.IP_19 = tonumber(LocalPlayer:GetValue("IP_19"))
	self.IP_20 = tonumber(LocalPlayer:GetValue("IP_20"))
	self.staminaMax = Decrypt(LocalPlayer:GetValue("StaminaMax"))
	self.staminaMaxOrig = Decrypt(LocalPlayer:GetValue("StaminaMax"))
	self.staminaRegen = Decrypt(LocalPlayer:GetValue("StaminaRegen"))
	self.staminaRegenOrig = Decrypt(LocalPlayer:GetValue("StaminaRegen"))
	self.staminaSwim = Decrypt(LocalPlayer:GetValue("StaminaSwim"))
	self.staminaSwimOrig = Decrypt(LocalPlayer:GetValue("StaminaSwim"))
	self.sprintEnergy = Decrypt(LocalPlayer:GetValue("SprintEnergy"))
	self.sprintEnergyOrig = Decrypt(LocalPlayer:GetValue("SprintEnergy"))
	self.stuntEnergy = Decrypt(LocalPlayer:GetValue("StuntEnergy"))
	self.stuntEnergyOrig = Decrypt(LocalPlayer:GetValue("StuntEnergy"))
	self.HealthRegen = Decrypt(LocalPlayer:GetValue("HealthRegen"))
	self.HealthRegenOrig = Decrypt(LocalPlayer:GetValue("HealthRegen"))
	self.CraftingLevel = Decrypt(LocalPlayer:GetValue("CraftingLevel"))
	self.CraftingLevelOrig = Decrypt(LocalPlayer:GetValue("CraftingLevel"))
	self.Melee_Sta_1 = Decrypt(LocalPlayer:GetValue("Melee_Sta_1"))
	self.Melee_Sta_1Orig = Decrypt(LocalPlayer:GetValue("Melee_Sta_1"))
end
	LocalPlayer:SetValue("StaminaReady", 1) --activates the stamina hud
	Events:Fire("IP_From_Sql_Fire")
	------------maximum stamina label and buttons
	self.staminaMaxChange = 1 --how much the skill goes up each time the button is pressed
	self.maxStamValueText = Label.Create(self.Window)
	self.maxStamValueText:SetTextColor(Color(255,255,255))
	self.maxStamValueText:SetText(tostring(self.staminaMax))
	self.maxStamValueText:SetPositionRel(Vector2(0.065, 0.04) + self.moveamountguiY1 + self.moveamountguiY2 + (self.moveamountguiX / 2))
	self.maxStamCPI = Label.Create(self.Window)
	self.maxStamCPI:SetText("Cost: "..tostring(self.IP_1))
	self.maxStamCPI:SetPositionRel(Vector2(0.045, 0.165) + self.moveamountguiY1 + self.moveamountguiY2 + (self.moveamountguiX / 2))
	self.maxStamCPI:SetSizeRel(Vector2(1, 1))
	self.maxStamText = Label.Create(self.Window)
	self.maxStamText:SetTextColor(Color(255,255,255))
	self.maxStamText:SetText("Maximum")
	self.maxStamText:SetPositionRel(Vector2(0.041, 0) + self.moveamountguiY1 + self.moveamountguiY2 + (self.moveamountguiX / 2))
	self.maxStamText:SetSizeRel(Vector2(1, 1))
	self.plus_1_b = Button.Create(self.Window)
	self.plus_1_b:SetText("+")
	self.plus_1_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.plus_1_b:SetPositionRel(Vector2(0.09, 0.08) + self.moveamountguiY1 + self.moveamountguiY2 + (self.moveamountguiX / 2))
	self.plus_1_b:Subscribe("Press", self, self.plus_1)
	self.plus_1_b:Subscribe("Press", self, self.Updater)
	self.minus_1_b = Button.Create(self.Window)
	self.minus_1_b:SetText("-")
	self.minus_1_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.minus_1_b:SetPositionRel(Vector2(0.03, 0.08) + self.moveamountguiY1 + self.moveamountguiY2 + (self.moveamountguiX / 2))
	self.minus_1_b:Subscribe("Press", self, self.minus_1)
	self.minus_1_b:Subscribe("Press", self, self.Updater)
	--------------------big stamina title
	self.StamText = Label.Create(self.Window)
	self.StamText:SetTextColor(Color(255,255,255))
	self.StamText:SetText("Stamina")
	self.StamText:SetPositionRel(Vector2(0.08, 0.05))
	self.StamText:SetSizeRel(Vector2(1, 1))
	self.StamText:SetTextSize(25)
	--------------------ip reset text
	self.resetText = Label.Create(self.Window)
	self.resetText:SetTextColor(Color(255,0,0))
	self.resetText:SetText("Reset all IP points?")
	self.resetText:SetPositionRel(Vector2(0.125, 0.2))
	self.resetText:SetSizeRel(Vector2(1, 1))
	self.resetText:SetTextSize(65)
	self.resetText:Hide()
	self.resetText2 = Label.Create(self.Window)
	self.resetText2:SetTextColor(Color(255,0,0))
	self.resetText2:SetText("You will not be able to undo this action.")
	self.resetText2:SetPositionRel(Vector2(0.25, 0.375))
	self.resetText2:SetSizeRel(Vector2(1, 1))
	self.resetText2:SetTextSize(20)
	self.resetText2:Hide()
	self.resetText3 = Label.Create(self.Window)
	self.resetText3:SetTextColor(Color(200,200,200))
	if self.IP_Resets == 1 then
		self.resetText3:SetText(tostring(self.IP_Resets).." IP Reset remaining.")
	else
		self.resetText3:SetText(tostring(self.IP_Resets).." IP Resets remaining.")
	end
	self.resetText3:SetPositionRel(Vector2(0.375, 0.45))
	self.resetText3:SetSizeRel(Vector2(1, 1))
	self.resetText3:SetTextSize(15)
	self.resetText3:Hide()
	--------------------big health title
	self.healthText = Label.Create(self.Window)
	self.healthText:SetTextColor(Color(255,255,255))
	self.healthText:SetText("Health")
	self.healthText:SetPositionRel(Vector2(0.305, 0.05))
	self.healthText:SetSizeRel(Vector2(1, 1))
	self.healthText:SetTextSize(25)
	--------------------big kick 1 title
	self.kick1Text = Label.Create(self.Window)
	self.kick1Text:SetTextColor(Color(255,255,255))
	self.kick1Text:SetText("Spin Kick")
	self.kick1Text:SetPositionRel(Vector2(0.355, 0.48))
	self.kick1Text:SetSizeRel(Vector2(1, 1))
	self.kick1Text:SetTextSize(25)
	--------------------big kick 2 title
	self.kick2Text = Label.Create(self.Window)
	self.kick2Text:SetTextColor(Color(255,255,255))
	self.kick2Text:SetText("Slide Kick")
	self.kick2Text:SetPositionRel(Vector2(0.625, 0.48))
	self.kick2Text:SetSizeRel(Vector2(1, 1))
	self.kick2Text:SetTextSize(25)
	--------------------big crafting title
	self.CraftText = Label.Create(self.Window)
	self.CraftText:SetTextColor(Color(255,255,255))
	self.CraftText:SetText("Crafting")
	self.CraftText:SetPositionRel(Vector2(0.47, 0.05))
	self.CraftText:SetSizeRel(Vector2(1, 1))
	self.CraftText:SetTextSize(25)
	------------stamina regen label and buttons
	self.staminaRegenChange = 1 --how much the skill goes up each time the button is pressed
	self.regenStamValueText = Label.Create(self.Window)
	self.regenStamValueText:SetTextColor(Color(255,255,255))
	self.regenStamValueText:SetText(tostring(self.staminaRegen))
	self.regenStamCPI = Label.Create(self.Window)
	self.regenStamValueText:SetPositionRel(Vector2(0.07, 0.04) + self.moveamountguiY + self.moveamountguiY2)
	self.regenStamCPI:SetText("Cost: "..tostring(self.IP_2))
	self.regenStamCPI:SetPositionRel(Vector2(0.045, 0.165) + self.moveamountguiY + self.moveamountguiY2)
	self.regenStamCPI:SetSizeRel(Vector2(1, 1))
	self.regenStamText = Label.Create(self.Window)
	self.regenStamText:SetTextColor(Color(255,255,255))
	self.regenStamText:SetText("Regeneration")
	self.regenStamText:SetPositionRel(Vector2(0.03, 0) + self.moveamountguiY + self.moveamountguiY2)
	self.regenStamText:SetSizeRel(Vector2(1, 1))
	self.plus_2_b = Button.Create(self.Window)
	self.plus_2_b:SetText("+")
	self.plus_2_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.plus_2_b:SetPositionRel(Vector2(0.09, 0.08) + self.moveamountguiY + self.moveamountguiY2)
	self.plus_2_b:Subscribe("Press", self, self.plus_2)
	self.plus_2_b:Subscribe("Press", self, self.Updater)
	self.minus_2_b = Button.Create(self.Window)
	self.minus_2_b:SetText("-")
	self.minus_2_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.minus_2_b:SetPositionRel(Vector2(0.03, 0.08) + self.moveamountguiY + self.moveamountguiY2)
	self.minus_2_b:Subscribe("Press", self, self.minus_2)
	self.minus_2_b:Subscribe("Press", self, self.Updater)
	------------stamina swim label and buttons
	self.staminaSwimChange = 1 --how much the skill goes up each time the button is pressed
	self.swimStamValueText = Label.Create(self.Window)
	self.swimStamValueText:SetTextColor(Color(255,255,255))
	self.swimStamValueText:SetText(tostring(self.staminaSwim))
	self.swimStamCPI = Label.Create(self.Window)
	self.swimStamValueText:SetPositionRel(Vector2(0.07, 0.04) + (self.moveamountguiY * 1.75) + self.moveamountguiY2)
	self.swimStamCPI:SetText("Cost: "..tostring(self.IP_3))
	self.swimStamCPI:SetPositionRel(Vector2(0.045, 0.165) + (self.moveamountguiY * 1.75) + self.moveamountguiY2)
	self.swimStamCPI:SetSizeRel(Vector2(1, 1))
	self.swimStamText = Label.Create(self.Window)
	self.swimStamText:SetTextColor(Color(255,255,255))
	self.swimStamText:SetText("Swimming")
	self.swimStamText:SetPositionRel(Vector2(0.04, 0) + (self.moveamountguiY * 1.75) + self.moveamountguiY2)
	self.swimStamText:SetSizeRel(Vector2(1, 1))
	self.plus_3_b = Button.Create(self.Window)
	self.plus_3_b:SetText("+")
	self.plus_3_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.plus_3_b:SetPositionRel(Vector2(0.09, 0.08) + (self.moveamountguiY * 1.75) + self.moveamountguiY2)
	self.plus_3_b:Subscribe("Press", self, self.plus_3)
	self.plus_3_b:Subscribe("Press", self, self.Updater)
	self.minus_3_b = Button.Create(self.Window)
	self.minus_3_b:SetText("-")
	self.minus_3_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.minus_3_b:SetPositionRel(Vector2(0.03, 0.08) + (self.moveamountguiY * 1.75) + self.moveamountguiY2)
	self.minus_3_b:Subscribe("Press", self, self.minus_3)
	self.minus_3_b:Subscribe("Press", self, self.Updater)
	------------sprint energy label and buttons
	self.sprintEnergyChange = 1 --how much the skill goes up each time the button is pressed
	self.sprintEnergyValueText = Label.Create(self.Window)
	self.sprintEnergyValueText:SetTextColor(Color(255,255,255))
	self.sprintEnergyValueText:SetText(tostring(self.sprintEnergy))
	self.sprintEnergyCPI = Label.Create(self.Window)
	self.sprintEnergyValueText:SetPositionRel(Vector2(0.07, 0.04) + (self.moveamountguiY * 1.75) + self.moveamountguiY2 + self.moveamountguiX)
	self.sprintEnergyCPI:SetText("Cost: "..tostring(self.IP_4))
	self.sprintEnergyCPI:SetPositionRel(Vector2(0.045, 0.165) + (self.moveamountguiY * 1.75) + self.moveamountguiY2 + self.moveamountguiX)
	self.sprintEnergyCPI:SetSizeRel(Vector2(1, 1))
	self.sprintEnergyText = Label.Create(self.Window)
	self.sprintEnergyText:SetTextColor(Color(255,255,255))
	self.sprintEnergyText:SetText("Sprinting")
	self.sprintEnergyText:SetPositionRel(Vector2(0.0425, 0) + (self.moveamountguiY * 1.75) + self.moveamountguiY2 + self.moveamountguiX)
	self.sprintEnergyText:SetSizeRel(Vector2(1, 1))
	self.plus_4_b = Button.Create(self.Window)
	self.plus_4_b:SetText("+")
	self.plus_4_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.plus_4_b:SetPositionRel(Vector2(0.09, 0.08) + (self.moveamountguiY * 1.75) + self.moveamountguiY2 + self.moveamountguiX)
	self.plus_4_b:Subscribe("Press", self, self.plus_4)
	self.plus_4_b:Subscribe("Press", self, self.Updater)
	self.minus_4_b = Button.Create(self.Window)
	self.minus_4_b:SetText("-")
	self.minus_4_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.minus_4_b:SetPositionRel(Vector2(0.03, 0.08) + (self.moveamountguiY * 1.75) + self.moveamountguiY2 + self.moveamountguiX)
	self.minus_4_b:Subscribe("Press", self, self.minus_4)
	self.minus_4_b:Subscribe("Press", self, self.Updater)
	------------stunt energy label and buttons
	self.stuntEnergyChange = 1 --how much the skill goes up each time the button is pressed
	self.stuntEnergyValueText = Label.Create(self.Window)
	self.stuntEnergyValueText:SetTextColor(Color(255,255,255))
	self.stuntEnergyValueText:SetText(tostring(self.stuntEnergy))
	self.stuntEnergyCPI = Label.Create(self.Window)
	self.stuntEnergyValueText:SetPositionRel(Vector2(0.07, 0.04) + (self.moveamountguiY) + self.moveamountguiY2 + self.moveamountguiX)
	self.stuntEnergyCPI:SetText("Cost: "..tostring(self.IP_5))
	self.stuntEnergyCPI:SetPositionRel(Vector2(0.045, 0.165) + (self.moveamountguiY) + self.moveamountguiY2 + self.moveamountguiX)
	self.stuntEnergyCPI:SetSizeRel(Vector2(1, 1))
	self.stuntEnergyText = Label.Create(self.Window)
	self.stuntEnergyText:SetTextColor(Color(255,255,255))
	self.stuntEnergyText:SetText("Stunting")
	self.stuntEnergyText:SetPositionRel(Vector2(0.045, 0) + (self.moveamountguiY) + self.moveamountguiY2 + self.moveamountguiX)
	self.stuntEnergyText:SetSizeRel(Vector2(1, 1))
	self.plus_5_b = Button.Create(self.Window)
	self.plus_5_b:SetText("+")
	self.plus_5_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.plus_5_b:SetPositionRel(Vector2(0.09, 0.08) + (self.moveamountguiY) + self.moveamountguiY2 + self.moveamountguiX)
	self.plus_5_b:Subscribe("Press", self, self.plus_5)
	self.plus_5_b:Subscribe("Press", self, self.Updater)
	self.minus_5_b = Button.Create(self.Window)
	self.minus_5_b:SetText("-")
	self.minus_5_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.minus_5_b:SetPositionRel(Vector2(0.03, 0.08) + (self.moveamountguiY) + self.moveamountguiY2 + self.moveamountguiX)
	self.minus_5_b:Subscribe("Press", self, self.minus_5)
	self.minus_5_b:Subscribe("Press", self, self.Updater)
	------------health regen label and buttons
	self.HealthRegenChange = 1 --how much the skill goes up each time the button is pressed
	self.HealthRegenValueText = Label.Create(self.Window)
	self.HealthRegenValueText:SetTextColor(Color(255,255,255))
	self.HealthRegenValueText:SetText(tostring(self.HealthRegen))
	self.HealthRegenCPI = Label.Create(self.Window)
	self.HealthRegenValueText:SetPositionRel(Vector2(0.07, 0.04) + self.moveamountguiY1 + self.moveamountguiY2 + self.moveamountguiX2)
	self.HealthRegenCPI:SetText("Cost: "..tostring(self.IP_6))
	self.HealthRegenCPI:SetPositionRel(Vector2(0.040, 0.165) + self.moveamountguiY1 + self.moveamountguiY2 + self.moveamountguiX2)
	self.HealthRegenCPI:SetSizeRel(Vector2(1, 1))
	self.HealthRegenText = Label.Create(self.Window)
	self.HealthRegenText:SetTextColor(Color(255,255,255))
	self.HealthRegenText:SetText("Regeneration")
	self.HealthRegenText:SetPositionRel(Vector2(0.03, 0) + self.moveamountguiY1 + self.moveamountguiY2 + self.moveamountguiX2)
	self.HealthRegenText:SetSizeRel(Vector2(1, 1))
	self.plus_6_b = Button.Create(self.Window)
	self.plus_6_b:SetText("+")
	self.plus_6_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.plus_6_b:SetPositionRel(Vector2(0.09, 0.08) + self.moveamountguiY1 + self.moveamountguiY2 + self.moveamountguiX2)
	self.plus_6_b:Subscribe("Press", self, self.plus_6)
	self.plus_6_b:Subscribe("Press", self, self.Updater)
	self.minus_6_b = Button.Create(self.Window)
	self.minus_6_b:SetText("-")
	self.minus_6_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.minus_6_b:SetPositionRel(Vector2(0.03, 0.08) + self.moveamountguiY1 + self.moveamountguiY2 + self.moveamountguiX2)
	self.minus_6_b:Subscribe("Press", self, self.minus_6)
	self.minus_6_b:Subscribe("Press", self, self.Updater)
	------------crafting level label and buttons
	self.CraftingLevelChange = 1 --how much the skill goes up each time the button is pressed
	self.CraftingLevelValueText = Label.Create(self.Window)
	self.CraftingLevelmove = self.moveamountguiY1 + self.moveamountguiY2 + self.moveamountguiX2 + (self.moveamountguiX2 / 1.5)
	self.CraftingLevelValueText:SetTextColor(Color(255,255,255))
	self.CraftingLevelValueText:SetText(tostring(self.CraftingLevel))
	self.CraftingLevelCPI = Label.Create(self.Window)
	self.CraftingLevelValueText:SetPositionRel(Vector2(0.07, 0.04) + self.CraftingLevelmove)
	self.CraftingLevelCPI:SetText("Cost: "..tostring(self.IP_7))
	self.CraftingLevelCPI:SetPositionRel(Vector2(0.040, 0.165) + self.CraftingLevelmove)
	self.CraftingLevelCPI:SetSizeRel(Vector2(1, 1))
	self.CraftingLevelText = Label.Create(self.Window)
	self.CraftingLevelText:SetTextColor(Color(255,255,255))
	self.CraftingLevelText:SetText("Proficiency")
	self.CraftingLevelText:SetPositionRel(Vector2(0.035, 0) + self.CraftingLevelmove)
	self.CraftingLevelText:SetSizeRel(Vector2(1, 1))
	self.plus_7_b = Button.Create(self.Window)
	self.plus_7_b:SetText("+")
	self.plus_7_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.plus_7_b:SetPositionRel(Vector2(0.09, 0.08) + self.CraftingLevelmove)
	self.plus_7_b:Subscribe("Press", self, self.plus_7)
	self.plus_7_b:Subscribe("Press", self, self.Updater)
	self.minus_7_b = Button.Create(self.Window)
	self.minus_7_b:SetText("-")
	self.minus_7_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.minus_7_b:SetPositionRel(Vector2(0.03, 0.08) + self.CraftingLevelmove)
	self.minus_7_b:Subscribe("Press", self, self.minus_7)
	self.minus_7_b:Subscribe("Press", self, self.Updater)
	------------melee dmg 1 label and buttons
	self.Melee_Dmg_1Change = 1 --how much the skill goes up each time the button is pressed
	self.Melee_Dmg_1ValueText = Label.Create(self.Window)
	self.Melee_Dmg_1move =  self.moveamountguiX2 + (self.moveamountguiY * 1.75) + self.moveamountguiY2
	self.Melee_Dmg_1ValueText:SetTextColor(Color(255,255,255))
	self.Melee_Dmg_1ValueText:SetText(tostring(self.Melee_Dmg_1))
	self.Melee_Dmg_1CPI = Label.Create(self.Window)
	self.Melee_Dmg_1ValueText:SetPositionRel(Vector2(0.07, 0.04) + self.Melee_Dmg_1move)
	self.Melee_Dmg_1CPI:SetText("Cost: "..tostring(self.IP_8))
	self.Melee_Dmg_1CPI:SetPositionRel(Vector2(0.040, 0.165) + self.Melee_Dmg_1move)
	self.Melee_Dmg_1CPI:SetSizeRel(Vector2(1, 1))
	self.Melee_Dmg_1Text = Label.Create(self.Window)
	self.Melee_Dmg_1Text:SetTextColor(Color(255,255,255))
	self.Melee_Dmg_1Text:SetText("Damage")
	self.Melee_Dmg_1Text:SetPositionRel(Vector2(0.045, 0) + self.Melee_Dmg_1move)
	self.Melee_Dmg_1Text:SetSizeRel(Vector2(1, 1))
	self.plus_8_b = Button.Create(self.Window)
	self.plus_8_b:SetText("+")
	self.plus_8_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.plus_8_b:SetPositionRel(Vector2(0.09, 0.08) + self.Melee_Dmg_1move)
	self.plus_8_b:Subscribe("Press", self, self.plus_8)
	self.plus_8_b:Subscribe("Press", self, self.Updater)
	self.minus_8_b = Button.Create(self.Window)
	self.minus_8_b:SetText("-")
	self.minus_8_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.minus_8_b:SetPositionRel(Vector2(0.03, 0.08) + self.Melee_Dmg_1move)
	self.minus_8_b:Subscribe("Press", self, self.minus_8)
	self.minus_8_b:Subscribe("Press", self, self.Updater)
	------------melee stamina 1 label and buttons
	self.Melee_Sta_1Change = 1 --how much the skill goes up each time the button is pressed
	self.Melee_Sta_1ValueText = Label.Create(self.Window)
	self.Melee_Sta_1move =  self.moveamountguiX2 + (self.moveamountguiX2 / 2) + (self.moveamountguiY * 1.75) + self.moveamountguiY2
	self.Melee_Sta_1ValueText:SetTextColor(Color(255,255,255))
	self.Melee_Sta_1ValueText:SetText(tostring(self.Melee_Sta_1))
	self.Melee_Sta_1CPI = Label.Create(self.Window)
	self.Melee_Sta_1ValueText:SetPositionRel(Vector2(0.07, 0.04) + self.Melee_Sta_1move)
	self.Melee_Sta_1CPI:SetText("Cost: "..tostring(self.IP_9))
	self.Melee_Sta_1CPI:SetPositionRel(Vector2(0.040, 0.165) + self.Melee_Sta_1move)
	self.Melee_Sta_1CPI:SetSizeRel(Vector2(1, 1))
	self.Melee_Sta_1Text = Label.Create(self.Window)
	self.Melee_Sta_1Text:SetTextColor(Color(255,255,255))
	self.Melee_Sta_1Text:SetText("Stamina")
	self.Melee_Sta_1Text:SetPositionRel(Vector2(0.045, 0) + self.Melee_Sta_1move)
	self.Melee_Sta_1Text:SetSizeRel(Vector2(1, 1))
	self.plus_9_b = Button.Create(self.Window)
	self.plus_9_b:SetText("+")
	self.plus_9_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.plus_9_b:SetPositionRel(Vector2(0.09, 0.08) + self.Melee_Sta_1move)
	self.plus_9_b:Subscribe("Press", self, self.plus_9)
	self.plus_9_b:Subscribe("Press", self, self.Updater)
	self.minus_9_b = Button.Create(self.Window)
	self.minus_9_b:SetText("-")
	self.minus_9_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.minus_9_b:SetPositionRel(Vector2(0.03, 0.08) + self.Melee_Sta_1move)
	self.minus_9_b:Subscribe("Press", self, self.minus_9)
	self.minus_9_b:Subscribe("Press", self, self.Updater)
	------------melee dmg 2 label and buttons
	self.Melee_Dmg_2Change = 1 --how much the skill goes up each time the button is pressed
	self.Melee_Dmg_2ValueText = Label.Create(self.Window)
	self.Melee_Dmg_2move =  self.moveamountguiX2 + (self.moveamountguiX2) + (self.moveamountguiY * 1.75) + self.moveamountguiY2
	self.Melee_Dmg_2ValueText:SetTextColor(Color(255,255,255))
	self.Melee_Dmg_2ValueText:SetText(tostring(self.Melee_Dmg_2))
	self.Melee_Dmg_2CPI = Label.Create(self.Window)
	self.Melee_Dmg_2ValueText:SetPositionRel(Vector2(0.07, 0.04) + self.Melee_Dmg_2move)
	self.Melee_Dmg_2CPI:SetText("Cost: "..tostring(self.IP_10))
	self.Melee_Dmg_2CPI:SetPositionRel(Vector2(0.040, 0.165) + self.Melee_Dmg_2move)
	self.Melee_Dmg_2CPI:SetSizeRel(Vector2(1, 1))
	self.Melee_Dmg_2Text = Label.Create(self.Window)
	self.Melee_Dmg_2Text:SetTextColor(Color(255,255,255))
	self.Melee_Dmg_2Text:SetText("Damage")
	self.Melee_Dmg_2Text:SetPositionRel(Vector2(0.045, 0) + self.Melee_Dmg_2move)
	self.Melee_Dmg_2Text:SetSizeRel(Vector2(1, 1))
	self.plus_10_b = Button.Create(self.Window)
	self.plus_10_b:SetText("+")
	self.plus_10_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.plus_10_b:SetPositionRel(Vector2(0.09, 0.08) + self.Melee_Dmg_2move)
	self.plus_10_b:Subscribe("Press", self, self.plus_10)
	self.plus_10_b:Subscribe("Press", self, self.Updater)
	self.minus_10_b = Button.Create(self.Window)
	self.minus_10_b:SetText("-")
	self.minus_10_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.minus_10_b:SetPositionRel(Vector2(0.03, 0.08) + self.Melee_Dmg_2move)
	self.minus_10_b:Subscribe("Press", self, self.minus_10)
	self.minus_10_b:Subscribe("Press", self, self.Updater)
	------------melee stamina 2 label and buttons
	self.Melee_Sta_2Change = 1 --how much the skill goes up each time the button is pressed
	self.Melee_Sta_2ValueText = Label.Create(self.Window)
	self.Melee_Sta_2move =  self.moveamountguiX2 + (self.moveamountguiX2 * 1.5) + (self.moveamountguiY * 1.75) + self.moveamountguiY2
	self.Melee_Sta_2ValueText:SetTextColor(Color(255,255,255))
	self.Melee_Sta_2ValueText:SetText(tostring(self.Melee_Sta_2))
	self.Melee_Sta_2CPI = Label.Create(self.Window)
	self.Melee_Sta_2ValueText:SetPositionRel(Vector2(0.07, 0.04) + self.Melee_Sta_2move)
	self.Melee_Sta_2CPI:SetText("Cost: "..tostring(self.IP_10))
	self.Melee_Sta_2CPI:SetPositionRel(Vector2(0.040, 0.165) + self.Melee_Sta_2move)
	self.Melee_Sta_2CPI:SetSizeRel(Vector2(1, 1))
	self.Melee_Sta_2Text = Label.Create(self.Window)
	self.Melee_Sta_2Text:SetTextColor(Color(255,255,255))
	self.Melee_Sta_2Text:SetText("Stamina")
	self.Melee_Sta_2Text:SetPositionRel(Vector2(0.045, 0) + self.Melee_Sta_2move)
	self.Melee_Sta_2Text:SetSizeRel(Vector2(1, 1))
	self.plus_11_b = Button.Create(self.Window)
	self.plus_11_b:SetText("+")
	self.plus_11_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.plus_11_b:SetPositionRel(Vector2(0.09, 0.08) + self.Melee_Sta_2move)
	self.plus_11_b:Subscribe("Press", self, self.plus_11)
	self.plus_11_b:Subscribe("Press", self, self.Updater)
	self.minus_11_b = Button.Create(self.Window)
	self.minus_11_b:SetText("-")
	self.minus_11_b:SetSize(Vector2(self.sizeX / 75, self.sizeX / 75))
	self.minus_11_b:SetPositionRel(Vector2(0.03, 0.08) + self.Melee_Sta_2move)
	self.minus_11_b:Subscribe("Press", self, self.minus_11)
	self.minus_11_b:Subscribe("Press", self, self.Updater)
	------------save button and label
	self.savebutton = Button.Create(self.Window)
	self.savebutton:SetText("Apply Changes")
	self.savebutton:SetSizeRel(Vector2(0.125, 0.075))
	self.savebutton:SetPositionRel(Vector2(0.85, 0.825))
	self.savebutton:SetTextColor(Color(0,255,255))
	self.savebutton:Subscribe("Press", self, self.savebutton_f)
	self.savebutton:Hide()
	------------ip reset button
	self.ipreset = Button.Create(self.Window)
	self.ipreset:SetText("Reset IP")
	self.ipreset:SetSizeRel(Vector2(0.09, 0.06))
	self.ipreset:SetPositionRel(Vector2(0.825, 0.1))
	self.ipreset:Subscribe("Press", self, self.resetbutton)
	self.ipreset:SetTextNormalColor(Color(255,0,0,255))
	self.ipreset:SetTextHoveredColor(Color(255,0,0,255))
	self.ipreset:SetTextPressedColor(Color(255,0,0,255))
	------------help button
	self.help = Button.Create(self.Window)
	self.help:SetText("Help")
	self.help:SetTextSize(15)
	self.help:SetSizeRel(Vector2(0.1, 0.07))
	self.help:SetPositionRel(Vector2(0.65, 0.025))
	self.help:Subscribe("Press", self, self.helpbutton)
	--------- help text
	self.staminaHelpText = Label.Create(self.Window)
	self.staminaHelpText:SetTextColor(Color(255,255,255))
	self.staminaHelpText:SetText("Raising Maximum Stamina will\nincrease the total amount of\nstamina you have.\n\nRaising Stamina Regeneration\nwill increase how quickly\nyour stamina regenerates.\n\nRaising swimming, stunting, or\nsprinting will decrease the\nstamina needed for those\nactions.\n\n---------------------------------------------------\n\nEach time you raise a skill,\nthe cost increases by two.\n\nWhen a cost is green, you\nhave enough IP to raise it.\n\nWhen a cost is red, you do not\nhave enough IP to raise it.")
	self.staminaHelpText:SetPositionRel(Vector2(0.03, 0.125))
	self.staminaHelpText:SetSizeRel(Vector2(1, 1))
	self.hpHelpText = Label.Create(self.Window)
	self.hpHelpText:SetTextColor(Color(255,255,255))
	self.hpHelpText:SetText("Raising Health\nRegeneration\nwill slowly bring\nyour health\nback to full\nwhen you are\nout of combat.")
	self.hpHelpText:SetPositionRel(Vector2(0.3, 0.125))
	self.hpHelpText:SetSizeRel(Vector2(1, 1))
	self.craftHelpText = Label.Create(self.Window)
	self.craftHelpText:SetTextColor(Color(255,255,255))
	self.craftHelpText:SetText("Raising Crafting\nProficiency will\nmake you able\nto craft better\nitems.")
	self.craftHelpText:SetPositionRel(Vector2(0.47, 0.125))
	self.craftHelpText:SetSizeRel(Vector2(1, 1))
	self.kick1HelpText = Label.Create(self.Window)
	self.kick1HelpText:SetTextColor(Color(255,255,255))
	self.kick1HelpText:SetText("Used by pressing Q.\n\nRaising the damage will increase\nthe damage of the kick.  Every 15\npoints in damage will add an\nadditional effect to the kick.\n\nRaising the stamina will decrease\nthe stamina needed to kick.")
	self.kick1HelpText:SetPositionRel(Vector2(0.295, 0.57))
	self.kick1HelpText:SetSizeRel(Vector2(1, 1))
	self.kick2HelpText = Label.Create(self.Window)
	self.kick2HelpText:SetTextColor(Color(255,255,255))
	self.kick2HelpText:SetText("Used by pressing Q while running.\n\nRaising the damage will increase\nthe damage of the kick.  Every 15\npoints in damage will add an\nadditional effect to the kick.\n\nRaising the stamina will decrease\nthe stamina needed to kick.")
	self.kick2HelpText:SetPositionRel(Vector2(0.575, 0.57))
	self.kick2HelpText:SetSizeRel(Vector2(1, 1))
	self.ipresetHelpText = Label.Create(self.Window)
	self.ipresetHelpText:SetTextColor(Color(255,255,255))
	self.ipresetHelpText:SetText("If you have at least one\nIP Reset, the button will\nappear here. Using an IP\nReset will set all skills to\nzero and refund all the IP\nused.\n\nOne IP Reset is gained\nevery 25 levels.")
	self.ipresetHelpText:SetPositionRel(Vector2(0.795, 0.11))
	self.ipresetHelpText:SetSizeRel(Vector2(1, 1))
	self.saveHelpText = Label.Create(self.Window)
	self.saveHelpText:SetTextColor(Color(255,255,255))
	self.saveHelpText:SetText('When you have\nraised a skill, it will\nturn blue. Hit the\n"Apply Changes"\nbutton to save.\n\nIf saved correctly,\nthe skill will turn\nwhite again and you\nwill receive a chat\nmessage.\n\nThe "Apply Changes"\nbutton will appear\ndown here once you\nhave made changes.')
	self.saveHelpText:SetPositionRel(Vector2(0.835, 0.44))
	self.saveHelpText:SetSizeRel(Vector2(1, 1))
	self.nosaveHelpText = Label.Create(self.Window)
	self.nosaveHelpText:SetTextColor(Color(255,255,255))
	self.nosaveHelpText:SetText("If you have changes\nthat you do not want\nto save, simply exit the\nmenu by pressing 'U'\nor clicking the X.\n\nYou cannot lower skills\nbelow their saved\namounts.")
	self.nosaveHelpText:SetPositionRel(Vector2(0.61, 0.125))
	self.nosaveHelpText:SetSizeRel(Vector2(1, 1))
	-- 4real
	self.ipresetreal = Button.Create(self.Window)
	self.ipresetreal:SetText("I understand, reset my IP anyway.")
	self.ipresetreal:SetTextSize(35)
	self.ipresetreal:SetSizeRel(Vector2(0.8, 0.25))
	self.ipresetreal:SetPositionRel(Vector2(0.09, 0.6))
	self.ipresetreal:Subscribe("Press", self, self.resetbuttonreal)
	self.ipresetreal:SetTextNormalColor(Color(255,0,0,255))
	self.ipresetreal:SetTextHoveredColor(Color(255,0,0,255))
	self.ipresetreal:SetTextPressedColor(Color(255,0,0,255))
	self.ipresetreal:Hide()
	------------ip label
	self.ipText = Label.Create(self.Window)
	self.ipText:SetTextColor(Color(255,255,255))
	self.ipText:SetText("IP: "..tostring(self.IP))
	self.ipText:SetPositionRel(Vector2(0.8, 0))
	self.ipText:SetSizeRel(Vector2(0.8, 0.8))
	self.ipText:SetTextSize(30)
	self.open = false
	
	self.Window:Subscribe("PostRender", self, self.Render)
	--Network:Subscribe("IP_Changed", self, self.Changed)
	Events:Subscribe("KeyDown", self, self.Open)
	self.Window:Subscribe("WindowClosed", self, self.Close)
	Network:Subscribe("IP_Change", self, self.Update)
	--Network:Subscribe("IP_Hax", self, self.HackIP)
end
function AddHelp()
    Events:Fire( "HelpAddItem",
        {
            name = "IP",
            text = 
                "IP is short for Influence Points, which are points gained each level that can be "..
                "used to upgrade your abilities.  You can open the IP menu by pressing U. " ..
                "When you gain a level, you also gain IP equal to that level."..
				"Once you make desired increases of your abilities, hit the 'Apply Changes' button "..
				"to confirm and save them. Once saved, you cannot decrease your abilities. There is "..
				"additional help available in the actual IP menu."
        } )
end

function RemoveHelp()
    Events:Fire( "HelpRemoveItem",
        {
            name = "IP"
        } )
end

Events:Subscribe("ModulesLoad", AddHelp)
Events:Subscribe("ModuleUnload", RemoveHelp)
function IP_Menu:HackIP(amt)
	if amt then
		--LocalPlayer:SetValue("IP", amt)
	end
end
function Decrypt(value)
	if value then
		value = tonumber(Crypt34(tostring(value)))
		return value
	end
end
function Encrypt(value)
	if value then
		value = Crypt34(tostring(value))
		return value
	end
end
function IP_Menu:XOut()
	if not self.Window:GetVisible() and self.open then
		self.open = false
		Mouse:SetVisible(false)
	end
end
function IP_Menu:ShowGUI()
	self.saveHelpText:Hide()
	self.nosaveHelpText:Hide()
	self.ipresetHelpText:Hide()
	self.kick2HelpText:Hide()
	self.kick1HelpText:Hide()
	self.craftHelpText:Hide()
	self.staminaHelpText:Hide()
	self.hpHelpText:Hide()
	self.resetText3:Hide()
	self.ipresetreal:Hide()
	self.resetText:Hide()
	self.resetText2:Hide()
	self.minus_1_b:Show()
	self.minus_2_b:Show()
	self.minus_3_b:Show()
	self.minus_4_b:Show()
	self.minus_5_b:Show()
	self.minus_6_b:Show()
	self.minus_7_b:Show()
	self.minus_8_b:Show()
	self.minus_9_b:Show()
	self.minus_10_b:Show()
	self.minus_11_b:Show()
	self.savebutton:Show()
	self.plus_1_b:Show()
	self.plus_2_b:Show()
	self.plus_3_b:Show()
	self.plus_4_b:Show()
	self.plus_5_b:Show()
	self.plus_6_b:Show()
	self.plus_7_b:Show()
	self.plus_8_b:Show()
	self.plus_9_b:Show()
	self.plus_10_b:Show()
	self.plus_11_b:Show()
	self.savebutton:Show()
	self.ipText:Show()
	self.Melee_Sta_2ValueText:Show()
	self.Melee_Sta_2CPI:Show()
	self.Melee_Sta_2Text:Show()
	self.StamText:Show()
	self.healthText:Show()
	self.CraftText:Show()
	self.kick1Text:Show()
	self.kick2Text:Show()
	self.Melee_Sta_1ValueText:Show()
	self.Melee_Sta_1CPI:Show()
	self.Melee_Sta_1Text:Show()
	self.Melee_Dmg_1ValueText:Show()
	self.Melee_Dmg_1CPI:Show()
	self.Melee_Dmg_1Text:Show()
	self.Melee_Dmg_2ValueText:Show()
	self.Melee_Dmg_2CPI:Show()
	self.Melee_Dmg_2Text:Show()
	self.CraftingLevelValueText:Show()
	self.CraftingLevelCPI:Show()
	self.CraftingLevelText:Show()
	self.HealthRegenValueText:Show()
	self.HealthRegenCPI:Show()
	self.HealthRegenText:Show()
	self.stuntEnergyValueText:Show()
	self.stuntEnergyCPI:Show()
	self.stuntEnergyText:Show()
	self.sprintEnergyValueText:Show()
	self.sprintEnergyCPI:Show()
	self.sprintEnergyText:Show()
	self.swimStamValueText:Show()
	self.swimStamCPI:Show()
	self.swimStamText:Show()
	self.maxStamValueText:Show()
	self.maxStamCPI:Show()
	self.maxStamText:Show()
	self.regenStamValueText:Show()
	self.regenStamCPI:Show()
	self.regenStamText:Show()
end
function IP_Menu:HideGUI()
	self.minus_1_b:Hide()
	self.minus_2_b:Hide()
	self.minus_3_b:Hide()
	self.minus_4_b:Hide()
	self.minus_5_b:Hide()
	self.minus_6_b:Hide()
	self.minus_7_b:Hide()
	self.minus_8_b:Hide()
	self.minus_9_b:Hide()
	self.minus_10_b:Hide()
	self.minus_11_b:Hide()
	self.savebutton:Hide()
	self.plus_1_b:Hide()
	self.plus_2_b:Hide()
	self.plus_3_b:Hide()
	self.plus_4_b:Hide()
	self.plus_5_b:Hide()
	self.plus_6_b:Hide()
	self.plus_7_b:Hide()
	self.plus_8_b:Hide()
	self.plus_9_b:Hide()
	self.plus_10_b:Hide()
	self.plus_11_b:Hide()
	self.ipText:Hide()
	self.Melee_Sta_2ValueText:Hide()
	self.Melee_Sta_2CPI:Hide()
	self.Melee_Sta_2Text:Hide()
	self.StamText:Hide()
	self.healthText:Hide()
	self.CraftText:Hide()
	self.kick1Text:Hide()
	self.kick2Text:Hide()
	self.Melee_Sta_1ValueText:Hide()
	self.Melee_Sta_1CPI:Hide()
	self.Melee_Sta_1Text:Hide()
	self.Melee_Dmg_1ValueText:Hide()
	self.Melee_Dmg_1CPI:Hide()
	self.Melee_Dmg_1Text:Hide()
	self.Melee_Dmg_2ValueText:Hide()
	self.Melee_Dmg_2CPI:Hide()
	self.Melee_Dmg_2Text:Hide()
	self.CraftingLevelValueText:Hide()
	self.CraftingLevelCPI:Hide()
	self.CraftingLevelText:Hide()
	self.HealthRegenValueText:Hide()
	self.HealthRegenCPI:Hide()
	self.HealthRegenText:Hide()
	self.stuntEnergyValueText:Hide()
	self.stuntEnergyCPI:Hide()
	self.stuntEnergyText:Hide()
	self.sprintEnergyValueText:Hide()
	self.sprintEnergyCPI:Hide()
	self.sprintEnergyText:Hide()
	self.swimStamValueText:Hide()
	self.swimStamCPI:Hide()
	self.swimStamText:Hide()
	self.maxStamValueText:Hide()
	self.maxStamCPI:Hide()
	self.maxStamText:Hide()
	self.regenStamValueText:Hide()
	self.regenStamCPI:Hide()
	self.regenStamText:Hide()
end
function IP_Menu:resetbutton()
	IP_Menu:HideGUI()
	self.render = 0
	self.help:Hide()
	self.ipreset:Hide()
	self.resetText:Show()
	self.resetText2:Show()
	self.ipresetreal:Show()
	self.resetText3:Show()
	if self.IP_Resets == 1 then
		self.resetText3:SetText(tostring(self.IP_Resets).." IP Reset remaining.")
	elseif self.IP_Resets then
		self.resetText3:SetText(tostring(self.IP_Resets).." IP Resets remaining.")
	end
end
function IP_Menu:helpbutton()
	if self.helpopen == 0 then
		self.helpopen = 1
		IP_Menu:HideGUI()
		self.ipreset:Hide()
		self.ipText:Show()
		self.StamText:Show()
		self.healthText:Show()
		self.CraftText:Show()
		self.kick1Text:Show()
		self.kick2Text:Show()
		self.staminaHelpText:Show()
		self.hpHelpText:Show()
		self.craftHelpText:Show()
		self.kick1HelpText:Show()
		self.kick2HelpText:Show()
		self.ipresetHelpText:Show()
		self.saveHelpText:Show()
		self.nosaveHelpText:Show()
		self.help:SetText("Back")
	else
		if self.IP_Resets then
			if tonumber(self.IP_Resets) > 0 then
				self.ipreset:Show()
			else
				self.ipreset:Hide()
			end
		else
			self.ipreset:Hide()
		end
		self.helpopen = 0
		self.help:SetText("Help")
		IP_Menu:ShowGUI()
		--print("self.IP ", self.IP)
		if self.IP ~= tonumber(LocalPlayer:GetValue("IP")) then
			self.savebutton:Show()
		else
			self.savebutton:Hide()
		end
	end
end
function IP_Menu:resetbuttonreal()
	Network:Send("IP_Reset")
	self.resetText:Hide()
	self.resetText2:Hide()
	self.ipresetreal:Hide()
	self.resetText3:Hide()
	IP_Menu:ShowGUI()
	self.render = 1
end
function IP_Menu:savebutton_f()
	local IP_get = LocalPlayer:GetValue("IP")
	local staminaMax_get1 = LocalPlayer:GetValue("StaminaMax")
	local staminaRegen_get1 = LocalPlayer:GetValue("StaminaRegen")
	local staminaSwim_get1 = LocalPlayer:GetValue("StaminaSwim")
	local staminaSwim_get1 = LocalPlayer:GetValue("SprintEnergy")
	local stuntEnergy_get1 = LocalPlayer:GetValue("StuntEnergy")
	local HealthRegen_get1 = LocalPlayer:GetValue("HealthRegen")
	local CraftingLevel_get1 = LocalPlayer:GetValue("CraftingLevel")
	local Melee_Dmg_11 = LocalPlayer:GetValue("Melee_Dmg_1")
	local Melee_Sta_11 = LocalPlayer:GetValue("Melee_Sta_1")
	local Melee_Dmg_21 = LocalPlayer:GetValue("Melee_Dmg_2")
	local Melee_Sta_21 = LocalPlayer:GetValue("Melee_Sta_2")
	local staminaMax_get = Decrypt(staminaMax_get1)
	local staminaRegen_get = Decrypt(staminaRegen_get1)
	local staminaSwim_get = Decrypt(staminaSwim_get1)
	local sprintEnergy_get = Decrypt(sprintEnergy_get1)
	local stuntEnergy_get = Decrypt(stuntEnergy_get1)
	local HealthRegen_get = Decrypt(HealthRegen_get1)
	local CraftingLevel_get = Decrypt(CraftingLevel_get1)
	local Melee_Dmg_1_get = Decrypt(Melee_Dmg_11)
	local Melee_Sta_1_get = Decrypt(Melee_Sta_11)
	local Melee_Dmg_2_get = Decrypt(Melee_Dmg_21)
	local Melee_Sta_2_get = Decrypt(Melee_Sta_21)
	if tonumber(IP_get) >= self.IP
	and self.staminaMax ~= staminaMax_get
	or self.staminaRegen ~= staminaRegen_get
	or self.staminaSwim ~= staminaSwim_get 
	or self.sprintEnergy ~= sprintEnergy_get 
	or self.HealthRegen ~= HealthRegen_get 
	or self.CraftingLevel ~= CraftingLevel_get 
	or self.Melee_Dmg_1 ~= Melee_Dmg_1_get 
	or self.Melee_Sta_1 ~= Melee_Sta_1_get 
	or self.Melee_Dmg_2 ~= Melee_Dmg_2_get 
	or self.Melee_Sta_2 ~= Melee_Sta_2_get 
	or self.stuntEnergy ~= stuntEnergy_get then
		local args = {}
		args.IP = self.IP
		args.staminaMax = self.staminaMax
		args.staminaRegen = self.staminaRegen
		args.staminaSwim = self.staminaSwim
		args.sprintEnergy = self.sprintEnergy
		args.stuntEnergy = self.stuntEnergy
		args.HealthRegen = self.HealthRegen
		args.CraftingLevel = self.CraftingLevel
		args.Melee_Dmg_1 = self.Melee_Dmg_1
		args.Melee_Sta_1 = self.Melee_Sta_1
		args.Melee_Dmg_2 = self.Melee_Dmg_2
		--print("Melee_Sta_2", self.Melee_Sta_2)
		args.Melee_Sta_2 = self.Melee_Sta_2
		Network:Send("IP_Save", args)
		self.savebutton:Hide()
		args = nil --delete args so no one can get the goods
	else
		Chat:Print("You must have changes to save!", self.red)
	end
end
function IP_Menu:Update(args)
--fired when the player saves and the server send info back
	if args.IP_Resets then
		LocalPlayer:SetValue("IP_Resets", args.IP_Resets)
	end
	if not self.IP_Resets then
		self.IP_Resets = 0
	else
		self.IP_Resets = LocalPlayer:GetValue("IP_Resets")
	end
	LocalPlayer:SetValue("IP", args.IP)
	LocalPlayer:SetValue("IP_1", args.IP_1)
	LocalPlayer:SetValue("IP_2", args.IP_2)
	LocalPlayer:SetValue("IP_3", args.IP_3)
	LocalPlayer:SetValue("IP_4", args.IP_4)
	LocalPlayer:SetValue("IP_5", args.IP_5)
	LocalPlayer:SetValue("IP_6", args.IP_6)
	LocalPlayer:SetValue("IP_7", args.IP_7)
	LocalPlayer:SetValue("IP_8", args.IP_8)
	LocalPlayer:SetValue("IP_9", args.IP_9)
	LocalPlayer:SetValue("IP_10", args.IP_10)
	LocalPlayer:SetValue("IP_11", args.IP_11)
	LocalPlayer:SetValue("IP_12", args.IP_12)
	LocalPlayer:SetValue("IP_13", args.IP_13)
	LocalPlayer:SetValue("IP_14", args.IP_14)
	LocalPlayer:SetValue("IP_15", args.IP_15)
	LocalPlayer:SetValue("IP_16", args.IP_16)
	LocalPlayer:SetValue("IP_17", args.IP_17)
	LocalPlayer:SetValue("IP_18", args.IP_18)
	LocalPlayer:SetValue("IP_19", args.IP_19)
	LocalPlayer:SetValue("IP_20", args.IP_20)
	local estaminaMax = Encrypt(args.staminaMax)
	local eStaminaRegen = Encrypt(args.StaminaRegen)
	local eStaminaSwim = Encrypt(args.StaminaSwim)
	local eMelee_Dmg_1 = Encrypt(args.Melee_Dmg_1)
	local eMelee_Dmg_2 = Encrypt(args.Melee_Dmg_2)
	local eMelee_Sta_1 = Encrypt(args.Melee_Sta_1)
	local eMelee_Sta_2 = Encrypt(args.Melee_Sta_2)
	local eMaxHealth = Encrypt(args.MaxHealth)
	local eCraftingLevel = Encrypt(args.CraftingLevel)
	local eHealthRegen = Encrypt(args.HealthRegen)
	local eSprintEnergy = Encrypt(args.SprintEnergy)
	local eStuntEnergy = Encrypt(args.StuntEnergy)
	local eConcealment = Encrypt(args.Concealment)
	local ePerception = Encrypt(args.Perception)
	LocalPlayer:SetValue("StaminaMax", estaminaMax)
	LocalPlayer:SetValue("StaminaRegen", eStaminaRegen)
	LocalPlayer:SetValue("StaminaSwim", eStaminaSwim)
	LocalPlayer:SetValue("Melee_Dmg_1", eMelee_Dmg_1)
	LocalPlayer:SetValue("Melee_Dmg_2", eMelee_Dmg_2)
	LocalPlayer:SetValue("Melee_Sta_1", eMelee_Sta_1)
	LocalPlayer:SetValue("Melee_Sta_2", eMelee_Sta_2)
	LocalPlayer:SetValue("MaxHealth", eMaxHealth)
	LocalPlayer:SetValue("CraftingLevel", eCraftingLevel)
	LocalPlayer:SetValue("HealthRegen", eHealthRegen)
	LocalPlayer:SetValue("SprintEnergy", eSprintEnergy)
	LocalPlayer:SetValue("StuntEnergy", eStuntEnergy)
	LocalPlayer:SetValue("Concealment", eConcealment)
	LocalPlayer:SetValue("Perception", ePerception)
	self.IP_Resets = tonumber(args.IP_Resets)
	self.IP = tonumber(args.IP)
	self.IP_1 = tonumber(args.IP_1)
	self.IP_2 = tonumber(args.IP_2)
	self.IP_3 = tonumber(args.IP_3)
	self.IP_4 = tonumber(args.IP_4)
	self.IP_5 = tonumber(args.IP_5)
	self.IP_6 = tonumber(args.IP_6)
	self.IP_7 = tonumber(args.IP_7)
	self.IP_8 = tonumber(args.IP_8)
	self.IP_9 = tonumber(args.IP_9)
	self.IP_10 = tonumber(args.IP_10)
	self.IP_11 = tonumber(args.IP_11)
	self.IP_12 = tonumber(args.IP_12)
	self.IP_13 = tonumber(args.IP_13)
	self.IP_14 = tonumber(args.IP_14)
	self.IP_15 = tonumber(args.IP_15)
	self.IP_16 = tonumber(args.IP_16)
	self.IP_17 = tonumber(args.IP_17)
	self.IP_18 = tonumber(args.IP_18)
	self.IP_19 = tonumber(args.IP_19)
	self.IP_20 = tonumber(args.IP_20)
	self.staminaMax = tonumber(args.staminaMax)
	self.staminaMaxOrig = tonumber(args.staminaMax)
	self.staminaRegen = tonumber(args.StaminaRegen)
	self.staminaRegenOrig = tonumber(args.StaminaRegen)
	self.staminaSwim = tonumber(args.StaminaSwim)
	self.staminaSwimOrig = tonumber(args.StaminaSwim)
	self.sprintEnergy = tonumber(args.SprintEnergy)
	self.sprintEnergyOrig = tonumber(args.SprintEnergy)
	self.stuntEnergy = tonumber(args.StuntEnergy)
	self.stuntEnergyOrig = tonumber(args.StuntEnergy)
	self.HealthRegen = tonumber(args.HealthRegen)
	self.HealthRegenOrig = tonumber(args.HealthRegen)
	self.CraftingLevel = tonumber(args.CraftingLevel)
	self.CraftingLevelOrig = tonumber(args.CraftingLevel)
	self.Melee_Dmg_1 = tonumber(args.Melee_Dmg_1)
	self.Melee_Dmg_1Orig = tonumber(args.Melee_Dmg_1)
	self.Melee_Sta_1 = tonumber(args.Melee_Sta_1)
	self.Melee_Sta_1Orig = tonumber(args.Melee_Sta_1)
	self.Melee_Dmg_2 = tonumber(args.Melee_Dmg_2)
	self.Melee_Dmg_2Orig = tonumber(args.Melee_Dmg_2)
	self.Melee_Sta_2 = tonumber(args.Melee_Sta_2)
	self.Melee_Sta_2Orig = tonumber(args.Melee_Sta_2)
	IP_Menu:Updater()
	self.savebutton:Hide()
end
function IP_Menu:plus_11()
	if self.IP - self.IP_11 >= 0 then
		self.IP = self.IP - self.IP_11
		self.Melee_Sta_2 = self.Melee_Sta_2 + self.Melee_Sta_2Change
		local Melee_Sta_2New = self.Melee_Sta_2 --upgraded skill value
		local Melee_Sta_2Diff = Melee_Sta_2New - self.Melee_Sta_2 --how much the value has changed
		local Melee_Sta_2ChangeDiff = Melee_Sta_2Diff / self.Melee_Sta_2Change --how much IP was spent
		if tonumber(self.IP_11) < 2 then --if first time, keep it even
			self.IP_11 = self.IP_11 + (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_11 = self.IP_11 + self.changeperincrease
		end
		self.Melee_Sta_2ValueText:SetText(tostring(self.Melee_Sta_2))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.Melee_Sta_2CPI:SetText("Cost: "..tostring(self.IP_11))
	end
end
function IP_Menu:plus_10()
	if self.IP - self.IP_10 >= 0 then
		self.IP = self.IP - self.IP_10
		self.Melee_Dmg_2 = self.Melee_Dmg_2 + self.Melee_Dmg_2Change
		local Melee_Dmg_2New = self.Melee_Dmg_2 --upgraded skill value
		local Melee_Dmg_2Diff = Melee_Dmg_2New - self.Melee_Dmg_2 --how much the value has changed
		local Melee_Dmg_2ChangeDiff = Melee_Dmg_2Diff / self.Melee_Dmg_2Change --how much IP was spent
		if tonumber(self.IP_10) < 2 then --if first time, keep it even
			self.IP_10 = self.IP_10 + (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_10 = self.IP_10 + self.changeperincrease
		end
		self.Melee_Dmg_2ValueText:SetText(tostring(self.Melee_Dmg_2))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.Melee_Dmg_2CPI:SetText("Cost: "..tostring(self.IP_10))
	end
end
function IP_Menu:plus_9()
	if self.IP - self.IP_9 >= 0 then
		self.IP = self.IP - self.IP_9
		self.Melee_Sta_1 = self.Melee_Sta_1 + self.Melee_Sta_1Change
		local Melee_Sta_1New = self.Melee_Sta_1 --upgraded skill value
		local Melee_Sta_1Diff = Melee_Sta_1New - self.Melee_Sta_1 --how much the value has changed
		local Melee_Sta_1ChangeDiff = Melee_Sta_1Diff / self.Melee_Sta_1Change --how much IP was spent
		if tonumber(self.IP_9) < 2 then --if first time, keep it even
			self.IP_9 = self.IP_9 + (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_9 = self.IP_9 + self.changeperincrease
		end
		self.Melee_Sta_1ValueText:SetText(tostring(self.Melee_Sta_1))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.Melee_Sta_1CPI:SetText("Cost: "..tostring(self.IP_9))
	end
end
function IP_Menu:plus_8()
	if self.IP - self.IP_8 >= 0 then
		self.IP = self.IP - self.IP_8
		self.Melee_Dmg_1 = self.Melee_Dmg_1 + self.Melee_Dmg_1Change
		local Melee_Dmg_1New = self.Melee_Dmg_1 --upgraded skill value
		local Melee_Dmg_1Diff = Melee_Dmg_1New - self.Melee_Dmg_1 --how much the value has changed
		local Melee_Dmg_1ChangeDiff = Melee_Dmg_1Diff / self.Melee_Dmg_1Change --how much IP was spent
		if tonumber(self.IP_8) < 2 then --if first time, keep it even
			self.IP_8 = self.IP_8 + (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_8 = self.IP_8 + self.changeperincrease
		end
		self.Melee_Dmg_1ValueText:SetText(tostring(self.Melee_Dmg_1))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.Melee_Dmg_1CPI:SetText("Cost: "..tostring(self.IP_8))
	end
end
function IP_Menu:plus_7()
	if self.IP - self.IP_7 >= 0 then
		self.IP = self.IP - self.IP_7
		self.CraftingLevel = self.CraftingLevel + self.CraftingLevelChange
		local CraftingLevelNew = self.CraftingLevel --upgraded skill value
		local CraftingLevelDiff = CraftingLevelNew - self.CraftingLevel --how much the value has changed
		local CraftingLevelChangeDiff = CraftingLevelDiff / self.CraftingLevelChange --how much IP was spent
		if tonumber(self.IP_7) < 2 then --if first time, keep it even
			self.IP_7 = self.IP_7 + (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_7 = self.IP_7 + self.changeperincrease
		end
		self.CraftingLevelValueText:SetText(tostring(self.CraftingLevel))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.CraftingLevelCPI:SetText("Cost: "..tostring(self.IP_7))
	end
end
function IP_Menu:plus_6()
	if self.IP - self.IP_6 >= 0 then
		self.IP = self.IP - self.IP_6
		self.HealthRegen = self.HealthRegen + self.HealthRegenChange
		local HealthRegenNew = self.HealthRegen --upgraded skill value
		local HealthRegenDiff = HealthRegenNew - self.HealthRegen --how much the value has changed
		local HealthRegenChangeDiff = HealthRegenDiff / self.HealthRegenChange --how much IP was spent
		if tonumber(self.IP_6) < 2 then --if first time, keep it even
			self.IP_6 = self.IP_6 + (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_6 = self.IP_6 + self.changeperincrease
		end
		self.HealthRegenValueText:SetText(tostring(self.HealthRegen))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.HealthRegenCPI:SetText("Cost: "..tostring(self.IP_6))
	end
end
function IP_Menu:plus_5()
	if self.IP - self.IP_5 >= 0 then
		self.IP = self.IP - self.IP_5
		self.stuntEnergy = self.stuntEnergy + self.stuntEnergyChange
		local stuntEnergyNew = self.stuntEnergy --upgraded skill value
		local stuntEnergyDiff = stuntEnergyNew - self.stuntEnergy --how much the value has changed
		local stuntEnergyChangeDiff = stuntEnergyDiff / self.stuntEnergyChange --how much IP was spent
		if tonumber(self.IP_5) < 2 then --if first time, keep it even
			self.IP_5 = self.IP_5 + (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_5 = self.IP_5 + self.changeperincrease
		end
		self.stuntEnergyValueText:SetText(tostring(self.stuntEnergy))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.stuntEnergyCPI:SetText("Cost: "..tostring(self.IP_5))
	end
end
function IP_Menu:plus_4()
	if self.IP - self.IP_4 >= 0 then
		self.IP = self.IP - self.IP_4
		self.sprintEnergy = self.sprintEnergy + self.sprintEnergyChange
		local sprintEnergyNew = self.sprintEnergy --upgraded skill value
		local sprintEnergyDiff = sprintEnergyNew - self.sprintEnergy --how much the value has changed
		local sprintEnergyChangeDiff = sprintEnergyDiff / self.sprintEnergyChange --how much IP was spent
		if tonumber(self.IP_4) < 2 then --if first time, keep it even
			self.IP_4 = self.IP_4 + (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_4 = self.IP_4 + self.changeperincrease
		end
		self.sprintEnergyValueText:SetText(tostring(self.sprintEnergy))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.sprintEnergyCPI:SetText("Cost: "..tostring(self.IP_4))
	end
end
function IP_Menu:plus_3()
	if self.IP - self.IP_3 >= 0 then
		self.IP = self.IP - self.IP_3
		self.staminaSwim = self.staminaSwim + self.staminaSwimChange
		local staminaSwimNew = self.staminaSwim --upgraded skill value
		local staminaSwimDiff = staminaSwimNew - self.staminaSwim --how much the value has changed
		local staminaSwimChangeDiff = staminaSwimDiff / self.staminaSwimChange --how much IP was spent
		if tonumber(self.IP_3) < 2 then --if first time, keep it even
			self.IP_3 = self.IP_3 + (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_3 = self.IP_3 + self.changeperincrease
		end
		self.swimStamValueText:SetText(tostring(self.staminaSwim))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.swimStamCPI:SetText("Cost: "..tostring(self.IP_3))
	end
end
function IP_Menu:plus_2()
	if self.IP - self.IP_2 >= 0 then
		self.IP = self.IP - self.IP_2
		self.staminaRegen = self.staminaRegen + self.staminaRegenChange
		local staminaRegenNew = self.staminaRegen --upgraded skill value
		local staminaRegenDiff = staminaRegenNew - self.staminaRegen --how much the value has changed
		local staminaRegenChangeDiff = staminaRegenDiff / self.staminaRegenChange --how much IP was spent
		if tonumber(self.IP_2) < 2 then --if first time, keep it even
			self.IP_2 = self.IP_2 + (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_2 = self.IP_2 + self.changeperincrease
		end
		self.regenStamValueText:SetText(tostring(self.staminaRegen))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.regenStamCPI:SetText("Cost: "..tostring(self.IP_2))
	end
end
function IP_Menu:plus_1()
	if self.IP - self.IP_1 >= 0 then
		self.IP = self.IP - self.IP_1
		self.staminaMax = self.staminaMax + self.staminaMaxChange
		local staminaMaxNew = tonumber(self.staminaMax) --upgraded skill value
		local staminaMaxDiff = staminaMaxNew - self.staminaMax --how much the value has changed
		local staminaMaxChangeDiff = staminaMaxDiff / self.staminaMaxChange --how much IP was spent
		if tonumber(self.IP_1) < 2 then --if first time, keep it even
			self.IP_1 = self.IP_1 + (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_1 = self.IP_1 + self.changeperincrease
		end
		self.maxStamValueText:SetText(tostring(self.staminaMax))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.maxStamCPI:SetText("Cost: "..tostring(self.IP_1))
	end
end
-------------------MINUS BUTTONS BEGIN
function IP_Menu:minus_11()
	if self.Melee_Sta_2 - self.Melee_Sta_2Change >= self.Melee_Sta_2Orig then
		if self.IP_11 == 2 then --if first time, keep it even
			self.IP_11 = self.IP_11 - (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_11 = self.IP_11 - self.changeperincrease
		end
		self.IP = self.IP + self.IP_11
		self.Melee_Sta_2 = self.Melee_Sta_2 - self.Melee_Sta_2Change
		self.Melee_Sta_2ValueText:SetText(tostring(self.Melee_Sta_2))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.Melee_Sta_2CPI:SetText("Cost: "..tostring(self.IP_11))
	end
end
function IP_Menu:minus_10()
	if self.Melee_Dmg_2 - self.Melee_Dmg_2Change >= self.Melee_Dmg_2Orig then
		if self.IP_10 == 2 then --if first time, keep it even
			self.IP_10 = self.IP_10 - (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_10 = self.IP_10 - self.changeperincrease
		end
		self.IP = self.IP + self.IP_10
		self.Melee_Dmg_2 = self.Melee_Dmg_2 - self.Melee_Dmg_2Change
		self.Melee_Dmg_2ValueText:SetText(tostring(self.Melee_Dmg_2))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.Melee_Dmg_2CPI:SetText("Cost: "..tostring(self.IP_10))
	end
end
function IP_Menu:minus_9()
	if self.Melee_Sta_1 - self.Melee_Sta_1Change >= self.Melee_Sta_1Orig then
		if self.IP_9 == 2 then --if first time, keep it even
			self.IP_9 = self.IP_9 - (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_9 = self.IP_9 - self.changeperincrease
		end
		self.IP = self.IP + self.IP_9
		self.Melee_Sta_1 = self.Melee_Sta_1 - self.Melee_Sta_1Change
		self.Melee_Sta_1ValueText:SetText(tostring(self.Melee_Sta_1))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.Melee_Sta_1CPI:SetText("Cost: "..tostring(self.IP_9))
	end
end
function IP_Menu:minus_8()
	if self.Melee_Dmg_1 - self.Melee_Dmg_1Change >= self.Melee_Dmg_1Orig then
		if self.IP_8 == 2 then --if first time, keep it even
			self.IP_8 = self.IP_8 - (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_8 = self.IP_8 - self.changeperincrease
		end
		self.IP = self.IP + self.IP_8
		self.Melee_Dmg_1 = self.Melee_Dmg_1 - self.Melee_Dmg_1Change
		self.Melee_Dmg_1ValueText:SetText(tostring(self.Melee_Dmg_1))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.Melee_Dmg_1CPI:SetText("Cost: "..tostring(self.IP_8))
	end
end
function IP_Menu:minus_7()
	if self.CraftingLevel - self.CraftingLevelChange >= self.CraftingLevelOrig then
		if self.IP_7 == 2 then --if first time, keep it even
			self.IP_7 = self.IP_7 - (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_7 = self.IP_7 - self.changeperincrease
		end
		self.IP = self.IP + self.IP_7
		self.CraftingLevel = self.CraftingLevel - self.CraftingLevelChange
		self.CraftingLevelValueText:SetText(tostring(self.CraftingLevel))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.CraftingLevelCPI:SetText("Cost: "..tostring(self.IP_7))
	end
end
function IP_Menu:minus_6()
	if self.HealthRegen - self.HealthRegenChange >= self.HealthRegenOrig then
		if self.IP_6 == 2 then --if first time, keep it even
			self.IP_6 = self.IP_6 - (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_6 = self.IP_6 - self.changeperincrease
		end
		self.IP = self.IP + self.IP_6
		self.HealthRegen = self.HealthRegen - self.HealthRegenChange
		self.HealthRegenValueText:SetText(tostring(self.HealthRegen))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.HealthRegenCPI:SetText("Cost: "..tostring(self.IP_6))
	end
end
function IP_Menu:minus_5()
	if self.stuntEnergy - self.stuntEnergyChange >= self.stuntEnergyOrig then
		if self.IP_5 == 2 then --if first time, keep it even
			self.IP_5 = self.IP_5 - (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_5 = self.IP_5 - self.changeperincrease
		end
		self.IP = self.IP + self.IP_5
		self.stuntEnergy = self.stuntEnergy - self.stuntEnergyChange
		self.stuntEnergyValueText:SetText(tostring(self.stuntEnergy))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.stuntEnergyCPI:SetText("Cost: "..tostring(self.IP_5))
	end
end
function IP_Menu:minus_4()
	if self.sprintEnergy - self.sprintEnergyChange >= self.sprintEnergyOrig then
		if self.IP_4 == 2 then --if first time, keep it even
			self.IP_4 = self.IP_4 - (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_4 = self.IP_4 - self.changeperincrease
		end
		self.IP = self.IP + self.IP_4
		self.sprintEnergy = self.sprintEnergy - self.sprintEnergyChange
		self.sprintEnergyValueText:SetText(tostring(self.sprintEnergy))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.sprintEnergyCPI:SetText("Cost: "..tostring(self.IP_4))
	end
end
function IP_Menu:minus_3()
	if self.staminaSwim - self.staminaSwimChange >= self.staminaSwimOrig then
		if self.IP_3 == 2 then --if first time, keep it even
			self.IP_3 = self.IP_3 - (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_3 = self.IP_3 - self.changeperincrease
		end
		self.IP = self.IP + self.IP_3
		self.staminaSwim = self.staminaSwim - self.staminaSwimChange
		self.swimStamValueText:SetText(tostring(self.staminaSwim))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.swimStamCPI:SetText("Cost: "..tostring(self.IP_3))
	end
end
function IP_Menu:minus_2()
	if self.staminaRegen - self.staminaRegenChange >= self.staminaRegenOrig then
		if self.IP_2 == 2 then --if first time, keep it even
			self.IP_2 = self.IP_2 - (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_2 = self.IP_2 - self.changeperincrease
		end
		self.IP = self.IP + self.IP_2
		self.staminaRegen = self.staminaRegen - self.staminaRegenChange
		self.regenStamValueText:SetText(tostring(self.staminaRegen))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.regenStamCPI:SetText("Cost: "..tostring(self.IP_1))
	end
end
function IP_Menu:minus_1()
	if self.staminaMax - self.staminaMaxChange >= self.staminaMaxOrig then
		if self.IP_1 == 2 then --if first time, keep it even
			self.IP_1 = self.IP_1 - (self.changeperincrease / self.changeperincrease)
		else --otherwise add 2 to the cost each time
			self.IP_1 = self.IP_1 - self.changeperincrease
		end
		self.IP = self.IP + self.IP_1
		self.staminaMax = self.staminaMax - self.staminaMaxChange
		self.maxStamValueText:SetText(tostring(self.staminaMax))
		self.ipText:SetText("IP: "..tostring(self.IP))
		self.maxStamCPI:SetText("Cost: "..tostring(self.IP_1))
	end
end
function IP_Menu:RestrictMovement()
	if self.open then --if it's open then you can't move or fire, etc
		--Mouse:SetVisible(true)
		return false
	--else
		--Mouse:SetVisible(false)
	end
end
function IP_Menu:Updater()
		--reload and rerender the values for everything to keep up to date
		--for some reason it doesn't like to decrypt
		------------------------------------------------------
		--self.ipText:SetText("IP: "..tostring(self.IP))
		if self.IP - self.IP_1 >= 0 then
			self.maxStamCPI:SetTextColor(self.green)
		else
			self.maxStamCPI:SetTextColor(self.red)
		end
		if self.IP - self.IP_2 >= 0 then
			self.regenStamCPI:SetTextColor(self.green)
		else
			self.regenStamCPI:SetTextColor(self.red)
		end
		if self.IP - self.IP_3 >= 0 then
			self.swimStamCPI:SetTextColor(self.green)
		else
			self.swimStamCPI:SetTextColor(self.red)
		end
		if self.IP - self.IP_4 >= 0 then
			self.sprintEnergyCPI:SetTextColor(self.green)
		else
			self.sprintEnergyCPI:SetTextColor(self.red)
		end
		if self.IP - self.IP_5 >= 0 then
			self.stuntEnergyCPI:SetTextColor(self.green)
		else
			self.stuntEnergyCPI:SetTextColor(self.red)
		end
		if self.IP - self.IP_6 >= 0 then
			self.HealthRegenCPI:SetTextColor(self.green)
		else
			self.HealthRegenCPI:SetTextColor(self.red)
		end
		if self.IP - self.IP_7 >= 0 then
			self.CraftingLevelCPI:SetTextColor(self.green)
		else
			self.CraftingLevelCPI:SetTextColor(self.red)
		end
		if self.IP - self.IP_8 >= 0 then
			self.Melee_Dmg_1CPI:SetTextColor(self.green)
		else
			self.Melee_Dmg_1CPI:SetTextColor(self.red)
		end
		if self.IP - self.IP_9 >= 0 then
			self.Melee_Sta_1CPI:SetTextColor(self.green)
		else
			self.Melee_Sta_1CPI:SetTextColor(self.red)
		end
		if self.IP - self.IP_10 >= 0 then
			self.Melee_Dmg_2CPI:SetTextColor(self.green)
		else
			self.Melee_Dmg_2CPI:SetTextColor(self.red)
		end
		if self.IP - self.IP_11 >= 0 then
			self.Melee_Sta_2CPI:SetTextColor(self.green)
		else
			self.Melee_Sta_2CPI:SetTextColor(self.red)
		end
		if self.staminaRegen == self.staminaRegenOrig then --if they didn't spend on max stam
			self.regenStamValueText:SetTextColor(self.white)
			self.regenStamText:SetTextColor(self.white)
		else
			self.regenStamValueText:SetTextColor(self.lightblue)
			self.regenStamText:SetTextColor(self.lightblue)
		end
		if self.staminaMax == self.staminaMaxOrig then --if they didn't spend on stam regen
			self.maxStamValueText:SetTextColor(self.white)
			self.maxStamText:SetTextColor(self.white)
		else
			self.maxStamValueText:SetTextColor(self.lightblue)
			self.maxStamText:SetTextColor(self.lightblue)
		end
		if self.staminaSwim == self.staminaSwimOrig then --if they didn't spend on stam swim
			self.swimStamValueText:SetTextColor(self.white)
			self.swimStamText:SetTextColor(self.white)
		else
			self.swimStamValueText:SetTextColor(self.lightblue)
			self.swimStamText:SetTextColor(self.lightblue)
		end
		if self.sprintEnergy == self.sprintEnergyOrig then --if they didn't spend on stam swim
			self.sprintEnergyValueText:SetTextColor(self.white)
			self.sprintEnergyText:SetTextColor(self.white)
		else
			self.sprintEnergyValueText:SetTextColor(self.lightblue)
			self.sprintEnergyText:SetTextColor(self.lightblue)
		end
		if self.stuntEnergy == self.stuntEnergyOrig then --if they didn't spend on stam swim
			self.stuntEnergyValueText:SetTextColor(self.white)
			self.stuntEnergyText:SetTextColor(self.white)
		else
			self.stuntEnergyValueText:SetTextColor(self.lightblue)
			self.stuntEnergyText:SetTextColor(self.lightblue)
		end
		if self.HealthRegen == self.HealthRegenOrig then --if they didn't spend on stam swim
			self.HealthRegenValueText:SetTextColor(self.white)
			self.HealthRegenText:SetTextColor(self.white)
		else
			self.HealthRegenValueText:SetTextColor(self.lightblue)
			self.HealthRegenText:SetTextColor(self.lightblue)
		end
		if self.CraftingLevel == self.CraftingLevelOrig then --if they didn't spend on stam swim
			self.CraftingLevelValueText:SetTextColor(self.white)
			self.CraftingLevelText:SetTextColor(self.white)
		else
			self.CraftingLevelValueText:SetTextColor(self.lightblue)
			self.CraftingLevelText:SetTextColor(self.lightblue)
		end
		if self.Melee_Dmg_1 == self.Melee_Dmg_1Orig then --if they didn't spend on stam swim
			self.Melee_Dmg_1ValueText:SetTextColor(self.white)
			self.Melee_Dmg_1Text:SetTextColor(self.white)
		else
			self.Melee_Dmg_1ValueText:SetTextColor(self.lightblue)
			self.Melee_Dmg_1Text:SetTextColor(self.lightblue)
		end
		if self.Melee_Sta_1 == self.Melee_Sta_1Orig then --if they didn't spend on stam swim
			self.Melee_Sta_1ValueText:SetTextColor(self.white)
			self.Melee_Sta_1Text:SetTextColor(self.white)
		else
			self.Melee_Sta_1ValueText:SetTextColor(self.lightblue)
			self.Melee_Sta_1Text:SetTextColor(self.lightblue)
		end
		if self.Melee_Dmg_2 == self.Melee_Dmg_2Orig then --if they didn't spend on stam swim
			self.Melee_Dmg_2ValueText:SetTextColor(self.white)
			self.Melee_Dmg_2Text:SetTextColor(self.white)
		else
			self.Melee_Dmg_2ValueText:SetTextColor(self.lightblue)
			self.Melee_Dmg_2Text:SetTextColor(self.lightblue)
		end
		if self.Melee_Sta_2 == self.Melee_Sta_2Orig then --if they didn't spend on stam swim
			self.Melee_Sta_2ValueText:SetTextColor(self.white)
			self.Melee_Sta_2Text:SetTextColor(self.white)
		else
			self.Melee_Sta_2ValueText:SetTextColor(self.lightblue)
			self.Melee_Sta_2Text:SetTextColor(self.lightblue)
		end
		local IP_get = tonumber(LocalPlayer:GetValue("IP"))
		if self.IP ~= IP_get and self.open then --save button manager, shows if ip has been spent
			self.savebutton:Show()
		end
		if self.IP == IP_get and self.open then --save button manager, shows if ip has been spent
			self.savebutton:Hide()
		end
		if self.IP_Resets == 1 then
			self.resetText3:SetText(tostring(self.IP_Resets).." IP Reset remaining.")
		elseif self.IP_Resets then
			self.resetText3:SetText(tostring(self.IP_Resets).." IP Resets remaining.")
		end
		self.maxStamCPI:SetText("Cost: "..tostring(self.IP_1))
		self.regenStamCPI:SetText("Cost: "..tostring(self.IP_2))
		self.swimStamCPI:SetText("Cost: "..tostring(self.IP_3))
		self.sprintEnergyCPI:SetText("Cost: "..tostring(self.IP_4))
		self.stuntEnergyCPI:SetText("Cost: "..tostring(self.IP_5))
		self.HealthRegenCPI:SetText("Cost: "..tostring(self.IP_6))
		self.CraftingLevelCPI:SetText("Cost: "..tostring(self.IP_7))
		self.Melee_Dmg_1CPI:SetText("Cost: "..tostring(self.IP_8))
		self.Melee_Sta_1CPI:SetText("Cost: "..tostring(self.IP_9))
		self.Melee_Dmg_2CPI:SetText("Cost: "..tostring(self.IP_10))
		self.Melee_Sta_2CPI:SetText("Cost: "..tostring(self.IP_11))
		
		if self.IP_Resets then
			if tonumber(self.IP_Resets) > 0 then
				self.ipreset:Show()
			else
				self.ipreset:Hide()
			end
		else
			self.ipreset:Hide()
		end
		self.help:Show()
		self.help:SetText("Help")
		self.ipText:SetText("IP: "..tostring(self.IP))
		
		self.maxStamValueText:SetText(tostring(self.staminaMax))
		self.regenStamValueText:SetText(tostring(self.staminaRegen))
		self.swimStamValueText:SetText(tostring(self.staminaSwim))
		self.sprintEnergyValueText:SetText(tostring(self.sprintEnergy))
		self.stuntEnergyValueText:SetText(tostring(self.stuntEnergy))
		self.HealthRegenValueText:SetText(tostring(self.HealthRegen))
		self.CraftingLevelValueText:SetText(tostring(self.CraftingLevel))
		self.Melee_Dmg_1ValueText:SetText(tostring(self.Melee_Dmg_1))
		self.Melee_Sta_1ValueText:SetText(tostring(self.Melee_Sta_1))
		self.Melee_Dmg_2ValueText:SetText(tostring(self.Melee_Dmg_2))
		self.Melee_Sta_2ValueText:SetText(tostring(self.Melee_Sta_2))
end
function IP_Menu:Render()
	if self.open and self.render ~= 0 then
		self.position = self.Window:GetPosition()
		-- stamina
		self.stampos1 = self.position + Vector2(self.sizeX / 150, self.sizeY / 33)
		self.stampos2 = Vector2(self.sizeX / 333, self.sizeY / 3)
		self.stampos3 = Vector2(self.sizeX / 9.75, self.sizeY / 190)
		self.stampos1b = self.stampos1 + self.stampos2 + self.stampos3
		self.stampos2b = self.stampos2 + Vector2(0, self.sizeY / 190)
		self.stampos3b = self.stampos3 + Vector2(self.sizeX / 333, 0)
		-- health
		self.healthpos1 = self.position + Vector2(self.sizeX / 8.66, self.sizeY / 33)
		self.healthpos2 = Vector2(self.sizeX / 333, self.sizeY / 6.66)
		self.healthpos3 = Vector2(self.sizeX / 18, self.sizeY / 190)
		self.healthpos1b = self.healthpos1 + self.healthpos2 + self.healthpos3
		self.healthpos2b = self.healthpos2 + Vector2(0, self.sizeY / 190)
		self.healthpos3b = self.healthpos3 + Vector2(self.sizeX / 333, 0)
		-- crafting
		self.craftpos1 = self.position + Vector2(self.sizeX / 5.38, self.sizeY / 33)
		self.craftpos2 = Vector2(self.sizeX / 333, self.sizeY / 6.66)
		self.craftpos3 = Vector2(self.sizeX / 18, self.sizeY / 190)
		self.craftpos1b = self.craftpos1 + self.craftpos2 + self.craftpos3
		self.craftpos2b = self.craftpos2 + Vector2(0, self.sizeY / 190)
		self.craftpos3b = self.craftpos3 + Vector2(self.sizeX / 333, 0)
		-- kick 1
		self.kick1pos1 = self.position + Vector2(self.sizeX / 8.66, self.sizeY / 5)
		self.kick1pos2 = Vector2(self.sizeX / 333, self.sizeY / 6.1)
		self.kick1pos3 = Vector2(self.sizeX / 9.5, self.sizeY / 190)
		self.kick1pos1b = self.kick1pos1 + self.kick1pos2 + self.kick1pos3
		self.kick1pos2b = self.kick1pos2 + Vector2(0, self.sizeY / 190)
		self.kick1pos3b = self.kick1pos3 + Vector2(self.sizeX / 333, 0)
		-- kick 2
		self.kick2pos1 = self.position + Vector2(self.sizeX / 4.4, self.sizeY / 5)
		self.kick2pos2 = Vector2(self.sizeX / 333, self.sizeY / 6.1)
		self.kick2pos3 = Vector2(self.sizeX / 9.5, self.sizeY / 190)
		self.kick2pos1b = self.kick2pos1 + self.kick2pos2 + self.kick2pos3
		self.kick2pos2b = self.kick2pos2 + Vector2(0, self.sizeY / 190)
		self.kick2pos3b = self.kick2pos3 + Vector2(self.sizeX / 333, 0)
		-- ip
		self.ippos1 = self.position + Vector2(self.sizeX / 3.1, self.sizeY / 20)
		self.ippos2 = Vector2(self.sizeX / 14, self.sizeY / 300)
		-- other
		self.whiteColor = Color(255,255,255,255)
		self.stamColor = Color(255,171,74,255)
		self.healthColor = Color(255,84,84,255)
		self.craftColor = Color(89,189,119,255)
		self.kick1Color = Color(0,190,255,255)
		self.kick2Color = Color(225,116,237,255)
		-- stamina
		Render:FillArea(self.stampos1, self.stampos2, self.stamColor) --left line
		Render:FillArea(self.stampos1, self.stampos3, self.stamColor) --top line
		Render:FillArea(self.stampos1b, -self.stampos2b, self.stamColor) --right line
		Render:FillArea(self.stampos1b, -self.stampos3b, self.stamColor) --bottom line
		-- hp
		Render:FillArea(self.healthpos1, self.healthpos2, self.healthColor) --left line
		Render:FillArea(self.healthpos1, self.healthpos3, self.healthColor) --top line
		Render:FillArea(self.healthpos1b, -self.healthpos2b, self.healthColor) --right line
		Render:FillArea(self.healthpos1b, -self.healthpos3b, self.healthColor) --bottom line
		-- crafting
		Render:FillArea(self.craftpos1, self.craftpos2, self.craftColor) --left line
		Render:FillArea(self.craftpos1, self.craftpos3, self.craftColor) --top line
		Render:FillArea(self.craftpos1b, -self.craftpos2b, self.craftColor) --right line
		Render:FillArea(self.craftpos1b, -self.craftpos3b, self.craftColor) --bottom line
		-- kick1
		Render:FillArea(self.kick1pos1, self.kick1pos2, self.kick1Color) --left line
		Render:FillArea(self.kick1pos1, self.kick1pos3, self.kick1Color) --top line
		Render:FillArea(self.kick1pos1b, -self.kick1pos2b, self.kick1Color) --right line
		Render:FillArea(self.kick1pos1b, -self.kick1pos3b, self.kick1Color) --bottom line
		-- kick2
		Render:FillArea(self.kick2pos1, self.kick2pos2, self.kick2Color) --left line
		Render:FillArea(self.kick2pos1, self.kick2pos3, self.kick2Color) --top line
		Render:FillArea(self.kick2pos1b, -self.kick2pos2b, self.kick2Color) --right line
		Render:FillArea(self.kick2pos1b, -self.kick2pos3b, self.kick2Color) --bottom line
		-- ip
		Render:FillArea(self.ippos1, self.ippos2, self.whiteColor)
	end
end
function IP_Menu:Open(args)
		if args.key == string.byte("U") and not self.open then
		self.IP_Resets = tonumber(LocalPlayer:GetValue("IP_Resets"))
		self.render = 1
		if not self.IP_Resets then
			self.IP_Resets = 0
		end
		self.helpopen = 0
		IP_Menu:ShowGUI()
		self.RestrictEvent = Events:Subscribe("LocalPlayerInput", self, self.RestrictMovement)
		self.IP = LocalPlayer:GetValue("IP")
		self.IP_1 = LocalPlayer:GetValue("IP_1")
		self.IP_2 = LocalPlayer:GetValue("IP_2")
		self.IP_3 = LocalPlayer:GetValue("IP_3")
		self.IP_4 = LocalPlayer:GetValue("IP_4")
		self.IP_5 = LocalPlayer:GetValue("IP_5")
		self.IP_6 = LocalPlayer:GetValue("IP_6")
		self.IP_7 = LocalPlayer:GetValue("IP_7")
		self.IP_8 = LocalPlayer:GetValue("IP_8")
		self.IP_9 = LocalPlayer:GetValue("IP_9")
		self.IP_10 = LocalPlayer:GetValue("IP_10")
		self.IP_11 = LocalPlayer:GetValue("IP_11")
		self.IP_12 = LocalPlayer:GetValue("IP_12")
		self.IP_13 = LocalPlayer:GetValue("IP_13")
		self.IP_14 = LocalPlayer:GetValue("IP_14")
		self.IP_15 = LocalPlayer:GetValue("IP_15")
		self.IP_16 = LocalPlayer:GetValue("IP_16")
		self.IP_17 = LocalPlayer:GetValue("IP_17")
		self.IP_18 = LocalPlayer:GetValue("IP_18")
		self.IP_19 = LocalPlayer:GetValue("IP_19")
		self.IP_20 = LocalPlayer:GetValue("IP_20")
		local staminaMax1 = LocalPlayer:GetValue("StaminaMax")
		local staminaRegen1 = LocalPlayer:GetValue("StaminaRegen")
		local staminaSwim1 = LocalPlayer:GetValue("StaminaSwim")
		local sprintEnergy1 = LocalPlayer:GetValue("SprintEnergy")
		local stuntEnergy1 = LocalPlayer:GetValue("StuntEnergy")
		local HealthRegen1 = LocalPlayer:GetValue("HealthRegen")
		local CraftingLevel1 = LocalPlayer:GetValue("CraftingLevel")
		local Melee_Dmg_11 = LocalPlayer:GetValue("Melee_Dmg_1")
		local Melee_Sta_11 = LocalPlayer:GetValue("Melee_Sta_1")
		local Melee_Dmg_21 = LocalPlayer:GetValue("Melee_Dmg_2")
		local Melee_Sta_21 = LocalPlayer:GetValue("Melee_Sta_2")
		self.staminaMax = Decrypt(staminaMax1)
		self.staminaMaxOrig = Decrypt(staminaMax1)
		self.staminaRegen = Decrypt(staminaRegen1)
		self.staminaRegenOrig = Decrypt(staminaRegen1)
		self.staminaSwim = Decrypt(staminaSwim1)
		self.staminaSwimOrig = Decrypt(staminaSwim1)
		self.sprintEnergy = Decrypt(sprintEnergy1)
		self.sprintEnergyOrig = Decrypt(sprintEnergy1)
		self.stuntEnergy = Decrypt(stuntEnergy1)
		self.stuntEnergyOrig = Decrypt(stuntEnergy1)
		self.HealthRegen = Decrypt(HealthRegen1)
		self.HealthRegenOrig = Decrypt(HealthRegen1)
		self.CraftingLevel = Decrypt(CraftingLevel1)
		self.CraftingLevelOrig = Decrypt(CraftingLevel1)
		self.Melee_Dmg_1 = Decrypt(Melee_Dmg_11)
		self.Melee_Dmg_1Orig = Decrypt(Melee_Dmg_11)
		self.Melee_Sta_1 = Decrypt(Melee_Sta_11)
		self.Melee_Sta_1Orig = Decrypt(Melee_Sta_11)
		self.Melee_Dmg_2 = Decrypt(Melee_Dmg_21)
		self.Melee_Dmg_2Orig = Decrypt(Melee_Dmg_21)
		self.Melee_Sta_2 = Decrypt(Melee_Sta_21)
		self.Melee_Sta_2Orig = Decrypt(Melee_Sta_21)
		self.ipText:SetText("IP: "..tostring(self.IP))
		IP_Menu:Updater()
		self.Window:SetSize(self.windowsize)
		self.Window:SetPosition(self.windowpos)
		self.Window:Show()
		self.open = true
		self.savebutton:Hide()
		Mouse:SetVisible(true)
	elseif args.key == string.byte("U") and self.open then
		Mouse:SetVisible(false)
		self.Window:Hide()
		self.open = false
		self.savebutton:Hide()
	end
end
function IP_Menu:Close()
	self.open = false
	Mouse:SetVisible(false)
	--self.Window:Hide()
	self.open = false
	Events:Unsubscribe(self.RestrictEvent)
end
function subs(args)
	--print("go")
	IP_Menu = IP_Menu(args)
end
Network:Subscribe("IP_From_Sql", subs)
function LocalPlayerChatIP(args)
	if args.text == "/ipmenu" then
		--IP_Menu:ShowGUI()
		--self.open = true
		--self.render = 1
	end
end
Events:Subscribe("LocalPlayerChat", LocalPlayerChatIP)