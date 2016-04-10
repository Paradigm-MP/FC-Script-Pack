class 'Turret'

function Turret:__init()
	turrets = {}
	bullets = {}
	effects = {}
	fire_interval = .35
	bullet_speed = 1.5
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
end

function Turret:Scan()
	for obj in Client:GetStaticObjects() do
		if IsValid(obj) then
			local id = obj:GetId()
			if obj:GetValue("iTarget") and not turrets[id] and not obj:GetValue("PlayerMortar") then
				obj:SetValue("LastFire", os.clock())
				turrets[id] = obj
			end
		end
	end
end

function Turret:Fire()
	local current_time = os.clock()
	local plypos = LocalPlayer:GetPosition()
	for index, turret in pairs(turrets) do
		if IsValid(turret) then
			if turret:GetValue("iTarget") then
				if Vector3.Distance(plypos, turret:GetPosition()) < 450 then
					local target = Player.GetById(turret:GetValue("iTarget"))
					if IsValid(target) then
						--
						if current_time - turret:GetValue("LastFire") > fire_interval then
							turret:SetValue("LastFire", current_time)
							local open = false
							while (open == false) do
								newindex = math.random(1, 999999)
								if not bullets[newindex] then
									open = true
								end
							end
							bullets[newindex] = {}
							bullets[newindex].time = current_time
							bullets[newindex].position = turret:GetPosition() + Vector3(0, .75, 0)
							bullets[newindex].angle = turret:GetAngle() * Angle(math.pi, 0, 0)
							bullets[newindex].origin = turret:GetPosition()
							bullets[newindex].bullet = ClientStaticObject.Create(
							{
								position = turret:GetPosition(),
								angle = bullets[newindex].angle,
								model = "general.blz/wea16-wea16_02.lod",
								collision = "general.blz/wea16_lod1-wea16_02_col.pfx",
								fixed = true
							})
							bullets[newindex].effect = ClientEffect.Create(AssetLocation.Game, 
							{
								effect_id = 246,
								position = turret:GetPosition(),
								angle = bullets[newindex].angle
							})
						end
					end
				else
					turrets[index] = nil
				end
			end
		else
			turrets[index] = nil
		end
	end
end

function Turret:HandleBullets() -- move and handle bullets
	local new_time = os.clock()
	for index, itable in pairs(bullets) do
		if new_time - bullets[index].time < 10 then
			local bullet = itable.bullet
			local effect = itable.effect
			if IsValid(bullet) and IsValid(effect) then
				local ray = Physics:Raycast(bullet:GetPosition(), bullets[index].angle * Vector3.Forward, 0, 5, false)
				if ray.distance < 2.5 then
					if ray.entity then
						if ray.entity.__type == "LocalPlayer" then
							if LocalPlayer:GetHealth() > 0 then
								Network:Send("TurretDamagePly", {dmg = math.random(.3, .6)})
								table.insert(effects, ClientEffect.Create(AssetLocation.Game, 
								{
									effect_id = 189,
									position = bullet:GetPosition(),
									angle = Angle(0, 0, 0)
								}))
							end
						elseif ray.entity.__type == "Vehicle" then
							if LocalPlayer:InVehicle() then
								local veh = LocalPlayer:GetVehicle()
								if IsValid(veh) then
									if veh == ray.entity then
										--local dir = veh:GetAngle() * Vector3(0, 0, -1)
										--veh:SetAngularVelocity(dir * 30)
										Network:Send("TurretDamageVeh", {vehicle = veh, new_health = veh:GetHealth() - (math.floor((1.2 * .175 / veh:GetMass() ^ 0.2) * 100) / 100) * 1.2})
									end
								end
							end
						end
					else
						local dist = Vector3.Distance(LocalPlayer:GetPosition(), bullet:GetPosition())
						if dist < 5 then
							Network:Send("TurretDamagePly", {dmg = math.random(.1, .2)})
						end
					end
					if Vector3.Distance(bullets[index].position, bullets[index].origin) > 5 then
						table.insert(effects, ClientEffect.Create(AssetLocation.Game,
						{
							effect_id = 1,
							position = ray.position,
							angle = Angle(0, 0, 0)
						}))
					end
					bullets[index].bullet:Remove()
					bullets[index].effect:Remove()
					bullets[index] = nil
				else
					bullets[index].position = bullets[index].position + (bullets[index].angle * (Vector3.Forward * bullet_speed))
					bullet:SetPosition(bullets[index].position)
					effect:SetPosition(bullets[index].position + (bullets[index].angle * (Vector3.Backward * .25)))
				end
			end
		else
			if IsValid(bullets[index].bullet) then bullets[index].bullet:Remove() end
			if IsValid(bullets[index].effect) then bullets[index].effect:Remove() end
			bullets[index] = nil
		end
	end
end

function Turret:Render()
	for index, itable in pairs(bullets) do
		if IsValid(itable.bullet) then
			Render:FillCircle(itable.bullet:GetPosition(), .75, Color(0, 255, 0, 25))
		end
	end
end

function Turret:OnUnload()
	for index, itable in pairs(bullets) do
		if IsValid(itable.bullet) then
			itable.bullet:Remove()
		end
		if IsValid(itable.effect) then
			itable.effect:Remove()
		end
	end
	for index, effect in pairs(effects) do
		if IsValid(effect) then effect:Remove() end
	end
end

turret = Turret()

Events:Subscribe("SecondTick", turret, turret.Scan)
Events:Subscribe("PreTick", turret, turret.Fire)
Events:Subscribe("PostTick", turret, turret.HandleBullets)
--Events:Subscribe("Render", turret, turret.Render)
Events:Subscribe("ModuleUnload", turret, turret.OnUnload)