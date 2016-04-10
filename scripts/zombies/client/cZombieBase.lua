class 'Zombies'

function Zombies:__init()
	if SharedObject.GetByName("ClientSharedZombies") ~= nil then
		SharedObject.GetByName("ClientSharedZombies"):Remove()
	end
	local zs = SharedObject.Create("ClientSharedZombies", {})
	zombs = {}
	zombs_actors = {}
	default_speed = .7
	raycast_frequency = 22
	angle_adjust_delay = 30
	actor_max_distance = 100
	chase_distance_min = 75
	--
	streamed_players = {}
	target_queue = {}
	--
	local_pos = Vector3(0, 0, 0)
end

function Zombies:SimulateZombies()
	local delete = {}
	local respawn = {}
	local rand = math.random
	for id, itable in pairs(zombs) do
		local wno_pos = itable.iWNO:GetPosition()
		local targetting = itable.iWNO:GetValue("Targetting")
		--print("iterating")
		if IsValid(itable.actor) and IsValid(itable.iWNO) then
			local actor = itable.actor
			actor:SetHealth(itable.health)
			if actor:GetHealth() > 0 then
				local pos_raycast = Physics:Raycast(wno_pos + Vector3(0, 1.72, 0), itable.iWNO:GetAngle() * Vector3.Down, 0, 250)
				local target_pos = pos_raycast.position
				local actor_pos = actor:GetPosition()
				local dist = Vector3.Distance(target_pos, actor_pos)
				if itable.raycast_ticks == raycast_frequency - 1 then
					local idist = Vector3.Distance(local_pos, actor_pos)
					if idist > chase_distance_min then
						if targetting and targetting == LocalPlayer then
							target_queue[itable.iWNO:GetId()] = 34
							--Chat:Print("Untargetting because out of range of LocalPlayer", Color.Green)
							--print("local_pos: " .. tostring(local_pos))
							--print("actor_pos: " .. tostring(actor_pos))
							--print("idist: " .. tostring(idist))
						end
					end
					if idist < chase_distance_min and not target_queue[itable.iWNO:GetId()] then
						if not targetting or targetting == LocalPlayer then
							local closest_dist = idist
							local closest_ply = LocalPlayer
							for _, t in pairs(streamed_players) do
								local newdist = Vector3.Distance(t.pos, actor_pos)
								if newdist < closest_dist then 
									closest_dist = newdist
									closest_ply = t.ply
								end
							end
							--Chat:Print("closest_ply: " .. tostring(closest_ply), Color(0, 255, 0))
							if targetting and IsValid(targetting) then
								if LocalPlayer ~= closest_ply then
									target_queue[itable.iWNO:GetId()] = closest_ply
									--Chat:Print("Made " .. tostring(closest_ply) .. " new target", Color.Red)
								end
							else
								target_queue[itable.iWNO:GetId()] = closest_ply
								--Chat:Print("Made " .. tostring(closest_ply) .. " new target because zombie had no target", Color.Red)
							end
						end
					end
				end
				if not targetting then
					--print("1")
					if dist < actor_max_distance then
						if itable.jump_counter == 0 and itable.evade_ticks == 0 and itable.ragdoll_ticks == 0 then
							local actor_pos = actor:GetPosition()
							local actor_ang = actor:GetAngle()
							local iWNO_ang = itable.iWNO:GetAngle()
						
							local ang_updown = (target_pos - actor_pos):Dot(iWNO_ang * Vector3.Forward)
							local ang_rightleft = (target_pos - actor_pos):Dot(iWNO_ang * Vector3.Right)
							--print("left-right: " .. ang_rightleft)
							--print("up-down: " .. ang_updown)
							itable.speed = default_speed
							local i = true
							if ang_updown < -.5 then
								--print("b")
								i = false
								itable.speed = default_speed * 2
								--print("speed: " .. tostring(itable.speed))
								actor:SetInput(Action.MoveForward, itable.speed)
								actor:SetBaseState( AnimationState.SUprightBasicNavigation )
							elseif ang_updown > .5 then
								--print("a")
								i = false
								itable.speed = default_speed / 2
								actor:SetInput(Action.MoveForward, itable.speed)
								actor:SetBaseState( AnimationState.SUprightBasicNavigation )
							end
							if ang_rightleft > .5 then
								--print("c")
								i = false
								itable.speed = default_speed * 2
								actor:SetInput(Action.MoveLeft, .7)
								actor:SetBaseState( AnimationState.SUprightBasicNavigation )
							elseif ang_rightleft < -.5 then
								--print("d")
								i = false
								itable.speed = default_speed / 2
								actor:SetInput(Action.MoveRight, .7)
								actor:SetBaseState( AnimationState.SUprightBasicNavigation )
							end
							
							actor:SetAngle(iWNO_ang * Angle(math.pi, 0, 0))
							if i == true then
								--print("2")
								actor:SetInput(Action.MoveForward, itable.speed)
								actor:SetBaseState( AnimationState.SUprightBasicNavigation )
							end
							itable.speed = default_speed
							itable.raycast_ticks = itable.raycast_ticks + 1
							if itable.raycast_ticks >= raycast_frequency then
								local ray = Physics:Raycast(actor_pos + Vector3(0, .3, 0), actor_ang * Vector3.Forward, 0, 5, false)
								local ray3 = Physics:Raycast(actor_pos + Vector3(0, .35, 0), actor_ang * Vector3.Forward, 0, 5, false)
								--print("ray.distance: " .. tostring(ray.distance))
								if not ray.entity or ray.entity.__type ~= "ClientActor" then
									if ray.distance < .65 and ray3.distance < .65 then
										local ray2 = Physics:Raycast(actor_pos + Vector3(0, 1.9, 0), actor_ang * Vector3.Forward, 0, 5, false)
										--print("ray2.distance: " .. tostring(ray2.distance))
										if ray2.distance > 2.5 then
											actor:SetInput(Action.Jump, 1.0)
											actor:SetBaseState(AnimationState.SJumpStartSprintForward)
											--Chat:Print("Actor attempted to jump obstacle", Color(0, 255, 0))
											itable.jump_counter = 17
										else
											--Chat:Print("Start Evade", Color.Red)
											itable.evade_ticks = 100
											local dir = itable.iWNO:GetValue("EvadePreference")
											if dir == 0 then
												actor:SetAngle(actor:GetAngle() * Angle(-math.pi / 2, 0, 0))
											else
												actor:SetAngle(actor:GetAngle() * Angle(math.pi * 2 / 3, 0, 0))
											end
										end
									end
								end
								itable.raycast_ticks = 0
							end
						elseif itable.jump_counter > 0 then
							actor:SetInput(Action.Jump, 1.0)
							itable.jump_counter = itable.jump_counter - 1
						elseif itable.evade_ticks > 0 then
							--print("EVADING")
							actor:SetInput(Action.MoveForward, 2.2)
							actor:SetBaseState( AnimationState.SUprightBasicNavigation )
							itable.evade_ticks = itable.evade_ticks - 1
						elseif itable.ragdoll_ticks > 0 then
							
						end
					else -- actor is too far from target
						--Chat:Print("Actor removed because too far from target pos", Color.Red)
						local model_id = actor:GetModelId()
						actor:Remove()
						local pos_raycast = Physics:Raycast(wno_pos, itable.iWNO:GetAngle() * Vector3.Down, 0, 250)
						local target_pos = wno_pos
						respawn[id] = itable.iWNO
					end
				elseif targetting and IsValid(targetting) then
					--print("TARGETTING")
					local actor_pos = actor:GetPosition()
					local dist2 = Vector3.Distance(actor_pos, targetting:GetPosition())
					if dist2 < 1 and itable.attack_ticks == 0 then
						itable.attack_ticks = 20
						itable.attack_choice = not itable.attack_choice
						if LocalPlayer == targetting then
							Network:Send("ZombieHit", {dmg = .2})
						end
					end

					itable.angle_ticks = itable.angle_ticks + 1
					
					if itable.jump_counter == 0 and itable.evade_ticks == 0 and itable.attack_ticks == 0 and itable.ragdoll_ticks == 0 then
						local actor = itable.actor
						local actor_ang = actor:GetAngle()
						local iWNO_ang = itable.iWNO:GetAngle()
					
						--local ang_forwardbackward = (target_pos - actor_pos):Dot(iWNO_ang * Vector3.Forward)
						--local ang_rightleft = (target_pos - actor_pos):Dot(iWNO_ang * Vector3.Right)
						
						--print("left-right: " .. ang_rightleft)
						--print("up-down: " .. ang_updown)
						itable.speed = default_speed
						local i = true
						
						--actor:SetAngle(iWNO_ang * Angle(math.pi, 0, 0))
						--actor:SetAngle(Angle.FromVectors(actor_pos, wno_pos))
						if itable.angle_ticks >= angle_adjust_delay then -- config actor angle set here
							actor:SetAngle(Angle(Angle.FromVectors(Vector3.Forward, (wno_pos) - actor_pos).yaw, 0, 0)) -- aim at target
							actor:SetAimPosition(wno_pos)
							itable.angle_ticks = 0
						end
						
						if i == true then
							actor:SetInput(Action.Dash, itable.speed)
							actor:SetBaseState( AnimationState.SDash )
						end
						itable.speed = default_speed
						itable.raycast_ticks = itable.raycast_ticks + 1
						if itable.raycast_ticks >= raycast_frequency then
							if not IsNaN(actor_pos) and not IsNaN(actor_ang) then
								local ray = Physics:Raycast(actor_pos + Vector3(0, .3, 0), actor_ang * Vector3.Forward, 0, 5, false)
								local ray3 = Physics:Raycast(actor_pos + Vector3(0, .35, 0), actor_ang * Vector3.Forward, 0, 5, false)
								--print("ray.distance: " .. tostring(ray.distance))
								if not ray.entity or ray.entity.__type ~= "ClientActor" then
									if ray.distance < .65 and ray3.distance < .65 then
										local ray2 = Physics:Raycast(actor_pos + Vector3(0, 1.9, 0), actor_ang * Vector3.Forward, 0, 5, false)
										--print("ray2.distance: " .. tostring(ray2.distance))
										if ray2.distance > 2.5 then
											actor:SetInput(Action.Jump, 1.0)
											actor:SetBaseState(AnimationState.SJumpStartSprintForward)
											--Chat:Print("Actor attempted to jump obstacle", Color(0, 255, 0))
											itable.jump_counter = 17
										else
											itable.evade_ticks = 100
											local dir = itable.iWNO:GetValue("EvadePreference")
											if dir == 0 then
												actor:SetAngle(actor:GetAngle() * Angle(-math.pi / 2, 0, 0))
											else
												actor:SetAngle(actor:GetAngle() * Angle(math.pi * 2 / 3, 0, 0))
											end
										end
									end
								end
							end
							itable.raycast_ticks = 0
						end
					elseif itable.jump_counter > 0 then
						actor:SetInput(Action.Jump, 1.0)
						itable.jump_counter = itable.jump_counter - 1
					elseif itable.evade_ticks > 0 then
						--print("EVADING")
						actor:SetInput(Action.MoveForward, 2.2)
						actor:SetBaseState( AnimationState.SUprightBasicNavigation )
						itable.evade_ticks = itable.evade_ticks - 1
					elseif itable.attack_ticks > 0 then
						if itable.attack_choice == true then
							actor:SetBaseState(AnimationState.SGrappleSmashRight)
						else
							actor:SetBaseState(AnimationState.SGrappleSmashLeft)
						end
						actor:SetAngle(Angle(Angle.FromVectors(Vector3.Forward, wno_pos - actor_pos).yaw, 0, 0)) -- aim at target
						itable.attack_ticks = itable.attack_ticks - 1
					elseif itable.ragdoll_ticks > 0 then
						actor:SetLinearVelocity(Angle(0, itable.collision_angle.yaw, 0) * ((Vector3.Forward * (.075 * itable.ragdoll_ticks)) + (Vector3.Right * math.random())))
						actor:SetBaseState(257)
						itable.ragdoll_ticks = itable.ragdoll_ticks - 1
					end
				end
			else
				actor:SetBaseState(56) -- dead
			end
		end
	end
	for index, id in pairs(delete) do
		zombs[id] = nil
	end
	for id, iWNO in pairs(respawn) do
		zombs_actors[zombs[id].actor:GetId()] = nil
		zombs[id] = nil
		zombs[id] = {iWNO = iWNO, actor = ClientActor.Create(AssetLocation.Game, {model_id = 39, position = iWNO:GetPosition(), angle = iWNO:GetAngle()}), speed = default_speed, raycast_ticks = math.random(0, raycast_frequency), jump_counter = 0, evade_ticks = 0, angle_ticks = math.random(0, angle_adjust_delay), attack_ticks = 0, attack_choice = true, health = iWNO:GetValue("Health") or 1, ragdoll_ticks = 0, collision_angle = Angle()}
		zombs_actors[zombs[id].actor:GetId()] = id
	end
