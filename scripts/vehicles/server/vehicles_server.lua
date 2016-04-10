class "VehiclesServer"
function VehiclesServer:__init()
	--THIS CLASS HANDLES THE MAGIC OF THE MADDNESS
	self.respawnTimer = Timer()
	self.ownedvehs = {}
	self.notownedvehs = {}
	self.respawnTimes = {}
	self.vspawns = {}
	self.defaultResTimes = {}
	self.removeQueue = {}
	self.removeTimer = Timer()
	self.removeTime = 5 --minutes in which a vehicle stays on after a person leaves
	self.vtable = {}
	self.prices = {}
	self.prices["CIV_GROUND"] = 250
	self.prices["CIV_WATER"] = 350
	self.prices["CIV_HELI"] = 400
	self.prices["CIV_PLANE"] = 400
	self.prices["MIL_GROUND"] = 750
	self.prices["MIL_WATER"] = 850
	self.prices["MIL_HELI"] = 1000
	self.prices["MIL_PLANE"] = 900
	self.vspawns["CIV_GROUND"] = {}
	self.vspawns["CIV_WATER"] = {}
	self.vspawns["CIV_HELI"] = {}
	self.vspawns["CIV_PLANE"] = {}
	self.vspawns["MIL_GROUND"] = {}
	self.vspawns["MIL_WATER"] = {}
	self.vspawns["MIL_HELI"] = {}
	self.vspawns["MIL_PLANE"] = {}
	self.defaultResTimes["CIV_GROUND"] = 1.5 * 60
	self.defaultResTimes["CIV_WATER"] = 1.5 * 60
	self.defaultResTimes["CIV_HELI"] = 3 * 60
	self.defaultResTimes["CIV_PLANE"] = 3 * 60
	self.defaultResTimes["MIL_GROUND"] = 6 * 60
	self.defaultResTimes["MIL_WATER"] = 6 * 60
	self.defaultResTimes["MIL_HELI"] = 6 * 60
	self.defaultResTimes["MIL_PLANE"] = 6 * 60
	self.minutes = 0
	self.maxvehicles = 10
	self.maxplacedistance = 30
	self.fillingVehicles = {}
	self.spawnEnabled = true --if vehicles can spawn
	self.spawnEnabled2 = false --if you want super increased spawning for testing
	self:LoadFile("spawns.txt")
	Events:Subscribe("ModuleLoad", self, self.ModuleLoad)
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
	Events:Subscribe("PlayerQuit", self, self.PQuit)
	Events:Subscribe("ClientModuleLoad", self, self.PJoin)
	Events:Subscribe("TimeChange", self, self.Minute)
	Events:Subscribe("SecondTick", self, self.Second)
	--Events:Subscribe("ClientModuleLoad", self, self.SendDataTemp) --VEHICLE PLACING ONLY
	--Events:Subscribe("PlayerEnterVehicle", self, self.EnterVehicle)
	--Events:Subscribe("ClientModuleLoad", self, self.SendVehicleTable)
	Events:Subscribe("PlayerEnterVehicle", self, self.VehicleEnterCheckTraps)
	Network:Subscribe("ClientVehiclePlaceTemp", self, self.ClientVehiclePlaceTempF) --VEHICLE PLACING ONLY
	Network:Subscribe("V_ClientVehicleCreate", self, self.ClientVehicleCreate)
	Network:Subscribe("V_RemoveMyV", self, self.ClientRemoveOwnedVehicle)
	Network:Subscribe("V_ConfirmTransfer", self, self.ClientConfirmTransfer)
	Network:Subscribe("V_BuyVehicle", self, self.ClientPurchaseVehicle)
	Network:Subscribe("V_ClientSetTrap", self, self.ClientSetTrap)
	Network:Subscribe("V_ClientSendGas", self, self.ClientGasUpdate)
	Network:Subscribe("FillVehicleWithGas", self, self.FillVehicleGas)
	Network:Subscribe("FillGasCanMoney", self, self.FillGasCanMoney)
	
end

function VehiclesServer:FillGasCanMoney(args, sender)
	sender:SetMoney(sender:GetMoney() - 75)
end
function VehiclesServer:FillVehicleGas(args, sender)
	if not IsValid(args.v) then return end
	if args.v:GetDriver() ~= sender and not args.can then Chat:Send(sender, "You must be the driver to fill with gas!", Color.Red) return end
	if args.can and #args.v:GetOccupants() > 0 then Chat:Send(sender, "The vehicle must be empty to fill it with gas!", Color.Red) return end
	local pos1 = sender:GetPosition()
	local nearStation = false
	for index, pos in pairs(gasStations) do
		if Vector3.Distance(pos, pos1) < 15 then
			nearStation = true
		end
	end
	if nearStation or args.can then
		local cost = CalculateCost(args.v:GetValue("Gas"))
		if not args.can and (not sender:GetMoney() or sender:GetMoney() - cost < 0) then
			Chat:Send(sender, "You do not have enough money to fill up with gas!", Color.Red)
			return
		end
		local gas = tonumber(args.v:GetValue("Gas")) + args.amt
		if gas > 100 then gas = 100 end
		if gas < 0 then gas = 0 end
		args.v:SetNetworkValue("Gas", gas)
		if not args.can then
			sender:SetMoney(sender:GetMoney() - cost)
			Network:Send(sender, "GasChangeFromServer")
		end
	end
end
function CalculateCost(amt)
	return (100 - tonumber(amt)) * 5
end
function VehiclesServer:ClientGasUpdate(args, sender)
	if IsValid(args.v) and args.gas < 101 then
		args.v:SetNetworkValue("Gas", args.gas)
	end
