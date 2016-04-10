class 'Mines'

function Mines:__init()
	mines = {}
	model = "km07.submarine.eez/key014_02-globebase.lod"
	local i, j = string.find(model, "-")
	local str1 = string.sub(model, 1, i-1)
	str1 = str1.."_lod1"
	local k, m = string.find(model, ".lod")
	str1 = str1..string.sub(model, j, k-1)
	str1 = str1.."_col.pfx"
	mine_collision = str1
	
	trade_zones = {}
	trade_zones[1] = Vector3(-9098.20, 585.9965, 4187.05)
	trade_zones[2] = Vector3(-7502.546, 206.96, -4128.777)
	trade_zones[3] = Vector3(1087.676, 202.54, 1125.976)
	trade_zones[4] = Vector3(10813.279, 202.77, -8506.759)
	trade_zones[5] = Vector3(7247.078, 822.935, -1166.325)
	trade_zones[6] = Vector3(-4927.674, 214.876, 3050.660)
	trade_zones[6] = Vector3(-4927.674, 214.876, 3050.660)
	trade_zones[7] = Vector3(-14709, 202, 14957) --noob island
end

function Mines:WNOCreate(args)
	if args.object:GetValue("ItemUse_Mine") then
		local id = args.object:GetId()
		local pos = args.object:GetPosition()
		mines[id] =
		{
			mine = ClientStaticObject.Create({
				position	= pos + Vector3(0, .075, 0),
				angle = Angle(0, 0, 0),
				model = "km07.submarine.eez/key014_02-globebase.lod",
				collision = mine_collision
			}),
			trigger = ShapeTrigger.Create({
				position = pos,
				angle = Angle(0, 0, 0),
				components = {
					{
						type = TriggerType.Sphere,
						size = Vector3(3, 3, 3),
						position = Vector3(0, 0, 0),
					}
				},
				trigger_player = true,
				trigger_player_in_vehicle = true,
				trigger_vehicle = true,
			}),
			owner = args.object:GetValue("ItemUse_Mine")
		}
	end
end

function Mines:WNODestroy(args)
	if args.object:GetValue("ItemUse_Mine") then
		local id = args.object:GetId()
		if mines[id] then
			if IsValid(mines[id].mine) then mines[id].mine:Remove() end
			if IsValid(mines[id].trigger) then mines[id].trigger:Remove() end
			mines[id] = nil
		end
	end
end

function Mines:TriggerEnter(args)
	if args.entity.__type ~= "LocalPlayer" then return end
	if LocalPlayer:GetValue("Invincible") then return end
	local steamid = tostring(LocalPlayer:GetSteamId().id)
	local friends = LocalPlayer:GetValue("Friends")
	for id, itable in pairs(mines) do
		if itable.trigger == args.trigger then
			if tostring(itable.owner) ~= steamid and not friends:find(itable.owner) then -- if shot a friend then
				ExplodeMine(os.clock() + 1.3, id, itable.mine)
				--Chat:Print("Exploding Mine", Color(0, 255, 0))
			else
				--Chat:Print("Stepped in my own mine", Color(0, 255, 0))
				--ExplodeMine(os.clock() + 1.75, id, itable.mine)
			end
		end
	end
end

class 'ExplodeMine'
function ExplodeMine:__init(time, id, mine) -- recieves time to explode and id index in mines and mine clientstaticobject
	self.time = time
	self.id = id
	self.timer = Timer()
	self.mine = mine
	self.beep_interval = .25
	self.beep_next = 0
	self.sound = nil
	self.event = Events:Subscribe("PostTick", self, self.PostTick)
end

function ExplodeMine:PostTick()
	local secs = os.clock()
	if self.timer:GetSeconds() > self.beep_next then
		if IsValid(self.sound) then self.sound:Remove() end
		self.sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 35,
			sound_id = 6,
			position = LocalPlayer:GetPosition(),
			angle = Angle()
		})
		self.sound:SetParameter(0,0.75)
		self.sound:SetParameter(1,0)
		self.beep_next = self.beep_next + self.beep_interval
		self.beep_interval = self.beep_interval - (self.beep_interval - .01)
		self.timer:Restart()
	end
	if secs > self.time then
		Network:Send("ExplodeMine", {wno_id = self.id})
		if IsValid(self.mine) then
			local boom = ClientEffect.Create(AssetLocation.Game, {
				position = self.mine:GetPosition(),
				angle = self.mine:GetAngle(),
				effect_id = 252 -- 211
			})
			local dist = Vector3.Distance(LocalPlayer:GetPosition(), self.mine:GetPosition())
			if dist < 10 then
				Network:Send("MineDamagePly", {dmg = ((10 - dist) * 13.5) / 100})
			end
		end
		if IsValid(mines[self.id].mine) then mines[self.id].mine:Remove() end
		if IsValid(mines[self.id].trigger) then mines[self.id].trigger:Remove() end
		if IsValid(self.sound) then self.sound:Remove() end
		mines[self.id] = nil
		self.timer = nil
		Events:Unsubscribe(self.event)
	end
