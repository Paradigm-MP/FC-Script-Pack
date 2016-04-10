class 'FreeBuild2'
function FreeBuild2:__init()
	lights = {}
	lightobjs = {}
	pickUpTimer = Timer()
	useTimer = Timer()
	destroyTimer = Timer()
	sitTimer = Timer()
	Events:Subscribe("SecondTick", self, self.CheckForLights)
	Events:Subscribe("Render", self, self.CheckForCSO)
	Events:Subscribe("ModuleUnload", self, self.Unload)
	Events:Subscribe("LC_ShootClaimObject", self, self.ShootObject)
	Events:Subscribe("LC_SetObjectHealth", self, self.SetObjectHealth)
	Events:Subscribe("KeyUp", self, self.WaypointHome)
	Network:Subscribe("LC_ClaimObjectDestroy", self, self.ClaimObjectDestroy)
end
function FreeBuild2:WaypointHome(args)
	if args.key == VirtualKey.F9 then
		if LocalPlayer:GetValue("HomePosition") then
			Waypoint:SetPosition(LocalPlayer:GetValue("HomePosition"))
		else
			Chat:Print("You do not have a home set!", Color.Red)
		end
	end
end
function FreeBuild2:CheckForLights()
	for obj in Client:GetStaticObjects() do
		if vlights[tostring(obj:GetValue("model"))] and not lights[obj:GetId()] then
			local lightArgs = vlights[tostring(obj:GetValue("model"))]
			lightArgs.position = obj:GetPosition() + Vector3(0,lightArgs.adj,0)
			local light = ClientLight.Create(lightArgs)
			lights[obj:GetId()] = light
			lightobjs[obj:GetId()] = obj
		end
	end
	for id, obj in pairs(lightobjs) do
		if not IsValid(obj) then
			if IsValid(lights[id]) then
				lights[id]:Remove()
			end
			lights[id] = nil
			lightobjs[id] = nil
		end
	end
end
function FreeBuild2:ClaimObjectDestroy(args)
	local id = expID[args.name]
	ClientEffect.Play(AssetLocation.Game, {
		position = args.pos,
		angle = args.angle,
		effect_id = id})
end
function FreeBuild2:ShootObject(args)
	local obj = args.target
	if not IsValid(obj) then return end
	args.id = obj:GetId()
	args.target = nil
	Network:Send("LC_HitClaimObject", args)
end

function FreeBuild2:SetObjectHealth(args) -- receives objects
	Network:Send("LC_HealObject", args)
end

function FreeBuild2:CheckForCSO()
	if sitTimer:GetSeconds() < 0.5 and self.sitting then
		LocalPlayer:SetBaseState(AnimationState.SIdlePassengerVehicle)
	end
	if not IsValid(self.sitting) and self.sitting then
		LocalPlayer:SetBaseState(AnimationState.SEvade)
		self.sitting = nil
	end
	local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, 10)
	if ray.entity and ray.entity.__type == "StaticObject" then
		local obj = ray.entity
		if IsValid(obj) and obj:GetValue("IsClaimOBJ") then
			self:RenderCSOInformation(obj)
		end
	end
end
function FreeBuild2:RenderObjectHealthBar(name, health)
	if not name or not health then return end
	local maxhp = HPamts[name]
	if not maxhp then return end
	local percent = health / maxhp
	local size = Vector2(Render.Size.x / 10, Render.Size.y / 30)
	local size2 = Vector2(Render.Size.x / 10, Render.Size.y / 40)
	local size3 = Vector2(Render.Size.x / 11, Render.Size.y / 150)
	local rendersize = Render:GetTextSize(name, size.x / 10)
	local textsize = size.x / tonumber(string.len(name)) * 1.55
	if textsize > Render.Size.x / 96 then textsize = Render.Size.x / 96 end
	local p1 = (Render.Size / 2) - (size / 2) - Vector2(0, Render.Size.y / 10)
	local p2 = (Render.Size / 2) - (size / 2) - Vector2(- Render.Size.x / 235, Render.Size.y / 13)
	local textpos = p1 + (size2 / 2) - (Render:GetTextSize(name, textsize) / 2)
	Render:FillArea(p1, size, Color(0,0,0, 180))
	Render:FillArea(p2, size3, Color(170,170,170,100))
	size3.x = size3.x * percent
	Render:FillArea(p2	, size3, Color(0,0,205))
	Render:DrawText(textpos, name, Color(200,200,200), textsize)
	
	Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.61), Vector2(Render.Size.x / 2.222, Render.Size.y / 2.395), Color(170,170,170,130))
	Render:DrawLine(Vector2(Render.Size.x / 1.8195, Render.Size.y / 2.61), Vector2(Render.Size.x / 1.8195, Render.Size.y / 2.395), Color(170,170,170,130))
	
	Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.609), Vector2(Render.Size.x / 1.8185, Render.Size.y / 2.609), Color(170,170,170,130))
	Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.395), Vector2(Render.Size.x / 1.8185, Render.Size.y / 2.395), Color(170,170,170,130))
	
