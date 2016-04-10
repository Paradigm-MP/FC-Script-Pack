class 'ServerLoot'
time_change_ticks = 0
time_change_ticks2 = 0
storage_force_respawn = 0
function ServerLoot:__init()
	saveMinutes = 0
	storage_check = Timer()
	os_clock = Timer()
	tier1SpawnTime = 600
	tier2SpawnTime = 1800
	tier3SpawnTime = 3600
	rarity_gen_utility = {}
	rarity_gen_weapons = {}
	rarity_gen_food = {}
	rarity_gen_raw = {}
	stackspawn = {}
	stackspawn["food"] = 2
	stackspawn["weapon"] = 1
	stackspawn["ammo"] = 4
	stackspawn["raw"] = 3
	stackspawn["utility"] = 1
	superTier = {}
	table.insert(superTier, "Radar")
	table.insert(superTier, "Vehiclefinder Drug")
	table.insert(superTier, "Playerfinder Drug")
	table.insert(superTier, "Super Grapple")
	table.insert(superTier, "Armored Vest")
	table.insert(superTier, "(Disguise) Palm Tree")
	table.insert(superTier, "(Disguise) Needlebush")
	table.insert(superTier, "(Disguise) Bush")
	table.insert(superTier, "(Disguise) Kelp")
	table.insert(superTier, "Lootfinder Drug")
	table.insert(superTier, "Wingsuit")
	table.insert(superTier, "Metal Sheet with Window")
	table.insert(superTier, "Hellfire")
	table.insert(superTier, "Death Drop Finder")
	table.insert(superTier, "Death Drop Finder")
	table.insert(superTier, "Death Drop Finder")
	table.insert(superTier, "Death Drop Finder")
	for i = 1, 5 do rarity_gen_utility[i] = {} end
	for i = 1, 5 do rarity_gen_weapons[i] = {} end
	for i = 1, 5 do rarity_gen_food[i] = {} end
	for i = 1, 5 do rarity_gen_raw[i] = {} end
	for itemname, rarnum in pairs(rarity) do
		if inlootbox[itemname] == true then
			for _, itemname2 in pairs(superTier) do
				if itemname ~= itemname2 and itemname ~= "Super Grapple" and itemname ~= "Rope"
				and itemname ~= "Vehicle Shield" and itemname ~= "Radar" then
					if reference[itemname] == "Utility" then
						table.insert(rarity_gen_utility[rarnum], itemname)
					elseif reference[itemname] == "Weaponry" then
						table.insert(rarity_gen_weapons[rarnum], itemname)
					elseif reference[itemname] == "Food" then
						table.insert(rarity_gen_food[rarnum], itemname)
					elseif reference[itemname] == "Raw" then
						table.insert(rarity_gen_raw[rarnum], itemname)
					end
				end
			end
		end
	end
	for i = 1, 10 do
		table.insert(rarity_gen_utility[4], "Grapplehook")
	end
	for i = 1, 12 do
		table.insert(rarity_gen_utility[3], "Grapplehook")
	end
	for i = 1, 5 do
		table.insert(rarity_gen_utility[2], "Grapplehook")
	end
	table.insert(rarity_gen_food[5], "Coffee")
	table.insert(rarity_gen_food[5], "Coffee")
	table.insert(rarity_gen_food[5], "Coffee")
	table.insert(rarity_gen_food[5], "Water")
	table.insert(rarity_gen_food[5], "Water")
	table.insert(rarity_gen_food[5], "Water")
	table.insert(rarity_gen_food[5], "Water")
	table.insert(rarity_gen_food[5], "Water")
	table.insert(rarity_gen_food[4], "Water")
	table.insert(rarity_gen_food[5], "Milk")
	table.insert(rarity_gen_food[5], "Milk")
	table.insert(rarity_gen_food[5], "Milk")
	table.insert(rarity_gen_food[5], "Milk")
	table.insert(rarity_gen_food[4], "Milk")
	table.insert(rarity_gen_food[4], "Milk")
	table.insert(rarity_gen_food[4], "Milk")
	table.insert(rarity_gen_food[4], "Water")
	table.insert(rarity_gen_food[4], "Water")
	table.insert(rarity_gen_food[4], "Water")
	table.insert(rarity_gen_food[3], "Water")
	table.insert(rarity_gen_food[3], "Water")
	table.insert(rarity_gen_food[3], "Coconut Water")
	table.insert(rarity_gen_food[3], "Coconut Water")
	table.insert(rarity_gen_food[3], "Coconut Water")
	table.insert(rarity_gen_food[4], "Coconut Water")
	table.insert(rarity_gen_food[3], "Milk")
	table.insert(rarity_gen_food[3], "Milk")
	table.insert(rarity_gen_food[3], "Milk")
	table.insert(rarity_gen_food[3], "Milk")
	table.insert(rarity_gen_food[3], "Water")
	table.insert(rarity_gen_food[3], "Water")
	table.insert(rarity_gen_utility[3], "Backpack")
	table.insert(rarity_gen_utility[3], "Backpack")
	table.insert(rarity_gen_utility[2], "Backpack")
	table.insert(rarity_gen_utility[2], "Pocketed Vest")
	--for rarnum, nametable in pairs(rarity_gen) do
		--print("rarnum: " .. rarnum)
	--	for index, item in pairs(nametable) do
			--print(item)
	--	end
	--end
	for static in Server:GetStaticObjects() do -- clean server
		if IsValid(static) then
			if static:GetValue("STier") or static:GetValue("LTier") then
				static:Remove()
			end
 		end
	end
	SQL:Execute("CREATE TABLE IF NOT EXISTS PlayerStorages (steamID VARCHAR, storageID INTEGER PRIMARY KEY AUTOINCREMENT, items VARCHAR, position VARCHAR, angle VARCHAR, tier INTEGER)")
	SQL:Execute("CREATE TABLE IF NOT EXISTS FactionStorages (faction VARCHAR, storageID INTEGER PRIMARY KEY AUTOINCREMENT, items VARCHAR, position VARCHAR, angle VARCHAR)")
	SQL:Execute("CREATE TABLE IF NOT EXISTS Inventories (steamID VARCHAR UNIQUE, items VARCHAR, slotmaxes VARCHAR)")
	-- put primary keys in table, then give to WNO with SetValue (dont make it a network value)
	inventories = {} -- key: steamid || value: table
	--
	--
	test_inv = {}
	test_inv["Raw"] = {}
	test_inv["Utility"] = {}
	test_inv["Social"] = {}
	test_inv["Build"] = {}
	test_inv["Weaponry"] = {}
	test_inv["Food"] = {}
	--------
	--------
	primary_keys = {}
	drops = {}
	lootspawns = {}
	lootboxes = {}
	storages = {} -- storages[steamid] = table[index(primary_key)] = static_id
	fstorages = {}
	dropval_args = {}
	refill_loot_args = {}
	respawn_loot_args = {}
	RefillQueue = {}
	LiveQueue = {}
	--
	respawn_loot_args.angle = Angle(0, 0, 0)
	--
	dropbox_args = {}
	dropbox_args.model = "pickup.boost.vehicle.eez/pu02-a.lod"
	dropbox_args.collision = "37x10.flz/go061_lod1-e_col.pfx"
	dropbox_args.angle = Angle(0, 0, 0)
	--
	tier1 = {} -- dont delete these tables
	tier1.model = "general.blz/go155-a.lod"
	tier1.collision = "general.blz/go155_lod1-a_col.pfx"
	tier1.position = Vector3(-12290.680664, 610.914551, 4756.412598)
	tier1.angle = Angle(-0.490874, 0.000000, 0.000000)
	tier2 = {}
	tier2.model = "km03.gamblinghouse.flz/key032_01-f.lod"
	tier2.collision = "km03.gamblinghouse.flz/key032_01_lod1-f_col.pfx"
	tier2.angle = Angle(-0.490874, 0.000000, 0.000000)
	tier2.position = Vector3(-12288.702148, 610.913452, 4757.436035)
	tier3 = {}
	tier3.model = "geo.cbb.eez/go152-a.lod"
	tier3.collision = "km05.hotelbuilding01.flz/key030_01_lod1-n_col.pfx"
	tier3.angle = Angle(-0.490874, 0.000000, 0.000000)
	tier3.position = Vector3(-12286.671875, 610.906860, 4758.502930)
	--
	------------------------------------------------------
	----------- START SPAWN LOOT FROM LOOT FILE ----------
	local counter = 0
	local spawn_timer = Timer() -- time loot spawn time
	local file = io.open("lootspawns.txt", "r") -- read from lootspawns.txt
	if file ~= nil then -- file might not exist
		local args = {}
		args.world = DefaultWorld
		for line in file:lines() do
			line = line:trim()
			if string.len(line) > 0 then -- filter out empty lines
				--counter = counter + 1
				--if counter % 2 == 0 then
					--Chat:Broadcast(tostring(line), Color(255, 0, 0))
					--Chat:Broadcast("length of line: " .. tostring(string.len(line)), Color(255, 0, 0))
					line = line:gsub("LootSpawn%(", "")
					line = line:gsub("%)", "")
					line = line:gsub(" ", "")
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
					--
					local static = StaticObject.Create({position = args.position, angle = args.angle, model = args.model, collision = args.collision})
					if args.model == tier1.model then
						static:SetNetworkValue("LTier", 1)
					elseif args.model == tier2.model then
						static:SetNetworkValue("LTier", 2)
					elseif args.model == tier3.model then
						static:SetNetworkValue("LTier", 3)
					end
					static:SetNetworkValue("Opened", 0)
					static:SetStreamDistance(300) -- config loot streaming distance here
					lootboxes[static:GetId()] = true
				--end
			end
		end
		file:close()
	else
		print("Fatal Error: Could not load loot from file")
	end
	-- START POPULATE LOOT
	math.randomseed(os.clock())
	for static_id, bool in pairs(lootboxes) do
		local static = StaticObject.GetById(static_id)
		local tier = static:GetValue("LTier")
		--
		if tier == 1 then
			for i = 1, math.random(2, 3) do
				local item = Convert(math.random(5), 1)
				static:SetNetworkValue("L" .. tostring(i), item)
			end
		elseif tier == 2 then
			for i = 1, math.random(1, 2) do
				local item = Convert(math.random(4), 2)
				static:SetNetworkValue("L" .. tostring(i), item)
			end
		elseif tier == 3 then
			for i = 1, math.random(1, 2) do
				local item = Convert(math.random(3), 3)
				static:SetNetworkValue("L" .. tostring(i), item)
			end
		end
	end
	--
	print("Took " .. tostring(spawn_timer:GetSeconds()) .. " seconds to spawn " .. table.count(lootboxes) .. " loot and initialize values from file")
	spawn_timer:Restart()
	-- START SPAWN AND POPULATE PLAYER STORAGE
	local data = {}
	local qry = SQL:Query("SELECT * FROM PlayerStorages")
	data = qry:Execute()
	for index, itable in pairs(data) do
		local split_pos = string.split(itable.position, ",")
		local pos = Vector3(tonumber(split_pos[1]), tonumber(split_pos[2]), tonumber(split_pos[3]))
		local split_ang = string.split(itable.angle, ",")
		for k, v in pairs(split_ang) do
			split_ang[k] = string.gsub(v, " ", "")
			--print(split_ang[k])
		end
		local ang = Angle(tonumber(split_ang[1]), tonumber(split_ang[2]), tonumber(split_ang[3]))
		local model
		local collision
		local tier = tonumber(itable.tier)
		if tier == 1 then
			model = "f1t16.garbage_can.eez/go225-a.lod"
			collision = "f1t16.garbage_can.eez/go225_lod1-a_col.pfx"
		end
		local static = StaticObject.Create({position = pos, angle = ang, model = model, collision = collision})
		static:SetStreamDistance(300) -- make this 300
		static:SetNetworkValue("STier", tier)
		static:SetNetworkValue("Owner", itable.steamID)
		static:SetValue("storageID", tonumber(itable.storageID))
		local item_table = ReverseFormatSQL(itable.items)
		for i = 1, table.count(item_table) do
			static:SetNetworkValue("L" .. tostring(i), item_table[i])
		end
		--
		if not storages[itable.steamID] then
			storages[itable.steamID] = {}
			storages[itable.steamID][tonumber(itable.storageID)] = static:GetId()
		else
			storages[itable.steamID][tonumber(itable.storageID)] = static:GetId()
		end
	end
	--
	local count = 0
	for k, v in pairs(storages) do
		for k2, v2 in pairs(v) do
			count = count + 1
		end
	end
	-- START SPAWN AND POPULATE FACTION STORAGE -- CURRENTLY NOT SUPPORTED
	local fdata = {}
	local qry = SQL:Query("SELECT * FROM FactionStorages")
	--fdata = qry:Execute()
	fdata = {}
	for index, itable in pairs(fdata) do
		local split_pos = string.split(itable.position, ",")
		local pos = Vector3(tonumber(split_pos[1]), tonumber(split_pos[2]), tonumber(split_pos[3]))
		local split_ang = string.split(itable.angle, ",")
		for k, v in pairs(split_ang) do
			split_ang[k] = string.gsub(v, " ", "")
			--print(split_ang[k])
		end
		local ang = Angle(tonumber(split_ang[1]), tonumber(split_ang[2]), tonumber(split_ang[3]))
		local static = StaticObject.Create({position = pos, angle = ang}) -- DOESNT WORK LELELEEL
		static:SetStreamDistance(300)
		static:SetNetworkValue("STier", 2)
		static:SetNetworkValue("Faction", itable.faction)
		static:SetValue("storageID", tonumber(itable.storageID))
		local item_table = ReverseFormatSQL(itable.items)
		for i = 1, table.count(item_table) do
			static:SetNetworkValue("L" .. tostring(i), item_table[i])
		end
		--
		if not fstorages[itable.faction] then
			fstorages[itable.faction] = {}
			fstorages[itable.faction][itable.faction] = static:GetId()
		else
			fstorages[itable.faction][itable.faction] = static:GetId()
		end
	end
	--
	print("Took " .. tostring(spawn_timer:GetSeconds() .. " seconds to spawn and populate " .. tostring(count) .. " storages from file"))
	spawn_timer = nil
