class 'Place'
lastplaced = Vector3(0,0,0)
function Place:__init()
	spawns = {}
	---
	tier1 = {}
	tier1.model = "general.blz/go155-a.lod"
	tier1.collision = "general.blz/go155_lod1-a_col.pfx"
	tier1.angle = Angle(0, 0, 0)
	tier2 = {}
	tier2.model = "km03.gamblinghouse.flz/key032_01-f.lod"
	tier2.collision = "km03.gamblinghouse.flz/key032_01_lod1-f_col.pfx"
	tier2.angle = Angle(0, 0, 0)
	tier3 = {}
	tier3.model = "geo.cbb.eez/go152-a.lod"
	tier3.collision = "km05.hotelbuilding01.flz/key030_01_lod1-n_col.pfx"
	tier3.angle = Angle(0, 0, 0)
	tiercredit = {}
	tiercredit.model = "pickup.boost.cash.eez/pu05-a.lod"
	tiercredit.collision = "37x10.flz/go061_lod1-e_col.pfx"
	tiercredit.angle = Angle(0, 0, 0)
	--
	for v in Server:GetStaticObjects() do
		local model = v:GetModel()
		if model == "km03.gamblinghouse.flz/key032_01-f.lod" or model == "geo.cbb.eez/go152-a.lod" or model == "general.blz/go155-a.lod" or model == "pickup.boost.cash.eez/pu05-a.lod" then
			if IsValid(v) then v:Remove() end
		end
	end
	--
	local file = io.open("lootspawns.txt", "r") -- read from lootspawns.txt
	if file ~= nil then -- file might not exist
		local args = {}
		args.world = DefaultWorld
		for line in file:lines() do
			line = line:trim()
			if string.len(line) > 0 then -- filter out empty lines
				--Chat:Broadcast(tostring(line), Color(255, 0, 0))
				--Chat:Broadcast("length of line: " .. tostring(string.len(line)), Color(255, 0, 0))
				line = line:gsub("LootSpawn%(", "")
				line = line:gsub("%)", "")
				line = line:gsub(" ", "")
				line = line:trim()
				local tokens = line:split(",")
				local pos_str = {tokens[3], tokens[4], tokens[5]}
				local ang_str = {tokens[6], tokens[7], tokens[8]}
				local mdl_str = tokens[1]
				local col_str = tokens[2]
				--
				args.position = Vector3(tonumber(pos_str[1]), tonumber(pos_str[2]), tonumber(pos_str[3]))
				args.angle = Angle(tonumber(ang_str[1]), tonumber(ang_str[2]), tonumber(ang_str[3]))
				args.model = tostring(mdl_str)
				args.collision = tostring(col_str)
				local v = StaticObject.Create(args)
				table.insert(spawns, v)
				v:SetStreamDistance(2500) -- configure loot streaming distance here
			end
		end
		file:close()
	end
end
-----
function Place:ChatHandle(args)
	if args.text == "/saveloot" then
		SaveLootToFile()
		Chat:Broadcast("All Loot Saved", Color(255, 0, 0))
		return false
	elseif args.text == "/sky" then
		local pos = args.player:GetPosition()
		pos.y = pos.y + 500
		args.player:SetPosition(pos)
	elseif args.text == "/dupes" then
		local dupecounter = 0
		for _, obj in pairs(spawns) do
			if IsValid(obj) then
				local pos = obj:GetPosition()
				for _, obj2 in pairs(spawns) do
					if IsValid(obj2) then
						if obj2 ~= obj then
							if pos == obj2:GetPosition() then
								--args.player:SetPosition(obj2:GetPosition())
								dupecounter = dupecounter + 1
								obj2:Remove()
							end
						end
					end
				end
			end
		end
		Chat:Broadcast("Number of Duplicates: " .. tostring(dupecounter), Color(0, 255, 0))
	end
end
-----
function Place:SpawnTier1(args, player)
	if player:GetValue("TrapPlacingMode") == 1 then return end
	tier1.position = args.pos
	local t1 = StaticObject.Create(tier1)
	table.insert(spawns, t1)
	local iden = t1:GetId()
	Network:Send(player, "GetLast", {id = iden})
	Events:Fire("NewSelect", {obj = t1, ply = player})
end
-----
function Place:SpawnTier2(args, player)
	if player:GetValue("TrapPlacingMode") == 1 then return end
	tier2.position = args.pos
	local t2 = StaticObject.Create(tier2)
	table.insert(spawns, t2)
	local iden = t2:GetId()
	Network:Send(player, "GetLast", {id = iden})
	Events:Fire("NewSelect", {obj = t2, ply = player})
end
-----
function Place:SpawnTier3(args, player)
	if player:GetValue("TrapPlacingMode") == 1 then return end
	local dist = Vector3.Distance(args.pos, lastplaced)
	print(tostring(player).." placed T3 "..tostring(dist).."m away from the last one at "..tostring(args.pos))
	lastplaced = args.pos
	tier3.position = args.pos
	local t3 = StaticObject.Create(tier3)
	table.insert(spawns, t3)
	local iden = t3:GetId()
	Network:Send(player, "GetLast", {id = iden})
	Events:Fire("NewSelect", {obj = t3, ply = player})
end
-----
function Place:SpawnTierCredit(args, player)
	tiercredit.position = args.pos
	local tc = StaticObject.Create(tiercredit)
	local iden = tc:GetId()
	Network:Send(player, "GetLast", {id = iden})
	Events:Fire("NewSelect", {obj = tc, ply = player})
end
-----
function SaveLootToFile(filename) -- save then reload from that file
	local file = io.open("lootspawns.txt", "w") -- completely re-new lootspawns.txt
	--
	for v in Server:GetStaticObjects() do
		local model = v:GetModel()
		if model == "km03.gamblinghouse.flz/key032_01-f.lod" or model == "geo.cbb.eez/go152-a.lod" or model == "general.blz/go155-a.lod" or model == "pickup.boost.cash.eez/pu05-a.lod" then
			local model = string.format(" %s", v:GetModel(), ",")
			local collision = string.format(" %s", v:GetCollision(), ",")
			local position = string.format(" %s", v:GetPosition(), ",")
			local angle = string.format(" %s", v:GetAngle(), ",")
			file:write("\n", "LootSpawn(", model, ",", collision, "," , position, ",", angle, ")")
		end
	end
	file:close()
end
--------
function Place:DeleteLootbox(args)
	local static = StaticObject.GetById(args.id)
	if IsValid(static) then static:Remove() end
end
-----
function Place:CountLoot()
	local counter = 0
	local file = io.open("lootspawns.txt", "r")
	for line in file:lines() do
		counter = counter + 1
	end
	file:close()
	Network:Broadcast("LootCounted", {num = counter})
	local superTable = {}
	for index, v in pairs(spawns) do
		if IsValid(v) then
			superTable[index] = v:GetPosition()
		end
	end
	Events:Fire("BroadcastSuperTable", superTable)
end
place = Place()

--Events:Subscribe("ModuleUnload", SaveLootToFile)
Events:Subscribe("PlayerChat", place, place.ChatHandle)
--
Network:Subscribe("SpawnTier1", place, place.SpawnTier1)
Network:Subscribe("SpawnTier2", place, place.SpawnTier2)
Network:Subscribe("SpawnTier3", place, place.SpawnTier3)
Network:Subscribe("SpawnTierCredit", place, place.SpawnTierCredit)
Network:Subscribe("DeleteLootbox", place, place.DeleteLootbox)
Events:Subscribe("TimeChange", place, place.CountLoot)