end
function FreeBuild2:SitInChair(obj)
	if not IsValid(obj) then return end
	if not self.sitting then
		self.sitting = obj
		Network:Send("SitInChair", obj)
		sitTimer:Restart()
	else
		Network:Send("GetUpFromChair", self.sitting)
		self.sitting = nil
		sitTimer:Restart()
	end
end
function FreeBuild2:RenderCSOInformation(obj)
	local health = tonumber(obj:GetValue("Health"))
	local owner = tostring(obj:GetValue("SteamID"))
	local iname = tostring(obj:GetValue("model"))
	local aimtarget = LocalPlayer:GetAimTarget()
	self:RenderObjectHealthBar(iname, health)
	if iname == "Crafting Table" 
	or (iname == "Chair" and (not obj:GetValue("Occupied") or obj == self.sitting)) then
		local Rsize = Vector2(Render.Size.x / 10, Render.Size.y / 50)
		local p1 = (Render.Size / 2) - (Rsize / 2) - Vector2(0, Render.Size.y / 14.7)
		local p3 = (Render.Size / 2) - (Rsize / 2) - Vector2(0, Render.Size.y / 15.1)
		local size2 = Vector2(Render.Size.x / 10, Render.Size.y / 40)
		local txt = "Press 'E' to use"
		local txtsize = Rsize.x / tonumber(string.len(txt)) * 1.25
		local textpos = p1 + (size2 / 2) - (Render:GetTextSize(txt, txtsize) / 2)
		local normcolor	= Color(200,200,200)
	
		Render:FillArea(p3, Rsize, Color(0,0,0, 180))
	
		Render:DrawText(textpos, txt, normcolor, txtsize)
		
		Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.247), Vector2(Render.Size.x / 2.222, Render.Size.y / 2.364), Color(170,170,170,130))
		Render:DrawLine(Vector2(Render.Size.x / 1.8195, Render.Size.y / 2.247), Vector2(Render.Size.x / 1.8195, Render.Size.y / 2.364), Color(170,170,170,130))
		
		Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.247), Vector2(Render.Size.x / 1.8185, Render.Size.y / 2.247), Color(170,170,170,130))
		Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.364), Vector2(Render.Size.x / 1.8185, Render.Size.y / 2.364), Color(170,170,170,130))

		if Key:IsDown(string.byte('E')) and useTimer:GetSeconds() > 1 and iname == "Chair" then
			self:SitInChair(obj)
			useTimer:Restart()
		end
	end
	
	if owner == tostring(LocalPlayer:GetSteamId()) or LocalPlayer:GetValue("NT_TagName") == "[Admin]" then
		if iname ~= nil then
		
			local Rsize = Vector2(Render.Size.x / 10, Render.Size.y / 50)
			local p1 = (Render.Size / 2) - (Rsize / 2) - Vector2(0, Render.Size.y / 7.4)
			local p3 = (Render.Size / 2) - (Rsize / 2) - Vector2(0, Render.Size.y / 7.5)
			local size2 = Vector2(Render.Size.x / 10, Render.Size.y / 40)
			local txt = "Press 'M' to pick up"
			local txtsize = Rsize.x / tonumber(string.len(txt)) * 1.55
			local textpos = p1 + (size2 / 2) - (Render:GetTextSize(txt, txtsize) / 2)
			local normcolor	= Color(200,200,200)
			local admincolor = Color(255,0,0,150)
			
			Render:FillArea(p3, Rsize, Color(0,0,0, 180))
			
			if owner == tostring(LocalPlayer:GetSteamId()) then
				Render:DrawText(textpos, txt, normcolor, txtsize)
			else 
				Render:DrawText(textpos, txt, admincolor, txtsize)
			end
			
			Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.812), Vector2(Render.Size.x / 2.222, Render.Size.y / 2.645), Color(170,170,170,130))
			Render:DrawLine(Vector2(Render.Size.x / 1.8195, Render.Size.y / 2.812), Vector2(Render.Size.x / 1.8195, Render.Size.y / 2.645), Color(170,170,170,130))
	
			Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.812), Vector2(Render.Size.x / 1.8185, Render.Size.y / 2.811), Color(170,170,170,130))
			Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.645), Vector2(Render.Size.x / 1.8185, Render.Size.y / 2.645), Color(170,170,170,130))
			
			
			local str = "Press M to pick up "..iname
			local size = (Render.Size.x / 128) * 2
			local textsize = Render:GetTextSize(str, size)
			local pos = Vector2(Render.Size.x - textsize.x, textsize.y * 4)
			local normcolor	= Color(255,255,0,150)
			local admincolor = Color(255,0,0,150)
			
			if Key:IsDown(string.byte('M')) and pickUpTimer:GetSeconds() > 1 then
				if tonumber(obj:GetValue("Health")) == HPamts[iname] then
					Network:Send("LC_PickUpObject", obj:GetId())
				else
					Chat:Print("This object has been damaged! Press M again quickly to destroy it.", Color.Red)
					destroyTimer:Restart()
				end
				pickUpTimer:Restart()
			elseif Key:IsDown(string.byte('M')) and destroyTimer:GetSeconds() < 0.5 and destroyTimer:GetSeconds() > 0.1 then
				if tonumber(obj:GetValue("Health")) ~= HPamts[iname] then
					local args = {}
					args.damage = 9999
					args.id = obj:GetId()
					Network:Send("LC_HitClaimObject", args)
				end
			end
			if iname == "Bed" then
				if owner == tostring(LocalPlayer:GetSteamId()) then
					local Rsize = Vector2(Render.Size.x / 10, Render.Size.y / 50)
					local p1 = (Render.Size / 2) - (Rsize / 2) - Vector2(0, Render.Size.y / 14.7)
					local p3 = (Render.Size / 2) - (Rsize / 2) - Vector2(0, Render.Size.y / 15.1)
					local size2 = Vector2(Render.Size.x / 10, Render.Size.y / 40)
					local txt = "Press 'E' to set as home"
					local txtsize = Rsize.x / tonumber(string.len(txt)) * 1.90
					local textpos = p1 + (size2 / 2) - (Render:GetTextSize(txt, txtsize) / 2)
					local normcolor	= Color(200,200,200)
			
					Render:FillArea(p3, Rsize, Color(0,0,0, 180))
				
					Render:DrawText(textpos, txt, normcolor, txtsize)
			
					Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.247), Vector2(Render.Size.x / 2.222, Render.Size.y / 2.364), Color(170,170,170,130))
					Render:DrawLine(Vector2(Render.Size.x / 1.8195, Render.Size.y / 2.247), Vector2(Render.Size.x / 1.8195, Render.Size.y / 2.364), Color(170,170,170,130))
		
					Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.247), Vector2(Render.Size.x / 1.8185, Render.Size.y / 2.247), Color(170,170,170,130))
					Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.364), Vector2(Render.Size.x / 1.8185, Render.Size.y / 2.364), Color(170,170,170,130))

					if Key:IsDown(string.byte('E')) and useTimer:GetSeconds() > 1 then
						Network:Send("LC_SetSpawn", obj:GetId())
						useTimer:Restart()
					end
				end
			end
		end
	end
	
	local AccessType = tostring(obj:GetValue("AccessType"))
	local steamidid = tostring(obj:GetValue("SteamIDid"))
	if AccessType == "Anyone" 
	or (AccessType == "Friends" and LocalPlayer:GetValue("Friends"):find(steamidid))
	or owner == tostring(LocalPlayer:GetSteamId())
	or LocalPlayer:GetValue("NT_TagName") == "[Admin]"	then
		if iname == "Door" or iname == "Reinforced Door" or iname == "Garage Door" then
			local Rsize = Vector2(Render.Size.x / 10, Render.Size.y / 50)
			local p1 = (Render.Size / 2) - (Rsize / 2) - Vector2(0, Render.Size.y / 14.7)
			local p3 = (Render.Size / 2) - (Rsize / 2) - Vector2(0, Render.Size.y / 15.1)
			local size2 = Vector2(Render.Size.x / 10, Render.Size.y / 40)
			local txt = "Press 'E' to use"
			local txtsize = Rsize.x / tonumber(string.len(txt)) * 1.25
			local textpos = p1 + (size2 / 2) - (Render:GetTextSize(txt, txtsize) / 2)
			local normcolor	= Color(200,200,200)
			local admincolor = Color(255,0,0,150)
			
			Render:FillArea(p3, Rsize, Color(0,0,0, 180))
			
			if owner == tostring(LocalPlayer:GetSteamId()) or AccessType == "Anyone" or (AccessType == "Friends" and LocalPlayer:GetValue("Friends"):find(steamidid)) then
				Render:DrawText(textpos, txt, normcolor, txtsize)
			else 
				Render:DrawText(textpos, txt, admincolor, txtsize)
			end
			
			Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.247), Vector2(Render.Size.x / 2.222, Render.Size.y / 2.364), Color(170,170,170,130))
			Render:DrawLine(Vector2(Render.Size.x / 1.8195, Render.Size.y / 2.247), Vector2(Render.Size.x / 1.8195, Render.Size.y / 2.364), Color(170,170,170,130))
		
			Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.247), Vector2(Render.Size.x / 1.8185, Render.Size.y / 2.247), Color(170,170,170,130))
			Render:DrawLine(Vector2(Render.Size.x / 2.222, Render.Size.y / 2.364), Vector2(Render.Size.x / 1.8185, Render.Size.y / 2.364), Color(170,170,170,130))

			if Key:IsDown(string.byte('E')) and useTimer:GetSeconds() > 0.5 then
				if iname == "Garage Door" then
					Network:Send("LC_UseGarageDoor", obj:GetId())
				else
					Network:Send("LC_UseDoor", obj:GetId())
				end
				useTimer:Restart()
				local sound = ClientSound.Create(AssetLocation.Game, {
					bank_id = 6,
					sound_id = 4,
					position = LocalPlayer:GetPosition(),
					angle = Angle()
					})
				sound:SetParameter(0,0.75)
				sound:SetParameter(1,0)
				sound:SetParameter(2,-180)
			end
			if owner == tostring(LocalPlayer:GetSteamId()) then
				local txt = "Door access:"
				local width = Render:GetTextWidth(txt, 15)
				Render:FillArea(Vector2(Render.Width - 120, 50), Vector2(100, 100), Color(0,0,0, 180))
				
				Render:FillArea(Vector2(Render.Width - 120, 50), Vector2(1, 100), Color(170,170,170, 180))
				Render:FillArea(Vector2(Render.Width - 120, 50), Vector2(100, 1), Color(170,170,170, 180))
				
				Render:FillArea(Vector2(Render.Width - 20, 50), Vector2(1, 100), Color(170,170,170, 180))
				Render:FillArea(Vector2(Render.Width - 120, 150), Vector2(100, 1), Color(170,170,170, 180))
				
				Render:DrawText(Vector2(Render.Width - width - 26, 57), txt, Color(150,150,150), 15)
				
				if tostring(obj:GetValue("AccessType")) == "Only Me" then
					local txt2 = "Only Me"
					local width2 = Render:GetTextWidth(txt2, 18)
					Render:DrawText(Vector2(Render.Width - width2 - 38, 84), txt2, Color(200,200,200), 18)
				end
				
				if tostring(obj:GetValue("AccessType")) == "Friends" then
					local txt2 = "Friends"
					local width2 = Render:GetTextWidth(txt2, 18)
					Render:DrawText(Vector2(Render.Width - width2 - 39, 84), txt2, Color(200,200,200), 18)
				end
				
				if tostring(obj:GetValue("AccessType")) == "Anyone" then
					local txt2 = "Anyone"
					local width2 = Render:GetTextWidth(txt2, 18)
					Render:DrawText(Vector2(Render.Width - width2 - 40, 84), txt2, Color(200,200,200), 18)
				end
				
				local txt3 = "Press 'C'"
				local width3 = Render:GetTextWidth(txt3, 14)
				Render:DrawText(Vector2(Render.Width - width3 - 43, 115), txt3, Color(150,150,150), 14)
				
				local txt4 = "to change"
				local width4 = Render:GetTextWidth(txt4, 15)
				Render:DrawText(Vector2(Render.Width - width3 - 53, 130), txt4, Color(150,150,150), 15)
				
				if Key:IsDown(string.byte('C')) and useTimer:GetSeconds() > 0.5 then
					Network:Send("LC_ChangeDoorAccessType", obj:GetId())
					useTimer:Restart()
				end
			end
		end
	end
end

function FreeBuild2:Unload()
	for id, light in pairs(lights) do
		if IsValid(light) then light:Remove() end 
	end
end
FreeBuild2 = FreeBuild2()