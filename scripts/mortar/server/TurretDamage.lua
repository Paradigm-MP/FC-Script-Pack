damage_enabled = true
function TurretDamagePly(args, player) -- receives dmg
	if damage_enabled == false or player:GetValue("CanHit") == false or player:GetValue("Invincible") then return end
	player:Damage(args.dmg)
end
Network:Subscribe("TurretDamagePly", TurretDamagePly)

function TurretDamageVeh(args, player) -- receives vehicle, new_health
	if damage_enabled == false then return end
	if IsValid(args.vehicle) then
		args.vehicle:SetHealth(args.new_health)
	end
end
Network:Subscribe("TurretDamageVeh", TurretDamageVeh)

function TurretChat(args)
	if args.text == "/dmg" then
		damage_enabled = not damage_enabled
		--Chat:Broadcast("Turret Damage Enabled: " .. tostring(damage_enabled), Color(255, 255, 0))
		return false
	end
end
--Events:Subscribe("PlayerChat", TurretChat)