end
function VehiclesServer:VehicleEnterCheckTraps(args)
	local trap = args.vehicle:GetValue("Trap")
	if not trap then return end
	if CheckOwner(args.vehicle, args.player) then return end
	if not args.is_driver then return end
	if IsValid(owner) then
		local friendString = tostring(args.player:GetValue("Friends"))
		local f1 = args.vehicle:GetValue("OwnerId")
		--local f2 = args.player:GetValue("Faction")
		--if f1 ~= nil and tostring(f1) ~= "nil" and tostring(f1) ~= " " then
		--	if tostring(f1) == tostring(f2) and string.len(tostring(f1)) > 3 then return end
		--end
		if string.find(friendString, tostring(args.vehicle:GetValue("OwnerId"))) then return end
	end
	if trap == 1 then
		args.player:SetPosition(args.player:GetPosition() + Vector3(0,1,0))
		Network:SendNearby(args.player, "TrapVehicleActivate", {pos = args.player:GetPosition(), fxid = 82})
		Network:Send(args.player, "TrapVehicleActivate", {pos = args.player:GetPosition(), fxid = 82, y = true})
		args.vehicle:SetHealth(0)
		args.player:Damage(0.75)
		args.vehicle:SetNetworkValue("Trap", 0)
	elseif trap == 2 then
		args.player:SetPosition(args.player:GetPosition() + Vector3(0,1,0))
		Network:SendNearby(args.player, "TrapVehicleActivate", {pos = args.player:GetPosition(), fxid = 91})
		Network:Send(args.player, "TrapVehicleActivate", {pos = args.player:GetPosition(), fxid = 91, y = true})
		args.player:Damage(0.25)
		args.vehicle:SetNetworkValue("Trap", 0)
	end
end
function CheckOwner(v, p)
	local ownerid = tostring(v:GetValue("OwnerId"))
	local pid = tostring(p:GetSteamId().id)
	if ownerid == pid then
		return true
	else
		return false
	end
end
function VehiclesServer:ClientSetTrap(args, sender)
	--TRAP 1 IS EXPLODE, TRAP 2 IS ELECTRIC
	local v = args.vehicle
	if not IsValid(v) or v.__type ~= "Vehicle" then return end
	local owner = tostring(v:GetValue("OwnerId"))
	if not CheckOwner(v, sender) then return end
	if args.trapnum == 1 or args.trapnum == 2 then
		v:SetNetworkValue("Trap", args.trapnum)
		Chat:Send(sender, "Trap set on vehicle.", Color.Green)
	else
		Chat:Send(sender, "This is not a valid trap!", Color.Red)
		return
	end
end
function VehiclesServer:ClientPurchaseVehicle(args, sender)
	local money = sender:GetMoney()
	local moneyneed = args.vehicle:GetValue("Price")
	local driver = args.vehicle:GetDriver()
	if not moneyneed or not money then return end
	local owner = args.vehicle:GetValue("OwnerId")
	if CheckOwner(args.vehicle, sender) then Chat:Send(sender, "You already own this vehicle!", Color.Red) return end
	if money - moneyneed < 0 then Chat:Send(sender, "You do not have enough credits to purchase this vehicle!", Color.Red) return end
	if args.vehicle:GetValue("Cursed") then return end
	if driver ~= sender then return end
	if owner then
		local friendString = tostring(sender:GetValue("Friends"))
		--local f1 = owner:GetValue("Faction")
		--local f2 = sender:GetValue("Faction")
		--if f1 ~= nil and tostring(f1) ~= "nil" and tostring(f1) ~= " " then
		--	if tostring(f1) == tostring(f2) and string.len(tostring(f1)) > 3 then Chat:Send(sender, "You cannot steal this vehicle from another faction member!", Color.Red) return end
		--end
		if string.find(friendString, tostring(args.vehicle:GetValue("OwnerId"))) then Chat:Send(sender, "You cannot steal this vehicle from your friend!", Color.Red) return end
	end
	if table.count(self.vtable[sender:GetSteamId().id]) >= self.maxvehicles then
		Chat:Send(sender, "You already have the maximum amount of vehicles!", Color.Red)
		return
	end
	sender:SetMoney(money - moneyneed)
	if not CheckOwner(args.vehicle, sender) then
		if not args.vehicle:GetValue("OwnerName") then
			self.notownedvehs[args.vehicle:GetId()] = nil
		end
		self.ownedvehs[args.vehicle:GetId()] = args.vehicle
		self.vtable[sender:GetSteamId().id][args.vehicle:GetId()] = args.vehicle
		args.vehicle:SetNetworkValue("Owner", sender)
		args.vehicle:SetNetworkValue("OwnerName", sender:GetName())
		args.vehicle:SetNetworkValue("OwnerId", tostring(sender:GetSteamId().id))
		self:AddOrUpdateToSQL(sender, args.vehicle)
		self:SendClientNewData(sender)
		if IsValid(owner) then
			self.vtable[owner:GetSteamId().id][args.vehicle:GetId()] = nil
			self:SendClientNewData(owner)
		end
	end
	if self.removeQueue[args.vehicle:GetId()] then
		self.removeQueue[args.vehicle:GetId()] = nil
	end
	local str1 = "Vehicle Claimed! ("..tostring(table.count(self.vtable[sender:GetSteamId().id])).."/10)"
	Chat:Send(sender, str1, Color.Yellow)
	if IsValid(args.vehicle:GetValue("Owner")) then
		local str2 = "Your "..tostring(args.vehicle:GetName()).." has been stolen! ("..tostring(table.count(self.vtable[owner:GetSteamId().id])).."/10)"
		Chat:Send(args.vehicle:GetValue("Owner"), str2, Color.Orange)
	end