end -- must add categories
------------------------------- END __INIT()
function ServerLoot:DeleteLootFromWNO(args, player) -- receives id(of WNO), index, max_index, inventory
	local static = StaticObject.GetById(args.id)
	if not IsValid(static) then return end
	static:SetNetworkValue("L" .. tostring(args.index), nil)
	local steamid = player:GetSteamId().id
	--
-- START RE-ASSIGN INDEXES
	if args.index == args.max_index then return end
	for i = args.index, args.max_index do
		static:SetNetworkValue("L" .. tostring(i), static:GetValue("L" .. tostring(i + 1))) -- shift indexes
	end
-- END RE-ASSIGN INDEXES
	--
	--
	local LTier = static:GetValue("LTier")
	if LTier then
		if LTier == 34 then -- if dropbox
			if static:GetValue("L1") == nil then
				if IsValid(static) then static:Remove() end
			end
			lootboxes[args.id] = nil
		elseif LTier == 1 or LTier == 2 or LTier == 3 then -- if loot
			static:SetNetworkValue("LastLooted", tostring(player:GetSteamId().id))
			local achs = player:GetValue("Achievements")
			if not achs.ach_loot100 then
				Events:Fire("SetAchievementProgress", {player = player, achievement = "ach_loot100", progress = 1})
				Events:Fire("SetAchievementProgress", {player = player, achievement = "ach_loot1000", progress = 1})
				Events:Fire("SetAchievementProgress", {player = player, achievement = "ach_loot10000", progress = 1})
			else
				if achs.ach_loot100.progress < 100 then
					Events:Fire("SetAchievementProgress", {player = player, achievement = "ach_loot100", progress = achs.ach_loot100.progress + 1})
				end
				if achs.ach_loot1000.progress < 1000 then
					Events:Fire("SetAchievementProgress", {player = player, achievement = "ach_loot1000", progress = achs.ach_loot1000.progress + 1})
				end
				if achs.ach_loot10000.progress < 10000 then
					Events:Fire("SetAchievementProgress", {player = player, achievement = "ach_loot10000", progress = achs.ach_loot10000.progress + 1})
				end
			end
			if static:GetValue("L1") == nil then
				lootboxes[args.id] = nil
				refill_loot_args.tier = LTier
				refill_loot_args.pos = static:GetPosition()
				refill_loot_args.ang = static:GetAngle()
				refill_loot_args.cidx = static:GetCellId().x
				refill_loot_args.cidy = static:GetCellId().y
				RefillQueue[os_clock:GetSeconds() + math.random()] = Copy(refill_loot_args)
				if IsValid(static) then static:Remove() end
			end
		end
	elseif static:GetValue("STier") then
		local owner = static:GetValue("Owner")
		if owner then
			ServerLoot:UpdatePlayerStorageToSQL(player:GetSteamId().id, static)
			if tostring(owner) ~= tostring(steamid) then
				print("( " .. tostring(steamid) .. " ) - ".. tostring(player:GetName()) .. " raided storage of " .. tostring(owner))
			end
		elseif static:GetValue("Faction") then
			ServerLoot:UpdateFactionStorageToSQL(player:GetSteamId().id, static)
		end
	end
	--
	local ply_id = player:GetSteamId().id
	inventories[ply_id] = nil
	inventories[ply_id] = Copy(args.inventory)
	--print("SYNCED INVENTORY FROM " .. tostring(player:GetName()) .. " | (Loot Take)")
	--print("STEAM ID: " .. tostring(ply_id))
