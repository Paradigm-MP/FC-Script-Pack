class 'HitDetection'

function HitDetection:__init()
	LocalPlayer:SetValue("HasReloaded", false)
	LocalPlayer:SetValue("CurrentWeapon", "")
	guns = {}
	guns["Pistol"] = 2
	guns["Revolver"] = 4
	guns["Sawed Off Shotgun"] = 6
	guns["Assault Rifle"] = 11
	guns["Pump Action Shotgun"] = 13
	guns["Grenade Launcher"] = 17
	--guns["Minigun"] = 26
	guns["Machine Gun"] = 28
	guns["Bubble Blaster"] = 43
	guns["Rocket Launcher"] = 16
	guns["Sniper Rifle"] = 14
	guns["Submachine Gun"] = 5
	
	dura_mod = {}
	dura_mod["Pistol"] = 10
	dura_mod["Revolver"] = 12
	dura_mod["Sawed Off Shotgun"] = 13
	dura_mod["Assault Rifle"] = 5
	dura_mod["Pump Action Shotgun"] = 16
	dura_mod["Grenade Launcher"] = 19
	--dura_mod["Minigun"] = 2
	dura_mod["Machine Gun"] = 6
	dura_mod["Bubble Blaster"] = 5
	dura_mod["Rocket Launcher"] = 19
	dura_mod["Sniper Rifle"] = 14
	dura_mod["Submachine Gun"] = 4
	

	HitDetection:InitTables()
	
	HitDetection:AddLimitedWeapon(2, 0.06, 200) -- Pistol
	HitDetection:AddLimitedWeapon(4, 0.11, 200) -- Revolver
	HitDetection:AddLimitedWeapon(5, 0.05, 200) -- SMG
	HitDetection:AddLimitedWeapon(6, 0.3, 100) -- Sawed-Off Shotgun
	HitDetection:AddLimitedWeapon(11, 0.07, 200) -- Assault Rifle
	HitDetection:AddLimitedWeapon(13, 0.21, 100) -- Shotgun
	HitDetection:AddLimitedWeapon(14, 0.65, 1000) -- Sniper Rifle
	HitDetection:AddLimitedWeapon(28, 0.09, 200) -- Machine Gun
	HitDetection:AddLimitedWeapon(43, -0.05, 0) -- Bubble Gun
	--HitDetection:AddLimitedWeapon(100, 0.06, 200) -- Bulls-Eye Assault Rifle
	--HitDetection:AddLimitedWeapon(103, 0.10, 200) -- Signature Gun
	HitDetection:AddLimitedWeapon(16, 0.0, 75) -- Normal Rocket Launcher -- dont work because atm only GetAimTarget() detection
	HitDetection:AddLimitedWeapon(66, 0.0, 75) -- Panay Rocket Launcher -- dont work because atm only GetAimTarget() detection
	HitDetection:AddLimitedWeapon(26, 0, 0) -- Minigun
	
	--HitDetection:AddUnlimitedWeapon(129, 145, 0.08, 200) -- Mounted Machine Gun
	
	HitDetection:AddVehicle(3, "FullyUpgraded", 120, 0.12, 200) -- [FullyUpgraded] Rowlinson K22
	HitDetection:AddVehicle(37, "Mission", 60, 0.08, 200) -- [Mission] Sivirkin 15 Havoc
	HitDetection:AddVehicle(37, "FullyUpgraded", 60, 0.08, 200) -- [FullyUpgraded] Sivirkin 15 Havoc
	HitDetection:AddVehicle(57, "Mission", 60, 0.08, 200) -- [Mission] Sivirkin 15 Havoc
	HitDetection:AddVehicle(57, "FullyUpgraded", 60, 0.08, 200) -- [FullyUpgraded] Sivirkin 15 Havoc
	HitDetection:AddVehicle(59, "", 145, 0.08, 200) -- Peek Airhawk 225
	HitDetection:AddVehicle(30, "", 60, 0.16, 300) -- Si-47 Leopard
	HitDetection:AddVehicle(64, "", 60, 0.16, 200) -- AH-33 Topachula
	
	self.physics = {
	
		["gravity"] = 9.81, -- 9.81 default earth gravity
		
		["projectile_motion"] = false, -- If true, then bullets will follow parabolic trajectories based on their initial velocity, angle, and gravity. Set gravity to 0 if you do not want bullet drop. Enabling this sets the maximum range on all guns to 1000 m.
		
	}
	
	self.bone_mod = {
	
		["ragdoll_Head"] = 2.5,
		
		["ragdoll_Spine1"] = 1.0,
		["ragdoll_Spine"] = 1.0,
		["ragdoll_Hips"] = 1.0,
		
		["ragdoll_RightArm"] = 0.8,
		["ragdoll_LeftArm"] = 0.8,
		
		["ragdoll_RightForeArm"] = 0.6,
		["ragdoll_LeftForeArm"] = 0.6,
		
		["ragdoll_RightUpLeg"] = 0.8,
		["ragdoll_LeftUpLeg"] = 0.8,
		
		["ragdoll_RightLeg"] = 0.6,
		["ragdoll_LeftLeg"] = 0.6,
		
		["ragdoll_RightFoot"] = 0.4,
		["ragdoll_LeftFoot"] = 0.4,
		
	}
	
	self.damagemultiplier = 1.0 -- make a server value for explosions - default value 1
	LocalPlayer:SetValue("HD_Attacker", nil)
	self.checkconform = false
	
	self.module_timer = Timer()
	self.shot_timer = Timer()
	self.last_hit_timer = Timer()
	self.last_attack_timer = Timer()
	
	self.shot_count = 0 -- Debug variable

	self.bullets = {}
	self.target = {}
	renderhits = {}
	renderplayers = {}
	currentrenderplayers = {}

	self.equipped = LocalPlayer:GetEquippedWeapon()
	self.screen_size = Render.Size

	--self.hitmarker = Image.Create(AssetLocation.Game, "hud_icon_objective_dif.dds") -- red hitmarker
	--self.hitmarker = Image.Create(AssetLocation.Game, "hud_icon_objective_green_dif.dds") -- green hitmarker
	--self.hitmarker = Image.Create(AssetLocation.Game, "hud_icon_objective_clamp_dif.dds") -- red arrow hitmarker
	self.hitmarker = Image.Create(AssetLocation.Game, "hud_icon_cp_destruct_dif.dds") -- red arrow hitmarker
	self.hitmarker_draw_time = 800
	self.hitmarker:SetPosition(self.screen_size / 2 - self.hitmarker:GetSize() / 2 )
	
	Events:Subscribe("LocalPlayerBulletHit", self, self.NativeDamageBlock)
	Events:Subscribe("LocalPlayerExplosionHit", self, self.ExplosionHit)
	Events:Subscribe("PreTick", self, self.LimitedAmmo)
	Events:Subscribe("Render", self, self.Render)
	Events:Subscribe("ResolutionChange", self, self.ResolutionChange)
	Events:Subscribe("PreTick", self, self.GetUp)
	Network:Subscribe("KnockDown", self, self.KnockDown)
	
