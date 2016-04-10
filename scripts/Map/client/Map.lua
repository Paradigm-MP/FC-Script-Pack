class 'Map'

function Map:__init()

	self.position = nil
	circletime = 0
	oldsize = Render.Height * 0.007
	
	self.openTimer = Timer()
	
	self.MovementBlocks = {
		[Action.LookDown] 			= 	true,
		[Action.LookLeft] 			= 	true,
		[Action.LookRight] 			= 	true,
		[Action.LookUp] 			= 	true,
		[Action.Fire] 				= 	true,
		[Action.FireLeft] 			= 	true,
		[Action.FireRight] 			= 	true,
		[Action.McFire] 			= 	true,
		[Action.VehicleFireLeft] 	= 	true,
		[Action.VehicleFireRight] 	= 	true
	}
	
	self.BlockedMapInputs = {
		[Action.Map]				=	true,
		--[Action.MapScrollDown]		=	true,
		--[Action.MapScrollLeft]		=	true,
		--[Action.MapScrollRight]		=	true,
		--[Action.MapScrollUp]		=	true,
		--[Action.MapZoomIn]			=	true,
		--[Action.MapZoomOut]			=	true,
		[Action.GuiPDA]				=	true
	}
	
	TradeZones = {
		Vector3(-9098.20, 585.9965, 4187.05),
		Vector3(-7502.546, 206.96, -4128.777),
		Vector3(1087.676, 202.54, 1125.976),
		Vector3(10813.279, 202.77, -8506.759),
		Vector3(7247.078, 822.935, -1166.325),
		Vector3(-4927.674, 214.876, 3050.660)
	}
	
	CursedZones = {
		{position = Vector3(-6568, 208, -3442), radius = 225},
		{position = Vector3(-10223, 300, -3065), radius = 1200},
		{position = Vector3(-12604, 300, -4771), radius = 1150},
		{position = Vector3(-15233, 300, -2883), radius = 1150},
		{position = Vector3(-12757, 300, -944), radius = 1350},
		{position = Vector3(-13603, 422, -13746), radius = 1500},
		{position = Vector3(13753, 270, -2373), radius = 1050},
		{position = Vector3(-1573, 358, 990), radius = 1000},
		{position = Vector3(2150, 711, 1397), radius = 425},
		{position = Vector3(13199, 1094, -4928), radius = 400}
	}
	
	self.map 		= 	Image.Create(AssetLocation.Resource, "Map")
	self.waypoint 	= 	Image.Create(AssetLocation.Resource, "Waypoint")
	self.home		= 	Image.Create(AssetLocation.Resource, "Home")
	self.open 		= 	false
	
	Events:Subscribe("Render", self, self.Render )
	Events:Subscribe("KeyUp", self, self.KeyUp )
	Events:Subscribe("MouseUp", self, self.Mouseup)
	Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
	
	InitTimer = Timer()
	CircleTimer = nil
	
end

