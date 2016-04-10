function HandleAnomaly(args, player)
	if args then
		local anomaly = args.irreg
	else
		local anomaly = "<unknown>"
	end
	print(tostring(player:GetName()) .. " had an ammo irregularity of " .. tostring(anomaly) .. " and was kicked from the server", Color.Green)
	--player:Kick()
end
Network:Subscribe("AmmoKickInClip", HandleAnomaly)
Network:Subscribe("AmmoKickInReload", HandleAnomaly)
Network:Subscribe("AmmoKickInReserve", HandleAnomaly)

function Damage(args, player)
	if not IsValid(player) then return end
	if IsValid(args.target) then
		local health = args.target:GetHealth()
		if args.target.Damage then
			args.target:Damage(args.damage, DamageEntity.Explosion, player)
		else
			args.target:SetHealth(health - args.damage)
		end
		if health - args.damage <= 0 then -- killed other player
			local achs = player:GetValue("Achievements")
			if not achs.ach_kill50 then
				Events:Fire("SetAchievementProgress", {player = player, achievement = "ach_kill50", progress = 1})
				Events:Fire("SetAchievementProgress", {player = player, achievement = "ach_kill200", progress = 1})
				Events:Fire("SetAchievementProgress", {player = player, achievement = "ach_kill1000", progress = 1})
			else
				if achs.ach_kill50.progress < 50 then
						Events:Fire("SetAchievementProgress", {player = player, achievement = "ach_kill50", progress = achs.ach_kill50.progress + 1})
					end
					if achs.ach_kill200.progress < 200 then
						Events:Fire("SetAchievementProgress", {player = player, achievement = "ach_kill200", progress = achs.ach_kill200.progress + 1})
					end
					if achs.ach_kill1000.progress < 1000 then
						Events:Fire("SetAchievementProgress", {player = player, achievement = "ach_kill1000", progress = achs.ach_kill1000.progress + 1})
					end
			end
			if not achs.ach_killstaff or achs.ach_killstaff.progress == false then
				local nametag = player:GetValue("NT_TagName")
				if nametag == "[Admin]" or nametag == "[Mod]" then
					Events:Fire("SetAchievementProgress", {player = player, achievement = "ach_killstaff", progress = true})
				end
			end
		end
	end
	--Chat:Broadcast(tostring(player:GetName()) .. " hit " .. tostring(args.target:GetName()) .. " for " .. tostring(args.damage * 100), Color(0, 255, 0))
end
Network:Subscribe("HitDetected", Damage)

function DamageExplosion(args, player)
	if args.attacker then
		player:Damage(args.damage, DamageEntity.Explosion, args.attacker)
		--Chat:Broadcast(tostring(args.attacker:GetName()) .. " hit " .. tostring(player:GetName()) .. " for " .. tostring(args.damage * 100), Color(0, 255, 0))
		local health = player:GetHealth()
		if health - args.damage <= 0 then -- killed other player
			local achs = args.attacker:GetValue("Achievements")
			if not achs.ach_kill50 then
					Events:Fire("SetAchievementProgress", {player = args.attacker, achievement = "ach_kill50", progress = 1})
					Events:Fire("SetAchievementProgress", {player = args.attacker, achievement = "ach_kill200", progress = 1})
					Events:Fire("SetAchievementProgress", {player = args.attacker, achievement = "ach_kill1000", progress = 1})
				else
					if achs.ach_kill50.progress < 50 then
						Events:Fire("SetAchievementProgress", {player = args.attacker, achievement = "ach_kill50", progress = achs.ach_kill50.progress + 1})
					end
					if achs.ach_kill200.progress < 200 then
						Events:Fire("SetAchievementProgress", {player = args.attacker, achievement = "ach_kill200", progress = achs.ach_kill200.progress + 1})
					end
					if achs.ach_kill1000.progress < 1000 then
						Events:Fire("SetAchievementProgress", {player = args.attacker, achievement = "ach_kill1000", progress = achs.ach_kill1000.progress + 1})
					end
			end
			if not achs.ach_killstaff or achs.ach_killstaff.progress == false then
				local nametag = player:GetValue("NT_TagName")
				if nametag == "[Admin]" or nametag == "[Mod]" then
					Events:Fire("SetAchievementProgress", {player = args.attacker, achievement = "ach_killstaff", progress = true})
				end
			end
		end
	else
		player:Damage(args.damage, DamageEntity.Explosion)
	end
end
Network:Subscribe("ExplosionHit", DamageExplosion)