end

function ServerLoot:SpawnDropbox(args, player) -- receives spawn_table, pos, ang, inventory
	if not args.ang then args.ang = Angle() end
	local static = StaticObject.Create({position = args.pos, angle = args.ang, model = "pickup.boost.vehicle.eez/pu02-a.lod", collision = "37x10.flz/go061_lod1-e_col.pfx"})
	local id = static:GetId()
	lootboxes[id] = true
	static:SetNetworkValue("LTier", 34) -- dropbox tier flag
	static:SetStreamDistance(300)
	for index, lootstring in pairs(args.spawn_table) do
		static:SetNetworkValue("L" .. tostring(index), lootstring)
	end
	-- handle aggregate drops table
	dropval_args.id = id
	dropval_args.pos = args.pos
	drops[os_clock:GetSeconds() + math.random()] = Copy(dropval_args)
	--
	if IsValid(player) then
		local ply_id = player:GetSteamId().id
		inventories[ply_id] = nil
		inventories[ply_id] = Copy(args.inventory)
	end
	--print("SYNCED INVENTORY FROM " .. tostring(player:GetName()))
	--print("STEAM ID: " .. tostring(ply_id))
end

function ServerLoot:SpawnDropboxServerside(args) -- receives spawn_table, pos, ang
	if not args.ang then args.ang = Angle() end
	local static = StaticObject.Create({position = args.pos, angle = args.ang, model = "pickup.boost.vehicle.eez/pu02-a.lod", collision = "37x10.flz/go061_lod1-e_col.pfx"})
	local id = static:GetId()
	lootboxes[id] = true
	static:SetNetworkValue("LTier", 34) -- dropbox tier flag
	static:SetStreamDistance(300)
	for index, lootstring in pairs(args.spawn_table) do
		static:SetNetworkValue("L" .. tostring(index), lootstring)
	end
	-- handle aggregate drops table
	dropval_args.id = id
	dropval_args.pos = args.pos
	drops[os_clock:GetSeconds() + math.random()] = Copy(dropval_args)
	--
	if IsValid(player) then
		local ply_id = player:GetSteamId().id
		inventories[ply_id] = nil
		inventories[ply_id] = Copy(args.inventory)
	end
	--print("SYNCED INVENTORY FROM " .. tostring(player:GetName()))
	--print("STEAM ID: " .. tostring(ply_id))
end

