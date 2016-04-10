class 'Squads'

function Squads:__init()
	squads = {}
	default_speed = .7
	raycast_frequency = 22 -- skipped ticks for raycasting to check for barriers
	squad_size = 6 -- MUST BE AN EVEN NUMBER
	backward_space = 3 -- meters of space between troop spawns backwards
	actor_max_distance = 125 -- maximum distance actor can be from target pos
	--
	troop_form = {}
	
end

function Squads:WNOCreate(args)
	local model_id = args.object:GetValue("Squad")
	if model_id then
		local rand = math.random
		local pos = args.object:GetPosition()
		local ang = args.object:GetAngle()
		squads[args.object:GetId()] = 
		{
			troops = 
			{
				leader = {actor = ClientActor.Create(AssetLocation.Game, {model_id = 42, position = pos, angle = ang}), speed = default_speed, raycast_ticks = rand(0, raycast_frequency), jump_counter = 0, evade_ticks = 0, offset = Vector3.Backward * (((squad_size / 2) * 3) + 2.5)},
			},
			iWNO = args.object
		}
		local backward_mod = backward_space
		for i = 1, squad_size do
			if i <= squad_size / 2 then
				table.insert(squads[args.object:GetId()].troops, {actor = ClientActor.Create(AssetLocation.Game, {model_id = 66, position = pos + (ang * (Vector3.Backward * backward_mod) + (Vector3.Right * 1.5)), angle = ang}), speed = default_speed, raycast_ticks = rand(0, raycast_frequency), jump_counter = 0, evade_ticks = 0, offset = (Vector3.Backward * backward_mod) + (Vector3.Right * 1.5)})
			else
				table.insert(squads[args.object:GetId()].troops, {actor = ClientActor.Create(AssetLocation.Game, {model_id = 66, position = pos + (ang * (Vector3.Backward * backward_mod) + (Vector3.Left * 1.5)), angle = ang}), speed = default_speed, raycast_ticks = rand(0, raycast_frequency), jump_counter = 0, evade_ticks = 0, offset = (Vector3.Backward * backward_mod) + (Vector3.Left * 1.5)})
			end
			if i == squad_size / 2 then backward_mod = 0 end
			backward_mod = backward_mod + backward_space
		end
	end
end

function Squads:WNODestroy(args)
	if args.object:GetValue("Squad") and squads[args.object:GetId()] then
		local id = args.object:GetId()
		for _, itable in pairs(squads[id].troops) do
			if IsValid(itable.actor) then
				itable.actor:Remove()
			end
		end
		squads[id] = nil
	end
end

