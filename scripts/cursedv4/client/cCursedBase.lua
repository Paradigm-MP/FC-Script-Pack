class 'Cursed'

function Cursed:__init()
	warning_zones = {}
	danger_zones = {}
	
	lights = {}
	local_effects = {443, 453, 201}
	cursed_effects = {}
	--25 is creepy sounds, 70 is brown dust, 130 red flare smoke, 
	--136 creepy electricity, 167 small black smoke, 172 nuke engine, 241 black smoke with distortion
	--44 gray smoke with distortion going up, 260 water wake, 262 nuke launch black smoke, 343 spooky crumbling sound
	--388 black smoke, 408 black smoke with fire, 418 fog, 443 helicopter dust, 453 spooky wind, 
	--455 nuke missile, 
	--cs_fog_floor_01.psmb ...death?
	--fire_lave_medium_06.psmb ... small ember particles...fire?
	--fire_lave_medium_08.psmb ... small orange flares
	--fx_ballonengine_02.psmb ... distortion
	--fx_char_explode_04.psmb, fx_char_explode_03.psmb, fx_char_explode_05.psmb, fx_char_explode_06.psmb ... death fx
	--fx_char_swim_01.psmb ... swirling water vortex small
	--fx_cut_trucksmoke_01.psmb ... smoky effect, maybe for teleportation
	--fx_emppower_active_04.psmb ... cool distortion vortex
	--fx_env_casino_window_09.psmb ... giant distortion wave
	--fx_env_fountain_constant_02.psmb ... little bubble things going up and down
	--fx_env_fountain_constant_05.psmb ... rings
	--fx_env_gastank_03.psmb ... small circular smoke
	--fx_env_pipeline_ventpop_360_11.psmb ... small distortion vortex
	--fx_exp_barrel_01.psmb ... small cool explosion
	--fx_exp_chockwave_large_06.psmb ... giant white shockwave
	--fx_f1m07_bomb_explosion_11.psmb ... even bigger yellowish shockwave
	--fx_f2m06_empfence_01.psmb ... blue flare and distortion
	--fx_f304_rocketengine_02.psmb ... giant orange/yellow flare...probably the death one
	--fx_green.psmb ... big green ball
	
	lightcolors = {}
	lightcolors[0] = Color(0,0,255)
	lightcolors[1] = Color(0,255,255)
	lightcolors[2] = Color(0,255,0)
	lightcolors[3] = Color(255,255,0)
	lightcolors[4] = Color(255,0,0)
	lightcolors[5] = Color(255,0,255)
	lightcolors[6] = Color(0,255,153)
	lightcolors[7] = Color(153,255,0)
	lightcolors[8] = Color(255,153,0)
	lightcolors[9] = Color(0,153,255)
	lightcolors[10] = Color(153,0,255)
	lightcolors[11] = Color(255,0,153)
	lightcolors[12] = Color(0,153,153)
	
	for _, itable in pairs(cursed_locations) do
		table.insert(warning_zones, {
			trigger = ShapeTrigger.Create(
			{
				position = itable.position,
				angle = Angle(0, 0, 0),
				components = {
				{
					type = TriggerType.Sphere,
					size = Vector3(itable.radius + 250, itable.radius + 250, itable.radius + 250),
					position = Vector3(0, 0, 0),
				}
				},
				trigger_player = true,
				trigger_player_in_vehicle = true,
				trigger_vehicle = false,
			}),
			radius = itable.radius + 250
		})
		table.insert(danger_zones, {
			trigger = ShapeTrigger.Create(
			{
				position = itable.position,
				angle = Angle(0, 0, 0),
				components = {
				{
					type = TriggerType.Sphere,
					size = Vector3(itable.radius, itable.radius, itable.radius),
					position = Vector3(0, 0, 0),
				}
				},
				trigger_player = true,
				trigger_player_in_vehicle = true,
				trigger_vehicle = false,
			}),
			radius = itable.radius
		})
	end
end

function Cursed:ShapeTriggerEnter(args)
	for i = 1, #danger_zones do
		if danger_zones[i].trigger == args.trigger then
			if args.entity.__type == "Player" or args.entity.__type == "LocalPlayer" then
				local id = args.entity:GetId()
				lights[id] = ClientLight.Create({
					position = args.entity:GetPosition() + Vector3(0, 2, 0),
					radius = 10,
					color = table.randomvalue(lightcolors),
					multiplier = 10, -- brightness
					fade_in_duration = 3,
					fade_out_duration = 3
				})
				if args.entity.__type == "LocalPlayer" then
					local pos = danger_zones[i].trigger:GetPosition()
					current_zone_position = pos
					Network:Send("ClientEnterMeteorZone", {pos = tostring(pos)})
					for index, effectid in pairs(local_effects) do
						local args = {}
						cursed_effects[index] = ClientEffect.Create(AssetLocation.Game, {
							effect_id = effectid,
							position = LocalPlayer:GetPosition(),
							angle = LocalPlayer:GetAngle()
						})
					end
				end
			end
			break
		end
	end
end

function Cursed:ShapeTriggerExit(args)
	if args.entity.__type == "Player" or args.entity.__type == "LocalPlayer" then
		local id = args.entity:GetId()
		if lights[id] then
			if IsValid(lights[id]) then lights[id]:Remove() end
			lights[id] = nil
		end
		if args.entity.__type == "LocalPlayer" then
			Network:Send("ClientExitMeteorZone", {pos = tostring(current_zone_position)})
			for index, effect in pairs(cursed_effects) do
				if IsValid(effect) then effect:Remove() end
			end
		end
	end
end

function Cursed:PreTick()
	for id, light in pairs(lights) do
		local ply = Player.GetById(id)
		if ply and IsValid(ply) then
			if IsValid(light) then
				light:SetPosition(ply:GetPosition()+ Vector3(0, 2, 0))
			end
		else
			if IsValid(lights[id]) then lights[id]:Remove() end
			lights[id] = nil
		end
	end
	local localpos = LocalPlayer:GetPosition()
	for _, effect in pairs(cursed_effects) do
		if IsValid(effect) then
			effect:SetPosition(localpos)
		end
	end
end

function Cursed:ModuleUnload()
	for id, light in pairs(lights) do
		if IsValid(light) then light:Remove() end
	end
	for _, effect in pairs(cursed_effects) do
		if IsValid(effect) then effect:Remove() end
	end
end

cursed = Cursed()

Events:Subscribe("ShapeTriggerEnter", cursed, cursed.ShapeTriggerEnter)
Events:Subscribe("ShapeTriggerExit", cursed, cursed.ShapeTriggerExit)
Events:Subscribe("PreTick", cursed, cursed.PreTick)
Events:Subscribe("ModuleUnload", cursed, cursed.ModuleUnload)

function RenderCursedZones()
	for _, itable in pairs(warning_zones) do
		local transform = Transform3()
		transform:Translate(itable.trigger:GetPosition())
		transform:Rotate(Angle(0, 0.5 * math.pi, 0))
		Render:SetTransform(transform)
		Render:DrawCircle(Vector3.Zero, itable.radius, Color(255, 255, 0))
		Render:ResetTransform()
	end
	for _, itable in pairs(danger_zones) do
		local transform = Transform3()
		transform:Translate(itable.trigger:GetPosition())
		transform:Rotate(Angle(0, 0.5 * math.pi, 0))
		Render:SetTransform(transform)
		Render:DrawCircle(Vector3.Zero, itable.radius, Color(255, 0, 0))
		Render:ResetTransform()
	end
	Render:ResetTransform()
end
--Events:Subscribe("Render", RenderCursedZones)
