class 'FactionNPC'

function FactionNPC:__init()
	if SharedObject.GetByName("ClientSharedActors") ~= nil then
		SharedObject.GetByName("ClientSharedActors"):Remove()
	end
	local sharing_table_actors = SharedObject.Create("ClientSharedActors", {})
	--
	actors = {}
	respawn = {}
	dead_actors = {}
	--
	actor_aggro_distance = 250
	actor_respawn_time = 30 -- in seconds
	--
	net_timer = Timer()
	--
	npc = ClientActor.Create(AssetLocation.Game,
	{
		model_id = 42,
		position = Vector3(-6499.2, 208.9, -3212.4),
		angle = Angle(0, 0, 0)
	})
	test = {}
	rayticks = 0
	screen_size = Render.Size
	disable_timer = Timer()
end

function FactionNPC:ActorAction()
	--print(table.count(overrides))
	for wno_id, actor in pairs(actors) do
		if IsValid(actor) == true then
			if overrides[actor:GetId()] == nil then
				local WNO = WorldNetworkObject.GetById(wno_id)
				if actor:GetHealth() > 0 then
					if WNO:GetValue("Alive") == true then
						if actor:GetBaseState() == 56 and overrides[actor:GetId()] == nil then
							actor:SetBaseState(6)
						end
						if WNO:GetValue("Aggro") == 1 then
							if actor:GetEquippedWeapon().id ~= 14 then
								actor:GiveWeapon(1, Weapon(14, 1000, 1000))
							end
							--
							if WNO:GetValue("Target") then
								local target = Player.GetById(WNO:GetValue("Target"))
								if IsValid(target) and target and not target:GetValue("Invincible") and not target:GetValue("Invis") and target:GetHealth() > 0 and Vector3.Distance(actor:GetPosition(), target:GetPosition()) < actor_aggro_distance then
									local bullets = actor:GetEquippedWeapon().ammo_clip
									if bullets > 0 then
										local rando1 = Vector3(math.random(-0.25, 0.25), math.random(-0.25, 0.25), math.random(-0.25, 0.25))
										local rando2 = math.random(0, 5)
										if rando2 == 1 or IsNaN(actor:GetAimPosition()) then
											actor:SetAimPosition(target:GetBonePosition("ragdoll_Spine1") + rando1)
										end
										local rando = math.random(0, 100)
										if rando == 1 then
											if IsValid(actor:GetBonePosition("ragdoll_Head")) and IsValid(actor:GetAimPosition()) then
												local aimdiff = actor:GetAimPosition() - target:GetPosition()
												local angleyaw = Angle.FromVectors(Vector3.Forward, target:GetPosition() - actor:GetPosition()).yaw
												actor:SetUpperBodyState(347)
												actor:SetBaseState(6)
												actor:SetAngle(Angle(angleyaw, actor:GetAngle().pitch, actor:GetAngle().pitch))
												actor:SetInput(Action.FireRight, 1)
												if dead_actors[wno_id] then
													dead_actors[wno_id] = nil
												end
											end
										end
									else -- no bullets - have to remove and respawn
										--actor:GiveWeapon(1, Weapon(14, 99, 99))
										--Chat:Print("Respawn Actor @ no bullets", Color(0, 255, 0))
										respawn.model_id = actor:GetModelId()
										respawn.position = actor:GetPosition()
										local health = actor:GetHealth()
										actor:Remove()
										actors[wno_id] = ClientActor.Create(AssetLocation.Game,
										{
											model_id = respawn.model_id,
											position = respawn.position,
											angle = Angle(0, 0, 0)
										})
										DelayedHealthSet(wno_id, health)
									end
								else
									actor:SetUpperBodyState(346)
								end
							end
						end
					else
						actor:SetBaseState(56)
					end
				else
					if WNO:GetValue("Alive") == true then
						if net_timer:GetSeconds() > .05 and not dead_actors[wno_id] then
							Network:Send("KillActor", {id = wno_id})
							--Chat:Print("Killed Actor", Color(255, 0, 255))
							dead_actors[WNO:GetId()] = os.clock()
							net_timer:Restart()
						end
					end
					actor:SetBaseState(56)
				end
			end
		end
	end
end

