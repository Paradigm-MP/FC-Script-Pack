timer = Timer()
function Collide(args)
	if timer:GetSeconds() > 3 then
		if args.vehicle then
			Network:Send("PersonalityCollide", -2)
		end
		timer:Restart()
	end
end
Events:Subscribe("VehicleCollide", Collide)
function Explosion(args)
	if args.attacker then
		Network:Send("PersonalityExplode", -4)
	else
		Network:Send("PersonalityExplode", 1)
	end
end
Events:Subscribe("LocalPlayerExplosionHit", Explosion)

function AddHelp()
    Events:Fire( "HelpAddItem",
        {
            name = "Personality",
            text = 
                "Throughout your time here, your actions will dictate a personality value for you. "..
                "This value is calculated through a number of different ways, and in the end only " ..
                "affects one thing: your pet. It will take some time before you have a pet, so do "..
				"not worry."
       } )
end

function RemoveHelp()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Personality"
        } )
end

Events:Subscribe("ModulesLoad", AddHelp)
Events:Subscribe("ModuleUnload", RemoveHelp)