class 'Mortar'

function Mortar:__init()
	gunargs = {}
	gunargs.model = "general.blz/gae09-b.lod"
	gunargs.collision = "general.blz/gae09_lod1-b_col.pfx"
	--
	turrets = {}
	bullets = {}
	effects = {}
	fire_interval = 2.5
	base_velocity = 67
	gravity = 14
	bullet_id = 246
	
	explosion_fx = 211
	--
	-- effect 28 : muzzle flash
	-- effect 90 : huge muzzle flash
	-- effect 432 : muzzle flash
	-- effect 35 : explosion ?
	-- effect 40 : ground splat large?
	-- effect 86 : explosion ? 
	-- effect 121 : ground on fire?
	-- effect 411 : explosion ?
	
	-- effect 0 & 1 : explosion ?
	death_timer = Timer()
end

function Mortar:Scan()
	for obj in Client:GetStaticObjects() do
		if IsValid(obj) then
			local id = obj:GetId()
			if obj:GetValue("PlayerMortar") and not turrets[id] then
				obj:SetValue("LastFire", os.clock())
				turrets[id] = obj
			end
		end
	end
	
	for id, turret in pairs(turrets) do
		if not IsValid(turret) then turrets[id] = nil end
	end
end

function Mortar:ObjectListener(args)
	if args.key ~= "FireMortarShell" then return end
	local id = args.object:GetId()
	if turrets[id] and IsValid(turrets[id]) then
		self:Fire({turret = args.object})
	end
end

function Mortar:Fire(args)
	local current_time = os.clock()
	local plypos = LocalPlayer:GetPosition()

	local turret = args.turret
		
	if Vector3.Distance(plypos, turret:GetPosition()) < 450 then
		local target = Player.GetById(turret:GetValue("iTarget"))
		if IsValid(target) then
			local turret_pos = turret:GetPosition()
			local target_pos = target:GetPosition()
			
			local open = false
			while (open == false) do
				newindex = math.random(1, 999999)
				if not bullets[newindex] then
					open = true
				end
			end
			bullets[newindex] = {}
			bullets[newindex].time = current_time
			bullets[newindex].position = turret_pos + Vector3(0, 1, 0)
			bullets[newindex].angle = turret:GetAngle() * Angle(math.pi, 0, 0)
			bullets[newindex].origin = turret_pos
			bullets[newindex].target = target_pos
			bullets[newindex].owner = turret:GetValue("PlayerMortar")
			bullets[newindex].turret = turret
			--bullets[newindex].velocity = (turret:GetAngle() * Angle(math.pi, 0, 0)) * Vector3(turret:GetAngle().x, 20, turret:GetAngle().z)
			--bullets[newindex].velocity = (turret:GetAngle() * Angle(math.pi, 0, 0)) * (Vector3.Forward * bullet_speed) + (Vector3.Up * bullet_speed)
			
			
			--local h = target_pos.y - turret_pos.y
			--local ay = -9.8 -- gravity
			--local vi = base_velocity
			--local d = Vector2.Distance(Vector2(turret_pos.x, turret_pos.z), Vector2(target_pos.x, target_pos.z)) -- horizontal distance between the two
			--local t = math.sqrt(((h * ay) + (vi ^ 2)) + math.sqrt((((h * ay + (vi ^ 2))) ^ 2) - ((ay ^ 2) * ((h ^ 2) + (d ^ 2)))) / (.5 * (ay ^ 2)))
			--local theta = math.acos(d / (vi * t))
			
			--print(t, theta)
			
			
			local x = Vector2.Distance(Vector2(turret_pos.x, turret_pos.z), Vector2(target_pos.x, target_pos.z)) -- horizontal distance between the two
			local y = target_pos.y - turret_pos.y
			local g = gravity
			local v = base_velocity
			--local theta = math.atan(((v ^ 2) - math.sqrt((g * ((g * x ^ 2) + (2 * y * (v ^ 2))))) / (g * x)))
			--local theta2 = math.atan(((v ^ 2) + math.sqrt((g * ((g * x ^ 2) + (2 * y * (v ^ 2))))) / (g * x)))			
			-- local theta = math.atan(((v ^ 2) - math.sqrt((v ^ 4) - (g * ((g * (x ^2)) + (2 * y * (v ^ 2)))))) / (g * x)) - nice path
			local theta = math.atan(((v ^ 2) + math.sqrt((v ^ 4) - (g * ((g * (x ^2)) + (2 * y * (v ^ 2)))))) / (g * x))
			if IsNaN(theta) then
				bullets[newindex] = nil
				return
			end
			--Chat:Print("Theta: " .. tostring(theta), Color(255, 0, 255))
			--print(theta)
			
			local tmp = (target_pos - turret:GetPosition()):Normalized()
			if IsNaN(tmp) then
				bullets[newindex] = nil
				return
			end
			--Chat:Print("TMP: " .. tostring(tmp), Color(0, 255, 0))
			local horizontal = Vector3(tmp.x, 0, tmp.z) * (math.cos(theta) * v)
			if IsNaN(horizontal) then
				bullets[newindex] = nil
				return
			end
			--Chat:Print("Horizontal: " .. tostring(horizontal), Color(0, 255, 0))
			local velocity = Vector3(horizontal.x, math.sin(theta) * v, horizontal.z)
			if IsNaN(velocity) then
				bullets[newindex] = nil
				return
			end
			--Chat:Print("Velocity: " .. tostring(velocity), Color(0, 255, 0))
			
			--Chat:Print("init magic: " .. tostring(math.cos(theta) * v), Color.Red)
			--Chat:Print("math.cos(theta2): " .. tostring(math.cos(theta)), Color.Red)
			
			bullets[newindex].velocity = velocity
			
			bullets[newindex].bullet = ClientStaticObject.Create(
			{
				position = turret_pos + Vector3(0, 1, 0),
				angle = bullets[newindex].angle,
				model = "general.blz/wea16-wea16_02.lod",
				collision = "general.blz/wea16_lod1-wea16_02_col.pfx",
				fixed = true
			})
			bullets[newindex].effect = ClientEffect.Create(AssetLocation.Game, 
			{
				effect_id = 246,
				position = turret_pos,
				angle = bullets[newindex].angle
			})
			bullets[newindex].light_hold = Vector3(0, 0, 0)
			
			table.insert(effects, ClientEffect.Create(AssetLocation.Game, 
			{
				effect_id = 115,
				position = turret:GetPosition() + Vector3(0, .55, 0),
				angle = Angle(0, 0, 0)
			}))
			local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 0,
				sound_id = 12,
				position = turret:GetPosition() + Vector3(0, .55, 0),
				angle = Angle()
			})
			sound:SetParameter(0,0)
			sound:SetParameter(1,0)
			sound:SetParameter(2,0.75)
			ClientLight.Play({position = turret:GetPosition() + Vector3(0, .55, 0), color = Color(255,217,0), multiplier = 5, radius = 10, timeout = 0.175})
		end
	end