function ServerLoot:DismountPlayerStorage(args, player) -- receives static_id, item_table, pos
	local steam_id = player:GetSteamId().id
	local static = StaticObject.GetById(args.static_id)
	if not IsValid(static) or not static:GetValue("storageID") then return end
	local primary_key = static:GetValue("storageID")
	local command = SQL:Command("DELETE FROM PlayerStorages WHERE storageID = (?)")
	command:Bind(1, primary_key)
	command:Execute()
	storages[steam_id][primary_key] = nil
	static:Remove()
	--
	if table.count(args.item_table) > 0 then
		local dropbox = StaticObject.Create({position = args.pos, angle = player:GetAngle(), model = "pickup.boost.vehicle.eez/pu02-a.lod", collision = "37x10.flz/go061_lod1-e_col.pfx"})
		local id = dropbox:GetId()
		lootboxes[id] = true
		dropbox:SetNetworkValue("LTier", 34) -- dropbox tier flag
		dropbox:SetStreamDistance(300)
		dropval_args.id = id
		dropval_args.pos = args.pos
		drops[os_clock:GetSeconds() + math.random()] = Copy(dropval_args)
		local i = 1
		for index, lootstring in pairs(args.item_table) do
			dropbox:SetNetworkValue("L" .. tostring(i), lootstring)
			i = i + 1
		end
	end
	ServerLoot:SendStoragesToClient(player, steam_id)
end

function ServerLoot:DismountFactionStorage(args, player) -- receives static_id, item_table, pos
	local steam_id = player:GetSteamId().id
	local static = StaticObject.GetById(args.static_id)
	if not IsValid(static) or not static:GetValue("storageID") or not static:GetValue("Faction") then return end
	local primary_key = static:GetValue("storageID")
	local command = SQL:Command("DELETE FROM FactionStorages WHERE storageID = (?)")
	command:Bind(1, primary_key)
	command:Execute()
	fstorages[static:GetValue("Faction")][primary_key] = nil
	static:Remove()
	--
	if table.count(args.item_table) > 0 then
		local dropbox = StaticObject.Create({position = args.pos, angle = player:GetAngle(), model = "pickup.boost.vehicle.eez/pu02-a.lod", collision = "37x10.flz/go061_lod1-e_col.pfx"})
		local id = dropbox:GetId()
		lootboxes[id] = true
		dropbox:SetNetworkValue("LTier", 34) -- dropbox tier flag
		dropbox:SetNetworkValue("Visible", true)
		dropbox:SetStreamDistance(300)
		dropval_args.id = id
		dropval_args.pos = args.pos
		drops[os_clock:GetSeconds() + math.random()] = Copy(dropval_args)
		local i = 1
		for index, lootstring in pairs(args.item_table) do
			dropbox:SetNetworkValue("L" .. tostring(i), lootstring)
			i = i + 1
		end
	end
end

function ServerLoot:AddToStorage(args, player) -- receives item_table, id(static_id), inventory
	local static = StaticObject.GetById(args.id)
	if not IsValid(static) then return end
	
	local val_table = {}
	for i = 1, 12 do
		local identifier = "L" .. tostring(i)
		local loot_val = static:GetValue(identifier)
		if loot_val then
			val_table[identifier] = loot_val
		end
	end
	
	for name_string, value in pairs(val_table) do
		static:SetNetworkValue(name_string, nil)
	end
	
	for index, lootstring in pairs(args.item_table) do
		static:SetNetworkValue("L" .. tostring(index), lootstring)
		--Chat:Broadcast("Adding To Storage: " .. tostring(lootstring), Color(255, 0, 0))
	end
	--
	local ply_id = player:GetSteamId().id
	inventories[ply_id] = nil
	inventories[ply_id] = Copy(args.inventory)
	--print("SYNCED INVENTORY FROM " .. tostring(player:GetName()) .. " (Storage Add)")
	--print("STEAM ID: " .. tostring(ply_id))
	--
	if static:GetValue("Owner") then
		ServerLoot:UpdatePlayerStorageToSQL(ply_id, static)
	elseif static:GetValue("Faction") then
		ServerLoot:UpdateFactionStorageToSQL(ply_id, static)
	end
end

function ServerLoot:Ach_OpenINV(args, ply)
	Events:Fire("SetAchievementProgress", {player = ply, achievement = "ach_openinv", progress = true})
end

function ServerLoot:MinuteTick()
	saveMinutes = saveMinutes + 1
	if saveMinutes >= 5 then
		for p in Server:GetPlayers() do
			local steam_id = p:GetSteamId().id
			if inventories[steam_id] then
				local inv_string = FormatInventorySQL(inventories[steam_id])
				t = ReverseFormatInventorySQL(inv_string)
				local update = SQL:Command("UPDATE Inventories SET items = ?, slotmaxes = ? WHERE steamID = (?)")
				update:Bind(1, inv_string)
				update:Bind(2, 34)
				update:Bind(3, steam_id)
				update:Execute()
			end
		end
		saveMinutes = 0
	end
	local current_time = os_clock:GetSeconds()
-- START DROPBOX HANDLING --
		for old_time, val_table in pairs(drops) do
			if math.abs(current_time - old_time) > 900 then -- configure how many SECONDS to let dropbox exist in server (round this up to nearest minute due to iteration delay)
				--Chat:Broadcast("DROPBOX REMOVED", Color(0, 255, 0))
				local static = StaticObject.GetById(val_table.id)
				if IsValid(static) and not static:GetValue("IsClaimOBJ") then
					lootboxes[val_table.id] = nil
					drops[old_time] = nil
					static:Remove()
				else
					lootboxes[val_table.id] = nil
					drops[old_time] = nil
				end
			end
		end
-- END DROPBOX HANDLING
--
-- START LOOT HANDLING -- 
		for old_time, val_table in pairs(RefillQueue) do
			local tier = val_table.tier
			local itime = math.abs(current_time - old_time)
			if tier == 1 then
				if itime > tier1SpawnTime or (val_table.cidx == 7 and val_table.cidy == 61 and itime > tier1SpawnTime / 5) then -- configure tier respawn time here in s
				--if itime > 2 then -- configure tier respawn time here
					local static = StaticObject.Create({position = val_table.pos, angle = val_table.ang, model = tier1.model, collision = tier1.collision})
					static:SetStreamDistance(300)
					static:SetNetworkValue("LTier", tier)
					static:SetNetworkValue("Opened", 0)
					for i = 1, math.random(2, 3) do
						static:SetNetworkValue("L" .. tostring(i), Convert(math.random(5), tier))
					end
					lootboxes[static:GetId()] = true
					RefillQueue[old_time] = nil
				end
			elseif tier == 2 then
				if itime > tier2SpawnTime or (val_table.cidx == 7 and val_table.cidy == 61 and itime > tier1SpawnTime / 5) then -- configure tier respawn time here
				--if itime > 2 then -- configure tier respawn time here
					local static = StaticObject.Create({position = val_table.pos, angle = val_table.ang, model = tier2.model, collision = tier2.collision})
					static:SetNetworkValue("LTier", tier)
					static:SetStreamDistance(300)
					static:SetNetworkValue("Opened", 0)
					for i = 1, math.random(1, 2) do
						static:SetNetworkValue("L" .. tostring(i), Convert(math.random(4), tier))
					end
					lootboxes[static:GetId()] = true
					RefillQueue[old_time] = nil
				end
			elseif tier == 3 or (val_table.cidx == 7 and val_table.cidy == 61 and itime > tier1SpawnTime / 5) then
				if itime > tier3SpawnTime then -- configure tier respawn time here
				--if itime > 2 then -- configure tier respawn time here
					local static = StaticObject.Create({position = val_table.pos, angle = val_table.ang, model = tier3.model, collision = tier3.collision})
					static:SetStreamDistance(300)
					static:SetNetworkValue("LTier", tier)
					static:SetNetworkValue("Opened", 0)
					for i = 1, math.random(1, 2) do
						static:SetNetworkValue("L" .. tostring(i), Convert(math.random(3), tier))
					end
					lootboxes[static:GetId()] = true
					RefillQueue[old_time] = nil
				end
			end
		end