function FactionNPC:HellfireExplosion(args) -- receives pos
	for wno_id, actor in pairs(actors) do
		if IsValid(actor) then
			if Vector3.Distance(actor:GetPosition(), args.pos) < 45 then
				local dist = Vector3.Distance(actor:GetPosition(), args.pos)
				if dist <= 20 then -- killzone
					actor:SetHealth(0)
				elseif dist <= 35 then
					actor:SetHealth(actor:GetHealth() - .65)
				elseif dist <= 45 then
					actor:SetHealth(actor:GetHealth() - .35)
				end
				if actor:GetHealth() <= 0 then
					local WNO = WorldNetworkObject.GetById(wno_id)
					if WNO then
						if WNO:GetValue("Alive") == true then
							Network:Send("KillActor", {id = wno_id})
						end
					end
				end
			end
		end
	end
end

function FactionNPC:ForceRevive()
	local new_time = os.clock()
	for wno_id, old_time in pairs(dead_actors) do
		if new_time - old_time > actor_respawn_time then
			local actor = actors[wno_id]
			respawn.model_id = actor:GetModelId()
			respawn.position = actor:GetPosition()						
			actor:Remove()
			actors[wno_id] = ClientActor.Create(AssetLocation.Game,
			{
				model_id = respawn.model_id,
				position = respawn.position,
				angle = Angle(0, 0, 0)
			})
			--Chat:Print("ForceRevive Actor", Color(0, 255, 0))
			dead_actors[wno_id] = nil
		end
	end
end

function FactionNPC:WNOCreate(args)
	if args.object:GetValue("M_ID") then
		local id = args.object:GetId()
		if not actors[id] then
			actors[id] = ClientActor.Create(AssetLocation.Game,
			{
				model_id = args.object:GetValue("M_ID"),
				position = args.object:GetPosition(),
				angle = Angle(0, 0, 0)
			})
		end
	end
end

function FactionNPC:WNODestroy(args)
	if args.object:GetValue("M_ID") then
		local id = args.object:GetId()
		if actors[id] then
			if IsValid(actors[id]) then
				actors[id]:Remove()
			end
			actors[id] = nil
			dead_actors[id] = nil
		end
	end
end

--function FactionNPC:Render()
	--for wno_id, actor in pairs(actors) do
		--if IsValid(actor) then
			--local WNO = WorldNetworkObject.GetById(wno_id)
		--	if IsValid(WNO) then
			--	if WNO:GetValue("Target") then
			--		local target = Player.GetById(WNO:GetValue("Target"))
			--		if IsValid(target) then
			--			if IsValid(actor:GetBonePosition("ragdoll_Head")) and IsValid(actor:GetAimPosition()) then
				--			local bones = target:GetBones()
				--			for boneName, bone in pairs(bones) do
			--					actor:SetAimPosition(bone.position)
			--					--Render:DrawLine(actor:GetBonePosition("ragdoll_Head"), actor:GetAimPosition(), Color(255, 255, 0))
			--					--local ray = Physics:Raycast(actor:GetBonePosition("ragdoll_Head"), Angle(Angle.FromVectors(Vector3.Forward, bone.position - actor:GetBonePosition("ragdoll_Head")).yaw, actor:GetAngle().pitch, actor:GetAngle().pitch) * Vector3.Forward, 0, actor_aggro_distance * 1.25)
			--					--local ray = Physics:Raycast(actor:GetBonePosition("ragdoll_Head"), actor:GetBoneAngle("ragdoll_RightForeArm") * Vector3.Backward, 0, 1500)
			--					--local ray = Physics:Raycast(actor:GetBonePosition("ragdoll_Head"), actor:GetAngle() * Vector3.Forward, 0, 1500)
			----					Render:DrawLine(actor:GetBonePosition("ragdoll_Head"), ray.position, Color(255, 255, 0))
			--					if ray.entity then
			--						Chat:Print("Ray Hit Entity", Color(0, 255, 0))
			--					end
								
								
								--local angleyaw = Angle.FromVectors(Vector3.Forward, target:GetPosition() - actor:GetPosition()).yaw
								--actor:SetAngle(Angle(angleyaw, actor:GetAngle().pitch, actor:GetAngle().pitch))
								
								
								
								
								
								
						--	end
			--			end
		--			end
		--		end
	--		end
	--	end
--	end
--end

