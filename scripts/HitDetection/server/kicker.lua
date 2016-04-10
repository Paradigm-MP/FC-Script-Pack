function kick(args, sender)
	sender:Kick("You cannot use miniguns on this server!")
end
Network:Subscribe("KickMe", kick)