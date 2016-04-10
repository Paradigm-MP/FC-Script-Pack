class 'vTraps'
function vTraps:__init()
	Events:Subscribe("SecondTick", self, self.LookForCars)
	Events:Subscribe("UseVehicleTrapItem", self, self.SetTrapOnCar)
	Network:Subscribe("TrapVehicleActivate", self, self.CarTrapActivate)
end
function vTraps:LookForCars()
	local num = 0
	for v in Client:GetVehicles() do
		num = num + 1
	end
	if num > 0 and not renderSub then
		renderSub = Events:Subscribe("Render", self, self.Render)
	elseif num == 0 and renderSub then
		Events:Unsubscribe(renderSub)
		renderSub = nil
	end
end
function GetCarTrapFromNumber(num)
	if num == 1 then return "Car Trap (Bomb)" end
	if num == 2 then return "Car Trap (Electric)" end
end
function vTraps:Render()
	local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, 5)
	if ray.entity and ray.entity.__type == "Vehicle" and tonumber(ray.entity:GetValue("Trap")) ~= 0 then
		--print(ray.entity:GetValue("OwnerId"),LocalPlayer:GetSteamId().id)
		if tostring(ray.entity:GetValue("OwnerId")) == tostring(LocalPlayer:GetSteamId().id) then
			--print("gog")
			local str = tostring(ray.entity).." has a "..
				GetCarTrapFromNumber(ray.entity:GetValue("Trap")).." equipped"
			local size = (Render.Size.x / 128) * 2
			local textsize = Render:GetTextSize(str, size)
			local pos = Vector2(Render.Size.x - textsize.x, textsize.y * 4)
			Render:DrawText(pos, str, Color(255,255,0,150), size)
		end
	end
end
function vTraps:CarTrapActivate(args)
	local fxargs = {}
	fxargs.position = args.pos
	fxargs.angle = Angle(0,0,0)
	fxargs.effect_id = args.fxid
	ClientEffect.Create(AssetLocation.Game, fxargs)
	if args.y then
		LocalPlayer:SetBaseState(34)
	end
end
function vTraps:SetTrapOnCar(item)
	--TRAP 1 IS EXPLODE, TRAP 2 IS ELECTRIC
	local trapset = 1
	if item == "Car Trap (Bomb)" then
		trapset = 1
	elseif item == "Car Trap (Electric)" then
		trapset = 2
	else Chat:Print("Not a valid car trap!", Color.Red) return end
	local result = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, 5)
	local v = result.entity
	if not v or v.__type ~= "Vehicle" then return end
	local owner = v:GetValue("Owner")
	if not owner or owner ~= LocalPlayer then Chat:Print("You can only set a trap on a car you own!", Color.Red) return end
	local trap = v:GetValue("Trap")
	Events:Fire("DeleteFromInventory", {sub_item = item, sub_amount = 1})
	if trap == 1 or trap == 2 then
		local itemadd = "Car Trap (Bomb)"
		if trap == 2 then itemadd = "Car Trap (Electric)" end
		Events:Fire("AddToInventory", {add_item = itemadd, add_amount = 1})
	end
	Network:Send("V_ClientSetTrap", {vehicle = v, trapnum = trapset})
end
vTraps = vTraps()