function FactionNPC:VehicleCollide(args) -- args.entity is ClientActor .. args.impulse is severity
	if args.entity then
		if tostring(args.entity) == "ClientActor" then
			local actor = args.entity
			if IsValid(actor) then
				local id = actor:GetId()
				local health = actor:GetHealth()
				if args.impulse > 3 then
					if not overrides[id] then
						overrides[id] = true
						local states = {}
						states[257] = true
						local angle = args.attacker:GetAngle() -- vehicles angle
						local velocity = 5
						ActorOverrideStates(actor, states, angle, velocity)
					end
				end
			end
		end
	end
end

function FactionNPC:ModuleUnload()
	for wno_id, actor in pairs(actors) do
		if IsValid(actor) then actor:Remove() end
	end
	if IsValid(npc) then npc:Remove() end
end

function FactionNPC:Path(args)
	if args.text == "/pathing" then
		local cell_x, cell_y = TerrainMap:GetCell(LocalPlayer:GetPosition())
		TerrainMap:BuildMap(TerrainMap:GetCell(LocalPlayer:GetPosition()))
		TerrainMap:Process(cell_x, cell_y)
		local path, nodes = TerrainMap:FindPath(TerrainMap:GetNearestNode(npc:GetPosition()), TerrainMap:GetNearestNode(LocalPlayer:GetPosition()))
		for k, v in pairs(path) do
			for k1, v1 in pairs(v) do
				if type(v1) ~= "table" then
					npc:SetPosition(v1)
				end
			end
		end
	end
	
end

function FactionNPC:UpdateSharedActors()
	local sr = SharedObject.GetByName("ClientSharedActors")
	sr:SetValue("Actors", nil)
	local new_actors = {}
	for wno_id, actor in pairs(actors) do
		if IsValid(actor) then
			new_actors[wno_id] = actor:GetId()
		end
	end
	sr:SetValue("Actors", new_actors)
end

function FactionNPC:iRaycast()
	rayticks = rayticks + 1
	if rayticks < 20 then return end
	rayticks = 0
	LookingAtActor = nil
	LookingAtTurret = nil
	if disable_timer:GetSeconds() > 5 then
		local ply_faction = LocalPlayer:GetValue("Faction")
		if not ply_faction or ply_faction == "" then return end
		local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, 12.5)
		if ray.entity then
			if ray.entity.__type == "ClientActor" then
				local wno_id = table.find(actors, ray.entity)
				if wno_id then
					local iWNO = WorldNetworkObject.GetById(wno_id)
					if IsValid(iWNO) then
						local faction = iWNO:GetValue("fFaction")
						if faction then
							if faction == ply_faction then
								if LocalPlayer:GetValue("FactionRank") == 3 then
									LookingAtActor = wno_id
								end
							end
						end
					end
				end
			elseif ray.entity.__type == "StaticObject" then
				local model = ray.entity:GetModel()
				if model == "f2s04emp.flz/key040_1-part_b.lod" or model == "22x19.flz/wea34-f.lod" then
					if LocalPlayer:GetValue("Faction") and ray.entity:GetValue("fFaction") == LocalPlayer:GetValue("Faction") then
						if LocalPlayer:GetValue("FactionRank") == 3 then
							LookingAtTurret = ray.entity:GetId()
						end
					end
				end
			end
		end
	end
end

function FactionNPC:Render()
	if LookingAtActor then
		local width = Render:GetTextWidth("Press Q to pick up Faction Guard", TextSize.Default * 1.5)
		Render:DrawText(Vector2(screen_size.x - (width + 5), screen_size.y * .05), "Press Q to pick up Faction Guard", Color(255, 200, 0), TextSize.Default * 1.5)
		local width2 = Render:GetTextWidth("Press E to set aggressive or Y to set passive", TextSize.Default * 1.5)
		Render:DrawText(Vector2(screen_size.x - (width2 + 5), screen_size.y * .1), "Press E to set aggressive or Y to set passive", Color(255, 200, 0), TextSize.Default * 1.5)
	elseif LookingAtTurret then
		local width = Render:GetTextWidth("Press Q to pick up Faction Turret", TextSize.Default * 1.5)
		Render:DrawText(Vector2(screen_size.x - (width + 5), screen_size.y * .05), "Press Q to pick up Faction Turret", Color(255, 200, 0), TextSize.Default * 1.5)
		local width2 = Render:GetTextWidth("Press E to set aggressive or Y to set passive", TextSize.Default * 1.5)
		Render:DrawText(Vector2(screen_size.x - (width2 + 5), screen_size.y * .1), "Press E to set aggressive or Y to set passive", Color(255, 200, 0), TextSize.Default * 1.5)
	end
