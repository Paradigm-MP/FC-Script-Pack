class 'TradeZone'

function TradeZone:__init()
	sendTimer = Timer()
	trade_zones = {}
	trade_zones[1] = Vector3(-9098.20, 585.9965, 4187.05)
	trade_zones[2] = Vector3(-7502.546, 206.96, -4128.777)
	trade_zones[3] = Vector3(1087.676, 202.54, 1125.976)
	trade_zones[4] = Vector3(10813.279, 202.77, -8506.759)
	trade_zones[5] = Vector3(7247.078, 822.935, -1166.325)
	trade_zones[6] = Vector3(-4927.674, 214.876, 3050.660)
	trade_zones[7] = Vector3(-14709, 202, 14957) --noob island
	
	--
	tz_radius = 100
	max_circles = 25
	--
	t = Crypt34("alkjd4a")
	f = Crypt34("498dyh8")
	--
	crypt_ref = {}
	crypt_ref[t] = true
	crypt_ref[f] = false
	--
	InZone = f
	--
	check_ticks = 0
	self.timer = Timer()
	self.players2 = {}
	self.seconds = 0
	Events:Subscribe("SecondTick", self, self.GetPlayers)
end
function TradeZone:GetPlayers()
	self.seconds = self.seconds + 1
	if self.seconds >= 5 then
		self.seconds = 0
		self.timer:Restart()
	end
	self.players2 = {}
	for p in Client:GetStreamedPlayers() do
		self.players2[p:GetId()] = p
	end
end
function TradeZone:RenderCircleBasedOnTimer(p, i)
	local ppos = p:GetPosition()
	local tAdd = self.timer:GetSeconds() / 2.5
	tAdd = tAdd + ((i-1) * 0.5)
	if tAdd > 2 then
		tAdd = tAdd - 2
	end
	local pos1 = ppos + Vector3(0,tAdd,0)
	local t = Transform3()
	t:Translate(pos1):Rotate(Angle(0,math.pi/2,0))
	Render:SetTransform(t)
	Render:DrawCircle(Vector3(), 0.5, Color(255,234,97,50))
	--Render:DrawCircle(Vector3(), 0.4, Color(0,255,0,50))
	--Render:DrawCircle(Vector3(), 0.3, Color(0,255,0,50))
	--Render:DrawCircle(Vector3(), 0.2, Color(0,255,0,50))
	--Render:DrawCircle(Vector3(), 0.1, Color(0,255,0,50))
	Render:ResetTransform()
end

function TradeZone:RenderTZ()
	--Chat:Print("InZone : " .. tostring(crypt_ref[InZone]), Color(255, 0, 255))
	local color = Color(196, 255, 0, 35)
	local campos = Camera:GetPosition()
	for index, position in pairs(trade_zones) do
		local dist = 1000
		local radius = tz_radius
		local circles = max_circles
		local color = Color(255,234,97,50)
		if index == 7 then
			dist = 7000
			color = Color(0, 255, 100, 95)
			radius = 4250
			circles = 50
		end

		if Vector3.Distance(campos, position) < dist then -- config tradezone render distance here
			--Render:DrawLine(Vector3(position.x, position.y + 1, position.z), Vector3(position.x + tz_radius, position.y + 1, position.z), Color(255, 0, 0))
			--Render:DrawLine(Vector3(position.x, position.y + 1, position.z), Vector3(position.x, position.y + 1, position.z + tz_radius), Color(255, 0, 0))
			--Render:DrawLine(Vector3(position.x, position.y + 1, position.z), Vector3(position.x - tz_radius, position.y + 1, position.z), Color(255, 0, 0))
			--Render:DrawLine(Vector3(position.x, position.y + 1, position.z), Vector3(position.x, position.y + 1, position.z - tz_radius), Color(255, 0, 0))
			--Render:DrawLine(Vector3(position.x, position.y + 1, position.z), Vector3(position.x, position.y + tz_radius, position.z), Color(255, 0, 0))
			--
			for i = 1, circles do
				local transform = Transform3()
				transform:Translate(Vector3(position.x, position.y - 1, position.z) + Vector3(0, (radius * ((circles - i) / circles)), 0))
				transform:Rotate(Angle(0, 0.5 * math.pi, 0))
				Render:SetTransform(transform)
				Render:DrawCircle(Vector3.Zero, radius * (i / circles), color)
				Render:ResetTransform()
			end
			Render:ResetTransform()
		end
	end
	if GetNearestTradeZone() ~= trade_zones[7] then
		for id, p in pairs(self.players2) do
			if IsValid(p) then
				if p:GetValue("CanHit") == false then
					for i=1, 5 do
						self:RenderCircleBasedOnTimer(p, i)
					end
				end
			end
		end
		if LocalPlayer:GetValue("CanHit") == false then
			for i=1, 5 do
				self:RenderCircleBasedOnTimer(LocalPlayer, i)
			end
		end
	end
