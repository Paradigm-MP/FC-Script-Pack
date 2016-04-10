function sModHealth(args, player) -- receives mod
	player:Damage(args.mod)
end
Network:Subscribe("ModHealth", sModHealth)