end

function Zombies:WNOCreate(args)
	if args.object:GetValue("iZombie") then
		local id = args.object:GetId()
		zombs[id] = {iWNO = args.object, actor = ClientActor.Create(AssetLocation.Game, {model_id = 39, position = args.object:GetPosition(), angle = args.object:GetAngle()}), speed = default_speed, raycast_ticks = math.random(0, raycast_frequency), jump_counter = 0, evade_ticks = 0, angle_ticks = math.random(0, angle_adjust_delay), attack_ticks = 0, attack_choice = true, health = args.object:GetValue("Health") or 1, ragdoll_ticks = 0, collision_angle = Angle()}
		zombs_actors[zombs[id].actor:GetId()] = id
	end
end

function Zombies:WNODestroy(args)
	if args.object:GetValue("iZombie") then
		local id = args.object:GetId()
		if zombs[id] then
			if IsValid(zombs[id].actor) then
				zombs[id].actor:Remove()
			end
			zombs[id] = nil
		end
	end
end

function Zombies:NetworkObjectValueChange(args)
	if args.key == "Health" then
		local id = args.object:GetId()
		if zombs[id] then
			zombs[id].health = args.value
		end
	end
end

function Zombies:VehicleCollide(args)
	if args.entity then
		if tostring(args.entity) == "ClientActor" then
			if args.attacker then
				local actor = args.entity
				if IsValid(actor) then
					local id = actor:GetId()
					if zombs_actors[id] then
						--Chat:Print("Hit Zombie with impulse: " .. tostring(args.impulse), Color.Red)
						if args.impulse > 20 then
							zombs[zombs_actors[id]].collision_angle = LocalPlayer:GetAngle()
							zombs[zombs_actors[id]].ragdoll_ticks = 75
						end
					end
				end
			end
		end
	end
