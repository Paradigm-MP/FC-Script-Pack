function GivePlayerExp(args)
	Network:Send("GetRandomExp", {xp = args.exp})
	Chat:Print("Net Send GetRandomEXP", Color.Blue)
end
Events:Subscribe("RandomExpCrossModule", GivePlayerExp)