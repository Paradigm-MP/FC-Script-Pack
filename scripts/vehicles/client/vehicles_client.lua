class 'cVehicles'
function cVehicles:__init()
	--THIS CLASS HANDLES EVERYTHING BUT GUI ... not really

	--TEMP VSAPWNS FOR PLACING, REMOVE LATER ######################################
	self.vspawns = {}
	self.vspawns["CIV_GROUND"] = {}
	self.vspawns["CIV_WATER"] = {}
	self.vspawns["CIV_HELI"] = {}
	self.vspawns["CIV_PLANE"] = {}
	self.vspawns["MIL_GROUND"] = {}
	self.vspawns["MIL_WATER"] = {}
	self.vspawns["MIL_HELI"] = {}
	self.vspawns["MIL_PLANE"] = {}
	--#############################################################
	warntimer = Timer()
	raycast_timer = Timer()
	self.maxvehicles = 10
	self.nearvs = {}
	self.planes = {}
	self.planes[59] = true
	self.planes[51] = true
	self.planes[81] = true
	self.planes[30] = true
	self.planes[34] = true
	self.planes[85] = true
	self.planes[53] = true
	self.planes[24] = true
	Events:Subscribe("KeyUp", self, self.PlaceVSpawn)
	Events:Subscribe("KeyUp", self, self.BuyVehicle)
	--Events:Subscribe("LocalPlayerChat", self, self.Chat)
	--Events:Subscribe("SecondTick", self, self.UpdateNearVTable)
	Events:Subscribe("Render", self, self.Render)
	Events:Subscribe("LocalPlayerInput", self, self.LPI)
	--Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInputF)
	Network:Subscribe("UpdateVehicleTablesTemp", self, self.UpdateTemp)
end
function cVehicles:LPI(args)
	local v = LocalPlayer:GetVehicle()
	if not IsValid(v) then return end
	local forwardvelocity = math.abs((v:GetAngle() * v:GetLinearVelocity()).z)
	if self.planes[v:GetModelId()] and args.input == Action.PlaneDecTrust and v:GetDriver() == LocalPlayer and forwardvelocity < 5 then
		v:SetLinearVelocity(v:GetLinearVelocity() + v:GetAngle() * Vector3.Backward * 0.25)
	end
end
function AddHelp()
    Events:Fire( "HelpAddItem",
        {
            name = "Vehicles",
            text = 
                "There are a few unoccupied vehicles around the island, and these cost credits "..
                "to obtain.  Looking at a vehicle will tell you its vehicle name, owner, and price. " ..
                "If you enter a vehicle and have enough credits to buy it, the vehicle will become yours. "..
				"You can manage your vehicles using the F7 menu.  If you enter a vehicle owned by a friend "..
				"or faction member, you will not steal the vehicle.  In the F7 menu, you can also waypoint, "..
				"transfer, or remove your vehicles."
       } )
end

function RemoveHelp()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Vehicles"
        } )
end

Events:Subscribe("ModulesLoad", AddHelp)
Events:Subscribe("ModuleUnload", RemoveHelp)
function cVehicles:BuyVehicle(args)
	if args.key == string.byte('B') then
		if not LocalPlayer:InVehicle() then return end
		local v = LocalPlayer:GetVehicle()
		local driver = v:GetDriver()
		local price = v:GetValue("Price")
		local owner = v:GetValue("Owner")
		local money = LocalPlayer:GetMoney()
		if owner == LocalPlayer then return end
		if not IsValid(v) or driver ~= LocalPlayer or not price or not money then return end
		if money - price < 0 then Chat:Print("You do not have enough money to buy this vehicle!", Color.Red) return end
		Network:Send("V_BuyVehicle", {vehicle = v})
	end
end
function cVehicles:UpdateNearVTable()
	--updates a table with vehicles near the client
	for v in Client:GetVehicles() do
		self.nearvs[v:GetId()] = v
	end
	for id, v in pairs(self.nearvs) do
		if not IsValid(v) then self.nearvs[id] = nil end
	end
end
function cVehicles:LocalPlayerInputF(args)
	--if LocalPlayer:InVehicle() then return end
end
function cVehicles:UpdateTemp(args)
	-- for placing v spawns, comes from the server
	self.vspawns = args
