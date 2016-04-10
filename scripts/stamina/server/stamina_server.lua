class 'Stamina_Server'
function Stamina_Server:__init()
	Network:Subscribe("Stunt_No_Energy", self, self.NoStunt)
end
function Stamina_Server:NoStunt(args, sender)
	if sender then
		sender:SetPosition(sender:GetPosition())
	end
end
Stamina_Server = Stamina_Server()