function MeleeAttack (args, sender)
	if sender then
		if not args.ent then return end
		local entityType = args.ent.__type
		if entityType ~= "Player" then return end
		if args.ent:GetValue("CanHit") == false or sender:GetValue("CanHit") == false then return end
		local velocity2 = -sender:GetAngle() * sender:GetLinearVelocity()
		local velocityY = -velocity2.y
		local velocity = -velocity2.z
		local pos = sender:GetPosition()
		--sender:SetValue("Stamina", args.stamina)
		if sender 
		and args.seconds > 1.5 
		and not sender:InVehicle() 
		and velocityY < 3 
		and velocity < 15 
		and pos.y > 200.15 
		and sender:GetHealth() > 0 
		and not sender:GetParachuting() 
		and args.state ~= 45 
		and args.state ~= 253 
		and args.state ~= 425 
		and args.state ~= 423 
		and args.state ~= 135 
		and args.state ~= 15 
		and args.state ~= 18 
		and args.state ~= 338 
		and args.state ~= 56 
		and args.state ~= 88 
		and args.state ~= 341 
		and args.state ~= 333 
		and args.state ~= 334 
		and args.state ~= 64 
		and args.state ~= 21 
		and args.state ~= 22 
		and args.state ~= 34 
		and args.state ~= 440 
		and args.state ~= 323 
		and args.state ~= 190 
		and args.state ~= 291 
		and args.state ~= 223 
		and args.state ~= 215 
		and args.state ~= 110 
		and args.state ~= 257 
		and args.state ~= 256 
		and args.state ~= 167 
		and args.state ~= 30 
		and args.state ~= 29 
		and args.state ~= 166 
		and args.state ~= 148 
		and args.state ~= 28 
		and args.state ~= 188 
		and args.state ~= 147 
		and args.state ~= 36 
		and args.state ~= 422 
		and args.state ~= 428 
		and args.state ~= 255 
		and args.state ~= 45 
		and args.state ~= 47 
		and args.state ~= 46 
		and args.state ~= 50 
		and args.state ~= 468 
		and args.state ~= 40 
		and args.state ~= 438 
		and args.state ~= 158 
		and args.state ~= 187 
		and args.state ~= 25 
		and args.state ~= 455 
		and args.state ~= 43 
		and args.state ~= 216 
		and args.state ~= 208 
		and args.state ~= 415 
		and args.state ~= 211 
		and args.state ~= 474 
		and args.state ~= 209 
		and args.state ~= 210 
		and args.state ~= 427 
		and args.state ~= 207 
		and args.state ~= 324 
		and args.state ~= 221 
		and args.state ~= 325 
		and args.state ~= 219 
		and args.state ~= 212 
		and args.state ~= 414 
		and args.state ~= 213 
		and args.state ~= 217 
		and args.state ~= 214 
		and args.state ~= 326 
		and args.state ~= 429 
		and args.state ~= 222 
		and args.state ~= 218 
		and args.state ~= 418 
		and args.state ~= 220 
		and args.state ~= 294 
		and args.state ~= 23 
		and args.state ~= 153 
		and args.state ~= 24 
		and args.state ~= 38 
		and args.state ~= 191 
		and args.state ~= 39 
		and args.state ~= 159 
		and args.state ~= 275 
		and args.state ~= 254 then
			--for player in Server:GetPlayers() do
				local pPos = args.ent:GetPosition()
				local sPos = sender:GetPosition()
				local dist = Vector3.Distance (pPos, sPos)
				local engv = tonumber(sender:GetValue("Melee_Sta_1")) / 50
				local energyNeeded = 7.5 - engv
				if energyNeeded < 0 then
					energyNeeded = 0
				end
				local dmg1 = tonumber(sender:GetValue("Melee_Dmg_1"))
				local dmgv = dmg1 / 500
				local damage = 0.04 + dmgv
				local energy = tonumber(args.stamina)
				--print("energyNeeded ", energyNeeded)
				--print("damage ", damage)
				if energy >= energyNeeded then
					local hurtDist = 2
					if dist < hurtDist then
						if dmg1 >= 15 and dmg1 < 30 then
							-- trigger the extra effects
							local fxargs = {}
							fxargs.pos = pPos
							fxargs.id = 35
							dmgv = dmgv + 0.15
							Network:SendNearby(sender, "QEffect", fxargs)
							Network:Send(sender, "QEffect", fxargs)
						elseif dmg1 >= 30 and dmg1 < 45 then
							-- trigger the extra effects
							local fxargs = {}
							fxargs.pos = pPos
							fxargs.id = 411
							dmgv = dmgv + 0.3
							Network:SendNearby(sender, "QEffect", fxargs)
							Network:Send(sender, "QEffect", fxargs)
						elseif dmg1 >= 45 and dmg1 < 60 then
							-- trigger the extra effects
							local fxargs = {}
							fxargs.pos = pPos
							fxargs.id = 156
							dmgv = dmgv + 0.6
							Network:SendNearby(sender, "QEffect", fxargs)
							Network:Send(sender, "QEffect", fxargs)
						elseif dmg1 >= 60 and dmg1 < 75 then
							-- trigger the extra effects
							if args.ent ~= sender then
								local fxargs = {}
								fxargs.pos = pPos
								fxargs.id = 259
								Network:SendNearby(sender, "QEffect", fxargs)
								Network:Send(sender, "QEffect", fxargs)
							end
						elseif dmg1 >= 75 and dmg1 < 90 then
							-- trigger the extra effects
							if args.ent ~= sender then
								local fxargs = {}
								fxargs.pos = pPos
								fxargs.id = 252
								Network:SendNearby(sender, "QEffect", fxargs)
								fxargs.pos = sPos
								fxargs.id = 135
								Network:Send(sender, "QEffect", fxargs)
							end
						elseif dmg1 >= 90 then
							-- trigger the extra effects
							if player ~= sender then
								local fxargs = {}
								fxargs.pos = pPos
								fxargs.id = 75
								Network:SendNearby(sender, "QEffect", fxargs)
								fxargs.pos = sPos
								fxargs.id = 135
								Network:Send(sender, "QEffect", fxargs)
							end
						end
					end
					if dist < hurtDist and args.ent ~= sender then
						args.ent:Damage(damage, DamageEntity.Physics, sender)
						local fxargs = {}
						fxargs.pos = pPos + Vector3(0,1.4,0)
						fxargs.angle = args.ent:GetAngle()
						Network:SendNearby(sender, "QEffect2", fxargs)
						Network:Send(sender, "QEffect2", fxargs)
						--Network:Send(player, "QEffect", 411)
					end
				end
			--end
		end
	end
