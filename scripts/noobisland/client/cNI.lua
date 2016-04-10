class 'NI'
function NI:__init()
	collideTimer = Timer()
	--Events:Subscribe("KeyUp", self, self.Place)
	self.renderSub = Events:Subscribe("GameRender", self, self.GameRender)
	Events:Subscribe("SecondTick", self, self.MakePortal)
	Events:Subscribe("ModuleUnload", self, self.Unload)
	Events:Subscribe("ShapeTriggerEnter", self, self.STEnter)
	Events:Subscribe("NoobTooFarAway", self, self.TpBackToSpawn)
	--Network:Subscribe("NI_Tips", self, self.GetTips)
end
function NI:TpBackToSpawn()
	Network:Send("Im_A_Noob")
end
function NI:STEnter(args)
	if args.trigger == trigger then
		portalFX2 = ClientEffect.Create(AssetLocation.Game,{
			position = args.entity:GetPosition(),
			angle = Angle(),
			effect_id = 137})
		if args.entity == LocalPlayer and LocalPlayer:GetValue("Noob") then
			if tonumber(LocalPlayer:GetValue("Level")) >= 2 then
				Network:Send("NI_LeaveNoobIsland")
			else
				Chat:Print("You must be at least level 2 to leave Newbie Island!", Color.Red)
			end
		end
	end
end
function NI:Unload()
	if IsValid(portalFX) then portalFX:Remove() portalFX = nil end
	if IsValid(portalFX2) then portalFX2:Remove() portalFX2 = nil end
end
function NI:MakePortal()
	if self.renderSub and not LocalPlayer:GetValue("Noob") then
		Events:Unsubscribe(self.renderSub)
		self.renderSub = nil
	elseif not self.renderSub and LocalPlayer:GetValue("Noob") then
		self.renderSub = Events:Subscribe("GameRender", self, self.GameRender)
	end
	if LocalPlayer:GetValue("Level") and tonumber(LocalPlayer:GetValue("Level")) < 10 and not portalFX then
		portalFX = ClientEffect.Create(AssetLocation.Game, {
			position = Vector3(-12709.050781, 215.518539, 15114.027344),
			angle = Angle(),
			effect_id = 262})
		portalFX2 = ClientEffect.Create(AssetLocation.Game,{
			position = Vector3(-12709.050781, 214.518539, 15114.027344),
			angle = Angle(),
			effect_id = 430})
			--137 for teleport, 262, 364 checkpont, 430 heli, 
		trigger = ShapeTrigger.Create({
			position = Vector3(-12709.050781, 213.518539, 15114.027344),
			angle = Angle(0, 0, 0),
			components = {
				{
					type = TriggerType.Sphere,
					size = Vector3(3, 4, 3),
					position = Vector3(0, 0, 0),
				}
			},
			trigger_player = true, -- Do not trigger on players
			trigger_player_in_vehicle = false, -- Trigger on players in vehicles
			trigger_vehicle = false, -- Do not trigger on vehicles
			trigger_npc = false, -- Do not trigger on NPC (ClientActor),
		})
	end
end
function NI:GameRender()
	for _, args in pairs(tips) do
		local text = args.text
		local pos = args.pos + Vector3(0,1,0)
		local size = args.size * 50
		local t = Transform3()
		t:Translate(pos):Rotate(args.angle * Angle(math.pi,0,math.pi))
		Render:SetTransform(t)
		Render:DrawText(Vector3(), text, args.color, size, 0.001)
	end
end
function NI:GetTips(args)
	tips = args
end
function NI:Place(args)
	if args.key == string.byte('R') then
		local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, 50)
		Network:Send("ncmake", ray)
	end
end
NI = NI()