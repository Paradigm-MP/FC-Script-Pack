class 'PortalGun'
function PortalGun:__init()
	players = {}
	portals = {}
	portaltypes = {}
	triggerids = {}
	csos = {}
	portalDelay = 8
	timer = Timer()
	fireResetTimer = Timer()
	fireTimer = Timer()
	delayTimer = Timer()
	triggerTimer = Timer()
	portaltimers = {}
	blue = Color(0,119,255)
	orange = Color(255,89,0)
	Events:Subscribe("SecondTick", self, self.GetPlayers)
	Events:Subscribe("WorldNetworkObjectCreate", self, self.WNOCreate)
	Events:Subscribe("WorldNetworkObjectDestroy", self, self.WNODestroy)
	Events:Subscribe("ShapeTriggerEnter", self, self.STEnter)
	--Events:Subscribe("ShapeTriggerExit", self, self.STExit)
	Events:Subscribe("ModuleUnload", self, self.Unload)
end

function PortalGun:STEnter(args)
	if not portals[triggerids[args.trigger:GetId()]] then return end
	if args.entity:GetValue("CanHit") == false then return end
	if tostring(args.entity.__type) == "Player" or (tostring(args.entity.__type) == "Vehicle" and args.entity:GetDriver()) then
		ClientEffect.Play(AssetLocation.Game, {position = args.trigger:GetPosition(), angle = Angle(0,0,0), effect_id = 135})
		if tostring(args.entity.__type) == "Vehicle" then
			args.entity:SetValue("Teleporting", nil)
		end
	end
	if tostring(args.entity.__type) == "LocalPlayer" and args.entity == LocalPlayer then
		if velocity then
			local velo = args.trigger:GetAngle() * velocity
			LocalPlayer:SetLinearVelocity(velo * 2)
			velocity = nil
			ClientEffect.Play(AssetLocation.Game, {position = args.trigger:GetPosition(), angle = Angle(0,0,0), effect_id = 135})
			return
		end
		velocity = Vector3.Forward * LocalPlayer:GetLinearVelocity():Length()
		Network:Send("PortalGun_EnterPlayer", triggerids[args.trigger:GetId()])
		ClientEffect.Play(AssetLocation.Game, {position = args.trigger:GetPosition(), angle = Angle(0,0,0), effect_id = 135})
	elseif tostring(args.entity.__type) == "Vehicle" and args.entity:GetDriver() == LocalPlayer and LocalPlayer:GetValue("CanHit") == true then
		Network:Send("PortalGun_EnterVehicle", {id = triggerids[args.trigger:GetId()], v = args.entity})
	elseif tostring(args.entity.__type) == "Vehicle" and not args.entity:GetDriver() then
		self:SeeIfSendUnoccupiedVehicle(args)
	end
end
function PortalGun:SeeIfSendUnoccupiedVehicle(args)
	local dist = Vector3.Distance(args.entity:GetPosition(), LocalPlayer:GetPosition())
	local player = LocalPlayer
	for p in Client:GetStreamedPlayers() do
		local dist2 = Vector3.Distance(args.entity:GetPosition(), p:GetPosition())
		if dist2 < dist then
			player = p
			dist = dist2
		end
	end
	if player == LocalPlayer and not args.entity:GetValue("Teleporting") then
		Network:Send("PortalGun_EnterVehicle", {id = triggerids[args.trigger:GetId()], v = args.entity})
		args.entity:SetValue("Teleporting", 1)
	end
end
function PortalGun:Unload()
	for id, cso in pairs(csos) do
		if IsValid(cso) then cso:Remove() end
	end
	for id, trigger in pairs(portals) do
		if IsValid(trigger) then trigger:Remove() end
	end
end
function PortalGun:WNOCreate(args)
	if args.object:GetValue("IsPortal") then
		local trigger = ShapeTrigger.Create({
			position = args.object:GetPosition(),
			angle = args.object:GetAngle(),
			components = {
				{
				type = TriggerType.Sphere,
				size = Vector3(1,1,1),
				position = Vector3(0, 0, 0),
				}
			},
			trigger_player = true,
			trigger_player_in_vehicle = false,
			trigger_vehicle = true,
			trigger_npc = false,
			vehicle_type = 0 --trigger on all vehicles
			})
		portals[args.object:GetId()] = trigger
		portaltypes[args.object:GetId()] = args.object:GetValue("Type")
		triggerids[trigger:GetId()] = args.object:GetId()
		portaltimers[trigger:GetId()] = Timer()
	end
