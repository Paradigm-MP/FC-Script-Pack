function Invis(args)
	if not CheckMod(args.player) then return end
	if args.text == "/invis" then
		if args.player:GetValue("Invis") then
			args.player:SetStreamDistance(500)
			Chat:Send(args.player, "You are now visible.", Color.Green)
			args.player:SetNetworkValue("Invis", nil)
		else
			args.player:SetStreamDistance(0)
			Chat:Send(args.player, "You are now invisible.", Color.Green)
			args.player:SetNetworkValue("Invis", 1)
		end
	end
end
Events:Subscribe("PlayerChat", Invis)
function CheckMod(p)
	if p:GetValue("NT_TagName") == "[Admin]" or
	p:GetValue("NT_TagName") == "[Mod]" then
		return true
	end
	return false
end

