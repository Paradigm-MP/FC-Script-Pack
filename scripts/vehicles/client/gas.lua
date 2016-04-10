class 'Gas'
function Gas:__init()
	self.gasAmts = {}
	self.gasAmts[1] = 0.0005
	self.gasAmts[2] = 0.00075
	self.gasAmts[3] = 0.00075
	self.prompt = Button.Create()
	self.keyTimer = Timer()
	self.GasPump = Image.Create(AssetLocation.Resource, "GasPump")
	self.prompt:SetSize(Vector2(Render.Size.x / 4.5, Render.Size.y / 20))
	self.prompt:SetPosition((Render.Size / 2) - (self.prompt:GetSize() / 2))
	self.prompt:SetText("Fill Gas? for much monies?")
	self.prompt:SetTextNormalColor(Color(79,255,123))
	self.prompt:SetTextHoveredColor(Color(79,255,123))
	self.prompt:SetTextPressedColor(Color(79,255,123))
	self.prompt:SetTextDisabledColor(Color(79,255,123))
	self.prompt:SetTextSize(Render.Size.x / 75)
	self.prompt:Hide()
	self.prompt:Subscribe("Press", self, self.Press)
	self.prompt:Subscribe("Render", self, self.PromptShowHide)
	Events:Subscribe("LocalPlayerEnterVehicle", self, self.EnterVehicle)
	Events:Subscribe("LocalPlayerExitVehicle", self, self.ExitVehicle)
	Events:Subscribe("UseGasItem", self, self.UseGasItem)
	Events:Subscribe("ResolutionChange", self, self.ResolutionChange)
	Network:Subscribe("GasChangeFromServer", self, self.GasChangeFromServer)
end
function Gas:GasChangeFromServer()
	if IsValid(self.v) then self.gas = Crypt34(self.v:GetValue("Gas")) end
end
function Gas:PromptShowHide()
	if not LocalPlayer:GetValue("Inv_Open") then self.prompt:Hide() end
end
function Gas:Press()
	local money = LocalPlayer:GetMoney()
	if money and money - 75 > 0 then
		Network:Send("FillGasCanMoney")
		self.prompt:Hide()
		Events:Fire("DeleteFromInventory", {sub_item = "Empty Gas Can", sub_amount = 1})
		local item = "Filled Gas Can"
		if CanAddItem(item, 1, reference[item]) then
			Events:Fire("AddToInventory", {add_item = "Filled Gas Can", add_amount = 1})
		else
			local lootstring = tostring(item).." (1)"
			Events:Fire("Crafting_SpawnDropbox", lootstring)
			Chat:Print("Inventory overflow!", Color.Yellow)
		end
	end
end
function Gas:ResolutionChange()
	self.prompt:SetSize(Render.Size / 100)
	self.prompt:SetPosition((Render.Size / 2) - (self.prompt:GetSize() / 2))
	self.prompt:SetTextSize(Render.Size.x / 30)
end
function Gas:UseGasItem(item)
	if item == "Empty Gas Can" then
		if LocalPlayer:InVehicle() then Chat:Print("You cannot fill a gas can while in a vehicle!", Color.Red) return end
		local pos1 = LocalPlayer:GetPosition()
		for index, pos in pairs(gasStations) do
			if Vector3.Distance(pos, pos1) < 15 then
				self.prompt:SetText("Fill Empty Gas Can for 75 credits")
				self.prompt:Show()
			end
		end
	elseif item == "Filled Gas Can" then
		if LocalPlayer:InVehicle() then Chat:Print("You cannot use a gas can while in a vehicle!", Color.Red) return end
		local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, 6)
		if ray.entity and ray.entity.__type == "Vehicle" then
			if tonumber(ray.entity:GetValue("Gas")) < 99.5 then
				Network:Send("FillVehicleWithGas", {v = ray.entity, amt = 25, can = true})
				Events:Fire("DeleteFromInventory", {sub_item = "Filled Gas Can", sub_amount = 1})
				local item = "Empty Gas Can"
				if CanAddItem(item, 1, reference[item]) then
					Events:Fire("AddToInventory", {add_item = "Empty Gas Can", add_amount = 1})
				else
					local lootstring = tostring(item).." (1)"
					Events:Fire("Crafting_SpawnDropbox", lootstring)
					Chat:Print("Inventory overflow!", Color.Yellow)
				end
			else
				Chat:Print("This car has a full tank of gas already!", Color.Red)
			end
		end
	end
