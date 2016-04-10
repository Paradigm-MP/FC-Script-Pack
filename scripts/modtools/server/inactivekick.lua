players = {}

function check()
	for p in Server:GetPlayers() do
		if not players[p:GetId()] then
			players[p:GetId()] = {pos = p:GetPosition(), t = Timer()}
		end
		if Vector3.Distance(players[p:GetId()].pos, p:GetPosition()) > 1 then
			players[p:GetId()].t:Restart()
			players[p:GetId()].pos = p:GetPosition()
		end
		if players[p:GetId()].t:GetMinutes() > 30 and not (p:GetValue("NT_TagName") == "[Admin]" or p:GetValue("NT_TagName") == "[Mod]") then
			p:Kick("You were inactive for too long.")
		end
	end
end
Events:Subscribe("TimeChange", check)
function quit(args)
	if players[args.player:GetId()] then
		players[args.player:GetId()] = nil
	end
end
Events:Subscribe("PlayerQuit", quit)