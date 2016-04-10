class 'SuperGrapple'
function SuperGrapple:__init()
	self.timer = Timer()
	self.distance = 80
	self.maxdistance = 1000
	self.destroyTimer = Timer()
	Events:Subscribe("SecondTick", self, self.Check)
	Events:Subscribe("ModuleUnload", self, self.Unload)
end
function SuperGrapple:Render()
	if LocalPlayer:InVehicle() then return end
	local velocity = -LocalPlayer:GetAngle() * LocalPlayer:GetLinearVelocity()
	self.velocity = -velocity.z
	if not self.object then
		local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, self.maxdistance)
		if ray.distance < self.maxdistance and ray.distance > 1 then
			self.distance = ray.distance
			self.position = ray.position
			self.normal = ray.normal
		else
			self.distance = 0
		end
	end
	if self.distance > 1 and (self.distance > 80 or (self.velocity > 20 and LocalPlayer:GetBaseState() ~= AnimationState.SSkydive)) then
		local str 		= 		string.format("%i m", tostring(self.distance))
		local size 		= 		Render.Size.x / 100
		local pos 		= 		Vector2((Render.Size.x / 2) - (Render:GetTextSize(str, size).x / 2), Render.Size.y - (Render:GetTextSize(str, size).y * 29.9))
		local color 	= 		Color(0,0,0,255)
		
		Render:DrawText(pos + (Render.Size / 1000), str, color, size)
		Render:DrawText(pos, str, Color.White, size)
		pos = pos + Vector2(0,Render:GetTextSize(str, size).y)
		Render:FillTriangle(pos - (Vector2(0,Render:GetTextSize(str, size).y)/2),
			pos - Vector2(Render.Size.x / 100,0), pos - (Vector2(0,Render:GetTextSize(str, size).y))- Vector2(Render.Size.x / 100,0), Color(0,0,250,200))
		pos = pos + Vector2(Render:GetTextSize(str, size).x,0) - Vector2(0,Render:GetTextSize(str, size).y)
		Render:FillTriangle(pos + (Vector2(0,Render:GetTextSize(str, size).y)/2),
			pos + Vector2(Render.Size.x / 100,0), pos + (Vector2(0,Render:GetTextSize(str, size).y)) + Vector2(Render.Size.x / 100,0), Color(0,0,250,200))
	end
	if self.fire and not self.object and self.distance > 80 then
		local args = {}
		args.collision = "km02.towercomplex.flz/key013_01_lod1-g_col.pfx"
		args.model = ""
		args.position = Camera:GetPosition() + (Camera:GetAngle() * (Vector3.Forward * 25))
		args.angle = Camera:GetAngle()
		self.object = ClientStaticObject.Create(args)
		self.endposition = self.position + (Camera:GetAngle() * (Vector3.Forward * 2))
		self.startposition = args.position
		self.fire = nil
	elseif self.object and self.endposition then
		local dist = Vector3.Distance(LocalPlayer:GetPosition(), self.object:GetPosition())
		if dist < 15 then
			local angle = Angle.FromVectors(Vector3.Up, self.normal) * Angle(0,math.pi/2,0)
			self.object:SetPosition(self.endposition - (angle * (Vector3.Forward * 2)))
			self.object:SetAngle(angle)
			self.endposition = nil
			self.object:Remove()
			self.object = nil
			self.destroyTimer:Restart()
		end
	end
	if self.velocity > 20 and LocalPlayer:GetValue("Equipped_Grapple") ~= "Super Grapple" then
		LocalPlayer:SetBaseState(AnimationState.SSkydive)
	end
end
function SuperGrapple:Unload()
	if self.object then self.object:Remove() end
	if self.fx then self.fx:Remove() end
end
function SuperGrapple:Input(args)
	if args.input == Action.FireGrapple and self.timer:GetSeconds() > 3 then
		self.destroyTimer:Restart()
		if self.object then self.object:Remove() self.object = nil end
		self.fire = true
		self.timer:Restart()
	elseif self.destroyTimer:GetSeconds() > 3 then
		if self.object then self.object:Remove() self.object = nil end
	elseif args.input == Action.GrapplingAction then
		self.grappling = true
	else
		self.fire = false
		self.grappling = false
	end
end
function SuperGrapple:Check()
	if LocalPlayer:GetValue("Equipped_Grapple") == "Super Grapple" 
	and not self.renderSub and not self.inputSub then
		self.renderSub = Events:Subscribe("Render", self, self.Render)
		self.inputSub = Events:Subscribe("LocalPlayerInput", self, self.Input)
	elseif LocalPlayer:GetValue("Equipped_Grapple") ~= "Super Grapple" 
	and self.renderSub and self.inputSub then
		Events:Unsubscribe(self.renderSub)
		self.renderSub = nil
		Events:Unsubscribe(self.inputSub)
		self.inputSub = nil
	end
end
SuperGrapple = SuperGrapple()