end

function Zombies:UpdateSyncedZombies()
	local sr = SharedObject.GetByName("ClientSharedZombies")
	sr:SetValue("Zombies", nil)
	local new_zombies = {}
	for wno_id, itable in pairs(zombs) do
		if IsValid(itable.actor) then
			new_zombies[wno_id] = itable.actor:GetId()
		end
	end
	sr:SetValue("Zombies", new_zombies)
end

function Zombies:GetStreamedPlayers()
	streamed_players = nil
	streamed_players = {}
	for ply in Client:GetStreamedPlayers() do
		table.insert(streamed_players, {ply = ply, pos = ply:GetPosition()})
	end
	local_pos = LocalPlayer:GetPosition()
	--
	if table.count(target_queue) > 0 then
		Network:Send("ZombieRetarget", {izombies = target_queue})
		for k, v in pairs(target_queue) do target_queue[k] = nil end
	end
end

function Zombies:Render()
	for id, itable in pairs(zombs) do
		if IsValid(itable.iWNO) then
			Render:FillCircle(itable.iWNO:GetPosition(), 2.5, Color(255, 0, 0, 10))
			Render:DrawLine(itable.iWNO:GetPosition(), itable.iWNO:GetPosition() + (itable.iWNO:GetAngle() * (Vector3.Backward * 10)), Color(255, 255, 0, 100))
		end
	end
end

function Zombies:ModuleUnload()
	for id, itable in pairs(zombs) do
		if IsValid(itable.actor) then
			itable.actor:Remove()
		end
	end
end

zombies = Zombies()

Events:Subscribe("WorldNetworkObjectCreate", zombies, zombies.WNOCreate)
Events:Subscribe("WorldNetworkObjectDestroy", zombies, zombies.WNODestroy)
Events:Subscribe("NetworkObjectValueChange", zombies, zombies.NetworkObjectValueChange)
Events:Subscribe("VehicleCollide", zombies, zombies.VehicleCollide)
Events:Subscribe("PostTick", zombies, zombies.SimulateZombies)
Events:Subscribe("SecondTick", zombies, zombies.GetStreamedPlayers)
--Events:Subscribe("Render", zombies, zombies.Render)
Events:Subscribe("ModuleUnload", zombies, zombies.ModuleUnload)
--
Events:Subscribe("UpdateSharedZombies", zombies, zombies.UpdateSyncedZombies)