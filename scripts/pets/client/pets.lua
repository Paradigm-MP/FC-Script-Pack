class 'Pets'
function Pets:__init()
	self.petobjs = {}
	self.petpositionslerp = Vector3(0,0,0)
	self.petstate = "GUARD"
	self.target = LocalPlayer
	self.randompos = {}
	self.removeids = {}
	self.fx = {}
	self.lightfx = {}
	self.items = {} --table of all items
	for item, canbefound in pairs(inlootbox) do
		if canbefound == true then
			table.insert(self.items, item)
		end
	end
	self.guardOtherTimer = Timer()
	self.hotkeyTimer = Timer()
	self.ticks = 0
	self.redseconds = 0
	self.blueseconds = 0
	self.viewdistance = 800
	self.petsnear = 0
	self.distance = 5000 --increase for smoother movement and more delay, decrease for opposite
	self.speed = 5 --increase for slow smooth, increase for fast jagged
	self.spiritmovement = Vector3(0,0,0)
	
	--GUI SETUP STARTS NOW
	
	self.maxcharacters = 24
	self.open = false
	self.openkey = 'H'
	self.green = Color(0,255,0)
	self.white = Color(255,255,255)
	self.red = Color(255,0,0)
	self.lightblue = Color(0,255,255)
	--MAIN WINDOW WITH BUTTONS
	self.controlWindow = Window.Create()
	self.controlWindow:Hide()
	self.sizeX = Render.Size.x
	self.sizeY = Render.Size.y
	self.windowpos = Vector2(self.sizeX / 1.75, 0)
	self.windowsize = Vector2(self.sizeX / 4, self.sizeY / 5)
	self.controlWindow:SetSize(self.windowsize)
	self.controlWindow:SetPosition(self.windowpos)
	self.controlWindow:SetTitle("Pet Control Panel (Press '"..self.openkey.."' to collapse)")
	self.controlWindowPos = self.controlWindow:GetPositionRel()
	
	--SMALL WINDOW WITH JUST STATS
	self.statsWindow = Window.Create()
	--self.statsWindow:Hide()
	self.windowposStats = Vector2(self.sizeX / 1.75, 0)
	self.windowsizeStats = Vector2(self.sizeX / 7, self.sizeY / 9)
	self.statsWindow:SetSize(self.windowsizeStats)
	self.statsWindow:Hide()
	self.statsWindow:SetPosition(self.windowposStats)
	self.statsWindow:SetTitle("Pet Information (Press '"..self.openkey.."' to expand)")
	self.statsWindowPos = self.statsWindow:GetPositionRel()
	
	self.guardButton = Button.Create(self.controlWindow)
	self.guardButton:SetText("Guard")
	self.guardButton:SetSizeRel(Vector2(0.2, 0.2))
	self.guardButton:SetTextSize(20)
	self.guardButton:SetPositionRel(Vector2(0.15, 0.55))
	self.guardButton:Subscribe("Press", self, self.guardButtonF)
	self.guardButton:SetTextNormalColor(self.white)
	self.guardButton:SetTextPressedColor(self.green)
	self.guardButton:SetToggleState(true)
	self.guardButton:SetToggleable(true)
	
	self.followButton = Button.Create(self.controlWindow)
	self.followButton:SetText("Follow")
	self.followButton:SetSizeRel(Vector2(0.2, 0.2))
	self.followButton:SetTextSize(20)
	self.followButton:SetPositionRel(Vector2(0.40, 0.55))
	self.followButton:Subscribe("Press", self, self.followButtonF)
	self.followButton:SetTextNormalColor(self.white)
	self.followButton:SetTextPressedColor(self.green)
	self.followButton:SetToggleState(false)
	self.followButton:SetToggleable(true)
	
	self.selfTargetButton = Button.Create(self.controlWindow)
	self.selfTargetButton:SetText("Target Self")
	self.selfTargetButton:SetSizeRel(Vector2(0.14, 0.1))
	self.selfTargetButton:SetTextSize(12)
	self.selfTargetButton:SetPositionRel(Vector2(0.005, 0.6))
	self.selfTargetButton:Subscribe("Press", self, self.selfTargetButtonF)
	self.selfTargetButton:SetTextNormalColor(self.white)
	self.selfTargetButton:SetTextPressedColor(self.green)
	
	self.summonPetButton = Button.Create(self.controlWindow)
	self.summonPetButton:SetText("Summon")
	self.summonPetButton:SetSizeRel(Vector2(0.19, 0.14))
	self.summonPetButton:SetTextSize(15)
	self.summonPetButton:SetPositionRel(Vector2(0.775, 0.19))
	self.summonPetButton:Subscribe("Press", self, self.summonPetButtonF)
	self.summonPetButton:SetTextNormalColor(self.white)
	self.summonPetButton:SetTextPressedColor(self.green)
	
	self.terminatePetButton = Button.Create(self.controlWindow)
	self.terminatePetButton:SetText("Terminate")
	self.terminatePetButton:SetSizeRel(Vector2(0.19, 0.14))
	self.terminatePetButton:SetTextSize(15)
	self.terminatePetButton:SetPositionRel(Vector2(0.775, 0.34))
	self.terminatePetButton:Subscribe("Press", self, self.terminatePetButtonF)
	self.terminatePetButton:SetTextNormalColor(self.white)
	self.terminatePetButton:SetTextPressedColor(self.green)
	
	self.becomePetButton = Button.Create(self.controlWindow)
	self.becomePetButton:SetText("Pet View")
	self.becomePetButton:SetSizeRel(Vector2(0.19, 0.14))
	self.becomePetButton:SetTextSize(15)
	self.becomePetButton:SetPositionRel(Vector2(0.585, 0.34))
	--self.becomePetButton:Subscribe("Press", self, self.becomePetButtonF)
	self.becomePetButton:SetTextNormalColor(self.white)
	self.becomePetButton:SetTextPressedColor(self.green)
	self.becomePetButton:SetToggleState(false)
	self.becomePetButton:SetToggleable(true)
	
	self.patrolButton = Button.Create(self.controlWindow)
	self.patrolButton:SetText("Patrol")
	self.patrolButton:SetSizeRel(Vector2(0.19, 0.14))
	self.patrolButton:SetTextSize(15)
	self.patrolButton:SetPositionRel(Vector2(0.585, 0.19))
	self.patrolButton:Subscribe("Press", self, self.patrolButtonF)
	self.patrolButton:SetTextNormalColor(self.white)
	self.patrolButton:SetTextPressedColor(self.green)
	self.patrolButton:SetToggleState(false)
	self.patrolButton:SetToggleable(true)
	
	self.atthealButton = Button.Create(self.controlWindow)
	if LocalPlayer:GetValue("Personality") then
		local value = tonumber(LocalPlayer:GetValue("Personality"))
		if value < 0 then
			self.p = value
			self.atthealButton:SetText("Attack")
		elseif value > 0 then
			self.p = value
			self.atthealButton:SetText("Heal")
		else
			self.p = value
			self.atthealButton:SetText("???")
		end
	end
	self.atthealButton:SetSizeRel(Vector2(0.2, 0.2))
	self.atthealButton:SetTextSize(20)
	self.atthealButton:SetPositionRel(Vector2(0.65, 0.55))
	self.atthealButton:Subscribe("Press", self, self.atthealButtonF)
	self.atthealButton:SetTextNormalColor(self.white)
	self.atthealButton:SetTextPressedColor(self.green)
	self.atthealButton:SetToggleState(false)
	self.atthealButton:SetToggleable(true)
	
	self.namecolor = Color(255,255,0)
	self.defaultname = "???"
	if self.p then
		if self.p < 0 then
			self.defaultname = "Animosity Incarnation"
			self.namecolor = Color(255,85,0)
		elseif self.p > 0 then
			self.defaultname = "Tonic Personification"
			self.namecolor = Color(0,191,255)
		elseif self.p == 0 then
			self.defaultname = "???"
		end
	end
	self.nameTag = Label.Create(self.controlWindow)
	self.nameTag:SetText(self.defaultname)
	self.nameTag:SetSizeRel(Vector2(1, 1))
	self.nameTag:SetTextColor(self.namecolor)
	self.nameTag:SetTextSize(25)
	self.nameLengthx = 0.5 - tonumber(self.nameTag:GetTextLength() / 75)
	self.nameTag:SetPositionRel(Vector2(self.nameLengthx, 0.05))
	self.nameTagDivision = 900
	
	self.nameBox = TextBox.Create(self.controlWindow)
	self.nameBox:SetPositionRel(Vector2(0.1, 0.015))
	self.nameBox:SetSizeRel(Vector2(0.8, 0.15))
	self.nameBox:SetTextSize(25)
	self.nameBox:SetTextColor(self.namecolor)
	self.nameBox:SetText(self.defaultname)
	--self.nameBox:SetBackgroundVisible(false)
	self.nameBox:SetAlignment(96)
	self.nameBoxCur = self.nameBox:GetText()
	self.nameBox:Subscribe("TextChanged", self, self.nameBoxF)
	self.nameBox:Hide()
	self.clicktimer = Timer()
	self.sendTimer = Timer()
	
	
	self.targetTagControl = Label.Create(self.controlWindow)
	self.targetTagControl:SetText("Pet not currently summoned")
	self.targetTagControl:SetSizeRel(Vector2(1, 1))
	self.targetTagControl:SetTextColor(self.white)
	self.targetTagControl:SetPositionRel(Vector2(0.01, 0.775))
	
	
	self.levelLabel = Label.Create(self.controlWindow)
	self.levelLabel:SetText("Level: 1")
	self.levelLabel:SetSizeRel(Vector2(1, 1))
	self.levelLabel:SetTextColor(self.white)
	self.levelLabel:SetPositionRel(Vector2(0.01, 0.3))
	
	self.expLabel = Label.Create(self.controlWindow)
	self.expLabel:SetText("Experience: 0")
	self.expLabel:SetSizeRel(Vector2(1, 1))
	self.expLabel:SetTextColor(self.white)
	self.expLabel:SetPositionRel(Vector2(0.01, 0.4))
	
	self:UpdatePetActions()
	self.selftimer = Timer()
	
	--GUI SETUP ENDS NOW
	
	self.controlWindow:Subscribe("WindowClosed", self, self.CloseControlPanel)
	self.controlWindow:Subscribe("Render", self, self.EditNameTag)
	self.statsWindow:Subscribe("Render", self, self.EditNameTag)
	self.nameBox:Subscribe("ReturnPressed", self, self.EditNameTagExit)
	Events:Subscribe("KeyDown", self, self.HitKey)
	Events:Subscribe("ModuleUnload", self, self.Unload)
	Events:Subscribe("LocalPlayerDeath", self, self.Unload)
	Events:Subscribe("SecondTick", self, self.Random)
	Events:Subscribe("SecondTick", self, self.UpdatePetData)
	personalityChecker =  Events:Subscribe("SecondTick", self, self.CheckForPersonality)
	Events:Subscribe("LocalPlayerBulletHit", self, self.SetTarget)
	Events:Subscribe("WorldNetworkObjectCreate", self, self.CreateWNO)
	Events:Subscribe("WorldNetworkObjectDestroy", self, self.DestroyWNO)
	Events:Subscribe("Pets_ShowPetPanel", self, self.ShowGUIFirstTime)
	Events:Subscribe("Pets_HasPet", self, self.Pets_HasPet)
	Network:Subscribe("LoadPetStatsSQL_Client", self, self.LoadPetStats)
	Network:Subscribe("PetGainLevel", self, self.PetGainLevelFX)
	Network:Subscribe("PetFindItem", self, self.PetFindItem)