end

function Mortar:HandleBullets(args) -- move and handle bullets
	local new_time = os.clock()
	for index, itable in pairs(bullets) do
		if new_time - bullets[index].time < 60 then
			local bullet = itable.bullet
			local effect = itable.effect
			local target = itable.target
			if IsValid(bullet) and IsValid(effect) and IsValid(target) then
				local ray = Physics:Raycast(bullet:GetPosition(), bullets[index].angle * Vector3.Forward, 0, 15, false)
				if ray.distance < 2.5 then
					--print("ray.distance: " .. tostring(ray.distance))
					
					local dist = Vector3.Distance(LocalPlayer:GetPosition(), ray.position)
					if dist <= 17.5 and LocalPlayer:GetHealth() > 0 and death_timer:GetSeconds() > 30 then
						local friends = LocalPlayer:GetValue("Friends")
						if friends and not LocalPlayer:GetValue("Friends"):find(tostring(bullets[index].owner)) and bullets[index].owner ~= LocalPlayer:GetSteamId().id then
							if dist <= 10 then
								Network:Send("TurretDamagePly", {dmg = 1})
							elseif dist <= 13.5 then
								Network:Send("TurretDamagePly", {dmg = math.random(45, 60) / 100})
							else
								Network:Send("TurretDamagePly", {dmg = math.random(27, 42) / 100})
							end
							table.insert(effects, ClientEffect.Create(AssetLocation.Game, 
							{
								effect_id = 189,
								position = ray.position,
								angle = Angle(0, 0, 0)
							}))
						end
					end
					
					local self_pos = LocalPlayer:GetPosition()
					--[[for static in Client:GetStaticObjects() do
						if static:GetValue("IsClaimOBJ") then
							local distance = Vector3.Distance(ray.position, static:GetPosition())
							local ply_dist = Vector3.Distance(self_pos, ray.position)
							if distance < 15 then
								local closest = true
								for player in Client:GetStreamedPlayers() do
									if Vector3.Distance(player:GetPosition(), ray.position) < ply_dist then
										closest = false
									end
								end
								if closest == true and IsValid(bullets[index].turret) then
									--print(static:GetValue("Health"))
									if not bullets[index].turret:GetValue("MortarFriends"):find(tostring(bullets[index].owner)) and static:GetValue("SteamIDid") ~= bullets[index].owner then
										--Chat:Print("Mortar Dmg Building for " .. tostring((15 - distance) * 2.25), Color.Red)
										Events:Fire("LC_ShootClaimObject", {target = static, damage = (15 - distance) * 2.25, absolute_damage = true})
									else
										--Chat:Print("Mortar Friendly fire on object, but didnt do shit", Color.Green)
									end
								end
							end
						end
					end--]]
					
					table.insert(effects, ClientEffect.Create(AssetLocation.Game,
					{
						effect_id = explosion_fx,
						position = ray.position,
						angle = Angle(0, 0, 0)
					}))

					if IsValid(bullets[index].bullet) then bullets[index].bullet:Remove() end
					if IsValid(bullets[index].effect) then bullets[index].effect:Remove() end
					if IsValid(bullets[index].tracer) then bullets[index].tracer:Remove() end
					bullets[index] = nil
				else
					--local target_pos = target:GetPosition()
					--local angleyaw = Angle.FromVectors(Vector3.Forward, target_pos - bullets[index].position).yaw
					--local anglepitch = Angle.FromVectors(Vector3.Forward, target_pos - bullets[index].position).pitch
					--local ang = Angle(angleyaw, anglepitch, 0)
					--bullet:SetAngle(ang) -- aim at target
					--bullets[index].angle = ang
					--
					local old_pos = bullets[index].position
					
					bullets[index].velocity.y = bullets[index].velocity.y - (args.delta * gravity)
					bullets[index].position = bullets[index].position + (bullets[index].velocity * args.delta)
					
					local new_pos = bullets[index].position
					local ang = Angle.FromVectors(Vector3.Forward, (old_pos) - new_pos)
					bullet:SetAngle(Angle(ang.yaw, ang.pitch, 0) * Angle(math.pi, 0, 0)) -- sick realistic bullet drop
					bullets[index].angle = bullet:GetAngle()
					
					bullet:SetPosition(bullets[index].position)
					local new_pos = bullets[index].position
					
					local velocity = bullets[index].velocity
					
					--print("new velocity: " .. tostring(bullets[index].velocity))
					
					if velocity.y > 0 then
						effect:SetPosition(bullets[index].position + (bullets[index].angle * (Vector3.Backward * .25)))
					else
						if bullets[index].light_hold == Vector3(0, 0, 0) then
							bullets[index].light_hold = effect:GetPosition()
							effect:Remove()
							bullets[index].effect = nil
							bullets[index].effect = ClientEffect.Create(AssetLocation.Game, 
							{
								--effect_id = 355,
								effect_id = 236,
								position = bullets[index].light_hold,
								angle = bullets[index].angle
							})
							bullets[index].tracer = ClientEffect.Create(AssetLocation.Game, 
							{
								effect_id = 68, -- 355
								position = bullets[index].light_hold,
								angle = bullets[index].angle
							})
						end
						effect:SetPosition(bullets[index].position + (bullets[index].angle * (Vector3.Backward * .25)))
						bullets[index].tracer:SetPosition(effect:GetPosition())
					end
				end
			end
		else
			if IsValid(bullets[index].bullet) then bullets[index].bullet:Remove() end
			if IsValid(bullets[index].effect) then bullets[index].effect:Remove() end
			if IsValid(bullets[index].tracer) then bullets[index].tracer:Remove() end
			bullets[index] = nil
		end
	end
