class 'Wingsuit'

function Wingsuit:__init()
	--##################### DO INVENTORY CHECKS FOR WINGSUIT HERE OR SERVER
	self.players = {}
	self.timers = {
		grapple = Timer()
	}
	
	self.superman = false -- Enables superman physics (disables custom grapple)
	self.grapple = false -- Enables custom grapple while gliding
	self.rolls = false -- Enables barrel rolls
	
	self.default_speed = 20 -- 51 m/s default
	self.default_vertical_speed = -5 -- -7 ms default
	
	self.max_speed = 300 -- 300 m/s default, for superman mode
	self.min_speed = 1 -- 1 m/s default, for superman mode
	
	self.tether_length = 150 -- meters
	self.yaw_gain = 1.5
	self.yaw = 0
	
	self.speed = self.default_speed
	self.vertical_speed = self.default_vertical_speed
	
	self.blacklist = {
		actions = { -- Actions to block while wingsuit is active
			--[Action.LookUp] = true,
			--[Action.LookDown] = true,
			--[Action.LookLeft] = true,
			--[Action.LookRight] = true
		},
		animations = { -- Disallow activation during these base states
			[AnimationState.SDead] = true,
			[AnimationState.SUnfoldParachuteHorizontal] = true,
			[AnimationState.SUnfoldParachuteVertical] = true,
			[AnimationState.SPullOpenParachuteVertical] = true
		}
	}
	
	self.whitelist = { -- Allow instant activation during these base states
		animations = {
			[AnimationState.SSkydive] = true
		}
	}
	
	self.subs = {}
	
	Events:Subscribe("SecondTick", self, self.GetPlayers)
	--Events:Subscribe("ModulesLoad", self, self.AddHelp)
	--Events:Subscribe("ModuleUnload", self, self.RemoveHelp)

end
function CheckWingsuit(p)
	if p:GetValue("SOCIAL_Wingsuit") and string.len(tostring(p:GetValue("SOCIAL_Wingsuit"))) > 3 then
		return tostring(p:GetValue("SOCIAL_Wingsuit"))
	else
		return false
	end
end
function Wingsuit:GetPlayers()
	for id, p in pairs(self.players) do
		if not IsValid(p) then self.players[id] = nil end
	end
	for p in Client:GetStreamedPlayers() do
		if CheckWingsuit(p) and not self.players[p:GetId()] then
			self.players[p:GetId()] = p
		elseif not CheckWingsuit(p) and self.players[p:GetId()] then
			self.players[LocalPlayer:GetId()] = nil
		end
	end
	if CheckWingsuit(LocalPlayer) and not self.players[LocalPlayer:GetId()] then
		self.players[LocalPlayer:GetId()] = LocalPlayer
	elseif not CheckWingsuit(LocalPlayer) and self.players[LocalPlayer:GetId()] then
		self.players[LocalPlayer:GetId()] = nil
	end
	if table.count(self.players) > 0 and not renderSub then
		renderSub = Events:Subscribe("GameRender", self, self.GameRender)
	elseif table.count(self.players) == 0 and renderSub then
		Events:Unsubscribe(renderSub)
		renderSub = nil
	end
	self:Activate()
end
function Wingsuit:GameRender()
	for id, p in pairs(self.players) do
		if IsValid(p) and not CheckSocial(p, "SOCIAL_Disguise") then
			self:DrawWings(p)
		end
	end
end
function CheckSocial(p, str)
	if not IsValid(p) then return false end
	if p:GetValue(str) and string.len(tostring(p:GetValue(str))) > 3 then
		return tostring(p:GetValue(str))
	else
		return false
	end
end
function Wingsuit:Activate()
	if not self.subs.camera and LocalPlayer:GetBaseState() == AnimationState.SSkydive
	and self.players[LocalPlayer:GetId()] then
		self.timers.camera_start = Timer()
		self.speed = self.default_speed
		self.subs.velocity = Events:Subscribe("Render", self, self.SetVelocity)
		--self.subs.camera = Events:Subscribe("CalcView", self, self.Camera)
		--self.subs.glide = Events:Subscribe("InputPoll", self, self.Glide)
		self.subs.input = Events:Subscribe("LocalPlayerInput", self, self.Input)
	elseif self.subs.camera and (LocalPlayer:GetBaseState() ~= AnimationState.SSkydive
	or not self.players[LocalPlayer:GetId()]) then
		self.timers.camera_start = nil
		Events:Unsubscribe(self.subs.velocity)
		self.subs.velocity = nil
		--Events:Unsubscribe(self.subs.camera)
		--self.subs.camera = nil
		--Events:Unsubscribe(self.subs.glide)
		--self.subs.glide = nil
		Events:Unsubscribe(self.subs.input)
		self.subs.input = nil
	end