end
function CalculateCost(amt)
	return (100 - tonumber(amt)) * 5
end


function Gas:Render()		-- This is a work in progress. The current design is not final and will get an overhaul later on.

	--print(Crypt34(self.gas),Crypt34(self.minusAmt))
	
	if not IsValid(self.v) or not self.gas then return end
	
	local speed 		= 		math.abs((-self.v:GetAngle() * self.v:GetLinearVelocity()).z)
	local gas			= 		tonumber(Crypt34(self.gas))
	local percent 		= 		tonumber(gas) / 100
	local size 			= 		Vector2(self.size.x * percent, self.size.y)
	
	Render:FillArea(Vector2((Render.Width / 2 - 190),(Render.Height - 38)), Vector2((380),38), Color(0,0,0,200))
	Render:FillArea(Vector2((Render.Width / 2 - 205),(Render.Height - 15)), Vector2((15),19), Color(0,0,0,200))
	Render:FillArea(Vector2((Render.Width / 2 + 190),(Render.Height - 15)), Vector2((15),19), Color(0,0,0,200))
	Render:FillTriangle(Vector2((Render.Width / 2 - 205),(Render.Height - 15)), Vector2((Render.Width / 2 - 190),(Render.Height - 15)), Vector2((Render.Width / 2 - 190),Render.Height - 38), Color(0,0,0,200))
	Render:FillTriangle(Vector2((Render.Width / 2 + 190),(Render.Height - 15)), Vector2((Render.Width / 2 + 205),(Render.Height - 15)), Vector2((Render.Width / 2 + 190),Render.Height - 38), Color(0,0,0,200))

	Render:FillArea(self.pos, self.size, Color(50,50,50,150))
	Render:FillArea(self.pos, size, Color(0,0,250,150))
	
	self.GasPump:Draw(Vector2((Render.Width / 2 - 185), (Render.Height - 32)), Vector2(30,26), Vector2(0,0),Vector2(1,1))
	
	if Crypt34(self.nearStation) == "yes" and gas < 99.5 then
	
		local str 		= 		string.format("Press 'Z' to fill %s with a full tank of gas for %.0f credits", tostring(self.v), tostring(CalculateCost(Crypt34(self.gas))))
		local size 		= 		Render.Size.x / 80
		local pos 		= 		Vector2((Render.Size.x / 2) - (Render:GetTextSize(str, size).x / 2), Render.Size.y - (Render:GetTextSize(str, size).y * 4.5))
		local color 	= 		Color(255,136,0,200)
		
		Render:DrawText(pos, str, color, size)
		
		if Key:IsDown(string.byte('Z')) and self.keyTimer:GetSeconds() > 0.25 then
			Network:Send("V_ClientSendGas", {gas = tonumber(Crypt34(self.gas)), v = self.v})
			Network:Send("FillVehicleWithGas", {v = self.v, amt = 100})
			
			self.keyTimer:Restart()
			
		end
		
	end
	
end


function Gas:SecondTick()
	--print(Crypt34(self.gas),Crypt34(self.minusAmt))
	if not IsValid(self.v) then return end
	local speed = math.abs((-self.v:GetAngle() * self.v:GetLinearVelocity()).z)
	self.gas = Crypt34(tonumber(Crypt34(self.gas)) - (speed * tonumber(Crypt34(self.minusAmt))))
	if tonumber(Crypt34(self.gas)) < 0 then self.gas = Crypt34(0) end
	if tonumber(Crypt34(self.gas)) <= 0 and not self.inputSub then
		Network:Send("V_ClientSendGas", {gas = tonumber(Crypt34(self.gas)), v = self.v})
		self.inputSub = Events:Subscribe("InputPoll", self, self.BlockDriving)
	elseif self.inputSub and tonumber(Crypt34(self.gas)) > 0 then
		if self.inputSub then Events:Unsubscribe(self.inputSub) self.inputSub = nil end
	end
end
function Gas:UpdateGasToServer()
	self.nearStation = Crypt34("no")
	self:SecondTick()
	if self.updateTimer:GetSeconds() > 20 then
		Network:Send("V_ClientSendGas", {gas = tonumber(Crypt34(self.gas)), v = self.v})
		self.updateTimer:Restart()
	end
	local pos1 = LocalPlayer:GetPosition()
	for index, pos in pairs(gasStations) do
		if Vector3.Distance(pos, pos1) < 15 then
			self.nearStation = Crypt34("yes")
		end
	end
