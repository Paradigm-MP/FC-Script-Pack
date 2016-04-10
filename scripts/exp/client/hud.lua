class 'Exp_Hud'
function Exp_Hud:__init()
	imgstr = "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"
	Events:Subscribe("SecondTick", self, self.CheckExp)
	self.exp = tonumber(LocalPlayer:GetValue("Experience"))
	self.expmax = tonumber(LocalPlayer:GetValue("ExperienceMax"))
	self.level = tonumber(LocalPlayer:GetValue("Level"))
	flare = Image.Create(AssetLocation.Base64,imgstr)
	self.exptimer = Timer()
	self.t2 = Timer()
	self.c1 = 255
	self.c2 = 0
	self.c3 = 0
	self.oldexp = self.exp
	self.oldmax = self.expmax
	self.percent1 = self.exp / self.expmax
	self.newip = false
	self.t = Timer() --timer for levelup thing
	self.duration = 5 --duration for levelup to show
	self.string = "Level "..tostring(self.level).."!"
	self.size = TextSize.Huge
	spendIp = Image.Create(AssetLocation.Resource, "SPENDYONEWIP")
	Events:Subscribe("Render", self, self.RenderLevelBelowMinimap)
	Network:Subscribe("Exp_PlayerGainLevel", self, self.CreateEffect)
end
function AddHelp()
    Events:Fire( "HelpAddItem",
        {
            name = "Experience",
            text = 
                "You can experience and levels as you kill players and craft items. Once you reach "..
                "the maximum amount of experience needed for a level, you will gain a level. " ..
                "With each level you gain, you'll need more experience to get to the next level. "..
				"If you die, you lose all your current experience, but you retain your level. "..
				"Killing players who are higher level than you will yield significantly more experience. "..
				"Each time you gain a level, you gain Influence Points, which are talked about in the IP "..
				"section."
        } )
end

function RemoveHelp()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Experience"
        } )
end

Events:Subscribe("ModulesLoad", AddHelp)
Events:Subscribe("ModuleUnload", RemoveHelp)
function Exp_Hud:RenderLevelBelowMinimap()
	if Game:GetState() == GUIState.Game then
		local yellow = Color(255,210,0)
		local percent = self.percent1
		local basepos = Vector2(Render.Size.x / 7, Render.Size.y / 50)
		local str = "Level "..tostring(self.level)
		--Render:DrawText(basepos + Vector2(basepos.x/100,basepos.y/20), str, Color(0,0,0), TextSize.Large)
		--Render:DrawText(basepos, str, yellow, TextSize.Large)
		local p1 = basepos + Vector2(0,Render:GetTextSize(str, TextSize.Large).y)
		local p2 = Vector2(Render:GetTextSize(str, TextSize.Large).x, Render.Size.y / 150)
		local p3 = Vector2(Render:GetTextSize(str, TextSize.Large).x * percent, Render.Size.y / 150)
		--Render:FillArea(p1,p2,Color.Black)
		--Render:FillArea(p1,p3,yellow)
		if self.newip and not LocalPlayer:GetValue("Inv_Open") then
			local b1 = Vector2(Render.Size.x - (spendIp:GetPixelSize().x /4), Render.Size.y / 4)
			spendIp:Draw(b1, spendIp:GetPixelSize()/4, Vector2(0,0), Vector2(1,1))
		end
		if self.newip and Key:IsDown(85) then self.newip = false end
	end
end
function Exp_Hud:CreateEffect(player)
	if not IsValid(player) then return end
	local args = {}
	args.position = player:GetPosition()
	args.angle = player:GetAngle()
	args.path = "fx_exp_c4_firework_03.psmb"
	ClientParticleSystem.Create(AssetLocation.Game, args)
	args.path = "fx_exp_c4_firework_02.psmb"
	ClientParticleSystem.Create(AssetLocation.Game, args)
end
function Exp_Hud:CheckExp()
	if self.exp ~= LocalPlayer:GetValue("Experience") then
		self.oldexp = self.exp
		self.exptimer:Restart()
		self.exp = LocalPlayer:GetValue("Experience")
		if not self.expsub then
			self.expsub = Events:Subscribe("Render", self, self.RenderExp)
		end
	end
	if self.expmax ~= LocalPlayer:GetValue("ExperienceMax") then
		self.oldmax = self.expmax
		self.expmax = LocalPlayer:GetValue("ExperienceMax")
	end
	if self.level ~= tonumber(LocalPlayer:GetValue("Level")) then
		self.newip = true
		self.level = tonumber(LocalPlayer:GetValue("Level"))
		self.string = "Level "..tostring(self.level).."!"
		if self.t then
			self.t:Restart()
		end
		self.t2:Restart()
		if not self.levelrender then
			self.levelrender = Events:Subscribe("Render", self, self.RenderNewLevel)
		end
		Events:Fire("Exp_GainLevel", {player = LocalPlayer, level = self.level})
	end