-- END LOOT HANDLING --
-- 
-- START LIVE QUEUE HANDLING
--[[
for id, itable in pairs(LiveQueue) do
	if math.abs(current_time - itable.time) > 600 then -- configure time for loot to respawn after it has been opened
		local static = StaticObject.GetById(id)
		if static and IsValid(static) and static:GetPosition() == itable.pos then
			static:Remove()
			local tier = itable.tier
			if tier == 1 then
				if tier == 1 then -- configure tier respawn time here in s
				--if itime > 2 then -- configure tier respawn time here
					local static = StaticObject.Create({position = itable.pos, angle = itable.ang, model = tier1.model, collision = tier1.collision})
					static:SetStreamDistance(300)
					static:SetNetworkValue("LTier", tier)
					static:SetNetworkValue("Opened", 0)
					for i = 1, math.random(2, 3) do
						static:SetNetworkValue("L" .. tostring(i), Convert(math.random(5), tier))
					end
					lootboxes[static:GetId()] = true
				end
			elseif tier == 2 then
				local static = StaticObject.Create({position = itable.pos, angle = itable.ang, model = tier2.model, collision = tier2.collision})
				static:SetNetworkValue("LTier", tier)
				static:SetStreamDistance(300)
				static:SetNetworkValue("Opened", 0)
				for i = 1, math.random(1, 2) do
					static:SetNetworkValue("L" .. tostring(i), Convert(math.random(4), tier))
				end
				lootboxes[static:GetId()] = true
			elseif tier == 3 then
				local static = StaticObject.Create({position = itable.pos, angle = itable.ang, model = tier3.model, collision = tier3.collision})
				static:SetStreamDistance(300)
				static:SetNetworkValue("LTier", tier)
				static:SetNetworkValue("Opened", 0)
				for i = 1, math.random(1, 2) do
					static:SetNetworkValue("L" .. tostring(i), Convert(math.random(3), tier))
				end
				lootboxes[static:GetId()] = true
			end
		end
		LiveQueue[id] = nil
	end
end
-- END LIVE QUEUE HANDLING
--]]
--
-- START BROKEN STORAGE HANDLING
	if storage_check:GetSeconds() > 60 then -- 60 s delay between checks
		--print("enterino1")
		storage_check:Restart()
		local data = {}
		local qry = SQL:Query("SELECT * FROM PlayerStorages")
		data = qry:Execute()
		for index, itable in pairs(data) do
			local static_id = storages[tostring(itable.steamID)][tonumber(itable.storageID)]
			local static
			if static_id then
				static = StaticObject.GetById(static_id)
			end
			local split_pos = string.split(itable.position, ",")
			if not static_id or not static or not IsValid(static) or tostring(static:GetPosition()) ~= tostring(Vector3(tonumber(split_pos[1]), tonumber(split_pos[2]), tonumber(split_pos[3]))) then
				storage_force_respawn = storage_force_respawn + 1
				local split_pos = string.split(itable.position, ",")
				local pos = Vector3(tonumber(split_pos[1]), tonumber(split_pos[2]), tonumber(split_pos[3]))
				local split_ang = string.split(itable.angle, ",")
				for k, v in pairs(split_ang) do
					split_ang[k] = string.gsub(v, " ", "")
					--print(split_ang[k])
				end
				local ang = Angle(tonumber(split_ang[1]), tonumber(split_ang[2]), tonumber(split_ang[3]))
				local static = StaticObject.Create({position = pos, angle = ang, model = "f1t16.garbage_can.eez/go225-a.lod", collision = "f1t16.garbage_can.eez/go225_lod1-a_col.pfx"})
				static:SetStreamDistance(300) -- make this 300
				static:SetNetworkValue("STier", tonumber(itable.tier))
				static:SetNetworkValue("Owner", itable.steamID)
				static:SetValue("storageID", tonumber(itable.storageID))
				local item_table = ReverseFormatSQL(itable.items)
				for i = 1, table.count(item_table) do
					static:SetNetworkValue("L" .. tostring(i), item_table[i])
				end
				--
				if not storages[itable.steamID] then
					storages[itable.steamID] = {}
					storages[itable.steamID][tonumber(itable.storageID)] = static:GetId()
				else
					storages[itable.steamID][tonumber(itable.storageID)] = static:GetId()
				end
				print("Respawned broken storage #" .. tostring(storage_force_respawn))
			end
		end
	end
-- END BROKEN STORAGE HANDLING
end


function ServerLoot:RegisterStatic(args) -- receives obj, steam_id, ply
	local index
	if IsValid(args.obj) and IsValid(args.ply) then
		if args.obj:GetValue("LTier") then
			lootboxes[args.obj:GetId()] = true
		elseif args.obj:GetValue("STier") then
			if not args.obj:GetValue("Faction") then -- if player storage
				if not storages[args.steam_id] then
					storages[args.steam_id] = {}
					table.insert(storages[args.steam_id], args.obj:GetId())
					index = table.find(storages[args.steam_id], args.obj:GetId())
				else -- if already has table entry in storage table
					table.insert(storages[args.steam_id], args.obj:GetId())
					index = table.find(storages[args.steam_id], args.obj:GetId())
				end
			else -- if faction storage
				local faction = args.obj:GetValue("Faction")
				if not fstorages[faction] then
					fstorages[faction] = {}
					table.insert(fstorages[faction], args.obj:GetId())
				else
					table.insert(fstorages[faction], args.obj:GetId())
				end
			end
			if index then
				ServerLoot:WriteNewStorageToDatabase(args.steam_id, args.obj, args.ply, index)
			else
				ServerLoot:WriteNewStorageToDatabase(args.steam_id, args.obj, args.ply, -1)
			end
		end
	end
end