end

function FactionNPC:KeyDown(args) -- faction == faction check already done in iRaycast()
	if args.key == string.byte("Q") then
		if LookingAtActor then
			local faction = LocalPlayer:GetValue("Faction")
			if faction and faction ~= "" then
				local rank = LocalPlayer:GetValue("FactionRank")
				if rank and rank == 3 then
					Network:Send("DeleteGuard", {wno_id = LookingAtActor})
					Events:Fire("AddToInventory", {add_item = "Faction Guard", add_amount = 1})
				end
			end
		elseif LookingAtTurret then
			local faction = LocalPlayer:GetValue("Faction")
			if faction and faction ~= "" then
				local rank = LocalPlayer:GetValue("FactionRank")
				if rank and rank == 3 then
					local static = StaticObject.GetById(LookingAtTurret)
					if IsValid(static) then
						local pos = static:GetPosition()
						for obj in Client:GetStaticObjects() do
							if IsValid(obj) then
								if Vector3.Distance(obj:GetPosition(), pos) == 6 then
									Network:Send("DeleteTurret", {static_id1 = LookingAtTurret, static_id2 = obj:GetId()})
									Events:Fire("AddToInventory", {add_item = "(F) Missile Turret", add_amount = 1})
									break
								end
							end
						end
					end
				end
			end
		end
	elseif args.key == string.byte("E") then -- aggressive
		if LookingAtActor then
			local rank = LocalPlayer:GetValue("FactionRank")
			if rank and rank == 3 then
				local iWNO = WorldNetworkObject.GetById(LookingAtActor)
				if not IsValid(iWNO) then return end
				local aggro = iWNO:GetValue("Aggro")
				if aggro and aggro == 0 then
					Network:Send("SetGuardAggressive", {wno_id = LookingAtActor})
					disable_timer:Restart()
				else
					Chat:Print("Guard is already aggressive", Color(255, 255, 0))
				end
			end
		elseif LookingAtTurret then
			local faction = LocalPlayer:GetValue("Faction")
			if faction and faction ~= "" then
				local rank = LocalPlayer:GetValue("FactionRank")
				if rank and rank == 3 then
					local static = StaticObject.GetById(LookingAtTurret)
					if IsValid(static) then
						local pos = static:GetPosition()
						for obj in Client:GetStaticObjects() do
							if IsValid(obj) then
								if Vector3.Distance(obj:GetPosition(), pos) == 6 then
									local static1 = StaticObject.GetById(LookingAtTurret)
									local static2 = StaticObject.GetById(obj:GetId())
									if static1:GetValue("Aggro") then
										if static1:GetValue("Aggro") == 0 then
											Network:Send("SetTurretAggressive", {static_id = LookingAtTurret})
											Events:Fire("AddToInventory", {add_item = "(F) Missile Turret", add_amount = 1})
										else
											Chat:Print("Turret is already aggressive", Color(255, 255, 0))
										end
									elseif static2:GetValue("Aggro") then
										if static2:GetValue("Aggro") == 0 then
											Network:Send("SetTurretAggressive", {static_id = obj:GetId()})
											Events:Fire("AddToInventory", {add_item = "(F) Missile Turret", add_amount = 1})
										else
											Chat:Print("Turret is already aggressive", Color(255, 255, 0))
										end
									end
									break
								end
							end
						end
					end
				end
			end
		end
	elseif args.key == string.byte("Y") then -- passive
		if LookingAtActor then
			local rank = LocalPlayer:GetValue("FactionRank")
			if rank and rank == 3 then
				local iWNO = WorldNetworkObject.GetById(LookingAtActor)
				if not IsValid(iWNO) then return end
				local aggro = iWNO:GetValue("Aggro")
				if aggro and aggro == 1 then
					Network:Send("SetGuardPassive", {wno_id = LookingAtActor})
					disable_timer:Restart()
				else
					Chat:Print("Guard is already passive", Color(255, 255, 0))
				end
			end
		elseif LookingAtTurret then
			local faction = LocalPlayer:GetValue("Faction")
			if faction and faction ~= "" then
				local rank = LocalPlayer:GetValue("FactionRank")
				if rank and rank == 3 then
					local static = StaticObject.GetById(LookingAtTurret)
					if IsValid(static) then
						local pos = static:GetPosition()
						for obj in Client:GetStaticObjects() do
							if IsValid(obj) then
								if Vector3.Distance(obj:GetPosition(), pos) == 6 then
									local static1 = StaticObject.GetById(LookingAtTurret)
									local static2 = StaticObject.GetById(obj:GetId())
									if static1:GetValue("Aggro") then
										if static1:GetValue("Aggro") == 1 then
											Network:Send("SetTurretPassive", {static_id = LookingAtTurret})
											Events:Fire("AddToInventory", {add_item = "(F) Missile Turret", add_amount = 1})
										else
											Chat:Print("Turret is already passive", Color(255, 255, 0))
										end
									elseif static2:GetValue("Aggro") then
										if static2:GetValue("Aggro") == 1 then
											Network:Send("SetTurretPassive", {static_id = obj:GetId()})
											Events:Fire("AddToInventory", {add_item = "(F) Missile Turret", add_amount = 1})
										else
											Chat:Print("Turret is already passive", Color(255, 255, 0))
										end
									end
									break
								end
							end
						end
					end
				end
			end
		end
	end