end
Network:Subscribe ("MeleeToServer", MeleeAttack)
function MeleeAttackBig (args, sender)
	if sender then
		if not args.ent then return end
		local entityType = args.ent.__type
		if entityType ~= "Player" then return end
		if args.ent:GetValue("CanHit") == false or sender:GetValue("CanHit") == false then return end
		local velocity2 = -sender:GetAngle() * sender:GetLinearVelocity()
		local velocityY = -velocity2.y
		local velocity = -velocity2.z
		local pos = sender:GetPosition()
		--sender:SetValue("Stamina", args.stamina)
		if sender 
		and args.seconds > 1.5 
		and not sender:InVehicle() 
		and velocity < 15 
		and velocityY < 5 
		and pos.y > 200.15 
		and sender:GetValue("DisableKick") ~= 1 
		and sender:GetHealth() > 0 
		and not sender:GetParachuting() 
		and args.state ~= 45 
		and args.state ~= 253 
		and args.state ~= 425 
		and args.state ~= 423 
		and args.state ~= 135 
		and args.state ~= 15 
		and args.state ~= 18 
		and args.state ~= 338 
		and args.state ~= 56 
		and args.state ~= 88 
		and args.state ~= 341 
		and args.state ~= 333 
		and args.state ~= 334 
		and args.state ~= 64 
		and args.state ~= 21 
		and args.state ~= 22 
		and args.state ~= 34 
		and args.state ~= 440 
		and args.state ~= 323 
		and args.state ~= 190 
		and args.state ~= 291 
		and args.state ~= 223 
		and args.state ~= 215 
		and args.state ~= 110 
		and args.state ~= 257 
		and args.state ~= 256 
		and args.state ~= 167 
		and args.state ~= 30 
		and args.state ~= 29 
		and args.state ~= 166 
		and args.state ~= 148 
		and args.state ~= 28 
		and args.state ~= 188 
		and args.state ~= 147 
		and args.state ~= 36 
		and args.state ~= 422 
		and args.state ~= 428 
		and args.state ~= 255 
		and args.state ~= 45 
		and args.state ~= 47 
		and args.state ~= 46 
		and args.state ~= 50 
		and args.state ~= 468 
		and args.state ~= 40 
		and args.state ~= 438 
		and args.state ~= 158 
		and args.state ~= 187 
		and args.state ~= 25 
		and args.state ~= 455 
		and args.state ~= 43 
		and args.state ~= 216 
		and args.state ~= 208 
		and args.state ~= 415 
		and args.state ~= 211 
		and args.state ~= 474 
		and args.state ~= 209 
		and args.state ~= 210 
		and args.state ~= 427 
		and args.state ~= 207 
		and args.state ~= 324 
		and args.state ~= 221 
		and args.state ~= 325 
		and args.state ~= 219 
		and args.state ~= 212 
		and args.state ~= 414 
		and args.state ~= 213 
		and args.state ~= 217 
		and args.state ~= 214 
		and args.state ~= 326 
		and args.state ~= 429 
		and args.state ~= 222 
		and args.state ~= 218 
		and args.state ~= 418 
		and args.state ~= 220 
		and args.state ~= 294 
		and args.state ~= 23 
		and args.state ~= 153 
		and args.state ~= 24 
		and args.state ~= 38 
		and args.state ~= 191 
		and args.state ~= 39 
		and args.state ~= 159 
		and args.state ~= 275 
		and args.state ~= 254 then
			--for player in Server:GetPlayers () do
				--local target = sender:GetAimTarget()
				local pPos = args.ent:GetPosition()
				local sPos = sender:GetPosition()
				local dist = Vector3.Distance (pPos, sPos)
				local maxDist = 100 --effect viewing radius
				local engv = tonumber(sender:GetValue("Melee_Sta_2")) / 40
				local energyNeeded = 20 - engv
				if energyNeeded < 0 then
					energyNeeded = 0
				end
				local dmg1 = tonumber(sender:GetValue("Melee_Dmg_2"))
				local dmgv = dmg1 / 500
				local damage = 0.1 + dmgv
				local energy = tonumber(args.stamina)
				--print("energyNeeded ", energyNeeded)
				--print("damage ", damage)
				if energy >= energyNeeded then
					local hurtDist = 5
					if dist < hurtDist then
						if dmg1 >= 15 and dmg1 < 30 then
							-- trigger the extra effects
							local fxargs = {}
							fxargs.pos = pPos
							fxargs.id = 35
							dmgv = dmgv + 0.15
							Network:SendNearby(sender, "QEffect", fxargs)
							Network:Send(sender, "QEffect", fxargs)
						elseif dmg1 >= 30 and dmg1 < 45 then
							-- trigger the extra effects
							local fxargs = {}
							fxargs.pos = pPos
							fxargs.id = 411
							dmgv = dmgv + 0.3
							Network:SendNearby(sender, "QEffect", fxargs)
							Network:Send(sender, "QEffect", fxargs)
						elseif dmg1 >= 45 and dmg1 < 60 then
							-- trigger the extra effects
							local fxargs = {}
							fxargs.pos = pPos
							fxargs.id = 156
							dmgv = dmgv + 0.6
							Network:SendNearby(sender, "QEffect", fxargs)
							Network:Send(sender, "QEffect", fxargs)
						elseif dmg1 >= 60 and dmg1 < 75 then
							-- trigger the extra effects
							if args.ent ~= sender then
								local fxargs = {}
								fxargs.pos = pPos
								fxargs.id = 259
								Network:SendNearby(sender, "QEffect", fxargs)
								Network:Send(sender, "QEffect", fxargs)
							end
						elseif dmg1 >= 75 and dmg1 < 90 then
							-- trigger the extra effects
							if args.ent ~= sender then
								local fxargs = {}
								fxargs.pos = pPos
								fxargs.id = 252
								Network:SendNearby(sender, "QEffect", fxargs)
								fxargs.pos = sPos
								fxargs.id = 135
								Network:Send(sender, "QEffect", fxargs)
							end
						elseif dmg1 >= 90 then
							-- trigger the extra effects
							if player ~= sender then
								local fxargs = {}
								fxargs.pos = pPos
								fxargs.id = 75
								Network:SendNearby(sender, "QEffect", fxargs)
								fxargs.pos = sPos
								fxargs.id = 135
								Network:Send(sender, "QEffect", fxargs)
							end
						end
					end
					if dist < hurtDist and args.ent ~= sender then
						args.ent:Damage(damage, DamageEntity.Physics, sender)
						local fxargs = {}
						fxargs.pos = pPos + Vector3(0,1.4,0)
						fxargs.angle = args.ent:GetAngle()
						Network:SendNearby(sender, "QEffect2", fxargs)
						Network:Send(sender, "QEffect2", fxargs)
						--Network:Send(player, "QEffect", 411)
					end
				end
			--end
		end
	end
end
Network:Subscribe ("MeleeBigToServer", MeleeAttackBig)