function Squads:MoveTroops()
	local delete = {}
	local rand = math.random
	for id, itable in pairs(squads) do
		if itable.troops then
			for numindex, troop_info in pairs(itable.troops) do
				if IsValid(troop_info.actor) and IsValid(itable.iWNO) then
					local actor = troop_info.actor
					local pos_raycast = Physics:Raycast(itable.iWNO:GetPosition(), itable.iWNO:GetAngle() * Vector3.Down, 0, 250)
					local target_pos = pos_raycast.position + (itable.iWNO:GetAngle() * troop_info.offset)
					local dist = Vector3.Distance(target_pos, actor:GetPosition())
					if dist < actor_max_distance then
						if troop_info.jump_counter == 0 and troop_info.evade_ticks == 0 then
							local actor = troop_info.actor
							local actor_pos = actor:GetPosition()
							local actor_ang = actor:GetAngle()
							local iWNO_ang = itable.iWNO:GetAngle()
						
							local ang_updown = (target_pos - actor_pos):Dot(iWNO_ang * Vector3.Forward)
							local ang_rightleft = (target_pos - actor_pos):Dot(iWNO_ang * Vector3.Right)
							--print("left-right: " .. ang_rightleft)
							--print("up-down: " .. ang_updown)
							troop_info.speed = default_speed
							local i = true
							if ang_updown < -.5 then
								i = false
								troop_info.speed = default_speed * 2
								actor:SetInput(Action.MoveForward, troop_info.speed)
								actor:SetBaseState( AnimationState.SUprightBasicNavigation )
							elseif ang_updown > .5 then
								i = false
								troop_info.speed = default_speed / 2
								actor:SetInput(Action.MoveForward, troop_info.speed)
								actor:SetBaseState( AnimationState.SUprightBasicNavigation )
							end
							if ang_rightleft > .5 then
								i = false
								troop_info.speed = default_speed * 2
								actor:SetInput(Action.MoveLeft, .7)
								actor:SetBaseState( AnimationState.SUprightBasicNavigation )
							elseif ang_rightleft < -.5 then
								i = false
								troop_info.speed = default_speed / 2
								actor:SetInput(Action.MoveRight, .7)
								actor:SetBaseState( AnimationState.SUprightBasicNavigation )
							end
							
							actor:SetAngle(iWNO_ang * Angle(math.pi, 0, 0))
							if i == true then
								actor:SetInput(Action.MoveForward, troop_info.speed)
								actor:SetBaseState( AnimationState.SUprightBasicNavigation )
							end
							troop_info.speed = default_speed
							troop_info.raycast_ticks = troop_info.raycast_ticks + 1
							if troop_info.raycast_ticks >= raycast_frequency then
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
											troop_info.jump_counter = 17
										else
											troop_info.evade_ticks = 100
											local dir = rand(0, 1)
											if dir == 0 then
												actor:SetAngle(actor:GetAngle() * Angle(-math.pi / 2, 0, 0))
											else
												actor:SetAngle(actor:GetAngle() * Angle(math.pi * 2 / 3, 0, 0))
											end
										end
									end
								end
								troop_info.raycast_ticks = 0
							end
						elseif troop_info.jump_counter > 0 then
							local actor_ang = actor:GetAngle()
							local actor_pos = actor:GetPosition()
							local ticks = troop_info.jump_counter
							--print("Enterino")
							actor:SetInput(Action.Jump, 1.0)
							troop_info.jump_counter = troop_info.jump_counter - 1
						elseif troop_info.evade_ticks > 0 then
							--print("EVADING")
							actor:SetInput(Action.MoveForward, 2.2)
							actor:SetBaseState( AnimationState.SUprightBasicNavigation )
							troop_info.evade_ticks = troop_info.evade_ticks - 1
						end
					else
						local model_id = actor:GetModelId()
						actor:Remove()
						local pos_raycast = Physics:Raycast(itable.iWNO:GetPosition(), itable.iWNO:GetAngle() * Vector3.Down, 0, 250)
						local target_pos = pos_raycast.position + (itable.iWNO:GetAngle() * troop_info.offset)
						table.insert(delete, id)
						table.insert(squads[id].troops, {actor = ClientActor.Create(AssetLocation.Game, {model_id = model_id, position = target_pos + Vector3(0, 1.72, 0), angle = itable.iWNO:GetAngle()}), speed = default_speed, raycast_ticks = rand(0, raycast_frequency), jump_counter = 0, evade_ticks = 0, offset = troop_info.offset})
					end
				end
			end
		end
	end
	for index, id in pairs(delete) do
		squads[id] = nil
	end
end

function Squads:ModuleUnload()
	for id, itable in pairs(squads) do
		for role, troop_info in pairs(itable.troops) do
			if IsValid(troop_info.actor) then
				troop_info.actor:Remove()
			end
		end
	end
end

squad = Squads()

Events:Subscribe("WorldNetworkObjectCreate", squad, squad.WNOCreate)
Events:Subscribe("WorldNetworkObjectDestroy", squad, squad.WNODestroy)
Events:Subscribe("PostTick", squad, squad.MoveTroops)
Events:Subscribe("ModuleUnload", squad, squad.ModuleUnload)

--function SquadRender()
	--for id, itable in pairs(squads) do
		--local iWNO = WorldNetworkObject.GetById(id)
		--if iWNO and IsValid(iWNO) then
			--local pos_raycast = Physics:Raycast(iWNO:GetPosition(), iWNO:GetAngle() * Vector3.Down, 0, 250)
			--Render:FillCircle(pos_raycast.position, 5, Color(0, 255, 0, 50))
			--Render:DrawLine(pos_raycast.position, pos_raycast.position + (iWNO:GetAngle() * (Vector3.Forward * 10)), Color(255, 0, 0))
		--end
	--end
--end
--Events:Subscribe("Render", SquadRender)