end
function cVehicles:DrawTagForVehicle()
	--if you look at a vehicle it draws a tag
	local results = LocalPlayer:GetAimTarget()
	if not results.entity then return end
	local entityType = results.entity.__type
	local dist = Vector3.Distance(results.entity:GetPosition(), LocalPlayer:GetPosition())
	if dist < 10 and entityType == "Vehicle" then
		RenderVTag(results.entity, results.entity:GetPosition())
	end
end
function cVehicles:DrawTagIfVehicleCanBePurchased()
	if not LocalPlayer:InVehicle() then return end
	local v = LocalPlayer:GetVehicle()
	local driver = v:GetDriver()
	local price = v:GetValue("Price")
	local owner = tostring(v:GetValue("OwnerId"))
	local myid = tostring(LocalPlayer:GetSteamId().id)
	local money = LocalPlayer:GetMoney()
	if owner == LocalPlayer then return end
	if not IsValid(v) or driver ~= LocalPlayer or not price or not money then return end
	if owner == myid then return end
	local str = "Press 'B' to purchase "..v:GetName().." for "..tostring(price).." credits"
	if v:GetValue("OwnerId") and owner ~= myid then
		local friendString = tostring(LocalPlayer:GetValue("Friends"))
		if string.find(friendString, tostring(owner)) then return end
		str = "Press 'B' to steal "..v:GetName().." for "..tostring(price).." credits from "..tostring(owner)
	elseif v:GetValue("OwnerName") and owner ~= myid then
		str = "Press 'B' to steal "..v:GetName().." for "..tostring(price).." credits from "..tostring(v:GetValue("OwnerName"))
	end
	local size = Render.Size.x / 80
	local pos = Vector2((Render.Size.x / 2) - (Render:GetTextSize(str, size).x / 2), Render.Size.y - (Render:GetTextSize(str, size).y * 3))
	local color = Color(0,255,153,200)
	Render:DrawText(pos, str, color, size)
end
function cVehicles:Render()
	--draws the placement hud and check if you look at a vehicle
	self:DrawTagForVehicle()
	self:DrawTagIfVehicleCanBePurchased()
	if not LocalPlayer:GetValue("VehicleMode") then
		--Render:DrawText(Vector2(Render.Size.x / 50,Render.Size.y / 1.05), "Type /vmode to go into vehicle placing mode!", Color(255,255,255), 20)
	end
	local numvs = 0
	if LocalPlayer:GetValue("VehicleMode") then
		for vtype, _ in pairs(self.vspawns) do
			for pos, angle in pairs(self.vspawns[vtype]) do
				numvs = numvs + 1
				local pos1 = LocalPlayer:GetPosition()
				local dist = Vector3.Distance(pos1, pos)
				if dist < 500 then
					t = Transform3()
					t:Translate(pos):Rotate(Angle(0,math.pi/2,0))
					Render:SetTransform(t)
					if vtype == "CIV_PLANE" or vtype == "MIL_PLANE" then
						Render:FillCircle(Vector3(0,0,0), 3, Color(0,255,255,50))
					else
						Render:FillCircle(Vector3(0,0,0), 2, Color(0,255,255,50))
					end
					RenderTag(vtype, pos)
					Render:ResetTransform()
				end
			end
		end
		local basepos = Vector2(Render.Size.x / 64, Render.Size.y / 4)
		local adj = Vector2(0,Render.Size.y / 40)
		local color = Color(0,138,176)
		Render:DrawText(basepos, "Press 1 to place a civilian ground vehicle", color, 20)
		Render:DrawText(basepos+adj, "Press 2 to place a civilian water vehicle", color, 20)
		Render:DrawText(basepos+(adj*2), "Press 3 to place a civilian helicopter", color, 20)
		Render:DrawText(basepos+(adj*3), "Press 4 to place a civilian plane", color, 20)
		Render:DrawText(basepos+(adj*4), "Press 5 to place a military ground vehicle", color, 20)
		Render:DrawText(basepos+(adj*5), "Press 6 to place a military water vehicle", color, 20)
		Render:DrawText(basepos+(adj*6), "Press 7 to place a military helicopter", color, 20)
		Render:DrawText(basepos+(adj*7), "Press 8 to place a military plane", color, 20)
		Render:DrawText(basepos+(adj*8), "Press R while in the middle of a circle to remove vehicle spawn", color, 20)
		Render:DrawText(basepos+(adj*9), "Vehicles are placed according to your position and angle", color, 20)
		Render:DrawText(basepos+(adj*10), "So make sure you are facing the right direction before placing", color, 20)
		Render:DrawText(basepos+(adj*11), "Place vehicles sparingly; they are meant to be rare!", color, 20)
		Render:DrawText(basepos+(adj*12), ("Number of vehicle spawns: "..numvs), color, 20)
		Render:DrawText(basepos+(adj*13), "Type /vmode to exit vehicle placing mode", color, 20)

	end
