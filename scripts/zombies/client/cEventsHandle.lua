class 'ZombieEvents'

function ZombieEvents:__init()
	
end

function ZombieEvents:DamageZombie(args)
	Network:Send("DamageZombie", args)
end

zevent = ZombieEvents()

Events:Subscribe("DamageZombieEvent", zevent, zevent.DamageZombie)