end
function VehiclesServer:ClientConfirmTransfer(args, sender)
	--WHEN THE CLIENT TRANSFERS A VEHICLE TO ANOTHER CLIENT
	if args.id == sender:GetId() then Chat:Send(sender, "Not a valid player ID!", Color.Red) return end
	local vehicle = nil
	for id, v in pairs(self.vtable[sender:GetSteamId().id]) do
		if args.v == id then
			vehicle = v
		end
	end
	if not IsValid(vehicle) then Chat:Send(sender, "Invalid vehicle!", Color.Red) return end
	local targetp
	for p in Server:GetPlayers() do
		if p:GetId() == args.id then
			targetp = p
		end
	end
	if table.count(self.vtable[targetp:GetSteamId().id]) >= self.maxvehicles then
		Chat:Send(sender, "The player already has too many vehicles!", Color.Red)
		return
	end
	vehicle:SetNetworkValue("Owner", targetp)
	vehicle:SetNetworkValue("OwnerName", targetp:GetName())
	vehicle:SetNetworkValue("OwnerId", tostring(targetp:GetSteamId().id))
	self.vtable[sender:GetSteamId().id][vehicle:GetId()] = nil
	self.vtable[targetp:GetSteamId().id][vehicle:GetId()] = vehicle
	self:SendClientNewData(sender)
	self:SendClientNewData(targetp)
	--local cmd = SQL:Command("delete from vehicles where vehicleid = ?")
	--cmd:Bind(1, tonumber(vehicle:GetValue("VehicleId")))
	--cmd:Execute()
	self:AddOrUpdateToSQL(targetp, vehicle)
	Chat:Send(sender, "Successfully transferred "..vehicle:GetName().." to "..targetp:GetName(), Color(0,200,0))
	Chat:Send(targetp, sender:GetName().." has transferred "..vehicle:GetName().." to you", Color(0,200,0))
end
function VehiclesServer:SendClientNewData(player)
	--MAGIC VEHICLE GUI UPDATING THING
	if IsValid(player) then
		local args = {}
		args.t1 = self.vtable[player:GetSteamId().id]
		args.t2 = {}
		if args.t1 then
			for id, v in pairs(args.t1) do
				args.t2[id] = v:GetPosition()
			end
		end
		args.t3 = self:GetT3Table(player:GetSteamId().id)
		args.t4 = {}
		if args.t1 then
			for id, v in pairs(args.t1) do
				args.t4[id] = v:GetName()
			end
		end
		Network:Send(player, "V_UpdateVTable", args)
	end
end
function VehiclesServer:ClientRemoveOwnedVehicle(id, sender)
	--WHEN THE CLIENT HITS REMOVE ON THE F7 MENU FOR A VEHICLE
	if not self.vtable[sender:GetSteamId().id] or not self.vtable[sender:GetSteamId().id][id] then return end
	local v = self.vtable[sender:GetSteamId().id][id]
	if IsValid(v) and tostring(v:GetValue("OwnerId")) == tostring(sender:GetSteamId().id) then
		local args = {}
		self.vtable[sender:GetSteamId().id][id] = nil
		self:SendClientNewData(sender)
		local cmd = SQL:Command("delete from vehicles where vehicleid = ?")
		cmd:Bind(1, v:GetValue("VehicleId"))
		cmd:Execute()
		self.ownedvehs[id] = nil
		v:Remove()
	end
end
--function VehiclesServer:SendVehicleTable(args)
	--WHEN THE CLIENT CONNECTS, DO DELAYED SEND OF DATA
	--self.timer[args.player:GetId()] = {}
	--self.timer[args.player:GetId()]["TIME"] = os.time()
	--self.timer[args.player:GetId()]["PLAYER"] = args.player
--end
function VehiclesServer:PQuit(args)
	--WHEN A CLIENT QUITS, REMOVE THEIR TABLE AND VEHICLES AND UPDATE SQL
	if not self.vtable[args.player:GetSteamId().id] then return end
	for id, v in pairs(self.vtable[args.player:GetSteamId().id]) do
		self.removeQueue[id] = {v = v, t = self.removeTimer:GetMinutes(), id = args.player:GetSteamId().id}
		--print(tostring(args.player).." quit, removing vehicle id "..tostring(id))
	end