end
function RenderTag(vtype, pos1)
	-- hud for the v spawns on the ground
	local pos = pos1 + Vector3(0,1.5,0)
	Render:ResetTransform()
	t = Transform3()
	t:Translate(pos)
	t:Rotate(Camera:GetAngle() * Angle(math.pi,0,math.pi))
	t:Translate(-Vector3(Render:GetTextWidth(vtype) / 250,0,0))
	Render:SetTransform(t)
	Render:DrawText(Vector3(0,0,0), vtype, Color(255,255,0), 25, 0.005)
	Render:ResetTransform()
end
function RenderVTag(vehicle, pos1)
	--render the vehicle tags
	if not vehicle:GetValue("Price") then return end
	local pos = pos1 + Vector3(0,1.5,0)
	local color = Color(49,212,119)
	if tostring(vehicle:GetValue("OwnerId")) == tostring(LocalPlayer:GetSteamId().id) then --######## IF IT IS OWNED AND THEY CAN USE
		color = Color(81,144,232)
	elseif vehicle:GetValue("OwnerName") then
		color = Color(255,119,46)
	end
	local owner = ""
	if vehicle:GetValue("OwnerName") then
		owner = "Owner: "..tostring(vehicle:GetValue("OwnerName"))
	else
		owner = "Owner: None"
	end
	if vehicle:GetValue("OwnerId") then
		if string.find(tostring(LocalPlayer:GetValue("Friends")), tostring(vehicle:GetValue("OwnerId"))) then
			color = Color(81,144,232)
		end
	end
	Render:ResetTransform()
	local t = Transform3()
	t:Translate(pos)
	t:Rotate(Camera:GetAngle() * Angle(math.pi,0,math.pi))
	t:Translate(-Vector3(Render:GetTextWidth(tostring(vehicle)) / 250,0,0))
	Render:SetTransform(t)
	Render:DrawText(Vector3(0.005,0.005,0.005), tostring(vehicle), Color(0,0,0), 75, 0.002)
	Render:DrawText(Vector3(0,0,0), tostring(vehicle), color, 75, 0.002)
	Render:ResetTransform()
	t = Transform3()
	t:Translate(pos)
	t:Rotate(Camera:GetAngle() * Angle(math.pi,0,math.pi))
	t:Translate(-Vector3(Render:GetTextWidth(tostring(owner)) / 250,0,0))
	t:Translate(Vector3(0,0.15,0))
	Render:SetTransform(t)
	Render:DrawText(Vector3(0.005,0.005,0.005), tostring(owner), Color(0,0,0), 75, 0.002)
	Render:DrawText(Vector3(0,0,0), tostring(owner), color, 75, 0.002)
	if not vehicle:GetValue("Price") then return end
	local price = "Price: "..tostring(vehicle:GetValue("Price"))
	Render:ResetTransform()
	t = Transform3()
	t:Translate(pos)
	t:Rotate(Camera:GetAngle() * Angle(math.pi,0,math.pi))
	t:Translate(-Vector3(Render:GetTextWidth(tostring(price)) / 250,0,0))
	t:Translate(Vector3(0,0.30,0))
	Render:SetTransform(t)
	Render:DrawText(Vector3(0.005,0.005,0.005), tostring(price), Color(0,0,0), 75, 0.002)
	Render:DrawText(Vector3(0,0,0), tostring(price), color, 75, 0.002)
	Render:ResetTransform()
end
function cVehicles:Chat(args)
	--enter vehicle placing mode
	if args.text == "/vmode" then
		if not LocalPlayer:GetValue("VehicleMode") then
			LocalPlayer:SetValue("VehicleMode", 1)
		else
			LocalPlayer:SetValue("VehicleMode", nil)
		end
	end
end
function cVehicles:PlaceVSpawn(args)
	-- place a vehicle spawn
	if not LocalPlayer:GetValue("VehicleMode") then return end
	if args.key > 48 and args.key <= 56 then
		Network:Send("ClientVehiclePlaceTemp", args.key)
	elseif args.key == 82 then
		Network:Send("ClientVehiclePlaceTemp", args.key)
	end
end
cVehicles = cVehicles()