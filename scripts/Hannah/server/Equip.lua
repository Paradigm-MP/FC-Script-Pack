class 'Equip'

function Equip:__init()
	SQL:Execute("CREATE TABLE IF NOT EXISTS PlayerEquipped (steamID VARCHAR, weapon VARCHAR, parachute VARCHAR, grapplehook VARCHAR)")
	player_equipped = {}
	delayedSends = {} --player id, player, because you cant give them a weapon too soon
	guns = {}
	guns["Pistol"] = 2
	guns["Revolver"] = 4
	guns["Sawed Off Shotgun"] = 6
	guns["Assault Rifle"] = 11
	guns["Pump Action Shotgun"] = 13
	guns["Grenade Launcher"] = 17
	guns["Minigun"] = 26
	guns["Machine Gun"] = 28
	guns["Bubble Blaster"] = 43
	guns["Rocket Launcher"] = 16
	guns["Sniper Rifle"] = 14
	guns["Submachine Gun"] = 5
	
	gunslots = {}
	gunslots["Pistol"] = 0
	gunslots["Revolver"] = 0
	gunslots["Sawed Off Shotgun"] = 0
	gunslots["Assault Rifle"] = 2
	gunslots["Pump Action Shotgun"] = 2
	gunslots["Grenade Launcher"] = 0
	gunslots["Minigun"] = 2
	gunslots["Machine Gun"] = 2
	gunslots["Bubble Blaster"] = 0
	gunslots["Rocket Launcher"] = 2	
	gunslots["Sniper Rifle"] = 2
	gunslots["Submachine Gun"] = 0
	
	other = {}
	other["Grapplehook"] = "Equipped_Grapple" --item, networkvalue name
	other["Super Grapple"] = "Equipped_Grapple"
	other["Portal Gun"] = "Equipped_Weapon"
	other["Parachute"] = "Equipped_Parachute"
	other["Rope"] = "Equipped_Weapon"
	
	Events:Subscribe("ClientModuleLoad", self, self.SetSQLEquippedOthers)
	Events:Subscribe("SecondTick", self, self.SendGunsDelayed)
	Network:Subscribe("EquipOther", self, self.EquipOther)
end
function Equip:SetSQLEquippedOthers(args)
	args.player:ClearInventory()
	local cmd = SQL:Query('SELECT steamID FROM PlayerEquipped WHERE steamID = ?')
	cmd:Bind(1, tostring(args.player:GetSteamId()))
	local result = cmd:Execute(), nil
	if result[1] == nil then
		local cmd2 = SQL:Command('INSERT INTO PlayerEquipped (steamID, weapon, parachute, grapplehook) VALUES (?,?,?,?)')
		cmd2:Bind(1, tostring(args.player:GetSteamId()))
		cmd2:Bind(2, " ")
		cmd2:Bind(3, " ")
		cmd2:Bind(4, " ")
		cmd2:Execute()
		--print("New player, default social values for social loaded.")
	end
	local query = SQL:Query('SELECT weapon, parachute, grapplehook FROM PlayerEquipped WHERE steamID = ? LIMIT 1')
	query:Bind(1, tostring(args.player:GetSteamId()))
	local result2 = query:Execute()
	args.player:SetNetworkValue("Equipped_Weapon", result2[1].weapon)
	args.player:SetNetworkValue("Equipped_Parachute", result2[1].parachute)
	args.player:SetNetworkValue("Equipped_Grapple", result2[1].grapplehook)
	if guns[args.player:GetValue("Equipped_Weapon")] then
		--if they have a gun equipped, give it to them
		delayedSends[args.player:GetId()] = {p = args.player, t = Timer()}
	end
end
function Equip:SendGunsDelayed(args)
	for id, tbl in pairs(delayedSends) do
		if tbl.t:GetSeconds() > 2 then
			local ammo = 0
			local weapon = tbl.p:GetValue("Equipped_Weapon")
			local inventory_table = inventories[tbl.p:GetSteamId()]
			if inventory_table then
				for category, loot_table in pairs(inventory_table) do
					for index, lootstring in pairs(loot_table) do
						if GetLootName(lootstring) == "Ammo" then
							ammo = ammo + GetLootAmount(lootstring)
						end
					end
				end
			end
			if IsValid(tbl.p) and gunslots[weapon] and guns[weapon] then
				tbl.p:GiveWeapon(gunslots[weapon], Weapon(guns[weapon], 0, ammo))
				Network:Send(tbl.p, "EquipWeaponInput")
			end
			delayedSends[id] = nil
			--print("give")
		end
	end
end
function Equip:EquipOther(item, sender)
	if other[item] then
		local oldEquipped = tostring(sender:GetValue(other[item]))
		if oldEquipped == item then
			--unequip
			--print("UNEQUIP", item)
			sender:SetNetworkValue(other[item], " ")
		else
			--equip
			--print("EQUIP", item, other[item])
			sender:SetNetworkValue(other[item], item)
		end
		self:UpdateSQL(sender)
	end