function ServerLoot:WriteNewStorageToDatabase(steam_id, static, player, optional_index)
	local val_table = {}
	for i = 1, 12 do
		local identifier = "L" .. tostring(i)
		local loot_val = static:GetValue(identifier)
		if loot_val then
			val_table[identifier] = loot_val
		end
	end
	local SQL_String = FormatSQL(val_table)

	--
	if not static:GetValue("Faction") then -- player storage
		local command = SQL:Command("INSERT INTO PlayerStorages (steamID, items, position, angle, tier) VALUES (?, ?, ?, ?, ?)")
		command:Bind(1, steam_id)
		command:Bind(2, SQL_String)
		command:Bind(3, tostring(static:GetPosition()))
		command:Bind(4, tostring(static:GetAngle()))
		command:Bind(5, static:GetValue("STier"))
		command:Execute()
		local qry = SQL:Query("SELECT last_insert_rowid() as storageID FROM PlayerStorages")
		local result = qry:Execute()
		if #result > 0 then
			static:SetValue("storageID", tonumber(result[1].storageID))
			--print("Set storageID on new player storage")
		end
		--print("optional index: " .. optional_index)
		storages[steam_id][optional_index] = nil
		storages[steam_id][tonumber(result[1].storageID)] = static:GetId()
		ServerLoot:SendStoragesToClient(player, steam_id)
	else -- if is faction storage
		local faction = static:GetValue("Faction")
		--print("FACTION: " .. faction)
		local command = SQL:Command("INSERT INTO FactionStorages (faction, items, position, angle) VALUES (?, ?, ?, ?)")
		command:Bind(1, faction)
		command:Bind(2, SQL_String)
		command:Bind(3, tostring(static:GetPosition()))
		command:Bind(4, tostring(static:GetAngle()))
		command:Execute()
		local qry = SQL:Query("SELECT last_insert_rowid() as storageID FROM FactionStorages")
		local result = qry:Execute()
		if #result > 0 then
			static:SetValue("storageID", tonumber(result[1].storageID))
			--print("Set storageID on new faction storage")
		end
	end

	--Chat:dBroadcast("Wrote New Storage To SQL", Color(0, 255, 0))
end

function ServerLoot:UpdatePlayerStorageToSQL(steam_id, static)
	local val_table = {}
	for i = 1, 12 do
		local identifier = "L" .. tostring(i)
		local loot_val = static:GetValue(identifier)
		if loot_val then
			val_table[identifier] = loot_val
		end
	end
	
	local primary_key = static:GetValue("storageID")
	--print("primary key: " .. primary_key)
	local update = SQL:Command("UPDATE PlayerStorages SET items = ? WHERE storageID = (?)")
	update:Bind(1, FormatSQL(val_table))
	update:Bind(2, primary_key)
	update:Execute()
	print("Updated Player Storage - ( " .. tostring(steam_id) .. " ) changed storage of ( " .. tostring(static:GetValue("Owner")) .. " )")
end

function ServerLoot:UpdateFactionStorageToSQL(steam_id, static)
	local val_table = {}
	for i = 1, 12 do
		local identifier = "L" .. tostring(i)
		local loot_val = static:GetValue(identifier)
		if loot_val then
			val_table[identifier] = loot_val
		end
	end
	
	local primary_key = static:GetValue("storageID")
	--print("primary key: " .. primary_key)
	local update = SQL:Command("UPDATE FactionStorages SET items = ? WHERE storageID = (?)")
	update:Bind(1, FormatSQL(val_table))
	update:Bind(2, primary_key)
	update:Execute()
	print("Updated Faction Storage")
end

function ServerLoot:InventoryServerSync(args, player) -- receives inventory
	local ply_id = player:GetSteamId().id
	inventories[ply_id] = nil
	inventories[ply_id] = Copy(args.inventory)
	self:PlayerQuit({player = player})
end

function ServerLoot:PlayerQuit(args)
	local steam_id = args.player:GetSteamId().id
	if inventories[steam_id] then
		local inv_string = FormatInventorySQL(inventories[steam_id])
		t = ReverseFormatInventorySQL(inv_string)
		local update = SQL:Command("UPDATE Inventories SET items = ?, slotmaxes = ? WHERE steamID = (?)")
		update:Bind(1, inv_string)
		update:Bind(2, 34)
		update:Bind(3, steam_id)
		update:Execute()
	end
end

function ServerLoot:ClientModuleLoad(args)
	local steam_id = args.player:GetSteamId().id
	local qry = SQL:Query("SELECT items FROM Inventories WHERE steamID = (?) LIMIT 1")
	qry:Bind(1, steam_id)
	local result = qry:Execute()
	if #result > 0 then -- if already in DB
		local inventory_table = ReverseFormatInventorySQL(result[1].items)
		Network:Send(args.player, "ServerInit", {inventory = inventory_table})
	else
		local command = SQL:Command("INSERT INTO Inventories (steamID, items) VALUES (?, ?)")
		command:Bind(1, steam_id)
		command:Bind(2, "de2.q3.") --pb&j and water
		command:Execute()
		Network:Send(args.player, "ServerInit", {inventory = ReverseFormatInventorySQL("de2.q3.")})
	end
	--
	ServerLoot:SendStoragesToClient(args.player, steam_id)
end

function ServerLoot:SendStoragesToClient(player, steam_id)
	local qry = SQL:Query("SELECT position, tier, items, storageID FROM PlayerStorages WHERE steamID = (?)")
	qry:Bind(1, steam_id)
	local result = qry:Execute()
	if #result > 0 then -- already in DB
		Network:Send(player, "SendStoragesToClient", {sinfo = result})
	else
		Network:Send(player, "SendStoragesToClient", {sinfo = {}})
	end
end

function ServerLoot:OpenLootboxEvent(args, player) -- receives tier
	Events:Fire("Exp_OutsideModule", {tier = args.tier, sender = player})
	player:SetMoney(player:GetMoney() + (math.random(1, 5) * args.tier))
end

function ServerLoot:InsertLootQueue(args, player) -- receives id
	local static = StaticObject.GetById(args.id)
	if static and IsValid(static) then
		static:SetNetworkValue("Opened", 1)
	else
		return
	end
	LiveQueue[args.id] = {time = os_clock:GetSeconds(), pos = static:GetPosition(), tier = static:GetValue("LTier"), ang = static:GetAngle()}
end

function ServerLoot:GUIDismountStorage(args, player) -- receives primary_key
	local steam_id = player:GetSteamId().id
	if storages[steam_id] then
		if storages[steam_id][args.primary_key] then
			local static = StaticObject.GetById(storages[steam_id][args.primary_key])
			if IsValid(static) then
				if static:GetValue("Owner") == steam_id then
					local qry = SQL:Query("SELECT items, position FROM PlayerStorages WHERE storageID = (?) LIMIT 1")
					qry:Bind(1, args.primary_key)
					local result = qry:Execute()
					if result[1].items then
						local split_pos = string.split(tostring(result[1].position), ",")
						local pos = Vector3(tonumber(split_pos[1]), tonumber(split_pos[2]), tonumber(split_pos[3]))
						local drop_table = ReverseFormatSQL(tostring(result[1].items))
						local static = StaticObject.Create({position = pos, angle = Angle(0, 0, 0), model = "pickup.boost.vehicle.eez/pu02-a.lod", collision = "37x10.flz/go061_lod1-e_col.pfx"})
						local id = static:GetId()
						lootboxes[id] = true
						static:SetNetworkValue("LTier", 34) -- dropbox tier flag
						static:SetStreamDistance(300)
						for index, lootstring in pairs(drop_table) do
							static:SetNetworkValue("L" .. tostring(index), lootstring)
						end
						dropval_args.id = id
						dropval_args.pos = pos
						drops[os_clock:GetSeconds() + math.random()] = Copy(dropval_args)
					end
					local command = SQL:Command("DELETE FROM PlayerStorages WHERE storageID = (?)")
					command:Bind(1, args.primary_key)
					command:Execute()
					storages[steam_id][args.primary_key] = nil
					static:Remove()
					ServerLoot:SendStoragesToClient(player, steam_id)
					print(tostring(player:GetName()) .. " GUI dismounted storage")
				end
			end
		end
	end