end

function TradeZone:LocalPlayerInputTZ(args)
	if InZone == t then
		if args.input == Action.FireLeft or args.input == Action.FireRight or args.input == Action.McFire or args.input == Action.FireVehicleWeapon or args.input == Action.VehicleFireLeft or args.input == Action.VehicleFireRight then
			return false
		end
	end
end

function TradeZone:PostTickTZ2()
	check_ticks = check_ticks + 1
	if check_ticks < 30 then return end
	check_ticks = 0
	local plypos = LocalPlayer:GetPosition()
	for index, zonepos in pairs(trade_zones) do
		local dist = Vector3.Distance(plypos, zonepos)
		local radius = tz_radius
		if index == 7 then radius = 4250 end
		if dist <= radius then
			if InZone == f then
				InZone = t
				Network:Send("ChangeCanHit", {can_hit = not crypt_ref[InZone], tz = GetNearestTradeZone()})
			end
			InZone = t
			return
		end
	end
	
	if InZone == t then
		InZone = f
		Network:Send("ChangeCanHit", {can_hit = not crypt_ref[InZone], tz = GetNearestTradeZone()})
	end
end

function TradeZone:IsInZone()
	return crypt_ref[InZone]
end

function TradeZone:PostTickTZ()
	if InZone == t then
		local ang = Angle.FromVectors(GetNearestTradeZone(), LocalPlayer:GetBonePosition("ragdoll_Spine1"))
		if not LocalPlayer:GetValue("Noob") and LocalPlayer:InVehicle() == true then
			local veh = LocalPlayer:GetVehicle()
			veh:SetLinearVelocity(ang * (Vector3.Backward * out_speed))
			out_speed = out_speed + .25
		elseif GetNearestTradeZone() == trade_zones[7] and LocalPlayer:GetValue("Level") and (LocalPlayer:GetValue("NT_TagName") ~= "[Admin]" and LocalPlayer:GetValue("NT_TagName") ~= "[Mod]") and
		(tonumber(LocalPlayer:GetValue("Level")) > 9 or not LocalPlayer:GetValue("Noob")) then
			LocalPlayer:SetLinearVelocity(ang * (Vector3.Up * out_speed))
			LocalPlayer:SetLinearVelocity(ang * (Vector3.Backward * out_speed / 5))
			out_speed = out_speed + 2.0
		end
		if out_speed > 100 then out_speed = 100 end
	else
		out_speed = 15
	end
end
function GetNearestTradeZone()
	local closest_dist = 99999
	local plypos = LocalPlayer:GetPosition()
	local closest_tz
	for index, pos in pairs(trade_zones) do
		local dist = Vector3.Distance(plypos, pos)
		if dist < closest_dist then
			closest_tz = pos
			closest_dist = dist
		end
		if index == 7 and dist > 4100 and LocalPlayer:GetValue("Noob") and sendTimer:GetSeconds() > 15 then
			sendTimer:Restart()
			Events:Fire("NoobTooFarAway")
		end
	end
	return closest_tz
end

tradezone = TradeZone()

Events:Subscribe("GameRender", tradezone, tradezone.RenderTZ)
Events:Subscribe("LocalPlayerInput", tradezone, tradezone.LocalPlayerInputTZ)
Events:Subscribe("PostTick", tradezone, tradezone.PostTickTZ2)
Events:Subscribe("PostTick", tradezone, tradezone.PostTickTZ)