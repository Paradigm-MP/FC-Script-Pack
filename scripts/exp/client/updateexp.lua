class 'UpdateExp'
function UpdateExp:__init()
	--this is purely for the hud currently
	Network:Subscribe("ExpLoad", self, self.Load)
	Network:Subscribe("LevelUp", self, self.LevelUp)
	Network:Subscribe("ExpUpdateDeath", self, self.UpdateDeath)
	Network:Subscribe("ExpUpdate", self, self.Update)
	Network:Subscribe("ExpHack", self, self.Hack)
end
function UpdateExp:Load(args)
	if args then
		print("exp loaded")
		LocalPlayer:SetValue("Level", args.level)
		LocalPlayer:SetValue("Experience", args.exp)
		LocalPlayer:SetValue("ExperienceMax", args.expmax)
		LocalPlayer:SetValue("ExpLoaded", 1)
	end
end
function UpdateExp:Hack(amn)
	if amn then
		LocalPlayer:SetValue("Experience", amn)
	end
end
function UpdateExp:LevelUp(args)
	if args then
		LocalPlayer:SetValue("IP_Resets", args.IP_Resets)
		LocalPlayer:SetValue("Level", args.level)
		LocalPlayer:SetValue("ExperienceMax", args.expmax)
		LocalPlayer:SetValue("IP", args.IP)
		LocalPlayer:SetValue("Experience", args.newexp)
	end
end
function UpdateExp:UpdateDeath()
	LocalPlayer:SetValue("Experience", 0)
end
function UpdateExp:Update(expe)
	if expe then
		LocalPlayer:SetValue("Experience", expe)
	end
end
function ModuleLoad()
	UpdateExp = UpdateExp()
end
Events:Subscribe("ModuleLoad", ModuleLoad)