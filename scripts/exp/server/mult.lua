multiplier = 1
function SetMultiplier(args)
	local p = tostring(args.player:GetSteamId())
	if p == "STEAM_0:1:31147722" or p == "STEAM_0:1:82883843" then
		local words = args.text:split(" ")
		if #words ~= 2 then
			return
		end
		local value = tonumber(words[2])
		if words[1] == "/mult" and value then
			multiplier = value
			for player in Server:GetPlayers() do
				player:SetNetworkValue("Multiplier", multiplier)
			end
			if value ~= 1 then
				Chat:Send(args.player, "Successfully set global experience multiplier to "..tostring(value)..".", Color(255,255,255))
				Chat:Broadcast("Bonus experience multiplier set to "..tostring(value).."!", Color(0,255,0))
			else
				Chat:Send(args.player, "Successfully removed global experience multiplier.", Color(255,255,255))
				Chat:Broadcast("Bonus experience multiplier removed!", Color(0,255,0))
			end
			return false
		end
	end
end
Events:Subscribe("PlayerChat", SetMultiplier)
function PlayerJoinMult(args)
	if args.player and multiplier > 1 then
		args.player:SetNetworkValue("Multiplier", multiplier)
		Chat:Send(args.player, "Bonus experience multiplier is currently "..tostring(multiplier).."!", Color(0,255,0))
	end
end
Events:Subscribe("PlayerJoin", PlayerJoinMult)