end
function VehiclesServer:PJoin(args)   
	--WHEN A PLAYER JOINS, FIND ALL THEIR VEHICLES, UPDATE AND SPAWN ETC ETC
	self.vtable[args.player:GetSteamId().id] = {}
	local result, newVehicle = SQL:Query( "select * from vehicles" ):Execute(), nil
    if #result > 0 then
        for i, v in ipairs(result) do
			local spawn = false
			if tostring(args.player:GetSteamId().id) == tostring(v.ownerid) then
				spawn = true
			end
			for id, v1 in pairs(self.ownedvehs) do
				if IsValid(v1) and tostring(v1:GetValue("VehicleId")) == tostring(v.vehicleid) then
					spawn = false
				end
			end
			if spawn == true then
				if tonumber(v.health) > 0.2 then
					--print("[Vehicle] Spawning ID " .. v.vehicleid)
					local psplit = v.pos:split(",")
					local asplit = v.angle:split(",")
					local vector = Vector3(tonumber(psplit[1]),tonumber(psplit[2]),tonumber(psplit[3]))
					local angle = Angle(tonumber(asplit[1]),tonumber(asplit[2]),tonumber(asplit[3]))
					newVehicle = self:SpawnVehicle(vector, angle, tonumber(v.modelid))
					local c1split = v.col1:split(",")
					local c2split = v.col2:split(",")
					local col1 = Color(tonumber(c1split[1]),tonumber(c1split[2]),tonumber(c1split[3]))
					local col2 = Color(tonumber(c2split[1]),tonumber(c2split[2]),tonumber(c2split[3]))
					newVehicle:SetColors(col1,col2)
					newVehicle:SetHealth(tonumber(v.health))
					newVehicle:SetNetworkValue("Price", tonumber(v.price))
					newVehicle:SetNetworkValue("Owner", args.player)
					newVehicle:SetNetworkValue("OwnerName", tostring(args.player:GetName()))
					newVehicle:SetNetworkValue("OwnerId", tostring(args.player:GetSteamId().id))
					newVehicle:SetNetworkValue("VehicleId", tonumber(v.vehicleid))
					newVehicle:SetNetworkValue("Trap", tonumber(v.trap))
					newVehicle:SetNetworkValue("Guard", tonumber(v.guard))
					newVehicle:SetNetworkValue("Storage", tonumber(v.storage))
					newVehicle:SetNetworkValue("Gas", tonumber(v.gas))
					self.ownedvehs[newVehicle:GetId()] = newVehicle
					self.vtable[args.player:GetSteamId().id][newVehicle:GetId()] = newVehicle
					--print("SPAWN V")
				else
					local cmd = SQL:Command("delete from vehicles where vehicleid = ?")
					cmd:Bind(1, v.vehicleid)
					cmd:Execute()
					--print("Deleted owned vehicle with id "..v.vehicleid.." due to death on spawn")
				end
			end
        end
		for id, v in pairs(self.ownedvehs) do
			if IsValid(v) and tostring(v:GetValue("OwnerId")) == tostring(args.player:GetSteamId().id) then
				self.vtable[args.player:GetSteamId().id][v:GetId()] = v
			end
		end
		self:SendClientNewData(args.player)
    end
end
--[[function VehiclesServer:EnterVehicle(args)
	--WHEN A PLAYER ENTERS A VEHICLE DO ALL CHECKS OWNER, PRICE, ETC ETC
	local owner = args.vehicle:GetValue("Owner")
	if args.vehicle:GetValue("Cursed") then return end
	if owner == args.player then return end
	if not args.is_driver then return end
	if IsValid(owner) then
		local friendString = tostring(args.player:GetValue("Friends"))
		local f1 = owner:GetValue("Faction")
		local f2 = args.player:GetValue("Faction")
		if f1 ~= nil and tostring(f1) ~= "nil" and tostring(f1) ~= " " then
			if tostring(f1) == tostring(f2) and string.len(tostring(f1)) > 3 then return end
		end
		if string.find(friendString, tostring(owner:GetSteamId().id)) then return end
	end
	if table.count(self.vtable[args.player:GetSteamId().id]) >= self.maxvehicles then
		args.player:SetPosition(args.player:GetPosition() + Vector3(0,1.5,0))
		Chat:Send(args.player, "You already have the maximum amount of vehicles!", Color.Red)
		return
	end
	local moneyneed = args.vehicle:GetValue("Price")
	local money = args.player:GetMoney()
	if not moneyneed or money - moneyneed < 0 then
		Chat:Send(args.player, "You do not have enough credits to buy this vehicle!", Color.Red)
		args.player:SetPosition(args.player:GetPosition() + Vector3(0,1.5,0))
		return
	end
	args.player:SetMoney(money - moneyneed)
	args.vehicle:SetNetworkValue("Owner", args.player)
	args.vehicle:SetNetworkValue("OwnerName", args.player:GetName())
	args.vehicle:SetNetworkValue("OwnerId", args.player:GetSteamId().id)
	if not owner then
		--claiming an unowned vehicle
		self.notownedvehs[args.vehicle:GetId()] = nil
		self.ownedvehs[args.vehicle:GetId()] = args.vehicle
		self:AddOrUpdateToSQL(args.player, args.vehicle)
		self.vtable[args.player:GetSteamId().id][args.vehicle:GetId()] = args.vehicle
		self:SendClientNewData(args.player)
	elseif owner ~= args.player and owner then
		-- stealing an owned vehicle
		local cmd = SQL:Command("delete from vehicles where vehicleid = ?")
		cmd:Bind(1, tonumber(args.vehicle:GetValue("VehicleId")))
		cmd:Execute()
		self:AddOrUpdateToSQL(args.player, args.vehicle)
		--#################################################
		self.vtable[owner:GetSteamId().id][args.vehicle:GetId()] = nil
		self.vtable[args.player:GetSteamId().id][args.vehicle:GetId()] = args.vehicle
		self:SendClientNewData(owner)
		self:SendClientNewData(args.player)
	end
	local str1 = "Vehicle Claimed! ("..tostring(table.count(self.vtable[args.player:GetSteamId().id])).."/10)"
	Chat:Send(args.player, str1, Color.Yellow)
	if owner then
		local str2 = "Your "..tostring(args.vehicle:GetName()).." has been stolen! ("..tostring(table.count(self.vtable[owner:GetSteamId().id])).."/10)"
		Chat:Send(owner, str2, Color.Orange)
	end
end--]]
function VehiclesServer:GetT3Table(pid)
	--CONVENIENCE FUNCTION BECAUSE IM LAZY
	local tb = {}
	--print(pid)
	--print(self.vtable[pid])
	for id, v in pairs(self.vtable[pid]) do
		tb[id] = v:GetHealth()*100
		--print(v:GetHealth()*100)
	end
	return tb