end
function Pets:PetFindItem()
	local item = table.randomvalue(self.items).." (1)"
	self:SendPetMessage("ITEMFOUND")
	Events:Fire("Crafting_SpawnDropbox", item)
end
function Pets:PetGainLevelFX(pos)
	local args = {}
	args.position = pos
	args.angle = Angle()
	args.path = "fx_exp_c4_firework_03.psmb"
	ClientParticleSystem.Create(AssetLocation.Game, args)
	args.path = "fx_exp_c4_firework_02.psmb"
	ClientParticleSystem.Create(AssetLocation.Game, args)
end
function AddHelp()
    Events:Fire( "HelpAddItem",
        {
            name = "Pets",
            text = 
                "Pets are very mysterious creatures that follow you around and obey your commands. "..
                "Based on your personality, your pet will either be an aggressive, attacking fireball " ..
                "or a calm, healing blue orb.  The process of obtaining a pet is long, arduous, and "..
				"not well known, but the rewards are great."
       } )
end

function RemoveHelp()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Pets"
        } )
end

Events:Subscribe("ModulesLoad", AddHelp)
Events:Subscribe("ModuleUnload", RemoveHelp)
--GUI FUNCTIONS BEGIN NOW---------------------------------------------------------------
function Pets:CheckForPersonality()
	if LocalPlayer:GetValue("Personality") then
		if LocalPlayer:GetValue("Personality") then
			local value = tonumber(LocalPlayer:GetValue("Personality"))
			if value < 0 then
				self.p = value
				self.atthealButton:SetText("Attack")
			elseif value > 0 then
				self.p = value
				self.atthealButton:SetText("Heal")
			else
				self.p = value
				self.atthealButton:SetText("???")
			end
		end
		self.nameBox:SetTextColor(self.namecolor)
		self.nameTag:SetTextColor(self.namecolor)
		if self.p < 0 then
			self.namecolor = Color(255,85,0)
		elseif self.p > 0 then
			self.namecolor = Color(0,191,255)
		end
		Events:Unsubscribe(personalityChecker)
		personalityChecker = nil
	end