end
function Exp_Hud:RenderExp()
	local timetoexpand = 2.5
	local timetoshow = 5
	if not self.oldexp then return end
	local percent = self.oldexp / self.oldmax
	local newpercent = self.exp / self.expmax
	local percentdiff = math.abs(percent - newpercent)
	percent = percent + (percentdiff / timetoexpand * self.exptimer:GetSeconds())
	if percent >= newpercent then percent = newpercent end
	self.percent1 = percent
	if self.level >= 200 then
		percent = 1
	end
	local alpha255 = self.exptimer:GetSeconds() * 255
	if alpha255 > 255 then alpha255 = 255 end
	if self.exptimer:GetSeconds() >= (timetoshow - 1) then
		alpha255 = (timetoshow - self.exptimer:GetSeconds()) * 255
	end
	if alpha255 < 0 then alpha255 = 0 end
	if self.exptimer:GetSeconds() >= timetoshow then alpha255 = 0 end
	local grey = Color(50,50,50, alpha255)
	local yellow = Color(255,210,0, alpha255)
	local black = Color(0,0,0, alpha255)
	local sizeX = Render.Size.x
	local sizeY = Render.Size.y
	local p1 = Vector2(0, sizeY / 1.02)
	local p2 = Vector2(sizeX, sizeY)
	local xpoint = sizeX * percent
	local endpoint = Vector2(xpoint, sizeY)
	local flareX = xpoint - (flare:GetPixelSize().x / 2.5)
	local flareY = p1.y - (flare:GetPixelSize().y / 3)
	-- Render:FillArea(p1, p2, black)
	-- Render:FillArea(p1, endpoint, yellow)
	local flarealpha = alpha255 / 255
	-- flare:SetAlpha(flarealpha)
	-- flare:Draw(
			-- Vector2(flareX, flareY),
			-- flare:GetPixelSize() / 1.25,
			-- Vector2(0, 0),
			-- Vector2(1, 1)
			-- )
	if self.exptimer:GetSeconds() >= timetoshow and self.expsub then
		Events:Unsubscribe(self.expsub)
		self.expsub = nil
	end
end
function Exp_Hud:RenderNewLevel()
	local timetoshow = 10
	self.timerS = self.t2:GetSeconds()
	self.duration = 1
	self.orig = 255 / self.duration
	self.alpha = self.t:GetSeconds() * 255
	if self.t:GetSeconds() >= (timetoshow-1) then
		self.alpha = 255 - (255 * (self.t:GetSeconds() - timetoshow + 1))
	end
	if self.alpha > 255 then self.alpha = 255 end
	if self.alpha < 0 then self.alpha = 0 end
	if self.timerS <= self.duration then
		self.c2 = self.orig * self.timerS
	elseif self.timerS <= (self.duration * 2) and self.timerS > self.duration then
		self.c1 = 255 - ((self.timerS - (self.duration * 1)) * self.orig)
	elseif self.timerS <= (self.duration * 3) and self.timerS > (self.duration * 2) then
		self.c3 = (self.timerS - (self.duration * 2)) * self.orig
	elseif self.timerS <= (self.duration * 4) and self.timerS > (self.duration * 3) then
		self.c2 = 255 - ((self.timerS - (self.duration * 3)) * self.orig)
	elseif self.timerS <= (self.duration * 5) and self.timerS > (self.duration * 4) then
		self.c1 = (self.timerS - (self.duration * 4)) * self.orig
	elseif self.timerS <= (self.duration * 6) and self.timerS > (self.duration * 5) then
		self.c3 = 255 - ((self.timerS - (self.duration * 5)) * self.orig)
	elseif self.timerS > (self.duration * 6) then
		self.t2:Restart()
	end
	if self.c1 < 3 then
		self.c1 = 0
	elseif self.c2 < 3 then
		self.c2 = 0 
	elseif self.c3 < 3 then
		self.c3 = 0
	end
	local color = Color(self.c1,self.c2,self.c3,self.alpha)
	local pos = Vector2(Render.Size.x / 2, Render.Size.y / 4) - (Render:GetTextSize(self.string, self.size) / 2)
	local pos2 = pos + (Render.Size / 500)
	color2 = Color(0, 0, 0, self.alpha)
	Render:DrawText(pos2, self.string, color2, self.size)
	Render:DrawText(pos, self.string, color, self.size)
	if self.t:GetSeconds() >= timetoshow and self.levelrender then
		Events:Unsubscribe(self.levelrender)
		self.levelrender = nil
	end
end
function ModulesLoad()
	if LocalPlayer:GetValue("Level") and LocalPlayer:GetValue("Experience") 
	and LocalPlayer:GetValue("ExperienceMax") then
		Exp_Hud = Exp_Hud()
		Events:Unsubscribe(loader)
		loader = nil
	end
end
loader = Events:Subscribe("SecondTick", ModulesLoad)