function InitZombies()
	updatesPerSecond = 20  -- config how often the server updates the horde/zombie positions
	targetDistance = 2   -- config distance (in meters) a horde has to reach a waypoint, to select the next one
	hordeSize = 20 -- config # of zombies in a horde
	respawnTime = 360 -- config time in seconds for zombie to respawn after death

	mastercontrol = MasterControl()
	
	mastercontrol:NewHorde("epies1.txt")
	mastercontrol:NewHorde("epies2.txt")
	mastercontrol:NewHorde("epies3.txt")
	mastercontrol:NewHorde("epies4.txt")
	mastercontrol:NewHorde("epies5.txt")
	mastercontrol:NewHorde("epies6.txt")
	mastercontrol:NewHorde("epies7.txt")
	mastercontrol:NewHorde("epies8.txt")
	mastercontrol:NewHorde("epies9.txt")
	mastercontrol:NewHorde("epies10.txt")
	mastercontrol:NewHorde("epies11.txt")
	mastercontrol:NewHorde("epies12.txt")
	mastercontrol:NewHorde("epies13.txt")
	mastercontrol:NewHorde("epies14.txt")
	mastercontrol:NewHorde("epies15.txt")
	mastercontrol:NewHorde("epies16.txt")
	mastercontrol:NewHorde("epies17.txt")
	mastercontrol:NewHorde("epies18.txt")
	mastercontrol:NewHorde("epies19.txt")
	mastercontrol:NewHorde("epies20.txt")
	mastercontrol:NewHorde("epies21.txt")
	mastercontrol:NewHorde("epies22.txt")
	mastercontrol:NewHorde("epies23.txt")
	mastercontrol:NewHorde("epies24.txt")
	mastercontrol:NewHorde("epies25.txt")
	mastercontrol:NewHorde("epies26.txt")
	mastercontrol:NewHorde("epies27.txt")
	mastercontrol:NewHorde("epies28.txt")
	mastercontrol:NewHorde("epies29.txt")
	--
	mastercontrol:NewHorde("test1.txt")
	mastercontrol:NewHorde("test2.txt")
	--
	mastercontrol:NewHorde("GunungMerahRadarFacility.txt")
	mastercontrol:NewHorde("LembahCerah.txt")
	mastercontrol:NewHorde("PekanKerisPerak.txt")
	mastercontrol:NewHorde("SungaiCurah.txt")
	
	Events:Unsubscribe(zombie_load_event)
end
zombie_load_event = Events:Subscribe("ModuleLoad", InitZombies)