end
function Pets:LoadPetStats(args)
	if not args.name then return end
	self.nameTag:SetText(args.name)
	self.nameLengthx = 0.5 - tonumber(self.nameTag:GetTextLength() / 75)
	self.nameTag:SetPositionRel(Vector2(self.nameLengthx, 0.05))
	self.nameBox:SetText(args.name)
	self.nameBoxCur = args.name
	self.petlevel = args.level
	self.petexp = args.experience
	self.maxexp = math.pow(self.petlevel, 2.75) + (self.petlevel * 50)
	self.statsWindow:Show()
	self.levelLabel:SetText(string.format("Level: %.0f", self.petlevel))
	self.expLabel:SetText(string.format("Experience: %.0f/%.0f", self.petexp, self.maxexp))

end
function Pets:ShowGUIFirstTime()
	self.statsWindow:Show()
end
function Pets:Pets_HasPet()
	return haspet
end
function Pets:SendDataIfChanged()
	local id = LocalPlayer:GetId()
	if self.changeMade and self.sendTimer:GetSeconds() > 0.25 then
		local data = {}
		data.petstate = self.petstate
		data.target = self.target
		data.petname = self.nameBoxCur
		Network:Send("PetDataChange", data)
		self.changeMade = false
		Events:Unsubscribe(self.changesub)
		self.changesub = nil
		self.sendTimer:Restart()
	end