end
function PortalGun:WNODestroy(args)
	if args.object:GetValue("IsPortal") then
		if IsValid(portals[args.object:GetId()]) then
			portals[args.object:GetId()]:Remove()
		end
		portals[args.object:GetId()] = nil
		portaltypes[args.object:GetId()] = nil
	end
end
function PortalGun:GameRender()
	if fireResetTimer:GetSeconds() > 0.1 then
		self.fireleft = nil
		self.fireright = nil
	end
	for id, p in pairs(players) do
		if IsValid(p) then
			self:RenderGun(id, p)
		end
	end
	for id, trigger in pairs(portals) do
		if IsValid(trigger) then
			self:RenderPortal(id, trigger)
		end
	end
	if (self.fireright or self.fireleft) and delayTimer:GetSeconds() > 1 and not LocalPlayer:InVehicle() then
		if fireTimer:GetSeconds() >= 1 then
			delayTimer:Restart()
			fireTimer:Restart()
			self:FireGun()
		else
			LocalPlayer:SetUpperBodyState(347)
			self:RenderChargeUp(LocalPlayer)
		end
	else
		if IsValid(chargesound) then chargesound:Remove() chargesound = nil end
		fireTimer:Restart()
	end
end
function PortalGun:FireGun()
	local angle = csos[LocalPlayer:GetId()]:GetAngle()
	--local raypos = csos[LocalPlayer:GetId()]:GetPosition() - (angle * Vector3(0,-0.175,0.4))
	local raypos = Camera:GetPosition()
	if self.fireleft then
		local result = Physics:Raycast(raypos, Camera:GetAngle() * Vector3.Forward, 1, 500)
		result.type = 1
		if result then
			Network:Send("PortalGun_Fire", result)
		end
		local sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 37,
			sound_id = 3,
			position = LocalPlayer:GetPosition(),
			angle = Angle()
		})

		sound:SetParameter(0,0)
		sound:SetParameter(1,0)
		sound:SetParameter(2,0.75)
	elseif self.fireright then
		local result = Physics:Raycast(raypos, Camera:GetAngle() * Vector3.Forward, 1, 500)
		result.type = 2
		if result then
			Network:Send("PortalGun_Fire", result)
		end
		local sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 37,
			sound_id = 3,
			position = LocalPlayer:GetPosition(),
			angle = Angle()
		})

		sound:SetParameter(0,0)
		sound:SetParameter(1,0)
		sound:SetParameter(2,0.75)


	end
end
function PortalGun:RenderChargeUp(p)
	local color = blue
	if self.fireright then color = orange end
	local gunpos = csos[p:GetId()]:GetPosition()
	local gunangle = csos[p:GetId()]:GetAngle()
	local circleAdj = gunangle * Vector3(0.02,-0.15,0.3)
	local basesize = (1 - fireTimer:GetSeconds()) * 5
	local t = Transform3()
	t:Translate(gunpos - circleAdj):Rotate(gunangle)
	Render:SetTransform(t)
	for i = 3, 13 do
		Render:DrawCircle(Vector3(0,0,0), (basesize) / i, color)
	end
	Render:ResetTransform()
	ClientLight.Play({position = gunpos, color = color, multiplier = fireTimer:GetSeconds()*2, timeout = 0.1, radius = 4})

	if not chargesound then
		chargesound = ClientSound.Create(AssetLocation.Game, {
		bank_id = 0,
		sound_id = 8,
		position = LocalPlayer:GetPosition(),
		angle = Angle()
		})

		chargesound:SetParameter(0,0)
		chargesound:SetParameter(1,0)
		chargesound:SetParameter(2,0.75)
		chargesound:SetParameter(3,0)
	end

