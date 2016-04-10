SetUnicode(true)
class "INuke"

function INuke:__init(wno)
	self.WNO = wno
	self.Trigger = ShapeTrigger.Create({
			position 	= self.WNO:GetPosition(),
			angle 		= Angle(),
			components	= {
					{
							type		= TriggerType.Sphere,
							size		= Vector3(NUKE_RADIUS, NUKE_RADIUS, NUKE_RADIUS),
							position	= Vector3(0, 0, 0)
					}
			},
			trigger_player				= true,
			trigger_player_in_vehicle	= true,
			trigger_vehicle				= false,
			trigger_npc					= true,
			vehicle_type				= VehicleTriggerType.All
	})
	self.CSO = ClientStaticObject.Create({
			position	= self.WNO:GetPosition(),
			angle		= self.WNO:GetAngle(),
			model		= "general.blz/go063-a1.lod",
			collision 	= "general.blz/go063_lod1-a1_col.pfx"
	})
	self.Active_Effect = ClientParticleSystem.Create(AssetLocation.Game, {
			position	= self.WNO:GetPosition(),
			angle		= self.WNO:GetAngle(),
			path		= "fx_emppower_active_01.psmb"
	})
	self.Pulled_Entities = {}
	self.Potential_Targets = {}
	self.Triggered = false
	self.Tick_Event = nil
	self.EMP_Fired = false
	self.Dead = false
	
	Events:Subscribe("ShapeTriggerEnter", self, self.ShapeTriggerEnter)
	Events:Subscribe("ShapeTriggerExit", self, self.ShapeTriggerExit)
end

function INuke:ActivateTrigger()
	if not self.Triggered then
		Network:Send("ImplosionTrapActivated", {id = self.WNO:GetId()})
	end
	
	self.Triggered = true
end

function INuke:PostTick(args)
	local delta = args.delta
	if self.Dead then return end
	
	if not self.Triggered then
		local removes = {}
		for id, entity in pairs(self.Potential_Targets) do
			local entity_pos = entity:GetPosition()
			local distance = Vector3.Distance(entity_pos, self.WNO:GetPosition())
			local raycast = Physics:Raycast(entity_pos, (self.WNO:GetPosition() - entity_pos):Normalized(), 0, distance)
			if raycast.distance == distance or raycast.entity == entity then
				table.insert(removes, id)
				self.Pulled_Entities[id] = entity
				self:ActivateTrigger()
			end
		end
		for _, id in pairs(removes) do
			self.Potential_Targets[id] = nil
		end
	end
	
	if self.Triggered then
		if not self.EMP_Fired then
			for i = 0, 10 do
				local num = math.random(1, 4)
				ClientParticleSystem.Play(AssetLocation.Game, {
						position	= self.WNO:GetPosition(),
						angle		= self.WNO:GetAngle(),
						path		= "fx_emppower_active_01.psmb",
						timeout		= DETONATION_DURATION
				})
			end
			ClientSound.Play(AssetLocation.Game, {
					position	= self.WNO:GetPosition(),
					bank_id		= 37,
					sound_id	= 74
			})
			self.EMP_Fired = true
		end
		local removes = {}
		for id, entity in pairs(self.Pulled_Entities) do
			if IsValid(entity) then
				if entity.__type == "Vehicle" and entity:GetDriver() != LocalPlayer then
					table.insert(removes, id)
				else
					local entity_pos = entity:GetPosition()
					local distance = Vector3.Distance(entity_pos, self.WNO:GetPosition())
					local raycast = Physics:Raycast(entity_pos, (self.WNO:GetPosition() - entity_pos):Normalized(), 0, distance)
					if raycast.distance == distance or raycast.entity == entity then
						local diff_vector = (self.WNO:GetPosition() - entity:GetPosition()):Normalized()
						local added_vel = math.lerp(0, PULL_STRENGTH, math.clamp(distance, 1, NUKE_RADIUS)) * diff_vector
						
						local entity_vel = entity:GetLinearVelocity()
						local vec_between = entity:GetPosition() - self.WNO:GetPosition()
						local angle_between = math.abs(math.atan2(entity_vel:Cross(vec_between):Length(), entity_vel:Dot(vec_between)))
						if angle_between <= (math.pi / 2.1) then
							added_vel = added_vel * math.lerp(0, CORRECTION_STRENGTH, ((math.pi / 2) - angle_between) / (math.pi / 2))
						end
						
						entity:SetLinearVelocity(entity:GetLinearVelocity() + added_vel)
						if distance <= RAGDOLL_RADIUS then
							if not (250 <= entity:GetBaseState() and entity:GetBaseState() <= 255) then
								if entity.__type == "LocalPlayer" or entity.__type == "ClientActor" then
									-- ClientEffect.Play(AssetLocation.Game, {
											-- position	= entity:GetPosition() - ((entity:GetBonePosition("ragdoll_Head") - self.WNO:GetPosition()) * 0.6),
											-- angle		= entity:GetAngle(),
											-- effect_id	= 75
									-- })
									entity:SetBaseState(AnimationState.SSkydive)
								end
							end
						end
					end
				end
			else
				table.insert(removes, id)
			end
		end
		for _, id in pairs(removes) do
			self.Pulled_Entities[id] = nil
		end
	end
end

function INuke:ShapeTriggerEnter(args)
	if self.Dead then return end
	if args.trigger:GetId() != self.Trigger:GetId() then
		return
	end
	
	if args.entity.__type == "Vehicle" then
		if args.entity:GetDriver() != LocalPlayer then
			return
		end
	end
	
	if args.entity.__type == "Player" then
		if args.entity != LocalPlayer then
			return
		end
	end
	
	self.Tick_Event = Events:Subscribe("PostTick", self, self.PostTick)
	
	local entity_pos = args.entity:GetPosition()
	local distance = Vector3.Distance(entity_pos, self.WNO:GetPosition())
	local raycast = Physics:Raycast(entity_pos, (self.WNO:GetPosition() - entity_pos):Normalized(), 0, distance)
	if raycast.distance != distance and raycast.entity != args.entity then
		self.Potential_Targets[args.entity:GetId()] = args.entity
		return
	end
	
	self.Pulled_Entities[args.entity:GetId()] = args.entity
	self:ActivateTrigger()
end

function INuke:ShapeTriggerExit(args)
	if self.Dead then return end
	if args.trigger:GetId() != self.Trigger:GetId() then
		return
	end
	
	self.Potential_Targets[args.entity:GetId()] = nil
	self.Pulled_Entities[args.entity:GetId()] = nil
end

function INuke:Remove()
	if self.Dead then return end
	ClientEffect.Play(AssetLocation.Game, {
			position	= self.WNO:GetPosition(),
			angle		= self.WNO:GetAngle(),
			effect_id	= 19
	})
	ClientEffect.Play(AssetLocation.Game, {
			position	= self.WNO:GetPosition(),
			angle		= self.WNO:GetAngle(),
			effect_id	= 91
	})
	self.Active_Effect:Remove()
	self.CSO:Remove()
	Events:Unsubscribe(self.Tick_Event)
	self.Dead = true
end
