class 'Wingsuit'
function Wingsuit:__init()
	Events:Subscribe("PlayerChat", self, self.Chat)
end
function CheckWingsuit(p)
	if p:GetValue("SOCIAL_Wingsuit") and string.len(tostring(p:GetValue("SOCIAL_Wingsuit"))) > 3 then
		return tostring(p:GetValue("SOCIAL_Wingsuit"))
	else
		return false
	end
end
function Wingsuit:Chat(args)
	if args.text == "/ws" then
		if CheckWingsuit(args.player) then
			args.player:SetNetworkValue("SOCIAL_Wingsuit", " ")
			Chat:Send(args.player, "Wingsuit disabled.", Color.Green)
		else
			args.player:SetNetworkValue("SOCIAL_Wingsuit", "Wingsuit")
			Chat:Send(args.player, "Wingsuit enabled.", Color.Green)
		end
	end
end
Wingsuit = Wingsuit()