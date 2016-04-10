function GetLoot()
	local total = 0
	for o in DefaultWorld:GetWorldNetworkObjects() do
		if o:GetValue("LTier") then
			total = total + 1
		end
	end
	print(total)
end
Console:Subscribe("getloot", GetLoot)
function Getplayer()
	local total = 0
	for p in Server:GetPlayers() do
		print(p:GetName())
		total = total + 1
	end
	print("Total players: ",total)
end
Console:Subscribe("list", Getplayer)
function block()
	return false
end
Events:Subscribe("PlayerAchievementUnlock", block)