end

function ServerLoot:AddToInventory(args) -- receives steamid.id, add_item, add_amount
	
end

function ServerLoot:DeleteFromInventory(args) -- receives steamid.id, add_item, add_amount 
	
end

-- START CONVENIENCE FUNCTIONS ------
function FormatSQL(val_table) -- receives single table with key index and value lootstring
	local s = ""
	for index, lootstring in pairs(val_table) do
		s = s .. SQLFormat[GetLootName(lootstring)] .. string.match(lootstring, '%d+') .. "."
	end
	return s
end

function ReverseFormatSQL(s) -- receives single table string
	local t = {}
	local s_split = string.split(s, ".")
	for k, v in pairs(s_split) do
		if string.len(v) > 0 then
			local num = tonumber(string.match(v, '%d+'))
			local item = table.find(SQLFormat, string.gsub(v, num, ""))
			table.insert(t, item .. " (" .. num .. ")")
		end
	end
	return t
	--print("-- start reverse format --")
	--for k, v in pairs(t) do
		--print(v)
	--end
end

function FormatInventorySQL(val_table) -- receives inventory table with key category and value table(key index and value lootstring)
	local s = ""
	for category, loottable in pairs(val_table) do
		for index, lootstring in pairs(loottable) do
			local item = SQLFormat[GetLootName(lootstring)]
			if item then
				s = s .. item .. string.match(lootstring, '%d+') .. "."
			else
				print("FATAL ERROR: DID NOT FIND SQLFORMAT MATCH FOR ITEM: " .. tostring(item))
			end
		end
		s = s .. "|"
	end
	return s
end

function ReverseFormatInventorySQL(inventory_string)
	local t = {}
	local category_split = string.split(inventory_string, "|")
	for index, category_string in pairs(category_split) do
		local s = string.split(category_string, ".")
		for k, lootstringcode in pairs(s) do 
			if k == 1 then
				local num = tonumber(string.match(lootstringcode, '%d+'))
				if num then
					local item = table.find(SQLFormat, string.gsub(lootstringcode, num, ""))
					cat = reference[item]
					t[cat] = {}
					t[cat][1] = item .. " (" .. tostring(num) .. ")"
				end
			else
				local num = tonumber(string.match(lootstringcode, '%d+'))
				if num then
					local item = table.find(SQLFormat, string.gsub(lootstringcode, num, ""))
					table.insert(t[cat], item .. " (" .. num .. ")")
				end
			end
		end
	end
	if not t["Raw"] then t["Raw"] = {} end
	if not t["Social"] then t["Social"] = {} end
	if not t["Weaponry"] then t["Weaponry"] = {} end
	if not t["Build"] then t["Build"] = {} end
	if not t["Utility"] then t["Utility"] = {} end
	if not t["Food"] then t["Food"] = {} end
	cat = nil
	return t
end

function Convert(amt, tier) -- loot generator - receives number between 1 - 50 (rarity)
	--print("[DEBUG] num: " .. tostring(num))
	--print("[DEBUG] cat: " .. tostring(cat))
	--local rarnum = math.floor((num / 10) + .5)
	--local item = table.randomvalue(rarity_gen[rarnum])
	--local cat = math.random(1, 6)
	--
	local item, category = SuperGen(tier)
	--Chat:Broadcast(tostring(item), Color(255,0,0))
	--print("[DEBUG] item: " .. tostring(item))
	--print("[DEBUG] rarity[item]: " .. tostring(rarity[item]))
	--print("[DEBUG] stackspawn[rarity[item]]: " .. tostring(stackspawn[rarity[item]]))
	return tostring(item .. " (" .. tostring(math.random(1, stackspawn[category])) .. ")")
end
function SuperGen(tier)
--	It's like magic, but real.
	if tier == 1 then
		local foodR = 30 --percent of getting it
		local weaponR = 6
		local rawR = 40
		local utilityR = 10
		local ammoR = 14
		local percent = math.random(100)
		local r1Percent = 60 --percents of the rarity of the item
		local r2Percent = 35
		local r3Percent = 5
		local percent2 = math.random(100)
		local rarity = 1
		if percent2 <= r1Percent then
			rarity = 5
		elseif percent2 <= (r2Percent + r1Percent) then
			rarity = 4
		elseif percent2 <= (r3Percent + r2Percent + r1Percent) then
			rarity = 3
		end
		if percent <= foodR then --FOOD
			return table.randomvalue(rarity_gen_food[rarity]), "food"
		elseif percent <= (weaponR + foodR) then --WEAPONS
			return table.randomvalue(rarity_gen_weapons[rarity]), "weapon"
		elseif percent <= (ammoR + weaponR + foodR) then --AMMO
			return "Ammo", "ammo"
		elseif percent <= (rawR + ammoR + weaponR + foodR) then --RAW
			return table.randomvalue(rarity_gen_raw[rarity]), "raw"
		elseif percent <= (utilityR + rawR + ammoR + weaponR + foodR) then --OTHER UTILITY
			if #rarity_gen_utility[rarity] == 0 then
				rarity = 4
			end
			return table.randomvalue(rarity_gen_utility[rarity]), "utility"
		end
	elseif tier == 2 then
		local foodR = 20 --percent of getting it
		local weaponR = 15
		local rawR = 40
		local utilityR = 10
		local ammoR = 15
		local percent = math.random(100)
		local r1Percent = 30 --percents of the rarity of the item
		local r2Percent = 65
		local r3Percent = 5
		local percent2 = math.random(100)
		local rarity = 1
		if percent2 <= r1Percent then
			rarity = 4
		elseif percent2 <= (r2Percent + r1Percent) then
			rarity = 3
		elseif percent2 <= (r3Percent + r2Percent + r1Percent) then
			rarity = 2
		end
		if percent <= foodR then --FOOD
			return table.randomvalue(rarity_gen_food[rarity]), "food"
		elseif percent <= (weaponR + foodR) then --WEAPONS
			return table.randomvalue(rarity_gen_weapons[rarity]), "weapon"
		elseif percent <= (ammoR + weaponR + foodR) then --AMMO
			return "Ammo", "ammo"
		elseif percent <= (rawR + ammoR + weaponR + foodR) then --RAW
			return table.randomvalue(rarity_gen_raw[rarity]), "raw"
		elseif percent <= (utilityR + rawR + ammoR + weaponR + foodR) then --OTHER UTILITY
			if #rarity_gen_utility[rarity] == 0 then
				rarity = 3
			end
			return table.randomvalue(rarity_gen_utility[rarity]), "utility"
		end
	elseif tier == 3 then
		local foodR = 5 --percent of getting it
		local superR = 2
		local weaponR = 30
		local rawR = 38
		local utilityR = 25
		local percent = math.random(100)
		local r1Percent = 5 --percents of the rarity of the item
		local r2Percent = 55
		local r3Percent = 40
		local percent2 = math.random(100)
		local rarity = 1
		if percent2 <= r1Percent then
			rarity = 3
		elseif percent2 <= (r2Percent + r1Percent) then
			rarity = 2
		elseif percent2 <= (r3Percent + r2Percent + r1Percent) then
			rarity = 1
		end
		if percent <= foodR then --FOOD
			return table.randomvalue(rarity_gen_food[rarity]), "food"
		elseif percent <= (weaponR + foodR) then --WEAPONS
			return table.randomvalue(rarity_gen_weapons[rarity]), "weapon"
		elseif percent <= (rawR + weaponR + foodR) then --RAW
			return table.randomvalue(rarity_gen_raw[rarity]), "raw"
		elseif percent <= (utilityR + rawR + weaponR + foodR) then --OTHER UTILITY
			if #rarity_gen_utility[rarity] == 0 then
				rarity = 2
			end
			return table.randomvalue(rarity_gen_utility[rarity]), "utility"
		elseif percent <= (utilityR + rawR + weaponR + foodR + superR) then --OTHER UTILITY
			return table.randomvalue(superTier), "weapon"
		end
	end