end
function GenerateVehicleLoot()
	local tbl = {}
	local r1 = math.random(1,50)
	if r1 <= 3 then
		if r1 == 1 then
			table.insert(tbl, "Machine Parts (2)")
		else
			table.insert(tbl, "Machine Parts (1)")
		end
	end
	local item = "Scrap Metal ("..tostring(math.random(1,8))..")"
	table.insert(tbl, item)
	r1 = math.random(1,3)
	if r1 == 3 then
		local item = "Iron ("..tostring(math.random(1,7))..")"
		table.insert(tbl, item)
	end
	r1 = math.random(1,4)
	if r1 == 3 then
		local item = "Steel ("..tostring(math.random(1,6))..")"
		table.insert(tbl, item)
	end
	r1 = math.random(1,6)
	if r1 == 5 then
		local item = "Silver ("..tostring(math.random(1,5))..")"
		table.insert(tbl, item)
	end
	r1 = math.random(1,17)
	if r1 == 7 then
		local item = "Platinum ("..tostring(math.random(1,4))..")"
		table.insert(tbl, item)
	end
	return tbl
end
function VehiclesServer:CheckForDeadVehs()
	--CHECKS FOR DEAD VEHICLES EVERY SECOND AND REMOVES THEM AFTER 7 SECONDS AND TABLES TOO ETC
	for k,v in pairs(self.ownedvehs) do
		if IsValid(v) and v:GetHealth() <= 0.1 then
			if not v:GetValue("DeathT") then
				v:SetValue("DeathT", os.time())
			elseif os.time() - tonumber(v:GetValue("DeathT")) > 12 then
				if v:GetHealth() <= 0.1 then
					--DELETE VEHICLE ON DEATH
					local cmd = SQL:Command("delete from vehicles where vehicleid = ?")
					cmd:Bind(1, v:GetValue("VehicleId"))
					cmd:Execute()
					self.ownedvehs[k] = nil
					local oid = v:GetValue("Owner"):GetSteamId().id
					--print("Deleted owned vehicle with id "..v:GetId().." due to death")
					self.vtable[oid][v:GetId()] = nil
					self:SendClientNewData(v:GetValue("Owner"))
					local args = {}
					args.posn = v:GetPosition() - Vector3(0,1,0)
					args.ang = v:GetAngle()
					args.spawn_table = GenerateVehicleLoot()
					Events:Fire("Vehicles_SpawnDropbox", args)
					v:Remove()
				else
					v:SetValue("DeathT", nil)
				end
			end
		end
	end
	for k,v in pairs(self.notownedvehs) do
		if IsValid(v) and v:GetHealth() <= 0.1 then
			if not v:GetValue("DeathT") then
				v:SetValue("DeathT", os.time())
			elseif os.time() - v:GetValue("DeathT") > 12 then
				if v:GetHealth() <= 0.1 then
					self.notownedvehs[k] = nil
					local args = {}
					args.pos = v:GetPosition() - Vector3(0,1,0)
					args.ang = v:GetAngle()
					args.spawn_table = GenerateVehicleLoot()
					Events:Fire("Vehicles_SpawnDropbox", args)
					--print("Deleted not owned vehicle with id "..v:GetId().." due to death")
					v:Remove()
				else
					v:SetValue("DeathT", nil)
				end
			end
		end
	end
end
function VehiclesServer:Second()
	self:CheckForDeadVehs()
	--for id, tbl in pairs(self.timer) do
	--	if os.time() - tbl["TIME"] > 1 then
	--		self:SendClientNewData(tbl["PLAYER"])
	--		self.timer[id] = nil
	--	end
	--end
end
function VehiclesServer:Minute()
	--FIRES EVERY MINUTE
	if self.spawnEnabled then
		self:RespawnVehicles()
	end
	for id, tbl in pairs(self.removeQueue) do
		if self.removeTimer:GetMinutes() - tbl.t > self.removeTime then
			self:AddOrUpdateToSQL(nil, tbl.v)
			if IsValid(tbl.v) then tbl.v:Remove() end
			self.removeQueue[id] = nil
			self.ownedvehs[id] = nil
			self.vtable[tbl.id] = {}
		end
	end
end
function VehiclesServer:RespawnVehicles()
	local currentTime = self.respawnTimer:GetMinutes()
	for id, tbl in pairs(self.respawnTimes) do
		local v = self.notownedvehs[id]
		local respawnTime = self.defaultResTimes[tbl.Type]
		local vtype = tbl.Type
		local Origpos = tbl.Position
		local Origangle = tbl.Angle
		if not IsValid(v) then
			self.respawnTimes[id] = nil
		end
		if self.respawnTimes[id] and IsValid(v) and Vector3.Distance(v:GetPosition(), Origpos) > 30 then
			if (currentTime - tbl.Time) >= respawnTime then
				--if its been the amount of respawn time and the vehicle moved then respawn it
				v:Remove()
				self.respawnTimes[id] = nil
				self.notownedvehs[id] = nil
				self:SpawnNewVehicle(Origpos, vtype, Origangle)
			end
		else
			--if the vehicle hasnt moved then reset the respawn time
			if self.respawnTimes[id] then
				self.respawnTimes[id].Time = self.respawnTimer:GetMinutes()
			end
		end
	end
