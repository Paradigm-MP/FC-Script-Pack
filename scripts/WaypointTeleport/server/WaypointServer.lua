function TeleportToWP(args, player)
	if player:GetValue("NT_TagName") then
		player:SetPosition(args.pos)
	end
end
Network:Subscribe("ToWaypoint", TeleportToWP)