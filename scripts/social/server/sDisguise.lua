class 'Disguise'
function Disguise:__init()
	disModels = {}
	second = 0
	self:CheckForDisguises()
	Events:Subscribe("ModuleUnload", self, self.Unload)
	Network:Subscribe("SOCIAL_DisguiseHit", self, self.DisguiseHit)
end
function Disguise:DisguiseHit(args, sender)
	sender:SetNetworkValue("SOCIAL_Disguise", " ")
end
function CheckSocial(p, str)
	if p:GetValue(str) and string.len(tostring(p:GetValue(str))) > 3 then
		return tostring(p:GetValue(str))
	else
		return false
	end
end
function Disguise:CheckForDisguises()
	for p in Server:GetPlayers() do
		if CheckSocial(p, "SOCIAL_Disguise") then
			disModels[p:GetId()] = p:GetModelId()
			p:SetModelId(20)
		end
	end
end
function Disguise:Unload()
	for p in Server:GetPlayers() do
		if CheckSocial(p, "SOCIAL_Disguise") then
			p:SetModelId(disModels[p:GetId()])
		end
	end
end
Disguise = Disguise()