function chat(args)
	local words = string.split(args.text, " ")
	if words[1] == "/cleardb" and words[2] and tostring(args.player:GetValue("NT_TagName")) == "[Admin]" then
		local cmd = "DROP TABLE IF EXISTS "..tostring(words[2])
		SQL:Execute(cmd)
		--Chat:Broadcast(tostring(value).." SQL database cleared by "..args.player:GetName(), Color.Red)
		Chat:Send(args.player, "You probably want to reload the module that depends on that database now.", Color(200,200,200))
	end
end
Events:Subscribe("PlayerChat", chat)