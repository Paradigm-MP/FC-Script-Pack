class 'Meteor'

function Meteor:__init()
	iclock = Timer()
	meteors = {}
	explosions = {}
	-- effect 101 - huge meteor
	-- 409 fire?
	-- 455
	-- 132 - big explo
	--move_distance = 2.5 -- movement per tick in meters
	-- 41 - small comet
	-- 136 lightning storm?
	-- 172
	-- 184 poison gas
	-- 185 big meteor explosion
	-- 188 randomly dropping things
	-- 201
	-- 211 sexy big explosion
	-- 329 ring of fire - spin around big meteor?
	-- 364 blue ring of fire - spin around big comet?
	-- 393 small comet?
	move_distance = 4.8
	raycast_frequency = 1 -- tick delay for terrain raycasting
end

function Meteor:WNOCreate(args)
	local id = args.object:GetId()
	if args.object:GetValue("Meteor") then
		if not meteors[id] then
			meteors[id] = true
		end
	end
end

function Meteor:WNOValueChange(args)
	local id = args.object:GetId()
	if meteors[id] and args.key == "Spawn" then
		if type(meteors[id]) ~= "boolean" and meteors[id].effect and IsValid(meteors[id].effect) then
			meteors[id].effect:Remove()
		end
		meteors[id] = nil
		meteors[id] =			
			{	effect = ClientEffect.Create(AssetLocation.Game,
				{
					effect_id = 455, -- config meteor effect
					position = args.object:GetPosition(),
					angle = args.object:GetAngle()
				}),
				type = args.object:GetValue("Meteor"),
				raycast_counter = 0
			}
		--Chat:Print("Started Meteor Path", Color(0, 255, 0))
	end
end

function Meteor:Path()
	local plypos = LocalPlayer:GetPosition()
	for id, itable in pairs(meteors) do
		if type(itable) ~= "boolean" and IsValid(itable.effect) then
			itable.raycast_counter = itable.raycast_counter + 1
			local pos = itable.effect:GetPosition()
			local ang = itable.effect:GetAngle()
			local iWNO = WorldNetworkObject.GetById(id)
			if not IsValid(iWNO) then return end
			--
			itable.effect:SetPosition(pos + ang * (Vector3.Forward * move_distance))
			--
			if itable.raycast_counter == raycast_frequency then
				local ray = Physics:Raycast(pos, ang * Vector3.Forward, 0, 7.5, false)
				if ray.distance < 5 then
					itable.effect:SetPosition(iWNO:GetPosition())
					table.insert(explosions, {spawn_time = iclock:GetSeconds(), explosion = ClientEffect.Create(AssetLocation.Game,
						{
							effect_id = 82, -- config explosion effect, default 211
							position = ray.position,
							angle = Angle(0, 0, 0)
						})})
					local dist = Vector3.Distance(plypos, ray.position)
					if dist < 12.5 then
						local damage
						if dist < 5 then
							damage = .65
							SpawnRagdollFx(ray.position)
						elseif dist < 7.5 then
							damage = .45
							SpawnRagdollFx(ray.position)
						elseif dist < 10 then
							damage = .2
							SpawnRagdollFx(ray.position)
						elseif dist < 12.5 then
							damage = .15
						end
						if LocalPlayer:GetHealth() > 0 then
							Network:Send("MeteorHit", {dmg = damage})
						end
					end
					if meteors[id].effect and IsValid(meteors[id].effect) then
						meteors[id].effect:Remove()
					end
					--Chat:Print("Meteor Hit Something", Color(255, 0, 0))
				end
				itable.raycast_counter = 0
			end
		end
	end
end

function Meteor:CleanUp()
	local current_time = iclock:GetSeconds()
	local absolute = math.abs
	for index, itable in pairs(explosions) do
		if absolute(current_time - itable.spawn_time) > 10 then
			if itable.explosion and IsValid(itable.explosion) then
				itable.explosion:Remove()
			end
			explosions[index] = nil
		end
	end
end

function Meteor:WNODestroy(args)
	local id = args.object:GetId()
	if meteors[id] then
		if meteors[id] then
			if type(meteors[id]) ~= "boolean" and IsValid(meteors[id].effect) then
				meteors[id].effect:Remove()
			end
		end
		meteors[id] = nil
	end
end

function Meteor:Render()
	for id, itable in pairs(meteors) do
		if type(itable) ~= "boolean" then
			if IsValid(itable.effect) then
				--Render:FillCircle(itable.effect:GetPosition(), 20, Color(255, 0, 0, 190))
			end
		end
	end
end

function Meteor:Unload()
	for id, itable in pairs(meteors) do
		if type(itable) ~= "boolean" and IsValid(itable.effect) then
			itable.effect:Remove()
		end
	end
end

function SpawnRagdollFx(pos)
	table.insert(explosions, {spawn_time = iclock:GetSeconds(), explosion = ClientEffect.Create(AssetLocation.Game,
	{
		effect_id = 189,
		position = pos,
		angle = Angle(0, 0, 0)
	})})
end

meteor = Meteor()

Events:Subscribe("PostTick", meteor, meteor.Path)
Events:Subscribe("SecondTick", meteor, meteor.CleanUp)
Events:Subscribe("WorldNetworkObjectCreate", meteor, meteor.WNOCreate)
Events:Subscribe("WorldNetworkObjectDestroy", meteor, meteor.WNODestroy)
Events:Subscribe("NetworkObjectValueChange", meteor, meteor.WNOValueChange)
Events:Subscribe("ModuleUnload", meteor, meteor.Unload)

Events:Subscribe("Render", meteor, meteor.Render)