end

function FactionNPC:ResolutionChange()
	screen_size = Render.Size
end

fnpc = FactionNPC()

Events:Subscribe("PostTick", fnpc, fnpc.ActorAction)
Events:Subscribe("WorldNetworkObjectCreate", fnpc, fnpc.WNOCreate)
Events:Subscribe("WorldNetworkObjectDestroy", fnpc, fnpc.WNODestroy)
Events:Subscribe("ModuleUnload", fnpc, fnpc.ModuleUnload)
Events:Subscribe("SecondTick", fnpc, fnpc.ForceRevive)
Events:Subscribe("VehicleCollide", fnpc, fnpc.VehicleCollide)
Events:Subscribe("LocalPlayerChat", fnpc, fnpc.Path)
Events:Subscribe("PostTick", fnpc, fnpc.iRaycast)
Events:Subscribe("Render", fnpc, fnpc.Render)
Events:Subscribe("ResolutionChange", fnpc, fnpc.ResolutionChange)
Events:Subscribe("KeyDown", fnpc, fnpc.KeyDown)
--
Events:Subscribe("HellfireExplosion", fnpc, fnpc.HellfireExplosion)
Events:Subscribe("UpdateSharedActors", fnpc, fnpc.UpdateSharedActors)
----------------------------------------------------------------------
class 'ActorOverrideStates'
overrides = {} -- id = true

function ActorOverrideStates:__init(actor, states, angle, velocity)
	self.actor = actor
	self.states = states
	self.angle = angle
	self.velocity = velocity
	self.timer = Timer()
	self.event = Events:Subscribe("PreTick", self, self.PreTick)
end

function ActorOverrideStates:PreTick()
	if IsValid(self.actor) then
		if self.timer:GetSeconds() < 2.0 then
			for state, bool in pairs(self.states) do -- if want to do arm states etc, change bool to descriptor
				self.actor:SetBaseState(state)
				self.actor:SetLinearVelocity(self.angle * (Vector3.Forward * self.velocity))
				self.velocity = (self.velocity * .98)
				--Chat:Print("Overriding state: " .. tostring(state), Color(math.random(0, 255), 255, math.random(0, 255)))
			end
		else
			overrides[self.actor:GetId()] = nil
			self.timer = nil
			Events:Unsubscribe(self.event)
		end
	end
end




class 'DelayedHealthSet'

function DelayedHealthSet:__init(id, health)
	self.id = id
	self.health = health
	self.timer = Timer()
	self.event = Events:Subscribe("PreTick", self, self.PreTick)
end

function DelayedHealthSet:PreTick()
	if self.timer:GetSeconds() > .35 then
		if actors[self.id] then
			local actor = actors[self.id]
			if IsValid(actor) then
				actor:SetBaseState(6)
				actor:SetUpperBodyState(346)
				actor:SetHealth(self.health)
				actor:SetPosition(actor:GetPosition() + Vector3(0, 1.5, 0))
			end
		end
		self.timer = nil
		Events:Unsubscribe(self.event)
	end
end