end
function Equip:UpdateSQL(p)
	if not IsValid(p) then return end
	local cmd = SQL:Command('UPDATE PlayerEquipped SET weapon=?,parachute=?,grapplehook=? WHERE steamID = ?')
	cmd:Bind(1, tostring(p:GetValue("Equipped_Weapon")))
	cmd:Bind(2, tostring(p:GetValue("Equipped_Parachute")))
	cmd:Bind(3, tostring(p:GetValue("Equipped_Grapple")))
	cmd:Bind(4, tostring(p:GetSteamId()))
	cmd:Execute()
	--print("SQL",p:GetValue("Equipped_Weapon"),p:GetValue("Equipped_Parachute"),p:GetValue("Equipped_Grapple"))
end
function Equip:EquipItem(args, player) -- receives gun_id, ply_equipped
	--print("EQUIP ",args.gun_name)
	player:SetNetworkValue("Equipped_Weapon", args.gun_name)
	player:ClearInventory()
	player:GiveWeapon(gunslots[args.gun_name], Weapon(args.gun_id, 0, args.ammo))
	Network:Send(player, "EquipWeaponInput", gunslots[args.gun_name])
	self:UpdateSQL(sender)
	--player_equipped[tostring(player:GetSteamId().id)] = nil
	--player_equipped[tostring(player:GetSteamId().id)] = args.ply_equipped
end

function Equip:UnequipItem(args, player) -- receives
	player:SetNetworkValue("Equipped_Weapon", " ")
	player:ClearInventory()
	self:UpdateSQL(sender)
	--player_equipped[tostring(player:GetSteamId().id)] = nil
	--player_equipped[tostring(player:GetSteamId().id)] = args.ply_equipped
end

function Equip:ClientModuleLoad(args)
	args.player:ClearInventory()
	--local steam_id = tostring(args.player:GetSteamId().id)
	--local qry = SQL:Query("SELECT equipped FROM PlayerEquipped WHERE steamID = (?)")
	--qry:Bind(1, steam_id)
	--local result = qry:Execute()
	--if #result > 0 then -- in db
		--if result[1].equipped and string.len(tostring(result[1].equipped)) > 2 then
			--eq_t = ReverseFormatDuraSQL(result[1].equipped)
			--for itemname, itable in pairs(eq_t) do
				--print(itemname)
				--print(itable.durability)
			--	if guns[itemname] and itable.active == true then
					--args.player:GiveWeapon(2, Weapon(guns[itemname], 0, 1))
					--print("GAVE WPN")
				--end
			--end
			--Network:Send(args.player, "SendEquippedToClient", {equipped_table = eq_t})
			--player_equipped[steam_id] = eq_t
		--else
			--Network:Send(args.player, "SendEquippedToClient", {equipped_table = {}})
		--end
	--else -- not in db
		--Network:Send(args.player, "SendEquippedToClient", {equipped_table = {}})
		--local cmd = SQL:Command("INSERT INTO PlayerEquipped (steamID) VALUES (?)")
		--cmd:Bind(1, steam_id)
		--cmd:Execute()
	--end
end

function Equip:PlayerQuit(args)
	--local steam_id = tostring(args.player:GetSteamId().id)
	--if player_equipped[steam_id] then
	--	local update = SQL:Command("UPDATE PlayerEquipped SET equipped = (?) WHERE steamID = (?)")
	--	update:Bind(1, FormatDuraSQL(player_equipped[steam_id]))
	--	update:Bind(2, steam_id)
	--	update:Execute()
	--end
end

function Equip:SecondTick()
	--for id, iitable in pairs(player_equipped) do
	--	for name, itable in pairs(iitable) do
			--print(itable.durability)
	--	end
	--end
end

function Equip:UpdateEquippedServer(args) -- receives t, sid
	--player_equipped[args.sid] = nil
	--player_equipped[args.sid] = args.t
	--print("UPDATED TABLE")
end

function FormatDuraSQL(val_table) -- receives val_table - index lootname - value table(active, durability)
	local s = ""
	for itemname, itable in pairs(val_table) do
		if itable.active == true then
			s = s .. SQLFormat[itemname] .. tostring(itable.durability) .. "|"
		end
	end
	return s
end

function ReverseFormatDuraSQL(equipped_string)
	local t = {}
	local item_split = string.split(equipped_string, "|")
	for index, itemstring in pairs(item_split) do
		if string.len(itemstring) > 2 then
			local num = tonumber(string.match(itemstring, '%d+'))
			t[table.find(SQLFormat, string.gsub(itemstring, tostring(num), ""))] = {durability = num, active = true}
		end
	end
	return t
end

equip = Equip()

Events:Subscribe("ClientModuleLoad", equip, equip.ClientModuleLoad)
Events:Subscribe("PlayerQuit", equip, equip.PlayerQuit)
Events:Subscribe("SecondTick", equip, equip.SecondTick)
--
Events:Subscribe("UpdateEquippedServer", equip, equip.UpdateEquippedServer)
--
Network:Subscribe("EquipItem", equip, equip.EquipItem)
Network:Subscribe("UnequipItem", equip, equip.UnequipItem)

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
function FindItem(item, p)
	local inventory_table = inventories[p:GetSteamId()]
	if inventory_table then
		for category, loot_table in pairs(inventory_table) do
			for index, lootstring in pairs(loot_table) do
				if GetLootName(lootstring) == item then
					return true
				end
			end
		end
	end
	return false
end