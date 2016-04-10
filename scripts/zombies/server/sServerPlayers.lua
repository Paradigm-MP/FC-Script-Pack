server_players = {}
function iGetServerPlayers()
	server_players = nil
	server_players = {}
	for p in Server:GetPlayers() do
		server_players[p:GetId()] = {ply = p, pos = p:GetPosition()}
	end
end
Events:Subscribe("SecondTick", iGetServerPlayers)