end

function Wingsuit:DrawWings(p)

	self.dt = math.abs((Game:GetTime() + 12) % 24 - 12) / 12

	local bones = p:GetBones()
	local color = p:GetColor()
	
	local r = math.lerp(0.1 * color.r, color.r, self.dt)
	local g = math.lerp(0.1 * color.g, color.g, self.dt)
	local b = math.lerp(0.1 * color.b, color.b, self.dt)
	
	color = Color(r, g, b)
	
	Render:FillTriangle(
		bones.ragdoll_Neck.position, 
		bones.ragdoll_RightForeArm.position,
		bones.ragdoll_RightUpLeg.position, 
		color
	)
	
	Render:FillTriangle(
		bones.ragdoll_Neck.position, 
		bones.ragdoll_LeftForeArm.position,
		bones.ragdoll_LeftUpLeg.position, 
		color
	)
	
	Render:DrawLine(
		bones.ragdoll_RightForeArm.position,
		bones.ragdoll_RightUpLeg.position,
		Color.Black
	)
	
	Render:DrawLine(
		bones.ragdoll_LeftForeArm.position,
		bones.ragdoll_LeftUpLeg.position,
		Color.Black
	)

end

function Wingsuit:SetVelocity()
	if not CheckWingsuit(LocalPlayer) then return end
	if LocalPlayer:GetValue("CanHit") == false then return end
	local bs = LocalPlayer:GetBaseState()

	if bs ~= AnimationState.SSkydive and bs ~= AnimationState.SSkydiveDash then
		return
	end
	--################################UPDATE THIS WITH NEW WINGSUIT VERSION TO BE BETTER
	local speed = self.speed - math.sin(LocalPlayer:GetAngle().pitch) * 20
		LocalPlayer:SetLinearVelocity(LocalPlayer:GetAngle() * Vector3(0, 0, -speed) 
			+ Vector3(0, self.vertical_speed, 0))
	local ray1 = Physics:Raycast(LocalPlayer:GetPosition(), Vector3.Down, 0, 10)
	local ray2 = Physics:Raycast(LocalPlayer:GetPosition(), LocalPlayer:GetAngle() *Vector3.Forward, 0, 10)
	if ray1.distance < 2 or ray2.distance < 2 then
		LocalPlayer:SetAngle(Angle(0,0,0))
		LocalPlayer:SetBaseState(AnimationState.SEvade)
	end
end

function Wingsuit:Glide()
	
	Input:SetValue(Action.MoveBackward, 1)
	
	if self.yaw < 0 then
		Input:SetValue(Action.MoveLeft, -self.yaw_gain * self.yaw)
	elseif self.yaw > 0 then
		Input:SetValue(Action.MoveRight, self.yaw_gain * self.yaw)
	end

end

function Wingsuit:Input(args)

	if self.blacklist.actions[args.input] then return false end

end

function Wingsuit:Camera()

	if self.timers.camera_start then
	
		local dt = self.timers.camera_start:GetMilliseconds()

		Camera:SetPosition(math.lerp(Camera:GetPosition(), LocalPlayer:GetPosition() + LocalPlayer:GetAngle() * Vector3(0, 2, 7), dt / 1000))
		Camera:SetAngle(Angle.Slerp(Camera:GetAngle(), LocalPlayer:GetAngle(), 0.9 * dt / 1000))

		if dt >= 1000 then 
			self.timers.camera_start = nil 
		end
		
	elseif self.timers.camera_stop then
	
		local dt = self.timers.camera_stop:GetMilliseconds()

		Camera:SetPosition(math.lerp(LocalPlayer:GetPosition() + LocalPlayer:GetAngle() * Vector3(0, 2, 7), Camera:GetPosition(), dt / 1000))
		Camera:SetAngle(Angle.Slerp(Camera:GetAngle(), LocalPlayer:GetAngle(), 0.9 - 0.9 * dt / 1000))

		if dt >= 1000 then 
			self.timers.camera_stop = nil
			Events:Unsubscribe(self.subs.camera)
			self.subs.camera = nil
		end	
		
	else
	
		Camera:SetPosition(LocalPlayer:GetPosition() + LocalPlayer:GetAngle() * Vector3(0, 2, 7))
		Camera:SetAngle(Angle.Slerp(Camera:GetAngle(), LocalPlayer:GetAngle(), 0.9))
		
	end

end

Wingsuit = Wingsuit()