end
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

-- END CONVENIENCE FUNCTIONS -----

function ServerLoot:OnUnload()
	for static_id, bool in pairs(lootboxes) do
		local static = StaticObject.GetById(static_id)
		if IsValid(static) then
			static:Remove()
		end
	end
	for steam_id, itable in pairs(storages) do
		for primary_key, static_id in pairs(itable) do
			local static = StaticObject.GetById(static_id)
			if IsValid(static) then 
				static:Remove()
			end
		end
	end
end

function ServerLoot:HandleChat(args)
	if args.text == "/toggleloot" and args.player:GetValue("NT_TagName") == "[Admin]" then
		-- deprecated with staticobjects
		--Chat:dBroadcast("Loot Visiblity Modified", Color(255, 255, 0))
		return false
	elseif args.text == "/suicide" then
		args.player:SetHealth(0)
		return false
	elseif args.text == "/countloot" and args.player:GetValue("NT_TagName") == "[Admin]" then
		local count = 0
		for id, bool in pairs(lootboxes) do 
			local static = StaticObject.GetById(id)
			if IsValid(static) then
				count = count + 1
			end
		end
		args.player:SendChatMessage("# of loot in server: " .. tostring(count), Color(0, 255, 0))
		return false
	elseif args.text == "/updatedb" and args.player:GetValue("NT_TagName") == "[Admin]" then
		for p in Server:GetPlayers() do
			local steam_id = p:GetSteamId().id
			if inventories[steam_id] then
				local inv_string = FormatInventorySQL(inventories[steam_id])
				t = ReverseFormatInventorySQL(inv_string)
				local update = SQL:Command("UPDATE Inventories SET items = ?, slotmaxes = ? WHERE steamID = (?)")
				update:Bind(1, inv_string)
				update:Bind(2, 34)
				update:Bind(3, steam_id)
				update:Execute()
			end
		end
		args.player:SendChatMessage("Successfully force updated database", Color(0, 255, 0))
	elseif args.text == "/deleteallstorages" and args.player:GetValue("NT_TagName") == "[Admin]" then
		local cmd_args = args.text:split( " " )
	
		if cmd_args[2] then
		
			local player = Player.Match( cmd_args[2] )[1]
			local steamid = player:GetSteamId()
			
			local command = SQL:Command("DELETE FROM PlayerStorages WHERE steamID = (?)")
			command:Bind(1, steamid)
			command:Execute()
		end
	end
end

--------------------- START SECURITY FUNCTIONS -------------------
function ServerLoot:ClientCryptoMismatch(args, player) -- receives anomaly(number), injection(boolean)
	local name = player:GetName()
	local steamid = player:GetSteamId().id
	player:Kick("Crypto Mismatch Error")
	--Chat:Broadcast(tostring(name) .. " had an inventory anomaly of " .. tostring(args.anomaly), Color(255, 0, 0))
	if args.injection == true then
		--Chat:Broadcast(tostring(name) .. " had item injection occur in inventory", Color(255, 0, 0))
	end
	print("ClientCryptoMismatch Error: " .. tostring(name) .. " ... steamid: " .. tostring(steamid))
end
--------------------- END SECURITY FUNCTIONS -----------------------

loot = ServerLoot()

-- START BASE EVENT SUBSCRIPTIONS
Events:Subscribe("ModuleUnload", loot, loot.OnUnload)
Events:Subscribe("PlayerChat", loot, loot.HandleChat)
Events:Subscribe("TimeChange", loot, loot.MinuteTick)
Events:Subscribe("ClientModuleLoad", loot, loot.ClientModuleLoad)
Events:Subscribe("PlayerQuit", loot, loot.PlayerQuit)
-- END BASE EVENT SUBSCRIPTIONS
--
-- START CROSS-MODULE SUBSCRIPTIONS
--Events:Subscribe("Vehicles_SpawnDropbox", loot, loot.SpawnDropbox) --hello
Events:Subscribe("RegisterStatic", loot, loot.RegisterStatic)
Events:Subscribe("AddToInventory", loot, loot.AddToInventory)
Events:Subscribe("DeleteFromInventory", loot, loot.DeleteFromInventory)
Events:Subscribe("SpawnDropboxServerside", loot, loot.SpawnDropbox)
-- END CROSS-MODULE SUBSCRIPTIONS
--
-- START NETWORK EVENT SUBSCRIPTIONS
Network:Subscribe("DeleteLootFromWNO", loot, loot.DeleteLootFromWNO)
Network:Subscribe("SpawnDropbox", loot, loot.SpawnDropbox)
Network:Subscribe("AddToStorage", loot, loot.AddToStorage)
Network:Subscribe("SyncInventory", loot, loot.InventoryServerSync)
Network:Subscribe("DismountPlayerStorage", loot, loot.DismountPlayerStorage)
Network:Subscribe("DismountFactionStorage", loot, loot.DismountFactionStorage)
Network:Subscribe("GUIDismountStorage", loot, loot.GUIDismountStorage)
Network:Subscribe("OpenLootboxEvent", loot, loot.OpenLootboxEvent)
Network:Subscribe("CryptoMismatch", loot, loot.ClientCryptoMismatch)
Network:Subscribe("Ach_OpenINV", loot, loot.Ach_OpenINV)
Network:Subscribe("InsertLootQueue", loot, loot.InsertLootQueue)
-- END NETWORK EVENT SUBSCRIPTIONS