end
function Pets:UpdatePetActions()
	if not haspet then return end
	local obj = self.petobjs[LocalPlayer:GetId()]
	if not IsValid(obj) then return end
	local state = obj:GetValue("State")
	local target = tostring(obj:GetValue("Target"))
	if state == "GUARD" then
		local dist = Vector3.Distance(obj:GetPosition(), LocalPlayer:GetPosition())
		if dist < 2 and dist > 1 then
			self.targetTagControl:SetText("Guarding "..target.." "..tostring(math.floor(dist)).." meter away")
		else
			self.targetTagControl:SetText("Guarding "..target.." "..tostring(math.floor(dist)).." meters away")
		end
		if not self.guardButton:GetToggleState() then
			self:ToggleFalseOtherButtons()
			self.guardButton:SetToggleState(true)
		end
	elseif state == "FOLLOW" then
		local dist = Vector3.Distance(obj:GetPosition(), LocalPlayer:GetPosition())
		if dist < 2 and dist > 1 then
			self.targetTagControl:SetText("Following "..target.." "..tostring(math.floor(dist)).." meter away")
		else
			self.targetTagControl:SetText("Following "..target.." "..tostring(math.floor(dist)).." meters away")
		end
		if not self.followButton:GetToggleState() then
			self:ToggleFalseOtherButtons()
			self.followButton:SetToggleState(true)
		end
	elseif state == "ATTACK" then
		local dist = Vector3.Distance(obj:GetPosition(), LocalPlayer:GetPosition())
		if dist < 2 and dist > 1 then
			self.targetTagControl:SetText("Attacking "..target.." "..tostring(math.floor(dist)).." meter away")
		else
			self.targetTagControl:SetText("Attacking "..target.." "..tostring(math.floor(dist)).." meters away")
		end
		if not self.atthealButton:GetToggleState() then
			self:ToggleFalseOtherButtons()
			self.atthealButton:SetToggleState(true)
		end
	elseif state == "HEAL" then
		local dist = Vector3.Distance(obj:GetPosition(), LocalPlayer:GetPosition())
		if dist < 2 and dist > 1 then
			self.targetTagControl:SetText("Healing "..target.." "..tostring(math.floor(dist)).." meter away")
		else
			self.targetTagControl:SetText("Healing "..target.." "..tostring(math.floor(dist)).." meters away")
		end
		if not self.atthealButton:GetToggleState() then
			self:ToggleFalseOtherButtons()
			self.atthealButton:SetToggleState(true)
		end
	elseif state == "PATROL" then
		local dist = Vector3.Distance(obj:GetPosition(), LocalPlayer:GetPosition())
		if dist < 2 and dist > 1 then
			self.targetTagControl:SetText("Patrolling "..tostring(math.floor(dist)).." meter away")
		else
			self.targetTagControl:SetText("Patrolling "..tostring(math.floor(dist)).." meters away")
		end
		if not self.patrolButton:GetToggleState() then
			self:ToggleFalseOtherButtons()
			self.patrolButton:SetToggleState(true)
		end
	else
		self.targetTagControl:SetText("Pet not currently summoned")
	end
end
function Pets:HitKey(args)
	if not LocalPlayer:GetValue("Pet_Enabled") then return end
	if args.key == string.byte(self.openkey) and not self.open then
		self.open = true
		Mouse:SetVisible(true)
		self:Expand()
		if not self.restrictCamera then
			self.restrictCamera = Events:Subscribe("LocalPlayerInput", self, self.RestrictCamera)
		end
	elseif args.key == string.byte(self.openkey) and self.open then
		self.open = false
		Mouse:SetVisible(false)
		self:Collapse()
		if self.restrictCamera and not self.camsub then
			Events:Unsubscribe(self.restrictCamera)
			self.restrictCamera = nil
		end
	end
end
function Pets:CloseControlPanel()
	self:Collapse()
	self.open = false
	Mouse:SetVisible(false)
	self.namechangeactive = false
	self.nameBox:SetText(self.nameBoxCur)
	self.nameTag:Show()
	self.nameBox:Hide()
	if self.restrictCamera then
		Events:Unsubscribe(self.restrictCamera)
		self.restrictCamera = nil
	end
end
function Pets:EditNameTagExit()
	self.namechangeactive = false
	self.nameTag:SetText(self.nameBoxCur)
	self.nameBox:SetText(self.nameBoxCur)
	self.nameLengthx = 0.5 - tonumber(Render:GetTextWidth(self.nameBoxCur, 25) / self.nameTagDivision)
	self.nameTag:SetPositionRel(Vector2(self.nameLengthx, 0.05))
	self.nameTag:Show()
	self.nameBox:Hide()
	if not self.changesub then
		self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
	end
	self.changeMade = true
end
function Pets:EditNameTag()
	if self.controlWindow:GetVisible() then
		if Key:IsDown(VirtualKey.LButton) and self.clicktimer:GetSeconds() > 0.25 then
			self.leftbuttondown = true
			self.clicktimer:Restart()
		else
			self.leftbuttondown = false
		end
		local pos = Mouse:GetPosition()
		local pos2 = self.nameTag:GetPosition() + self.controlWindow:GetPosition() - Vector2(10,0)
		local pos3 = pos2 + Vector2((self.nameTag:GetTextWidth()) + 30, (self.nameTag:GetTextHeight() * 2) + 7)
		if pos.x > pos2.x and pos.x < pos3.x and pos.y > pos2.y and pos.y < pos3.y then
			self.ineditarea = true
		else
			self.ineditarea = false
		end
		if self.ineditarea and self.leftbuttondown and self.nameTag:GetVisible() and not self.namechangeactive then
			self.namechangeactive = true
			self.nameBox:SetText(self.nameBoxCur)
			self.nameTag:Hide()
			self.nameBox:Show()
		elseif self.leftbuttondown and not self.nameTag:GetVisible() and not self.ineditarea and self.namechangeactive then
			self.namechangeactive = false
			self.nameTag:SetText(self.nameBoxCur)
			self.nameBox:Hide()
			self.nameBox:SetText(self.nameBoxCur)
			self.nameTag:Show()
			self.nameLengthx = 0.5 - tonumber(Render:GetTextWidth(self.nameBoxCur, 25) / self.nameTagDivision)
			self.nameTag:SetPositionRel(Vector2(self.nameLengthx, 0.05))
			self.changeMade = true
			if not self.changesub then
				self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
			end
		end
	end
	if self.hotkeyTimer:GetSeconds() > 0.1 then
		if Key:IsDown(VirtualKey.RButton) and not Key:IsDown(VirtualKey.LShift) 
		and not Key:IsDown(VirtualKey.LControl) then
			self:atthealButtonF()
		elseif Key:IsDown(VirtualKey.RButton) and Key:IsDown(VirtualKey.LShift) 
		and not Key:IsDown(VirtualKey.LControl) then
			self:guardButtonF()
		elseif Key:IsDown(VirtualKey.RButton) and not Key:IsDown(VirtualKey.LShift) 
		and Key:IsDown(VirtualKey.LControl) then
			self.target = LocalPlayer
			self:selfTargetButtonF()
			self.petstate = "GUARD"
		end
		self.hotkeyTimer:Restart()
	end