end
function Gas:FillGas(vehicle)
	if self.v == vehicle then
		gas = Crypt34(vehicle:GetValue("Gas"))
	end
end
function Gas:EnterVehicle(args)
	if args.is_driver then
		self.size = Vector2(320, 12)
		self.pos = Vector2(Render.Size.x / 2 - 140, Render.Size.y - 25 )
		self.v = args.vehicle
		self.minusAmt = Crypt34(self.gasAmts[self.v:GetClass()])
		self.updateTimer = Timer()
		self.gas = Crypt34(args.vehicle:GetValue("Gas"))
		self.renderSub = Events:Subscribe("Render", self, self.Render)
		self.secondTickSub = Events:Subscribe("SecondTick", self, self.UpdateGasToServer)
		self.fillSub = Network:Subscribe("V_FillGas", self, self.FillGas)
	end
end
function Gas:ExitVehicle(args)
	if self.gas then
		Network:Send("V_ClientSendGas", {gas = tonumber(Crypt34(self.gas)), v = self.v})
		if self.secondTickSub then Events:Unsubscribe(self.secondTickSub) self.secondTickSub = nil end
		if self.renderSub then Events:Unsubscribe(self.renderSub) self.renderSub = nil end
		if self.fillSub then Network:Unsubscribe(self.fillSub) self.fillSub = nil end
		self.gas = nil
		self.updateTimer = nil
	end
end
function Gas:BlockDriving(args)
	if Input:GetValue(Action.TurnRight) > 0 then
		Input:SetValue(Action.TurnRight, 0.2)
	elseif Input:GetValue(Action.TurnLeft) > 0 then
		Input:SetValue(Action.TurnLeft, 0.2)
	end
	Input:SetValue(Action.Accelerate, 0)
	Input:SetValue(Action.Handbrake, 0)
	Input:SetValue(Action.BoatBackward, 0)
	Input:SetValue(Action.BoatForward, 0)
	Input:SetValue(Action.HeliBackward, 0)
	Input:SetValue(Action.HeliForward, 0)
	Input:SetValue(Action.HeliDecAltitude, 1)
	Input:SetValue(Action.HeliIncAltitude, 0)
	Input:SetValue(Action.HeliTurnLeft, 0)
	Input:SetValue(Action.HeliTurnRight, 0)
	Input:SetValue(Action.Reverse, 0)
	Input:SetValue(Action.PlaneDecTrust, 1)
	Input:SetValue(Action.PlaneIncTrust, 0)
	Input:SetValue(Action.PlanePitchDown, 0.25)
	Input:SetValue(Action.PlanePitchUp, 0)
	Input:SetValue(Action.PlaneRollLeft, 0)
	Input:SetValue(Action.PlaneRollRight, 0)
	Input:SetValue(Action.PlaneTurnLeft, 0)
	Input:SetValue(Action.PlaneTurnRight, 0)
	Input:SetValue(Action.SoundHornSiren, 0)
	Input:SetValue(Action.VehicleFireLeft, 0)
	Input:SetValue(Action.VehicleFireRight, 0)
end
Gas = Gas()

function GetLootName(lootstring)
	local number = tonumber(string.match(lootstring, '%d+'))
	local item34 = ""
	if number == nil then return nil end
	if number < 10 then
		item34 = string.sub(lootstring, 1, string.len(lootstring) - 4)
	elseif number >= 10 then
		item34 = string.sub(lootstring, 1, string.len(lootstring) - 5)
	elseif number >= 100 then
		item34 = string.sub(lootstring, 1, string.len(lootstring) - 6)
	elseif number >= 1000 then
		item34 = string.sub(lootstring, 1, string.len(lootstring) - 7)
	end
	return item34
end

function GetLootAmount(lootstring)
	local number = tonumber(string.match(lootstring, '%d+'))
	return number
end
function CanAddItem(item, number, category)
	Events:Fire("UpdateSharedObjectInventory")
	local inv = SharedObject.GetByName("ClientSharedInventory"):GetValue("INV")
	if table.count(inv[category]) < LocalPlayer:GetValue("CatMaxes")[category] then return true end
		for index, lootstring in pairs(inv[category]) do
			if GetLootName(lootstring) == item then
				if GetLootAmount(lootstring) + number <= stacklimit[item] then
					return true
				end
			end
		end
	return false
end