end
function PortalGun:RenderPortal(id, trigger)
	local scale = portaltimers[trigger:GetId()]:GetSeconds() * 4
	if scale > 1 then scale = 1 end
	local color = blue
	if portaltypes[id] == 2 then color = orange end
	local t = Transform3()
	local basesize = (1 - timer:GetSeconds()) * 10
	t:Translate(trigger:GetPosition()):Rotate(trigger:GetAngle()):Scale(scale)
	Render:SetTransform(t)
	for i = 1, 20 do
		Render:DrawCircle(Vector3(0,0,0), 0.99 + (i/1000), Color(255,255,255,100))
	end
	Render:FillCircle(Vector3(0,0,0), 1, Color(color.r, color.g, color.b, 100))
	Render:ResetTransform()
	if timer:GetSeconds() >= 2 then
		timer:Restart()
	end
end
function PortalGun:Input(args)
	if LocalPlayer:InVehicle() then return end
	if args.input == Action.FireRight then
		self.fireleft = true
		self.fireright = nil
		fireResetTimer:Restart()
	elseif args.input == Action.FireLeft then
		self.fireright = true
		self.fireleft = nil
		fireResetTimer:Restart()
	end
end
function PortalGun:RenderGun(id, p)
	local gunCSO = csos[id]
	if not IsValid(gunCSO) then return end
	gunCSO:SetPosition(p:GetBonePosition("ragdoll_AttachHandRight") + p:GetBoneAngle("ragdoll_AttachHandRight") * Vector3(0.45,0,-0.3))
	gunCSO:SetAngle(p:GetBoneAngle("ragdoll_AttachHandRight") * Angle(0, 1.57, 0) * Angle(3 * math.pi/2,0,0))
end
function PortalGun:GetPlayers()
	for id, cso in pairs(csos) do
		if not IsValid(cso) or not players[id] then
			csos[id] = nil
		end
	end
	for id, p in pairs(players) do
		if not IsValid(p) then 
			if IsValid(csos[id]) then
				csos[id]:Remove() 
			end
			csos[id] = nil 
			players[id] = nil 
		end
	end
	for p in Client:GetStreamedPlayers() do
		if p:GetValue("Equipped_Weapon") == "Portal Gun" and not csos[p:GetId()] and not players[p:GetId()] then
			players[p:GetId()] = p
			csos[p:GetId()] = ClientStaticObject.Create({
				position =p:GetBonePosition("ragdoll_AttachHandRight") + p:GetBoneAngle("ragdoll_AttachHandRight") * Vector3(-0.05,0.02,0.03),
				angle = p:GetBoneAngle("ragdoll_AttachHandRight") * Angle(0, 1.57, 0) * Angle(3 * math.pi/2,0,math.pi),
				model = "general.blz/wea26-a.lod"})
		elseif p:GetValue("Equipped_Weapon") ~= "Portal Gun" and csos[p:GetId()] then
			csos[p:GetId()]:Remove()
		end
	end
	if LocalPlayer:GetValue("Equipped_Weapon") == "Portal Gun" and not csos[LocalPlayer:GetId()] then
		players[LocalPlayer:GetId()] = LocalPlayer
		csos[LocalPlayer:GetId()] = ClientStaticObject.Create({
			position = LocalPlayer:GetBonePosition("ragdoll_AttachHandLeft"),
			angle = LocalPlayer:GetBoneAngle("ragdoll_AttachHandLeft") * Angle(0, 1.57, 0),
			model = "general.blz/wea26-a.lod"})
		inputSub = Events:Subscribe("LocalPlayerInput", self, self.Input)
	elseif LocalPlayer:GetValue("Equipped_Weapon") ~= "Portal Gun" and csos[LocalPlayer:GetId()] then
		players[LocalPlayer:GetId()] = nil
		csos[LocalPlayer:GetId()]:Remove()
		csos[LocalPlayer:GetId()] = nil
		if inputSub then Events:Unsubscribe(inputSub) inputSub = nil end
	end
	if (table.count(csos) > 0 or table.count(portals) > 0) and not renderSub then
		renderSub = Events:Subscribe("GameRender", self, self.GameRender)
	elseif table.count(csos) == 0 and renderSub and table.count(portals) == 0 then
		Events:Unsubscribe(renderSub)
		renderSub = nil
	end
	if timer:GetSeconds() >= 5 then
		timer:Restart()
	end
end
PortalGun = PortalGun()