end

function HitDetection:InitTables()

	self.weapons = {}
	self.vehicles = {}

end

function HitDetection:AddLimitedWeapon(id, damage, velocity)

	self.weapons[id] = {
		["damage"] = damage,
		["velocity"] = velocity,
	}
	
end

function HitDetection:AddUnlimitedWeapon(id, shot_delay, damage, velocity)

	self.weapons[id] = {
		["shot_delay"] = shot_delay,
		["damage"] = damage,
		["velocity"] = velocity,
	}
	
end

function HitDetection:AddVehicle(id, template, shot_delay, damage, velocity)

		self.vehicles[id] = {
			["template"] = template,
			["shot_delay"] = shot_delay,
			["damage"] = damage,
			["velocity"] = velocity,
		}

end

function HitDetection:LimitedAmmo()
	self.equipped = LocalPlayer:GetEquippedWeapon()
	
	if not self.ammoclip then -- initial conform
		self.ammoclip = self.equipped.ammo_clip
		LocalPlayer:SetValue("HasReloaded", false)
		return
	end
	if not self.ammo then -- initial conform
		self.ammo = self.equipped.ammo_clip + self.equipped.ammo_reserve
		LocalPlayer:SetValue("self.ammo", self.ammo)
		LocalPlayer:SetValue("HasReloaded", false)
		return
	end
	if not self.currentweapon then -- initial conform
		self.currentweapon = self.equipped.id
		LocalPlayer:SetValue("HasReloaded", false)
		LocalPlayer:SetValue("CurrentWeapon", table.find(guns, self.equipped.id))
	end
	--
	if self.currentweapon ~= self.equipped.id then -- switch weapons conform
		self.currentweapon = self.equipped.id -- clips store ammo in different places technically, so when you are on a different weapon then switch back, there is conformity
		self.ammo = self.equipped.ammo_clip + self.equipped.ammo_reserve
		self.ammoclip = self.equipped.ammo_clip
		LocalPlayer:SetValue("self.ammo", self.ammo)
	end
	
	if type(self.ammo) == "string" then self.ammo = tonumber(Crypt34(self.ammo)) end
	if type(self.ammoclip) == "string" then self.ammoclip = tonumber(Crypt34(self.ammoclip)) end
	
	local func = (function()
		if scriptdeath then return end
		if true then--self.shot_timer:GetMilliseconds() > 80 then
			if self.equipped.id ~= 0 and self.weapons[self.equipped.id] then
				if self.ammoclip - 1 == self.equipped.ammo_clip then -- if shot fired(doesn't factor in reloading)
					local didshoot = true
					Chat:dPrint("self.ammo: " .. tostring(self.ammo - 1), Color(255, 255, 0))
					Events:Fire("DeleteFromInventory", {sub_item = "Ammo", sub_amount = 1, no_sync = true})
					if not self.physics.projectile_motion then
						self:FireWeapon()
						self.shot_count = self.shot_count + 1 -- debug
					elseif self.physics.projectile_motion then
						self:SpawnWeaponBullet()
						self.shot_count = self.shot_count + 1 -- debug
					end
					self.ammo = self.ammo - 1
					LocalPlayer:SetValue("self.ammo", self.ammo)
					self.ammoclip = self.ammoclip - 1
				end
			
				-- code under here is run on PreTick + interval
				local state = LocalPlayer:GetUpperBodyState()
				if state == 371 or state == 365 or state == 450 or state == 471 or state == 447 then -- reload conform
					LocalPlayer:SetValue("HasReloaded", true)
					if self.checkconform == false then
						self.pre_reload_ammo = Copy(self.equipped.ammo_reserve)
					end
					self.ammoclip = self.equipped.ammo_clip
					self.ammo = self.equipped.ammo_clip + self.equipped.ammo_reserve
					LocalPlayer:SetValue("self.ammo", self.ammo)
					self.checkconform = true
					return
				else
					if self.checkconform == true then
						if self.equipped.ammo_reserve == self.pre_reload_ammo then
							Chat:dPrint("Irregularity in reload", Color.Blue)
							Chat:dPrint("CHEATING DETECTED", Color.Red)
							Network:Send("AmmoKickInReload")
							self.ammo = self.equipped.ammo_clip + self.equipped.ammo_reserve
						end
						self.checkconform = false
					end
				end
				if didshoot == true then
					if self.ammo + 1 ~= self.equipped.ammo_clip + self.equipped.ammo_reserve then -- ammo cheating / irregularity when firing
						Chat:dPrint("Irregularity in reserve ammo", Color.Blue)
						Chat:dPrint("CHEATING DETECTED", Color.Red)
						Network:Send("AmmoKickInReserve")
						self.ammo = self.equipped.ammo_clip + self.equipped.ammo_reserve
						LocalPlayer:SetValue("self.ammo", self.ammo)
					end
				else
					if (self.ammo ~= self.equipped.ammo_clip + self.equipped.ammo_reserve) then -- ammo cheating / irregularity
						local anomaly = math.abs(self.ammo - (self.equipped.ammo_clip + self.equipped.ammo_reserve))
						if anomaly < 2 then return end
						if Game:GetState() == GUIState.Loading then
							if self.ammo > self.equipped.ammo_clip + self.equipped.ammo_reserve then
								return
							end
						end
						Chat:dPrint("Irregularity in clip", Color.Blue)
						Chat:dPrint("CHEATING DETECTED", Color.Red)
						Network:Send("AmmoKickInClip", {irreg = anomaly})
						self.ammo = self.equipped.ammo_clip + self.equipped.ammo_reserve
						LocalPlayer:SetValue("self.ammo", self.ammo)
					end
				end
			end
		end
	end)
	
	func()
	
	if type(self.ammo) == "number" and self.ammo ~= nil then self.ammo = Crypt34(self.ammo) end
	if type(self.ammoclip) == "number" and self.ammoclip ~= nil then self.ammoclip = Crypt34(self.ammoclip) end
end

function HitDetection:SpawnWeaponBullet()
		
	local args = {}
	args.position = LocalPlayer:GetBonePosition("ragdoll_RightForeArm")
	args.angle = Camera:GetAngle()
	args.velocity = self.weapons[self.equipped.id].velocity
	args.gravity = self.physics.gravity
	
	table.insert(self.bullets, Bullet(args))
	
	self.shot_timer:Restart()
	
end

function HitDetection:SpawnVehicleBullet()
		
	local args = {}
	args.position = self.occupied:GetPosition()
	args.angle = Camera:GetAngle()
	args.velocity = self.vehicles[self.occupied:GetModelId()].velocity
	args.gravity = self.physics.gravity
	
	table.insert(self.bullets, Bullet(args))
	
	self.shot_timer:Restart()
	
end

function HitDetection:FireWeapon()
	self.target = LocalPlayer:GetAimTarget()
	if self.target.entity then
		if self.target.entity.__type == "StaticObject" then
			local args = {}
			if LocalPlayer:GetValue("CanHit") == false then return end
			args.damage = self.weapons[self.equipped.id]["damage"]
			if args.damage == 0 or not args.damage then return end
			args.target = self.target.entity
			Events:Fire("LC_ShootClaimObject", args)
			if table.count(renderhits) >= 15 then
				renderhits[15] = math.floor(args.damage * 100)
			else
				table.insert(renderhits, args.damage * 100)
			end
		elseif self.target.entity.__type == "Player" or self.target.entity.__type == "Vehicle" then
			if self.target.entity:GetHealth() <= 0 then return end
			if self.target.entity:GetValue("Invincible") then return end
			local faction = self.target.entity:GetValue("Faction")
			local localFaction = tostring(LocalPlayer:GetValue("Faction"))
			if faction == LocalPlayer:GetValue("Faction") and string.len(localFaction) > 2 then return end
			if self.target.entity.__type == "Player" then
				if LocalPlayer:GetValue("Friends"):find(tostring(self.target.entity:GetSteamId().id)) then -- if shot a friend
					return
				end
			end
			local args = {}
			args.target = self.target.entity
			--
			if args.target:GetValue("CanHit") == false
			or LocalPlayer:GetValue("CanHit") == false then return end
			local ID = args.target:GetId()
			local attacking = LocalPlayer:GetValue("HD_Attacking")
			if tostring(attacking) ~= tostring(args.target) then
				LocalPlayer:SetValue("HD_Attacking", args.target)
				self.last_attack_timer:Restart()
			else -- same object type
				if attacking ~= args.target then
					LocalPlayer:SetValue("HD_Attacking", args.target)
					self.last_attack_timer:Restart()
				end
			end
			args.damage = self:CalculateDamageFromWeapon()
			if args.target:GetValue("SOCIAL_Back") == "Pocketed Vest" and args.damage > 0 then
				args.damage = args.damage * 0.75 --75% of damage
			elseif args.target:GetValue("SOCIAL_Back") == "Armored Vest" and args.damage > 0 then
				args.damage = args.damage * 0.5 --50% of damage
			end
			if args.damage == 0 then return end
			--Chat:dPrint("Hit " .. tostring(args.target) .. " for " .. tostring(args.damage), Color(0, 255, 0))
			Network:Send("HitDetected", args)
			if table.count(renderhits) >= 15 then
				renderhits[15] = math.floor(args.damage * 100)
			else
				table.insert(renderhits, args.damage * 100)
			end
		elseif self.target.entity.__type == "ClientActor" then
			Events:Fire("UpdateSharedActors")
			local actors_obj = SharedObject.GetByName("ClientSharedActors") -- wno_id = actor_id
			local actors = {}
			if actors_obj then
				actors = actors_obj:GetValue("Actors")
			end
			local iWNO_id = table.find(actors, self.target.entity:GetId())
			if iWNO_id then
				local iWNO = WorldNetworkObject.GetById(iWNO_id)
				if IsValid(iWNO) and iWNO:GetValue("fFaction") ~= LocalPlayer:GetValue("Faction") then
					local damage = self:CalculateDamageFromWeapon()
					--Chat:dPrint("damage:" .. tostring(damage), Color(255, 0, 255))
					local old_health = self.target.entity:GetHealth()
					self.target.entity:SetHealth(self.target.entity:GetHealth() - damage)
					if self.target.entity:GetHealth() <= 0 then
						self.target.entity:SetBaseState(56)
						if old_health ~= 0 then
							Events:Fire("RandomExpCrossModule", {exp = 150})
						end
					end
					if table.count(renderhits) >= 15 then
						renderhits[15] = math.floor(damage * 100)
					else
						table.insert(renderhits, damage * 100)
					end
				end
			else
				Events:Fire("UpdateSharedZombies")
				local zombies_obj = SharedObject.GetByName("ClientSharedZombies") -- wno_id = actor_id
				local actors = {}
				if zombies_obj then
					zombies = zombies_obj:GetValue("Zombies")
				end
				local wno_id = table.find(zombies, self.target.entity:GetId())
				if wno_id then
					local damage = self:CalculateDamageFromWeapon()
					--Chat:dPrint("damage:" .. tostring(damage), Color(255, 0, 255))
					local health = self.target.entity:GetHealth()
					--Chat:Print("Health: " .. tostring(health), Color.Green)
					if health > 0 then
						Events:Fire("DamageZombieEvent", {damage = damage, id = wno_id, actor_pos = self.target.entity:GetPosition()})
					end
					if table.count(renderhits) >= 15 then
						renderhits[15] = math.floor(damage * 100)
					else
						table.insert(renderhits, damage * 100)
					end
				end
			end
		end
	end
	self.shot_timer:Restart()
end

function HitDetection:FireVehicle()
	--print("FIRE VEHICLE CALLED")
	self.target = LocalPlayer:GetAimTarget()
	if self.target.entity then
		--print(self.target.entity.__type)
		if self.target.entity.__type == "ClientStaticObject" then
			local args = {}
			args.damage = self:CalculateDamageFromVehicle()
			--print(args.damage)
			if args.damage == 0 or not args.damage then return end
			args.target = self.target.entity
			args.damage = args.damage / 50
			Events:Fire("LC_ShootClaimObject", args)
			if table.count(renderhits) >= 15 then
				renderhits[15] = math.floor(args.damage * 100)
			else
				table.insert(renderhits, args.damage * 100)
			end
		elseif self.target.entity.__type == "Player" or self.target.entity.__type == "Vehicle" then
			if self.target.entity:GetValue("Invincible") then return end
			local args = {}
			args.target = self.target.entity
			if args.target:GetValue("CanHit") == false
			or LocalPlayer:GetValue("CanHit") == false then return end
			args.damage = self:CalculateDamageFromVehicle()
			if args.target:GetValue("SOCIAL_Back") == "Pocketed Vest" then
				args.damage = args.damage * 0.75 --75% of damage
			elseif args.target:GetValue("SOCIAL_Back") == "Armored Vest" then
				args.damage = args.damage * 0.5 --50% of damage
			end
			if args.damage < 0 then return end
			--Chat:dPrint("Hit " .. tostring(args.target) .. " for " .. tostring(args.damage), Color(0, 255, 0))
			Network:Send("HitDetected", args)
		end
	end
	self.shot_timer:Restart()
end

function HitDetection:Render()

	for i,k in pairs(self.bullets) do
		if not k:IsValid() then
			self.bullets[i] = nil
		end
	end
	
	if IsValid(self.target.entity) and self.shot_timer:GetMilliseconds() < self.hitmarker_draw_time and self.module_timer:GetMilliseconds() > self.hitmarker_draw_time then
		if self.target.entity.__type == "Player" or self.target.entity.__type == "Vehicle" then	
			self.hitmarker:SetAlpha(1 - self.shot_timer:GetMilliseconds() / self.hitmarker_draw_time)
			self.hitmarker:Draw()
		end
	end
	
	for numindex, damage in pairs(renderhits) do
		local color = Color()
		if damage <= 20 then
			color= Color(255, 255, 0)
		elseif damage <= 75 then
			color = Color(0, 255, 0)
		else
			color = Color(255, 0, 0)
		end
		Render:DrawText(Vector2(self.screen_size.x * 0.515, self.screen_size.y * (0.48 + (numindex * .025))), tostring(damage), color, TextSize.Default * 1.325)
	end
	
	-------------------
	for k, v in pairs(currentrenderplayers) do currentrenderplayers[k] = nil end -- reset
	
	for ply in Client:GetStreamedPlayers() do -- omits invisible players
		if not renderplayers[ply:GetId()] then
			renderplayers[ply:GetId()] = ply:GetEquippedWeapon().ammo_clip
			ply:SetValue("ShowMinimapDot", false) -- necessary since ply vals dont clear on module unload
		end
		currentrenderplayers[ply:GetId()] = true
	end
	
	for ID, ammo2 in pairs(renderplayers) do -- clean up out of streaming distance players
		if currentrenderplayers[ID] == nil then
			renderplayers[ID] = nil
			--print("deleted from table")
		end
	end
	
	for ID, clip_ammo in pairs(renderplayers) do -- valid render table
		local ply = Player.GetById(ID)
		if IsValid(ply) then
			local new_clip_ammo = ply:GetEquippedWeapon().ammo_clip
			--Chat:dPrint("Clip: " .. tostring(new_clip_ammo), Color(0, 255, 0))
			if clip_ammo - 1 == new_clip_ammo then
				Chat:dPrint("Shot Fired", Color(0, 255, 0))
				renderplayers[ID] = new_clip_ammo
				if ply:GetValue("ShowMinimapDot") == false then
					ShootRender(ply)
					ply:SetValue("ShowMinimapDot", true)
				else
					plyval = ply:GetValue("ShowMinimapDot")
					--Chat:dPrint("PlyVal: " .. tostring(plyval), Color(255, 0, 0))
				end
			else
				renderplayers[ID] = new_clip_ammo
			end
		end
	end
	
	local tcount = table.count(renderplayers)
	
	--Chat:dPrint(tostring(tcount), Color(0, 255, 0))
	
	--self:Debug()
	
end

function HitDetection:Debug()

	--Render:DrawText(Vector2(self.screen_size.x * 0.72, self.screen_size.y * 0.05), "UpperBodyState: "..tostring(LocalPlayer:GetUpperBodyState()), Color(255, 255, 255))
	--Render:DrawText(Vector2(self.screen_size.x * 0.72, self.screen_size.y * 0.10), "BaseState: "..tostring(LocalPlayer:GetBaseState()), Color(255, 255, 255))
	Render:DrawText(Vector2(self.screen_size.x * 0.75, self.screen_size.y * 0.15), "Weapon: "..tostring(LocalPlayer:GetEquippedWeapon().id), Color(255, 255, 255))
	Render:DrawText(Vector2(self.screen_size.x * 0.75, self.screen_size.y * 0.25), "Player Health: "..tostring(math.floor(LocalPlayer:GetHealth()*100 + 0.5)), math.lerp(Color(255, 255, 255), Color(255, 0, 0), 1 - LocalPlayer:GetHealth()))
	Render:DrawText(Vector2(self.screen_size.x * 0.75, self.screen_size.y * 0.20), "Shot Count: "..tostring(math.floor(self.shot_count + 0.5)), Color(255, 255, 255))
	
	if LocalPlayer:InVehicle() then
		Render:DrawText(Vector2(self.screen_size.x * 0.55, self.screen_size.y * 0.05), "Vehicle: "..tostring(LocalPlayer:GetVehicle()), Color(255, 255, 255))
		Render:DrawText(Vector2(self.screen_size.x * 0.55, self.screen_size.y * 0.20), "Vehicle Health: "..tostring(math.floor(LocalPlayer:GetVehicle():GetHealth()*100 + 0.5)), math.lerp(Color(255, 255, 255), Color(255, 0, 0), 1 - LocalPlayer:GetVehicle():GetHealth()))
		Render:DrawText(Vector2(self.screen_size.x * 0.55, self.screen_size.y * 0.10), "Template: "..tostring(LocalPlayer:GetVehicle():GetTemplate()), Color(255, 255, 255))
		Render:DrawText(Vector2(self.screen_size.x * 0.55, self.screen_size.y * 0.15), "Vehicle Mass: "..tostring(math.floor(LocalPlayer:GetVehicle():GetMass() + 0.5)), Color(255, 255, 255))
	end

end

function HitDetection:CalculateDamageFromWeapon()

	if self.target.entity.__type == "Player" or self.target.entity.__type == "ClientActor" then
	
		if self.target.entity:GetBaseState() == 56 then
			return 0
		else
			local bones = self.target.entity:GetBones()
			local nearest_bone = "ragdoll_Spine"
			local bone_distance = 1.0
			
			for bone_name, bone in pairs(bones) do
				local distance = Vector3.Distance(self.target.position, bone.position)
				if distance < bone_distance then
					bone_distance = distance
					nearest_bone = bone_name
				end
			end

			globalbone = nearest_bone
			
			if self.bone_mod[nearest_bone] and self.weapons[self.equipped.id] and self.damagemultiplier then
				return math.floor(self.bone_mod[nearest_bone] * (self.weapons[self.equipped.id].damage * self.damagemultiplier) * 100) / 100
			else
				return .01
			end
		end

	end
	
	if self.target.entity.__type == "Vehicle" then
		return (math.floor((1.2 * self.weapons[self.equipped.id].damage / self.target.entity:GetMass() ^ 0.2) * 100) / 100) * 1.2
		--return 50
	end

end

function HitDetection:CalculateDamageFromVehicle()

	if self.target.entity.__type == "Player" then
	
		if self.target.entity:GetBaseState() == 56 then
			return 0
		else
			return self.vehicles[self.occupied:GetModelId()].damage
		end
		
	end
	
	if self.target.entity.__type == "Vehicle" then
		--return 1.2 * self.vehicles[self.occupied:GetModelId()].damage / self.target.entity:GetMass() ^ 0.2
		return 50
	end

end

function HitDetection:NativeDamageBlock(args)
	if args.attacker then
		LocalPlayer:SetValue("HD_Attacker", args.attacker)
		self.last_hit_timer:Restart()
	end
	return false
end

function HitDetection:ExplosionHit(args)
	if LocalPlayer:GetValue("Invincible") then return false end
	if LocalPlayer:GetValue("CanHit") == false then
		--Chat:dPrint("Blocked Explosive Damage", Color(0, 255, 0))
		return false
	end
	local args2 = {}
	args2.damage = math.floor(args.damage) / 1000
	if args.attacker then
		if args.attacker.__type == "Player" and LocalPlayer:GetValue("Friends"):find(tostring(args.attacker:GetSteamId().id)) then -- if shot a friend
			return
		end
		args2.attacker = args.attacker
	end 
	if LocalPlayer:GetValue("SOCIAL_Back") == "Pocketed Vest" then
		args2.damage = args2.damage * 0.75 --75% of damage
	elseif LocalPlayer:GetValue("SOCIAL_Back") == "Armored Vest" then
		args2.damage = args2.damage * 0.5 --50% of damage
	end
	Network:Send("ExplosionHit", args2)
	return false
end

function HitDetection:ResolutionChange(args)
	self.screen_size = args.size
	self.hitmarker:SetPosition(self.screen_size / 2 - self.hitmarker:GetSize() / 2 )
end

function HitDetection:KnockDown()

	self.knockdown_timer = Timer()
	LocalPlayer:SetBaseState(56)

end

function HitDetection:GetUp()
	--print(LocalPlayer:GetValue("HD_Attacker"))
	if LocalPlayer:GetValue("HD_Attacker") then
		if self.last_hit_timer:GetSeconds() > 30 then -- config reset HD_Attacker here
			LocalPlayer:SetValue("HD_Attacker", nil)
		end
	end
	
	if LocalPlayer:GetValue("HD_Attacking") then
		if self.last_attack_timer:GetSeconds() > 30 then
			LocalPlayer:SetValue("HD_Attacking", nil)
		end
	end
	
	if self.knockdown_timer then
		if self.knockdown_timer:GetMilliseconds() > 5000 then
			LocalPlayer:SetBaseState(6)
			self.knockdown_timer = nil
		end
	end

end

HitDetection = HitDetection()

function ClearRenderHits()
	renderhits = {}
end
Events:Subscribe("SecondTick", ClearRenderHits)