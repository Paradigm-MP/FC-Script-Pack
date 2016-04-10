--[[-- Longer Grapple by Dev_34
class 'cGrapple'

function cGrapple:__init()
	objectargs = {}
	objectargs.collision = "km02.towercomplex.flz/key013_01_lod1-g_col.pfx"
	objectargs.model = ""
	tetherargs = {}
	tetherargs.collision = "f1m03airstrippile07.eez/go164_01_lod1-a_col.pfx"
	tetherargs.model = ""
	dowork = false
	interpolationtable = {}
	ticks = 75
	takeoverdistance = 20
	killticks = 0
	bike = {} -- reference table
	bike[21] = true
	bike[32] = true
	bike[43] = true
	bike[47] = true
	bike[61] = true
	bike[74] = true
	bike[83] = true
	bike[89] = true
	bike[90] = true
	--------------- CONFIG ---------------|
	range = 1200 -- range of grappling hook (recommended: 85 - 1200)
	pointswitchdistance = 80 -- (distance from next point on line at which tracer object's position is transferred)
	firstpointdistance = 45 -- (distance from player at which the first point is roughly placed. recommended: 30 - 60. cannot be over 83.5)
	numpoints = 15 -- (roughly controls the number of point created, higher is less, lower is more. recommended: 5 - 25. affects smoothness of grappling)
	underwater = true -- set to true to allow grappling to the sea floor, set to false to only allow grappling above sea level
	followvehicle = true -- set to true to follow vehicles. set to false to ignore vehicle grappling over 83.5 distances
	followplayer = true -- set to true to follow players. set to false to ignore players when grappling
		allowplayertether = false -- set to true to allow players to grapple and hold onto other players. set to false to break grapple when close to player
		-- ^ experimental and somewhat buggy and choppy
	--------------- END CONFIG ------------|
end

function cGrapple:InputManager(args)
ticks = ticks + 1
if ticks < 75 then return end -- prevent spam
	if args.input == Action.FireGrapple then
		if targetentity ~= nil then
			ticks = 25
			return
		end
		ticks = 0
		ray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, range + 1)
		if not ray.distance or not ray.position then return end
		if ray.distance > range then return end -- if unobstructed ray (no hit)
		if underwater == false and ray.position.y < 200 then return end
		local dofollow = false
		dotether = false
		if ray.entity then
			if ray.entity.__type == "Vehicle" and followvehicle == false then return end
			if ray.entity.__type == "Player" and followplayer == false then return end
			if ray.entity.__type ~= "Vehicle" and ray.entity.__type ~= "Player" then return end
			if ray.entity.__type == "Player" and allowplayertether == true then
				dotether = true
			elseif ray.entity.__type == "Player" and allowplayertether == false then
				dotether = false
			end
			if dotether == true then
				if ray.distance < 12.5 then
					return
				end 
			else
				if ray.distance < 83.5 then return end
			end
			if ray.entity.__type == "Vehicle" then
				if bike[ray.entity:GetModelId()] then
					takeoverdistance = 12.5
				else
					takeoverdistance = 20
				end
			end
			targetentity = ray.entity
			dofollow = true
		else
			if ray.distance < 83.5 then return end
		end
		local state = LocalPlayer:GetBaseState()
		if state ~= 6 and state ~= 12 and state ~= 19 and state ~= 7 and state ~= 9 then return end -- state limitation
		if tracer == nil then
			if dotether == false then
				objectargs.position = LocalPlayer:GetPosition() + (Camera:GetAngle() * (Vector3.Forward * 25))
				objectargs.angle = Angle()
				tracer = ClientStaticObject.Create(objectargs)
			elseif dotether == true then
				tetherargs.position = Camera:GetPosition() + (Vector3.Forward * 15 + Vector3.Down * .25 + Vector3.Left * .125)
				tetherargs.angle = Angle()
				tracer = ClientStaticObject.Create(tetherargs)
			end
		end
		totalpoints = math.floor(ray.distance / numpoints)
		if totalpoints == 0 then totalpoints = 1 end
		camangle = Camera:GetAngle()
		dowork = true
		timer = Timer()
		local closestpoint = totalpoints
		local closestdistance = math.huge
		local cpos = Camera:GetPosition()
		for i = 1, totalpoints do
			local pos = math.lerp(cpos, ray.position, i/totalpoints) -- split line into points
			interpolationtable[i] = pos
			local dist = cpos:Distance(pos)
			if dist >= firstpointdistance and dist < closestdistance then -- select point as close to first point distance from player as possible
				closestdistance = dist
				closestpoint = Copy(i)
			end
		end
		point = Copy(closestpoint)
		absolutemaximum = interpolationtable[totalpoints] + (Camera:GetAngle() * Vector3.Forward * 1.5) -- move past surface
		if dofollow == false then
			tracer:SetPosition(interpolationtable[point] - (Camera:GetAngle() * Vector3.Up) + (Camera:GetAngle() * Vector3.Left)) -- adjust offset
			tracer:SetAngle(camangle)
			event = Events:Subscribe("PreTick", grap, grap.NonEntityTick)
		else
			killticks = 0
			event34 = Events:Subscribe("PreTick", grap, grap.EntityTick)
		end
	end
end

function cGrapple:NonEntityTick()
	if LocalPlayer:GetBaseState() ~= 208 and timer then
		if timer:GetSeconds() > 2.0 then
			dowork = false
			for k,v in pairs(interpolationtable) do interpolationtable[k] = nil end
			timer = nil
			if IsValid(tracer) then
				tracer:Remove()
				tracer = nil
				targetentity = nil
			end
			Events:Unsubscribe(event)
		end
	end	
	if dowork == true then
		if IsValid(tracer) then
			if not timer then return end
			if timer:GetSeconds() < .75 then return end -- fire delay
			local campos = Camera:GetPosition()
			local nextpoint = point + 1
			if nextpoint == totalpoints + 1 then
				tracer:SetPosition(absolutemaximum - (Camera:GetAngle() * Vector3.Up) + (Camera:GetAngle() * Vector3.Left))
				tracer:SetAngle(camangle)
				dowork = false
				return
			end
			if campos:Distance(interpolationtable[nextpoint]) <= pointswitchdistance then -- configure switch point distance here
				point = point + 1
				tracer:SetPosition(interpolationtable[point] - (Camera:GetAngle() * Vector3.Up) + (Camera:GetAngle() * Vector3.Left))
				tracer:SetAngle(camangle)
			end
		end
		ppos = Camera:GetPosition()
		local tracepos = tracer:GetPosition()
		local terrainheight = Physics:GetTerrainHeight(ppos)
		if math.abs(ppos.y - terrainheight) < 1.0 then
		tracepos.y = tracepos.y + 1.0
		tracer:SetPosition(tracepos)
	end
	end
end

function cGrapple:EntityTick()
	local plystate = LocalPlayer:GetBaseState()
	if plystate ~= 208 and timer and dotether == false then
		if timer:GetSeconds() > 2.0 then
			if IsValid(tracer) then tracer:Remove() end
			dowork = false
			for k,v in pairs(interpolationtable) do interpolationtable[k] = nil end
			timer = nil
			tracer = nil
			targetentity = nil
			Events:Unsubscribe(event34)
			return
		end
	elseif dotether == true and plystate ~= 208 and plystate ~= 212 and plystate ~= 210 and timer then
		killticks = killticks + 1
		if timer:GetSeconds() > 2.0 and killticks > 150 then
			LocalPlayer:SetBaseState(6)
			killticks = 0
			Chat:Print("Kill Tick", Color(0, 255, 0))
			if IsValid(tracer) then tracer:Remove() end
			dowork = false
			for k,v in pairs(interpolationtable) do interpolationtable[k] = nil end
			timer = nil
			tracer = nil
			targetentity = nil
			Events:Unsubscribe(event34)
			return
		end
	end
	if not IsValid(targetentity) or not IsValid(tracer) then
		tracer = nil
		targetentity = nil
		return
	end
	for k,v in pairs(interpolationtable) do interpolationtable[k] = nil end
	local startpoint = Camera:GetPosition()
	local endpoint = targetentity:GetPosition()
	local linelength = startpoint:Distance(endpoint)
	if linelength < takeoverdistance and dotether == false then
		tracer:Remove()
		LocalPlayer:SetBaseState(6)
		if targetentity:GetHealth() > .01 then
			Network:Send("MountVehicle", {veh = targetentity})
		end
		tracer = nil
		targetentity = nil
		Events:Unsubscribe(event34)
		return
	elseif linelength > 500 then
		LocalPlayer:SetBaseState(6)
		tracer:Remove()
		tracer = nil
		targetentity = nil
		Events:Unsubscribe(event34)
		return
	end
	local tpoints = math.floor(linelength / numpoints)
	if tpoints == 0 then tpoints = 1 end
	local cangle = Camera:GetAngle()
	local closestpoint = tpoints
	local closestdistance = math.huge
	for i = 1, tpoints do
		local pos = math.lerp(startpoint, endpoint, i/tpoints) -- split line into points
		interpolationtable[i] = pos
		local dist = startpoint:Distance(pos)
		if dist >= firstpointdistance and dist < closestdistance then
			closestdistance = dist
			closestpoint = Copy(i)
		end
	end
	local selectpoint = Copy(closestpoint)
	local pointdistend = interpolationtable[selectpoint]:Distance(endpoint)
	if pointdistend < 10 and dotether == false then
		tracer:SetPosition(interpolationtable[selectpoint] + (Camera:GetAngle() * Vector3.Forward * 17.5) + (Camera:GetAngle() * Vector3.Up * 1.25))
	elseif pointdistend >= 10 and dotether == false then
		tracer:SetPosition(interpolationtable[selectpoint] + (Vector3.Down * 0.5))
	elseif dotether == true and linelength < 7.5 then
		if targetentity:InVehicle() == true then
			tracer:Remove()
			tracer = nil
			targetentity = nil
			Events:Unsubscribe(event34)
			return
		end
		local bonepos = targetentity:GetBonePosition("ragdoll_Head")
		bonepos.y = bonepos.y + .19
		tracer:SetPosition(bonepos)
	elseif dotether == true and linelength >= 7.5 then
		if plystate ~= 208 then -- if not connection
			tracer:SetPosition(startpoint + (cangle * (Vector3.Forward * 15 + Vector3.Down * .25 + Vector3.Left * .125)))
		else
			tracer:SetPosition(interpolationtable[selectpoint] + (Vector3.Up * 1.25))
		end
	end
	ppos = Camera:GetPosition()
	local tracepos = tracer:GetPosition()
	local terrainheight = Physics:GetTerrainHeight(ppos)
	if math.abs(ppos.y - terrainheight) < 1.0 then
		tracepos.y = tracepos.y + 1
		tracer:SetPosition(tracepos)
	end
	if dotether == true and linelength < 7.5 then
		tracer:SetAngle(Angle(0, 0, 0))
	else
		tracer:SetAngle(cangle)
	end
end

function cGrapple:OnUnload()
	if IsValid(tracer) then tracer:Remove() end
end

grap = cGrapple() -- class set-up only used for organization
function CheckForSuperGrapple()
	if LocalPlayer:GetValue("Equipped_Grapple") == "Super Grapple" and not inputSub then
		inputSub = Events:Subscribe("LocalPlayerInput", grap, grap.InputManager)
	elseif inputSub and LocalPlayer:GetValue("Equipped_Grapple") ~= "Super Grapple" then
		Events:Unsubscribe(inputSub)
		inputSub = nil
	end
end
Events:Subscribe("SecondTick", CheckForSuperGrapple)
Events:Subscribe("ModuleUnload", grap, grap.OnUnload)--]]