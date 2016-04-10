class 'LevelUp'
function LevelUp:__init()
	self.t = Timer()
	self.duration = 5
	self.level = LocalPlayer:GetValue("Level")
	self.string = "Level "..tostring(self.level).."!"
	self.size = TextSize.VeryLarge
	self.sub = Events:Subscribe("Render", self, self.Draw)
	--print("LevelUp")
	self.t:Restart()
end
function LevelUp:Draw()
	--print("LevelUp Draw")
	self.pos = Vector2(Render.Size.x / 2, Render.Size.y / 4) - (Render:GetTextSize(self.string, self.size) / 2)
	self.pos2 = self.pos + Vector2(1,0)
	self.pos3 = self.pos + Vector2(-1,0)
	self.pos4 = self.pos + Vector2(0,1)
	self.pos5 = self.pos + Vector2(0,-1)
	self.origAlpha = 200 / self.duration
	self.alpha = ((self.origAlpha * self.t:GetSeconds()) * (-1)) + 255 --goes from 255 to 0, depending on what the duration is
	if self.alpha < 0 then
		self.alpha = 0
	end
	self.color = Color(ColorCycler.c1, ColorCycler.c2, ColorCycler.c3, self.alpha)
	self.color2 = Color(0, 0, 0, self.alpha)
	Render:DrawText(self.pos2, self.string, self.color2, self.size)
	Render:DrawText(self.pos3, self.string, self.color2, self.size)
	Render:DrawText(self.pos4, self.string, self.color2, self.size)
	Render:DrawText(self.pos5, self.string, self.color2, self.size)
	Render:DrawText(self.pos, self.string, self.color, self.size)
	--[[if self.alpha == 0 then
		Events:Unsubscribe(self.sub)
	end--]]
end
function ModuleLoad(args)
	if args then
		LocalPlayer:SetValue("IP", tonumber(args.IP))
		LocalPlayer:SetValue("Level", tonumber(args.level))
		LocalPlayer:SetValue("ExperienceMax", tonumber(args.expmax))
		LocalPlayer:SetValue("Experience", tonumber(args.newexp))
		LevelUp:__init()
		Events:Fire("LevelUp", args)
	end
end
Network:Subscribe("LevelUp", ModuleLoad)