end
function VehiclesServer:SpawnNewVehicle(pos, vtype, angle)
	--print("spawn new v")
	local model = vIds[vtype][math.random(#vIds[vtype])]
	if model == 64 then
		if math.random(100) <= 1 then
			model = vIds[vtype][math.random(3)]
		end
	end
	local price = self.prices[vtype] + (math.random(-self.prices[vtype]/4,self.prices[vtype]))
	price = tonumber(string.format("%.0f",tostring(price)))
	local vehicle = self:SpawnVehicle(pos + Vector3(0,1,0), angle, model)
	local col1 = table.randomvalue(colors)
	local col2 = table.randomvalue(colors)
	vehicle:SetColors(col1,col2)
	vehicle:SetNetworkValue("Price", price)
	vehicle:SetNetworkValue("Guard", 0)
	vehicle:SetNetworkValue("Trap", 0)
	if math.random(10) == 1 then
		vehicle:SetNetworkValue("Gas", math.random(10,75))
	else
		vehicle:SetNetworkValue("Gas", math.random(5,40))
	end
	vehicle:SetNetworkValue("Storage", "|")
	self.notownedvehs[vehicle:GetId()] = vehicle
	self.respawnTimes[vehicle:GetId()] = {
		Time = self.respawnTimer:GetMinutes(),
		Position = pos,
		Angle = angle,
		Type = vtype}
end
function VehiclesServer:SpawnAllVehicles()
	--SUPER COMPLEX ALGORITHM TO RANDOMLY SPAWN VEHICLES
	for vtype, _ in pairs(self.vspawns) do
		for pos, angle in pairs(self.vspawns[vtype]) do
			self:SpawnNewVehicle(pos, vtype, angle)
		end
	end
	--Chat:Broadcast(string.format("%.0f total vehicles spawned", table.count(self.notownedvehs)), Color.Yellow)
	--print(string.format("%.0f total vehicles spawned", table.count(self.notownedvehs)))
end
function VehiclesServer:SendDataTemp(args)
	--FOR PLACING VEHICLE SPAWN DATA ONLY
	Network:Send(args.player, "UpdateVehicleTablesTemp", self.vspawns)
end
function VehiclesServer:LoadFile(filename)
    -- Open up the spawns
    print("Opening " .. filename)
    local file = io.open( filename, "r" )

    if file == nil then
        print( "No spawns.txt, aborting loading of spawns" )
        return
    end
    -- Start a timer to measure load time
    local timer = Timer()

    -- For each line, handle appropriately
    for line in file:lines() do
        if line:sub(1,1) == "X" then
            self:ParseVehicle(line)
		end
    end
    
    print( string.format( "Loaded spawns, %.02f seconds", 
                            timer:GetSeconds() ) )

    file:close()
end
function VehiclesServer:ParseVehicle(line)
    -- Remove start, spaces
	line = string.trim(line)
    line = line:gsub( "X", "" )
    line = line:gsub( " ", "" )

    -- Split into tokens
    local tokens        = line:split( "," )
    -- Create vector
    local vector        = Vector3(tonumber(tokens[1]),tonumber(tokens[2]),tonumber(tokens[3]))
    local angle        = Angle(tonumber(tokens[4]),tonumber(tokens[5]),tonumber(tokens[6]))
	self.vspawns[tokens[7]][vector] = angle
	
    -- Save to table
end
function VehiclesServer:RemoveTrap(key, sender)
	--FOR REMOVING VEHICLE SPAWNS ONLY
		local pos1 = sender:GetPosition()
		local maxdist = 4
		for vtype, v in pairs(self.vspawns) do
			for location, angle in pairs(self.vspawns[vtype]) do
				local dist = Vector3.Distance(pos1, location)
				if dist < maxdist then
					local str = "X "..tostring(location)..", "..tostring(angle)..", "..tostring(vtype)
					--print(str)
					local num = 0
					local inf = assert(io.open("spawns.txt", "r"), "Failed to open input file") -- what textfile to read
					local lines = ""
					while(true) do
						local line = inf:read("*line")
						if not line then break end
						--[[if not string.find(line, str, 1) then --if string not found
							num = num + 1
							lines = lines .. line .. "\n"
						end--]]
						if string.trim(tostring(line)) ~= string.trim(tostring(str)) then
							num = num + 1
							lines = lines .. "\n" .. line
						else
							--print("removed")
						end
					end
					inf:close()
					file = io.open("spawns.txt", "w") --what textfile to write
					file:write(lines)
					file:close()
					self.vspawns[vtype][location] = nil
					Chat:Send(sender, "Vehicle spawn type "..tostring(vtype).." removed at "..tostring(location), Color(255,0,0))

					for p in Server:GetPlayers() do
						Network:Send(p, "UpdateVehicleTablesTemp", self.vspawns)
					end
				end
			end
		end
end

function VehiclesServer:ClientVehiclePlaceTempF(key,sender)
	--FOR PLACING VEHICLE SPAWNS ONLY
	if key == 82 then
		self:RemoveTrap(key, sender)
		return
	end
	local vType = "CIV_GROUND"
	if key == 49 then vType = "CIV_GROUND"
	elseif key == 50 then vType = "CIV_WATER"
	elseif key == 51 then vType = "CIV_HELI"
	elseif key == 52 then vType = "CIV_PLANE"
	elseif key == 53 then vType = "MIL_GROUND"
	elseif key == 54 then vType = "MIL_WATER"
	elseif key == 55 then vType = "MIL_HELI"
	elseif key == 56 then vType = "MIL_PLANE"
	else return	end
	Chat:Send(sender, "Set type "..vType.." car spawn at "..tostring(sender:GetPosition()), Color(0,255,255))
	local str = "\nX "..tostring(sender:GetPosition())..", "..tostring(sender:GetAngle())..", "..tostring(vType)
	local file = io.open("spawns.txt", "a")
	file:write(str)
	file:close()
	local tablenum = table.count(self.vspawns[vType])
	self.vspawns[vType][sender:GetPosition()] = sender:GetAngle()
	for p in Server:GetPlayers() do
		Network:Send(p, "UpdateVehicleTablesTemp", self.vspawns)
	end
end
function VehiclesServer:ModuleLoad()
	for v in Server:GetVehicles() do
		v:Remove()
	end
	--CHECK FOR PEOPLE ALREADY ON THE SERVER AND SPAWN THEIR VEHICLES, ETC
	if self.spawnEnabled then
		self:SpawnAllVehicles()
	end
	--[[local players = {}
	for p in Server:GetPlayers() do
		self.vtable[p:GetSteamId().id] = {}
		players[p:GetId()] = p
	end--]]
	-- Uncomment this line below if you want to delete all vehicles
	 --SQL:Execute("DROP TABLE IF EXISTS vehicles")
	SQL:Execute("create table if not exists vehicles (vehicleid INTEGER PRIMARY KEY AUTOINCREMENT, modelid INTEGER, pos VARCHAR, angle VARCHAR, col1 VARCHAR, col2 VARCHAR, ownerid VARCHAR, ownername VARCHAR, health FLOAT, price FLOAT, storage BLOB, trap INTEGER, guard INTEGER, gas FLOAT)" )
  --[[  local result, newVehicle = SQL:Query( "select * from vehicles" ):Execute(), nil
    if #result > 0 then
        for i, v in ipairs(result) do
			local spawn = false
			for id, player in pairs(players) do
				if tonumber(player:GetSteamId().id) == tonumber(v.ownerid) then
					spawn = true
				end
			end
			if spawn == true then
				if tonumber(v.health) > 0 then
					--print("[Vehicle] Spawning ID " .. v.vehicleid)
					local psplit = v.pos:split(",")
					local asplit = v.angle:split(",")
					local vector = Vector3(tonumber(psplit[1]),tonumber(psplit[2]),tonumber(psplit[3]))
					local angle = Angle(tonumber(asplit[1]),tonumber(asplit[2]),tonumber(asplit[3]))
					newVehicle = self:SpawnVehicle(vector, angle, tonumber(v.modelid))
					local c1split = v.col1:split(",")
					local c2split = v.col2:split(",")
					local col1 = Color(tonumber(c1split[1]),tonumber(c1split[2]),tonumber(c1split[3]))
					local col2 = Color(tonumber(c2split[1]),tonumber(c2split[2]),tonumber(c2split[3]))
					newVehicle:SetColors(col1,col2)
					newVehicle:SetHealth(tonumber(v.health))
					newVehicle:SetNetworkValue("Price", tonumber(v.price))
					local names = Player.Match(v.ownername)
					local owner
					for id,p in pairs(names) do
						if tonumber(p:GetSteamId().id) == tonumber(v.ownerid) then
							owner = p
						end
					end
					newVehicle:SetNetworkValue("Owner", owner)
					newVehicle:SetNetworkValue("OwnerName", tostring(v.ownername))
					newVehicle:SetNetworkValue("OwnerId", tostring(v.ownerid))
					newVehicle:SetNetworkValue("VehicleId", tonumber(v.vehicleid))
					newVehicle:SetNetworkValue("Storage", tonumber(v.storage))
					newVehicle:SetNetworkValue("Guard", tonumber(v.guard))
					newVehicle:SetNetworkValue("Trap", tonumber(v.trap))
					newVehicle:SetNetworkValue("Gas", tonumber(v.gas))
					self.ownedvehs[newVehicle:GetId()] = newVehicle
					self.vtable[owner:GetSteamId().id][newVehicle:GetId()] = newVehicle
				else
					local cmd = SQL:Command("delete from vehicles where vehicleid = ?")
					cmd:Bind(1, v.vehicleid)
					cmd:Execute()
					--print("Deleted owned vehicle with id "..v.vehicleid.." due to death on spawn reload")
				end
			end
        end
    end
	for id, p in pairs(players) do
		self:SendClientNewData(player)
	end--]]
end
function VehiclesServer:ModuleUnload()	
	--REMOVE ALL VEHICLES AND UPDATE OWNED VEHICLES TO SQL ETC
	for k,v in pairs(self.ownedvehs) do
		if IsValid(v) then
			--print("REMOVE ",tostring(v)," WITH VEHICLEID ",tostring(v:GetValue("VehicleId")))
			self:AddOrUpdateToSQL(v:GetValue("Owner"), v)
			v:Remove()
		end
	end
	for k,v in pairs(self.notownedvehs) do
		if IsValid(v) then
			--print("REMOVE UNONWED ",tostring(v)," WITH VEHICLEID ",tostring(v:GetValue("VehicleId")))
			v:Remove()
		end
	end
	self.ownedvehs = {}
	self.notownedvehs = {}
end
function VehiclesServer:ClientVehicleCreate(args, sender)
	--WHEN A CLIENT USES A "VEHICLE" ITEM AND MAKES ONE
	if table.count(self.vtable[sender:GetSteamId().id]) >= self.maxvehicles then
		Chat:Send(sender, "Vehicle creation failed; you have too many vehicles already!", Color.Red)
		Network:Send(sender, "V_RefundVehicleCreate", args.id)
		return
	end
	if Vector3.Distance(args.pos, sender:GetPosition()) > self.maxplacedistance then
		Chat:Send(sender, "Vehicle creation failed; too far away!", Color.Red)
		Network:Send(sender, "V_RefundVehicleCreate", args.id)
		return
	end
	local v = self:SpawnVehicle(args.pos + Vector3(0,0.25,0), Angle(math.pi/2,0,0) * args.angle, args.id)
	if not IsValid(v) then Chat:Send(sender, "Vehicle creation failed; invalid vehicle!", Color.Red) return end
	v:SetNetworkValue("Owner", sender)
	v:SetNetworkValue("OwnerId", tostring(sender:GetSteamId().id))
	v:SetNetworkValue("OwnerName", sender:GetName())
	local price = math.random(500,1500)
	for vtype, _ in pairs(vIds) do
		for index, vid in pairs(_) do
			if vid == args.id then
				price = self.prices[vtype] + (math.random(-self.prices[vtype]/4,self.prices[vtype]))
			end
		end
	end
	price = tonumber(string.format("%.0f", tostring(price)))
	v:SetNetworkValue("Price", price)
	v:SetNetworkValue("Storage", "|")
	v:SetNetworkValue("Gas", 100)
	v:SetNetworkValue("Trap", 0)
	v:SetNetworkValue("Guard", 0)
	local col1 = table.randomvalue(colors)
	local col2 = table.randomvalue(colors)
	v:SetColors(col1,col2)
	self.vtable[sender:GetSteamId().id][v:GetId()] = v
	self.ownedvehs[v:GetId()] = v
	self:AddOrUpdateToSQL(sender, v)
	self:SendClientNewData(sender)
end
function VehiclesServer:AddOrUpdateToSQL(player, vehicle)
	--SUPER MAGIC FUNCTION THAT UPDATES A VEHICLE TO SQL
	local cmd
	local update = false
	if not IsValid(vehicle) or vehicle:GetHealth() == 0 then return end
    if vehicle:GetValue("VehicleId") then
		--print("UPDATE")
		update = true
		if IsValid(player) then
			cmd = SQL:Command("update vehicles set modelid=?,pos=?,angle=?,col1=?,col2=?,ownerid=?,ownername=?,health=?,price=?,storage=?,trap=?,guard=?,gas=? where vehicleid = ?")	
			cmd:Bind( 14, tonumber(vehicle:GetValue("VehicleId")))
		else
			cmd = SQL:Command("update vehicles set modelid=?,pos=?,angle=?,col1=?,col2=?,health=?,price=?,storage=?,trap=?,guard=?,gas=? where vehicleid = ?")	
			cmd:Bind( 12, tonumber(vehicle:GetValue("VehicleId")))
		end
	else
		--print("INSERT")
		cmd = SQL:Command("insert into vehicles (modelid,pos,angle,col1,col2,ownerid,ownername,health,price,storage,trap,guard,gas) values (?,?,?,?,?,?,?,?,?,?,?,?,?)")
	end
	local col1, col2 = vehicle:GetColors()
	if IsValid(player) then
		cmd:Bind( 1, vehicle:GetModelId())
		cmd:Bind( 2, tostring(vehicle:GetPosition()))
		cmd:Bind( 3, tostring(vehicle:GetAngle()))
		cmd:Bind( 4, tostring(col1))
		cmd:Bind( 5, tostring(col2))
		cmd:Bind( 6, tostring(player:GetSteamId().id))
		cmd:Bind( 7, player:GetName())
		cmd:Bind( 8, vehicle:GetHealth())
		cmd:Bind( 9, vehicle:GetValue("Price"))
		if vehicle:GetValue("Storage") then
			cmd:Bind( 10, vehicle:GetValue("Storage"))
		else
			cmd:Bind( 10, "|")
		end
		cmd:Bind( 11, tonumber(vehicle:GetValue("Trap")))
		cmd:Bind( 12, tonumber(vehicle:GetValue("Guard")))
		if vehicle:GetValue("Gas") then
			cmd:Bind( 13, tonumber(vehicle:GetValue("Gas")))
		else
			cmd:Bind( 13, 1)
		end
		if update then
			cmd:Bind(14, tonumber(vehicle:GetValue("VehicleId")))
		end
	else
		cmd:Bind( 1, vehicle:GetModelId())
		cmd:Bind( 2, tostring(vehicle:GetPosition()))
		cmd:Bind( 3, tostring(vehicle:GetAngle()))
		cmd:Bind( 4, tostring(col1))
		cmd:Bind( 5, tostring(col2))
		cmd:Bind( 6, vehicle:GetHealth())
		cmd:Bind( 7, vehicle:GetValue("Price"))
		if vehicle:GetValue("Storage") then
			cmd:Bind( 8, vehicle:GetValue("Storage"))
		else
			cmd:Bind( 8, "|")
		end
		cmd:Bind( 9, tonumber(vehicle:GetValue("Trap")))
		cmd:Bind( 10, tonumber(vehicle:GetValue("Guard")))
		if vehicle:GetValue("Gas") then
			cmd:Bind( 11, tonumber(vehicle:GetValue("Gas")))
		else
			cmd:Bind( 11, 1)
		end
		if update then
			cmd:Bind(12, tonumber(vehicle:GetValue("VehicleId")))
		end
	end
	cmd:Execute()
	--print("SQL updated for vehicleid "..tostring(vehicle:GetValue("VehicleId")))
	
	cmd = SQL:Query("SELECT last_insert_rowid() as insert_id FROM vehicles")
	local result = cmd:Execute()
	if not vehicle:GetValue("VehicleId") and #result > 0 then
		vehicle:SetValue("VehicleId", tonumber(result[1].insert_id))
		--print("SET VEHICLE ID")
	end
end
function VehiclesServer:SpawnVehicle(pos, angle, model)
	--SPAWNS A VEHICLE LEL
	local veh, vehSpawnPos = {}, xyz
	veh.model_id = model
	veh.position = pos
	veh.angle = angle
	veh.enabled = true
	return Vehicle.Create(veh)
end

VehiclesServer = VehiclesServer()