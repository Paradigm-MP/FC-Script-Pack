function CMDS(args)
	local cmd_args = args.text:split( " " )
	
	if cmd_args[1] == "/tptome" and args.player:GetValue("NT_TagName") == "[Admin]" then
		if #cmd_args < 2 then
            return false
        end
		
		local player = Player.Match( cmd_args[2] )[1]
		
		if IsValid(player) then
			player:SetPosition(args.player:GetPosition())
		end
		
		return false
	elseif args.text == "/ping" then 
		args.player:SendChatMessage("Ping: " .. tostring(args.player:GetPing()), Color(0, 255, 0))
		return false
	elseif cmd_args[1] == "/noobplayer" and #cmd_args == 2 and args.player:GetValue("NT_TagName") == "[Admin]" then
		local cmd = SQL:Command("delete from notnoobs where steamID = ?")
		local player = Player.Match( cmd_args[2] )[1]
		cmd:Bind(1, player:GetSteamId().id)
		cmd:Execute()
		--Chat:Send(args.player, tostring(player)
	elseif args.text == "/invin" and (args.player:GetValue("NT_TagName") == "[Admin]" or args.player:GetValue("NT_TagName") == "[Mod]") then
		if args.player:GetValue("Invincible") then
			args.player:SetNetworkValue("Invincible", nil)
			Chat:Send(args.player, "Invincibility off.", Color.Green)
		else
			args.player:SetNetworkValue("Invincible", 1)
			Chat:Send(args.player, "Invincibility on.", Color.Green)
		end
		return false
	elseif cmd_args[1] == "/me" and string.len(string.trim(string.sub(args.text, 4, string.len(args.text)))) > 1 then
		Chat:Broadcast(args.player:GetName()..string.sub(args.text, 4, string.len(args.text)), args.player:GetColor())
	elseif args.text == "/disguise" and args.player:GetValue("NT_TagName") == "[Admin]" then
		local disguised = args.player:GetValue("Disguised")
		if disguised == nil then
			args.player:SetValue("Disguised", true)
		else
			args.player:SetValue("Disguised", not disguised)
		end
		
		
		return false
	end
		
end
Events:Subscribe("PlayerChat", CMDS)