end

function Mortar:LocalPlayerDeath()
	death_timer:Restart()
end

function Mortar:Render()
	local transform = Transform3()
    transform:Translate(LocalPlayer:GetPosition()) -- move it down a bit
    transform:Rotate(Angle(0, 0.5 * math.pi, 0))
    Render:SetTransform(transform)
    Render:FillCircle(Vector3.Zero, 15, Color(255, 0, 0, 100))
    Render:ResetTransform()
	
	for index, itable in pairs(bullets) do
		if IsValid(itable.bullet) then
			Render:FillCircle(itable.bullet:GetPosition(), 2.5, Color(0, 255, 0, 25))
		end
	end
end

function Mortar:CalcView()
	for index, itable in pairs(bullets) do
		if IsValid(itable.bullet) then
			Camera:SetPosition(itable.bullet:GetPosition())
			Camera:SetAngle(itable.bullet:GetAngle())
		end
	end
end

function Mortar:OnUnload()
	for index, itable in pairs(bullets) do
		if IsValid(itable.bullet) then
			itable.bullet:Remove()
		end
		if IsValid(itable.effect) then
			itable.effect:Remove()
		end
		if IsValid(itable.tracer) then
			itable.tracer:Remove()
		end
	end
	for index, effect in pairs(effects) do
		if IsValid(effect) then effect:Remove() end
	end
end

mortar = Mortar()

Events:Subscribe("NetworkObjectValueChange", mortar, mortar.ObjectListener)
Events:Subscribe("SecondTick", mortar, mortar.Scan)
Events:Subscribe("PostTick", mortar, mortar.HandleBullets)
Events:Subscribe("LocalPlayerDeath", mortar, mortar.LocalPlayerDeath)
--Events:Subscribe("Render", mortar, mortar.Render)
--Events:Subscribe("CalcView", mortar, mortar.CalcView)
Events:Subscribe("ModuleUnload", mortar, mortar.OnUnload)