end

function Mines:PlaceMine()
	PlaceMine(5, "Mine")
end

function Mines:ServerExplodeMine(args)
	local boom = ClientEffect.Create(AssetLocation.Game, {
			position = args.position,
			angle = Angle(0, 0, 0),
			effect_id = 252 -- 211
		})
	if mines[args.id] then
		if IsValid(mines[args.id].mine) then mines[args.id].mine:Remove() end
		if IsValid(mines[args.id].trigger) then mines[args.id].trigger:Remove() end
		mines[args.id] = nil
	end
end

function Mines:ModuleUnload()
	for id, itable in pairs(mines) do
		if IsValid(itable.mine) then itable.mine:Remove() end
		if IsValid(itable.trigger) then itable.trigger:Remove() end
		mine[id] = nil
	end
end

mine = Mines()

Events:Subscribe("WorldNetworkObjectCreate", mine, mine.WNOCreate)
Events:Subscribe("WorldNetworkObjectDestroy", mine, mine.WNODestroy)
Events:Subscribe("ShapeTriggerEnter", mine, mine.TriggerEnter)
Events:Subscribe("ModuleUnload", mine, mine.ModuleUnload)
--
Events:Subscribe("PlaceMine", mine, mine.PlaceMine)
--
Network:Subscribe("ServerExplodeMine", mine, mine.ServerExplodeMine)
--
busy_mines = false
class 'PlaceMine'
function PlaceMine:__init(time, item)
	if LocalPlayer:GetState() ~= 4 or LocalPlayer:GetHealth() == 0 or LocalPlayer:GetBaseState() ~= AnimationState.SUprightIdle then return end
	local plypos = LocalPlayer:GetPosition()
	for index, pos in pairs(trade_zones) do
		if Vector3.Distance(plypos, pos) <= 200 then
			Chat:Print("Too close to safezone to place mine", Color(255, 255, 0))
			return
		end
	end
	if Vector3.Distance(plypos, Vector3(-14709.128906, 188.288757, 14957.080078)) < 4250 then
		Chat:Print("Too close to Noob Island to place mine", Color(255, 255, 0))
		return
	end
	self.item = item
	self.time = time -- time in seconds
	self.timer = Timer()
	self.event = Events:Subscribe("Render", self, self.Render)
	self.event2 = Events:Subscribe("LocalPlayerInput", self, self.Input)
	busy_mines = true
	screen_size = Render.Size
end

function PlaceMine:Render()
	if self.timer:GetSeconds() < self.time then
		LocalPlayer:SetBaseState(15)
		if LocalPlayer:GetState() ~= PlayerState.OnFoot then
			self.timer = nil
			busy_mines = false
			Events:Unsubscribe(self.event)
			Events:Unsubscribe(self.event2)
		end
		Render:FillArea(Vector2(0, screen_size.y * .96), Vector2(screen_size.x * ((self.time * 1000 - self.timer:GetMilliseconds()) / (self.time * 1000)), screen_size.y), Color(255, 0, 0, 100))
	else
		self.timer = nil
		busy_mines = false
		Events:Fire("UpdateSharedObjectInventory")
		local inventory_table = SharedObject.GetByName("ClientSharedInventory"):GetValue("INV")
		local count = 0
		for index, lootstring in pairs(inventory_table[reference[self.item]]) do
			if GetLootName(lootstring) == self.item then
				count = count + GetLootAmount(lootstring)
			end
		end
		if count > 0 then
			Events:Fire("DeleteFromInventory", {sub_item = self.item, sub_amount = 1})
			Network:Send("ClientPlaceMine", {pos = LocalPlayer:GetPosition(), ang = LocalPlayer:GetAngle()})
			local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 11,
				sound_id = 2,
				position = LocalPlayer:GetPosition(),
				angle = Angle()
			})
			sound:SetParameter(0,0.75)
		end
		--end
		Events:Unsubscribe(self.event)
	end
end

function PlaceMine:Input(args)
	if not self.timer then return end
	if self.timer:GetSeconds() < self.time then
		if busy_mines == true then
			if args.input == Action.MoveLeft or args.input == Action.MoveRight or args.input == Action.MoveForward or args.input == Action.MoveBackward then
				self.timer = nil
				busy_mines = false
				Events:Unsubscribe(self.event)
				Events:Unsubscribe(self.event2)
			end
		end
	else
		Events:Unsubscribe(self.event2)
	end
end

-- START CONVENIENCE FUNCTIONS --
function GetLootName(lootstring)
	local number = tonumber(string.match(lootstring, '%d+'))
	local item34 = ""
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
	return tonumber(string.match(lootstring, '%d+'))
end

function GetCollision(model)
	model = objects[model]
	local i, j = string.find(model, "-")
	local str1 = string.sub(model, 1, i-1)
	str1 = str1.."_lod1"
	local k, m = string.find(model, ".lod")
	str1 = str1..string.sub(model, j, k-1)
	str1 = str1.."_col.pfx"
	return str1
end

-- END CONVENIENCE FUNCTIONS --
