mutedplayers = {}
function mute(args)
	local words = args.text:split(" ")
	if words[1] == "/mute" and words[2] 
	and (args.player:GetValue("NT_TagName") == "[Mod]" or 
	args.player:GetValue("NT_TagName") == "[Admin]") then
		local player = Player.Match(words[2])[1]
		if not IsValid(player) then return end
		player:SetNetworkValue("Muted", 1)
		Chat:Send(player, "You have been muted. Please ", Color.Red, "think", Color.Yellow, " before you speak next time.", Color.Red)
		Chat:Send(args.player, "You have muted "..tostring(player), Color.Red)
		mutedplayers[tostring(player:GetSteamId())] = 1
	elseif words[1] == "/unmute" and words[2] 
	and (args.player:GetValue("NT_TagName") == "[Mod]" or 
	args.player:GetValue("NT_TagName") == "[Admin]") then
		local player = Player.Match(words[2])[1]
		if not IsValid(player) then return end
		player:SetNetworkValue("Muted", nil)
		Chat:Send(player, "You have been unmuted. Please ", Color.Red, "think", Color.Yellow, " before you speak.", Color.Red)
		Chat:Send(args.player, "You have unmuted "..tostring(player), Color.Red)
		mutedplayers[tostring(player:GetSteamId())] = nil
	end
end
Events:Subscribe("PlayerChat", mute)


function muteonjoin(args)
	if mutedplayers[tostring(args.player:GetSteamId())] then
		args.player:SetNetworkValue("Muted", 1)
		Chat:Send(args.player, "You have been muted. Please ", Color.Red, "think", Color.Yellow, " before you speak next time.", Color.Red)
	end
end
Events:Subscribe("PlayerJoin", muteonjoin)