function Map:Render()
	
	if InitTimer then
		if InitTimer:GetMilliseconds() >= 100 then
			self.position = self:WorldToMap(LocalPlayer:GetPosition())
			InitTimer = nil
		end
	end
	
	if not self.open == true then return end
	
	local pos = Mouse:GetPosition()
	local position = self:MapToWorld(pos)
	local x = tonumber(position.x)
	local y = tonumber(position.z)
	local xpos = string.format("%.0f", x)
	local ypos = string.format("%.0f", y)
	local txtx = "X: " .. xpos
	local txty = "Y: " .. ypos
	local posx = Vector2( 40, 300)
	local posy = Vector2( 40, 320)
	local waypoint, exist = Waypoint:GetPosition()
	
	Render:FillArea(Vector2(0,0), Vector2(Render.Width, Render.Height), Color(0,0,0,220))
	self.map:Draw(Vector2(Render.Width/2 - Render.Height/2, 0), Vector2(Render.Height,Render.Height), Vector2(0,0), Vector2(1,1))
	
	Render:DrawText( posx, txtx, Color(200, 200, 200), 16)
	Render:DrawText( posy, txty, Color(200, 200, 200), 16)
	
	for index, pos in pairs(TradeZones) do
		local position = self:WorldToMap(pos)
		Render:FillCircle(position, Render.Height * 0.008, Color(0,107,222,100))
		Render:DrawCircle(position, Render.Height * 0.008, Color(0,107,222,200))
	end
	
	for index, tbl in pairs(CursedZones) do
		local pos = tbl.position
		local radius = tbl.radius
		local position = self:WorldToMap(pos)
		Render:FillCircle(position, (radius - 600) * (self.map:GetSize().x / 16384), Color(207,2,5,100))
		Render:DrawCircle(position, (radius - 600) * (self.map:GetSize().x / 16384), Color(207,2,5,200))
	end
		
	if exist then
		self.waypoint:SetSize(Vector2(Render.Height * 0.04,Render.Height * 0.04))
		self.waypoint:SetPosition(self:WorldToMap(waypoint) - 0.5 * self.waypoint:GetSize())
		self.waypoint:SetAlpha(0.8)
		self.waypoint:Draw()
	end
	
	if LocalPlayer:GetValue("HomePosition") ~= nil then
		self.home:SetSize(Vector2(Render.Height * 0.04,Render.Height * 0.04))
		self.home:SetPosition(self:WorldToMap(LocalPlayer:GetValue("HomePosition")) - 0.5 * self.home:GetSize())
		self.home:SetAlpha(0.8)
		self.home:Draw()
	end
	
	if CircleTimer or FadeInTimer or FadeOutTimer or DelayTimer then
		
		if CircleTimer:GetMilliseconds() >= circletime + 15 then
			local size = oldsize + Render.Height * 0.001
			oldsize = size
			circletime = CircleTimer:GetMilliseconds()
		end
		
		if FadeInTimer ~= nil then
			BlimpAlpha = math.clamp(0 + (FadeInTimer:GetSeconds() * 2000), 0, 255)
			CircleAlpha = 150
			if BlimpAlpha >= 255 then
				DelayTimer = Timer()
				FadeInTimer = nil
			end
		end
		
		if DelayTimer ~= nil then
			if DelayTimer:GetMilliseconds() >= 100 then
				FadeOutTimer = Timer()
				DelayTimer = nil
			end
		end
		
		if FadeOutTimer ~= nil then
			BlimpAlpha = math.clamp(255 - (FadeOutTimer:GetSeconds() * 96), 0, 255)
			CircleAlpha = math.clamp(150 - (FadeOutTimer:GetSeconds() * 150), 0, 150)
			if BlimpAlpha <= 0 then
				FadeOutTimer = nil
				self.position = self:WorldToMap(LocalPlayer:GetPosition())
				oldsize = 0
				FadeInTimer = Timer()
			end
		end
		
		Render:FillCircle(self.position, oldsize, Color(200,200,200,CircleAlpha))
		Render:FillCircle(self.position, Render.Height * 0.008, Color(240,240,240,BlimpAlpha))
		
	end

end

function Map:KeyUp(args)

	if args.key == string.byte("K") then
	
		if self.open == false then
			self.open = true
			CircleTimer = Timer()
			FadeInTimer = Timer()
			Mouse:SetVisible(true)
			Chat:SetEnabled(false)
		else
			self.open = false
			Mouse:SetVisible(false)
			Chat:SetEnabled(true)
			CircleTimer = nil
			FadeOutTimer = nil
			DelayTimer = nil
			FadeInTimer = nil
			circletime = 0
			oldsize = 0
		end
		
	end
	
end

function Map:Mouseup(args)

	if not self.open then return end
	
	if args.button == 3 then
	
		local waypoint, exist = Waypoint:GetPosition()
		
		if exist then
			Waypoint:Remove()
		else 
			Waypoint:SetPosition(self:MapToWorld(Mouse:GetPosition()))	
		end
	end
	
end

function Map:LocalPlayerInput(args)

	if self.BlockedMapInputs[args.input] then
		
		if self.openTimer:GetSeconds() > 0.25 then
			if self.open == false then
				self.open = true
				CircleTimer = Timer()
				FadeInTimer = Timer()
				Mouse:SetVisible(true)
				Chat:SetEnabled(false)
			else
				self.open = false
				Mouse:SetVisible(false)
				Chat:SetEnabled(true)
				CircleTimer = nil
				FadeOutTimer = nil
				DelayTimer = nil
				FadeInTimer = nil
				circletime = 0
				oldsize = 0
			end
			self.openTimer:Restart()
		end
		return false
		
	end
	
	if not self.open == true then return true end
	if self.MovementBlocks[args.input] then return false end
end

function Map:MapToWorld(position)

	local x = 32768 * (position.x - self.map:GetPosition().x) / Render.Height - 16384
	local z = 32768 * (position.y - self.map:GetPosition().y) / Render.Height - 16384
	
	return Vector3(x, Physics:GetTerrainHeight(Vector2(x, z)), z)

end

function Map:WorldToMap(position)

	local x = Render.Height * (position.x + 16384) / 32768 + self.map:GetPosition().x
	local y = Render.Height * (position.z + 16384) / 32768 + self.map:GetPosition().y
	
	return Vector2(x, y)

end

Map = Map()