end
function Pets:becomePetButtonF()
	local id = LocalPlayer:GetId()
	if not haspet then self.becomePetButton:SetToggleState(false) return end
	if not self.camsub then
		--[[if not self.restrictCamera2 then
			self.restrictCamera2 = Events:Subscribe("LocalPlayerInput", self, self.RestrictCamera2)
		end--]]
		if not self.restrictCamera then
			self.restrictCamera = Events:Subscribe("LocalPlayerInput", self, self.RestrictCamera)
		end
		self.camsub = Events:Subscribe("CalcView", self, self.Camera)
	elseif not self.camsub and not haspet then
		Chat:Print("You don't have a pet!", Color(255,0,0))
	elseif self.camsub then
		if self.restrictCamera and not self.open then
			Events:Unsubscribe(self.restrictCamera)
			self.restrictCamera = nil
		end
		Events:Unsubscribe(self.camsub)
		self.camsub = nil
		--[[if self.restrictCamera2 then
			Events:Unsubscribe(self.restrictCamera2)
			self.restrictCamera2 = nil
		end--]]
	end
end
function Pets:Camera()
	local obj = self.petobjs[LocalPlayer:GetId()]
	if not IsValid(obj) then return end
	if haspet then
		Camera:SetPosition(obj:GetPosition())
	else
		Events:Unsubscribe(self.camsub)
		self.camsub = nil
	end
end
function Pets:summonPetButtonF()
	if not haspet then
		Network:Send("PetSummon")
	else
		Chat:Print("You already have a pet!", Color(255,0,0))
	end
end
function Pets:patrolButtonF()
	self.patrolButton:SetToggleState(false)
	self:ToggleFalseOtherButtons()
	if not self.patrolButton:GetToggleState() then
		self.patrolButton:SetToggleState(true)
	end
	self.petstate = "PATROL"
	self.changeMade = true
	if not self.changesub then
		self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
	end
end
function Pets:terminatePetButtonF()
	if not haspet then return end
	local obj = self.petobjs[LocalPlayer:GetId()]
	if IsValid(obj) then
		Network:Send("PetTerminate")
	else
		Chat:Print("You do not have a pet!", Color(255,0,0))
	end
end
function Pets:selfTargetButtonF()
	self.selftimer:Restart()
	if self.guardButton:GetToggleState() then
		self.target = LocalPlayer
		self.selfTargetButton:SetToggleState(false)
		self.changeMade = true
		if not self.changesub then
			self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
		end
	elseif self.followButton:GetToggleState() then
		self.target = LocalPlayer
		self.selfTargetButton:SetToggleState(false)
		self.changeMade = true
		if not self.changesub then
			self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
		end
	elseif self.atthealButton:GetToggleState() then
		self.target = LocalPlayer
		self.petstate = "GUARD"
		self.selfTargetButton:SetToggleState(false)
		self.changeMade = true
		if not self.changesub then
			self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
		end
	end
end
function Pets:guardButtonF()
	self:ToggleFalseOtherButtons()
	local aimTarget = LocalPlayer:GetAimTarget().entity
	if not self.guardButton:GetToggleState() then
		self.guardButton:SetToggleState(true)
	end
	if IsValid(aimTarget) and aimTarget.__type == "Player" then
		self.target = aimTarget
		self.changeMade = true
	end
	self.petstate = "GUARD"
	self.changeMade = true
	if not self.changesub then
		self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
	end
end
function Pets:atthealButtonF()
	self:ToggleFalseOtherButtons()
	local aimTarget = LocalPlayer:GetAimTarget().entity
		if self.target.__type ~= "Player" or self.target.__type ~= "LocalPlayer" then
			self.target = LocalPlayer
			self.changeMade = true
			if not self.changesub then
				self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
			end
		end
		if self.p > 0 then
			if not self.atthealButton:GetToggleState() then
				self.atthealButton:SetToggleState(true)
			end
			if IsValid(aimTarget) and aimTarget.__type == "Player" and aimTarget:GetHealth() < 1 then
				self.target = aimTarget
				self.petstate = "HEAL"
			elseif IsValid(aimTarget) and aimTarget.__type == "Player" then
				self.target = aimTarget
				self.petstate = "GUARD"
			else
				self.petstate = "GUARD"
			end
			self.changeMade = true
			if not self.changesub then
				self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
			end
		elseif self.p < 0 and (self.target ~= LocalPlayer or (aimTarget and aimTarget.__type == "Player")) then
			if not self.atthealButton:GetToggleState() then
				self.atthealButton:SetToggleState(true)
			end
			if aimTarget and IsValid(aimTarget) and aimTarget.__type == "Player" then
				if aimTarget:GetValue("CanHit") == true then
					self:SendPetMessage("ATTACK")
					self.target = aimTarget
					self.changeMade = true
					self.petstate = "ATTACK"
				else
					self:SendPetMessage("NOATTACK")
				end
			end
			self.changeMade = true
			if not self.changesub then
				self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
			end
		elseif self.p < 0 and self.target == LocalPlayer and IsValid(aimTarget) then
			Pets:UpdatePetActions()
		end
end
function Pets:SendPetMessage(msgType)
	local sType = "blue"
	if self.p < 0 then
		sType = "red"
	end
	local msg = tostring(msgs[sType][msgType][math.random(#msgs[sType][msgType])])
	local color = Color.White
	if sType == "blue" then
		color = Color(0,191,255)
	elseif sType == "red" then
		color = Color(255,85,0)
	end
	Chat:Print(self.nameBoxCur, color, msg, Color.White)
end
function Pets:followButtonF()
	self:ToggleFalseOtherButtons()
	local aimTarget = LocalPlayer:GetAimTarget().entity
	if not self.followButton:GetToggleState() then
		self.followButton:SetToggleState(true)
	end
	if IsValid(aimTarget) and aimTarget.__type == "Player" then
		self.target = aimTarget
	end
	self.petstate = "FOLLOW"
	self.changeMade = true
	if not self.changesub then
		self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
	end
end
function Pets:nameBoxF()
	if self.nameBox:GetTextLength() > self.maxcharacters then
		self.nameBox:SetText(self.nameBoxCur)
	elseif self.nameBox:GetTextLength() == 0 then
		self.nameBoxCur = self.nameTag:GetText()
	elseif self.nameBox:GetTextLength() <= self.maxcharacters then
		self.nameBoxCur = self.nameBox:GetText()
	end
end
function Pets:ToggleFalseOtherButtons()
	self.followButton:SetToggleState(false)
	self.guardButton:SetToggleState(false)
	self.atthealButton:SetToggleState(false)
	self.patrolButton:SetToggleState(false)
end
function Pets:Expand()
	self.controlWindow:Show()
	self.statsWindow:Hide()
	self.sizeX = Render.Size.x
	self.sizeY = Render.Size.y
	self.windowpos = Vector2(self.sizeX / 1.75, 0)
	self.windowsize = Vector2(self.sizeX / 4, self.sizeY / 5)
	self.windowposStats = Vector2(self.sizeX / 1.75, 0)
	self.windowsizeStats = Vector2(self.sizeX / 7, self.sizeY / 9)
	self.controlWindow:SetSize(self.windowsize)
	self.controlWindow:SetPosition(self.windowpos)
	self.statsWindow:SetSize(self.windowsizeStats)
	self.statsWindow:SetPosition(self.windowposStats)
end
function Pets:Collapse()
	self.controlWindow:Hide()
	self.statsWindow:Show()
	self.sizeX = Render.Size.x
	self.sizeY = Render.Size.y
	self.windowpos = Vector2(Render.Size.x / 1.75, 0)
	self.windowsize = Vector2(Render.Size.x / 4, Render.Size.y / 5)
	self.windowposStats = Vector2(Render.Size.x / 1.75, 0)
	self.windowsizeStats = Vector2(Render.Size.x / 7, Render.Size.y / 9)
	self.controlWindow:SetSize(self.windowsize)
	self.controlWindow:SetPosition(self.windowpos)
	self.statsWindow:SetSize(self.windowsizeStats)
	self.statsWindow:SetPosition(self.windowposStats)
end
function Pets:RestrictCamera(args)
	if self.open then
		if args.input == Action.LookLeft or args.input == Action.LookRight
		or args.input == Action.LookDown or args.input == Action.LookUp then
			return false
		end
	end
	if self.nameBox:GetVisible() then
		return false
	end
	if self.camsub then
		if args.input ~= Action.LookLeft and args.input ~= Action.LookRight
		and args.input ~= Action.LookDown and args.input ~= Action.LookUp then
			return false
		end
	end
end
function Pets:RestrictCamera2(args)
	--[[if self.camsub then
		local id = LocalPlayer:GetId()
		if args.input == Action.MoveForward then
			local raycast = Physics:Raycast(self.lightfx[id]:GetPosition(), Vector3.Down, 0, 5)
			if raycast.distance < 1 then return end
			local direction = Camera:GetAngle() * Vector3.Forward
			self.spiritmovement = self.spiritmovement + (direction / 2)
			self.lightfx[id]:SetPosition(self.lightfx[id]:GetPosition() + (direction / 2))
			self.fx[id]:SetPosition(self.fx[id]:GetPosition() + direction)
			self.changeMade = true
			if not self.changesub then
				self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
			end
		elseif args.input == Action.MoveBackward then
			local raycast = Physics:Raycast(self.lightfx[id]:GetPosition(), Vector3.Down, 0, 5)
			if raycast.distance < 1 then return end
			local direction = Camera:GetAngle() * Vector3.Forward
			self.spiritmovement = self.spiritmovement - (direction / 2)
			self.lightfx[id]:SetPosition(self.lightfx[id]:GetPosition() - (direction / 2))
			self.fx[id]:SetPosition(self.fx[id]:GetPosition() - direction)
			self.changeMade = true
			if not self.changesub then
				self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
			end
		elseif args.input == Action.MoveLeft then
			local direction = Camera:GetAngle() * Vector3.Left
			self.spiritmovement = self.spiritmovement + (direction / 2)
			self.lightfx[id]:SetPosition(self.lightfx[id]:GetPosition() + (direction / 2))
			self.fx[id]:SetPosition(self.fx[id]:GetPosition() + direction)
			self.changeMade = true
			if not self.changesub then
				self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
			end
		elseif args.input == Action.MoveRight then
			local direction = Camera:GetAngle() * Vector3.Right
			self.spiritmovement = self.spiritmovement + (direction / 2)
			self.lightfx[id]:SetPosition(self.lightfx[id]:GetPosition() + direction)
			self.fx[id]:SetPosition(self.fx[id]:GetPosition() + (direction / 2))
			self.changeMade = true
			if not self.changesub then
				self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
			end
		end
		if args.input ~= Action.LookLeft and args.input ~= Action.LookRight
		and args.input ~= Action.LookDown and args.input ~= Action.LookUp then
			return false
		end
	end--]]
end
function Pets:UpdatePetData()
	if not self.changeMade and haspet then
		local obj = self.petobjs[LocalPlayer:GetId()]
		if not IsValid(obj) then return end
		self.target = obj:GetValue("Target")
		self.petstate = obj:GetValue("State")
		self:UpdatePetActions()
	end
	local obj = self.petobjs[LocalPlayer:GetId()]
	if not IsValid(obj) then return end
	self.levelLabel:SetText(string.format("Level: %.0f", obj:GetValue("Level")))
	self.expLabel:SetText(string.format("Experience: %.0f/%.0f", obj:GetValue("Experience"), obj:GetValue("ExperienceMax")))
end
function Pets:CheckIfShooting()
	local obj = self.petobjs[LocalPlayer:GetId()]
	if not IsValid(obj) then return end
	if LocalPlayer:GetValue("HD_Attacking") 
	and obj:GetValue("Type") == "red"
	and obj:GetValue("State") ~= "FOLLOW"
	and self.selftimer:GetSeconds() > 3 then
		self.target = LocalPlayer:GetValue("HD_Attacking")
		self.petstate = "ATTACK"
		self.changeMade = true
		LocalPlayer:SetValue("HD_Attacking", nil)
		if not self.changesub then
			self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
		end
	end
end
function Pets:Render()
	if self.petsnear <= 0 then return end
	if haspet then
		self:CheckIfShooting()
	end
	local pos2 = LocalPlayer:GetPosition()
	for id, obj in pairs(self.petobjs) do
		if not CheckExists(id) then return end
		if not IsValid(obj) then return end
		if self.camsub and id == LocalPlayer:GetId() then return end--disabled rendering when in pet view
		local pos = self.lightfx[id]:GetPosition() + Vector3(0,0.5,0)
		local dist = Vector3.Distance(pos, pos2)
		local name = tostring(obj:GetValue("Name"))
		local color = self.white
		--[[
		instead of this: local size = 50 - dist
		do this: local size = 50 + (dist * 2)
		adjust as necessary, and it may require re-centering
		--]]
		local size = 50 - (dist / 2)
		if dist > 35 then
			size = 0
		end
		if obj:GetValue("Type") == "red" then
			color = Color(255,85,0)
		elseif obj:GetValue("Type") == "blue" then
			color = Color(0,191,255)
		end
		t = Transform3()
		t:Translate(pos)
		t:Rotate(Camera:GetAngle() * Angle(math.pi,0,math.pi))
		t:Translate(-Vector3(Render:GetTextWidth(name) / 250,0,0))
		Render:SetTransform(t)
		Render:DrawText(Vector3(0.005,0.005,0.005), tostring(name), Color(0,0,0), size, 0.0025)
		Render:DrawText(Vector3(0,0,0), tostring(name), color, size, 0.0025)
		Render:ResetTransform()
	end
end

--GUI FUNCTIONS END NOW---------------------------------------------------------------

--[[

PET STATES:

	WAIT --SITS STILL UNTIL OUT OF RANGE, THEN RETURNS TO OWNER
	FOLLOW --FOLLLOWS SELECTED TARGET, IF NONE THEN FOLLOWS OWNER
	GUARD --DEFAULT STATE, SAME AS FOLLOW BUT IF OWNER IS ATTACKED THEN IT HEALS/ATTACKS
	HEAL --HEALS THE SELECTED TARGET, IF NONE THEN HEALS OWNER
	ATTACK --ATTACKS TARGET, IF NONE THEN GUARDS OWNER
	
	IF PET GETS TOO FAR AWAY IT TELEPORTS TO OWNER AND REVERTS TO GUARD STATE

--]]
function Pets:SetTarget(args)
	local obj = self.petobjs[LocalPlayer:GetId()]
	if IsValid(obj) then
		if obj:GetValue("Type") ~= "red" then return end
		if args.attacker and (obj:GetValue("State") == "GUARD" or obj:GetValue("State") == "ATTACK")
		and obj:GetValue("Target") == LocalPlayer then
			self.target = args.attacker
			self.petstate = "ATTACK"
			self.changeMade = true
			if not self.changesub then
				self.changesub = Events:Subscribe("PostTick", self, self.SendDataIfChanged)
			end
		end
	elseif self.guardOtherTimer:GetSeconds() > 0.5 then
		self.guardOtherTimer:Restart()
		for id, obj in pairs(self.petobjs) do
			if obj:GetValue("State") == "GUARD" and obj:GetValue("Target") == LocalPlayer
			and args.attacker then
				Network:Send("GuardOtherUpdateTarget", {attacker = args.attacker, obj = obj})
				return
			end
		end
	end
end
function Pets:Random()
	if self.petsnear > 0 then
		if not self.lerpsub then
			self.lerpsub = Events:Subscribe("PostTick", self, self.Lerp)
			self.rendersub = Events:Subscribe("GameRender", self, self.Render)
		end
	else
		if self.lerpsub then
			Events:Unsubscribe(self.lerpsub)
			self.lerpsub = nil
		end
		if self.rendersub then
			Events:Unsubscribe(self.rendersub)
			self.rendersub = nil
		end
	end
	for id, obj in pairs(self.petobjs) do
		if not IsValid(obj) then return end
		local state = obj:GetValue("State")
		local pType = obj:GetValue("Type")
		self.blueseconds = self.blueseconds + 1
		self.redseconds = self.redseconds + 1
		if state == "FOLLOW" or state == "GUARD" and self.fx[id] and self.lightfx[id] then
				--MAKE THE PET LOITER AROUND WHEN NOT DOING ANYTHING
			if pType == "red" and IsValid(self.lightfx[id]) then
				self.lightfx[id]:SetColor(Color(255,157,0))
			elseif pType == "blue" and IsValid(self.lightfx[id]) then
				self.lightfx[id]:SetColor(Color(0,120,255))
			end
		elseif state == "HEAL" or state == "ATTACK" and self.fx[id] and self.lightfx[id] then
			--MAKE THE PET MOVE UP AND DOWN WHEN ATTACKING OR HEALING
			if pType == "blue" then
				local fxargs = {}
				fxargs.position = self.fx[id]:GetPosition()
				fxargs.angle = Angle(0,0,0)
				fxargs.path = "fx_bulhit_water_large_02.psmb"
				local effect = ClientParticleSystem.Play(AssetLocation.Game, fxargs)
				self.lightfx[id]:SetColor(Color(0,255,55)) --green to indicate healing
			elseif pType == "red" then
				local fxargs = {}
				fxargs.position = self.fx[id]:GetPosition()
				fxargs.angle = Angle(0,0,0)
				fxargs.path = "fx_bulhit_metal_huge_07.psmb"
				local effect = ClientParticleSystem.Play(AssetLocation.Game, fxargs)
				self.lightfx[id]:SetColor(Color(255,0,0)) --red to indicate attacking
			end
		elseif state == "PATROL" and self.fx[id] and self.lightfx[id] then
			if pType == "red" then
				self.lightfx[id]:SetColor(Color(255,157,0))
			elseif pType == "blue" then
				self.lightfx[id]:SetColor(Color(0,120,255))
			end
		end
	end
end

function Pets:Lerp()
	for id, obj in pairs(self.petobjs) do
		if not CheckExists(id) then return false end
		if not IsValid(obj) then self.petobjs[id] = nil return end
		local fx = self.fx[id]
		local light = self.lightfx[id]
		local pos1 = obj:GetPosition()
		--[[local rando = obj:GetValue("randompos")
		local pos3 = target:GetPosition() + Vector3(0,1.5,0) + rando
		local dist = Vector3.Distance(pos1, pos3)
		local fraction = self.ticks / self.distance
		local lerp = math.lerp(pos1, pos3, fraction * (dist + 40))--]]
		--[[local lerpx = math.sin(lerp.x) + lerp.x
		local lerpy = math.sin(lerp.y) + lerp.y
		local lerpz = math.sin(lerp.z) + lerp.z
		lerp = Vector3(lerpx,lerpy,lerpz)--]]
		light:SetPosition(pos1)
		fx:SetPosition(pos1)
	end
end
function CheckExists(id)
	local exists = false
	for id2, light in pairs(Pets.lightfx) do
		if id == id2 then
			exists = true
		end
	end
	for id2, light in pairs(Pets.fx) do
		if id == id2 then
			exists = true
		end
	end
	if exists then
		return true
	else
		return false
	end
end
function Pets:CreateWNO(args)
	if tonumber(args.object:GetValue("IsPet")) == 1 then
		local obj = args.object
		local id = tonumber(obj:GetValue("OwnerId"))
		if id == LocalPlayer:GetId() then
			haspet = true
		end
		local pType = obj:GetValue("Type")
		self.petobjs[id] = obj
		self.petsnear = self.petsnear + 1
		self.currenttarget = obj:GetValue("Target")
		Pets:UpdatePetActions()
		local pos1 = LocalPlayer:GetPosition()
		local location = obj:GetPosition()
		self.randompos[id] = Vector3(0,0,0)
		self.petsnear = self.petsnear + 1
		local fxargs = {}
		fxargs.position = location + Vector3(0,1.5,0)
		fxargs.angle = Angle(0,0,0)
		local lightArgs = {}
		lightArgs.position = location + Vector3(0,1.5,0)
		lightArgs.radius = 5 --radius
		lightArgs.multiplier = 7 --brightness
		lightArgs.fade_in_duration = 3
		lightArgs.fade_out_duration = 3
		if pType == "blue" then
			fxargs.path = "fx_vehicle_jetthrust_medium_06.psmb"
			--fxargs.path = "fx_fire_missile_large_02.psmb" --???
			lightArgs.color = Color(0,120,255)
		elseif pType == "red" then
			fxargs.path = "fx_trail_fire_medium_01.psmb"
			lightArgs.color = Color(255,157,0)
		end
		local effect = ClientParticleSystem.Create(AssetLocation.Game, fxargs)
		self.fx[id] = effect
		local light = ClientLight.Create(lightArgs)
		self.lightfx[id] = light
	end
end
function Pets:DestroyWNO(args)
	if tonumber(args.object:GetValue("IsPet")) == 1 then
		local obj = args.object
		local id = tonumber(obj:GetValue("OwnerId"))
		if id == LocalPlayer:GetId() then
			haspet = false
		end
		self.petobjs[id] = nil
		if IsValid(self.fx[id]) then
			self.fx[id]:Remove()
		end
		self.fx[id] = nil
		if IsValid(self.lightfx[id]) then
			self.lightfx[id]:Remove()
		end
		self.lightfx[id] = nil
		self.petsnear = self.petsnear - 1
	end
end

function Pets:Unload()
	for id, light in pairs(self.fx) do
		if IsValid(light) then
			light:Remove()
		end
		self.fx[id] = nil
	end
	for id, light in pairs(self.lightfx) do
		if IsValid(light) then
			light:Remove()
		end
		self.lightfx[id] = nil
	end
end
Pets = Pets()