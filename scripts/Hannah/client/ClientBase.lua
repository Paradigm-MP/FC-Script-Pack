class 'ClientLoot'
check_view_ticks = 0
post_ticks = 0
current_loot_hover = 34
ShowSelection = false
inv = {}
crypto_inv = {}
renderloot = {}
crypto_renderloot = {}
temptable = {}
lootboxes = {}
storages = {}
guislots = {}
lootslots = {}
opened = {}
debugOn = false --enable for debug chat and dprint messages
arenderId = 1 --img id
InventoryOpen = false
InvFirstRender = true
ReceivedInv = false
Suicide = false
guns = {}
crypto_ticks = 0
guns["Pistol"] = 2
guns["Revolver"] = 4
guns["Sawed Off Shotgun"] = 6
guns["Assault Rifle"] = 11
guns["Pump Action Shotgun"] = 13
guns["Grenade Launcher"] = 17
guns["Minigun"] = 26
guns["Machine Gun"] = 28
guns["Bubble Blaster"] = 43
guns["Rocket Launcher"] = 66
guns["Sniper Rifle"] = 14
guns["Submachine Gun"] = 5
caught_wnos = {}

function ClientLoot:__init()
	if SharedObject.GetByName("ClientSharedInventory") ~= nil then
		SharedObject.GetByName("ClientSharedInventory"):Remove()
	end
	if SharedObject.GetByName("ClientEquipped") ~= nil then
		SharedObject.GetByName("ClientEquipped"):Remove()
	end
	if LocalPlayer:GetValue("CatMaxes") then
		LocalPlayer:SetValue("CatMaxes", nil)
	end
	local sharing_table = SharedObject.Create("ClientSharedInventory", {})
	local equipped_table = SharedObject.Create("ClientEquipped", {})
	equipped = {}
	--slot_open = Image.Create(AssetLocation.Resource, "Slot_IMG")
	
	BackGround_Image = Image.Create(AssetLocation.Resource, "Inv_BG_IMG")
	Storage_Image = Image.Create(AssetLocation.Resource, "StorageIcon_IMG")
	Social_Image = Image.Create(AssetLocation.Resource, "Social_Cat_IMG")
	Food_Image = Image.Create(AssetLocation.Resource, "Food_Cat_IMG")
	Weaponry_Image = Image.Create(AssetLocation.Resource, "Weaponry_Cat_IMG")
	Build_Image = Image.Create(AssetLocation.Resource, "Build_Cat_IMG")
	Raw_Image = Image.Create(AssetLocation.Resource, "Raw_Cat_IMG")
	Utility_Image = Image.Create(AssetLocation.Resource, "Utility_Cat_IMG")
	Dropbox_IMG = Image.Create(AssetLocation.Resource, "DropBox_IMG")
	T1_IMG = Image.Create(AssetLocation.Resource, "T1_INDICATOR_IMG")
	T2_IMG = Image.Create(AssetLocation.Resource, "T2_INDICATOR_IMG")
	T3_IMG = Image.Create(AssetLocation.Resource, "T3_INDICATOR_IMG")
	T4_IMG = Image.Create(AssetLocation.Resource, "T3_INDICATOR_IMG") --lootbox
	T5_IMG = Image.Create(AssetLocation.Resource, "T3_INDICATOR_IMG") --storage
	--= Image.Create(AssetLocation.Resource, "")
	
	--
	screen_size = Render.Size
	--
	--rarity = Parse_Items.rarity -- 1 legendary, 2 is rare, 3 is uncommon, 4 is common, 5 is trash
	--
	--
	triggermodel = {}
	triggermodel["general.blz/go155-a.lod"] = true
	triggermodel["km03.gamblinghouse.flz/key032_01-f.lod"] = true
	triggermodel["geo.cbb.eez/go152-a.lod"] = true
	triggermodel["f1t16.garbage_can.eez/go225-a.lod"] = true
	triggermodel["pickup.boost.vehicle.eez/pu02-a.lod"] = true
	triggermodel["37x10.flz/go231-b.lod"] = true
	--
	categoryslotmaxes = {}
	categoryslotmaxes["Food"] = 5
	categoryslotmaxes["Weaponry"] = 5
	categoryslotmaxes["Build"] = 5
	categoryslotmaxes["Utility"] = 5
	categoryslotmaxes["Raw"] = 7
	categoryslotmaxes["Social"] = 5
	LocalPlayer:SetValue("CatMaxes", categoryslotmaxes)
	--
	tier1 = {}
	tier2 = {}
	tier3 = {}
	tier34 = {}
	stier1 = {}
	stier2 = {}
	tier1.model = "general.blz/go155-a.lod"
	tier1.collision = "general.blz/go155_lod1-a_col.pfx"
	tier2.model = "km03.gamblinghouse.flz/key032_01-f.lod"
	tier2.collision = "km03.gamblinghouse.flz/key032_01_lod1-f_col.pfx"
	tier3.model = "geo.cbb.eez/go152-a.lod"
	tier3.collision = "km05.hotelbuilding01.flz/key030_01_lod1-n_col.pfx"
	stier1.model = "f1t16.garbage_can.eez/go225-a.lod" -- gbin
	stier1.collision = "f1t16.garbage_can.eez/go225_lod1-a_col.pfx" -- gbin
	stier2.model = "37x10.flz/go231-b.lod"
	stier2.collision = "37x10.flz/go231_lod1-b_col.pfx"
	tier34.model = "pickup.boost.vehicle.eez/pu02-a.lod"
	tier34.collision = "37x10.flz/go061_lod1-e_col.pfx"
	---------------------------------------------
	---------------------------------------------
	-- START 2.0 __INIT
	L1 = LabelClickable.Create()
	L2 = LabelClickable.Create()
	L3 = LabelClickable.Create()
	L4 = LabelClickable.Create()
	L5 = LabelClickable.Create()
	L6 = LabelClickable.Create()
	L7 = LabelClickable.Create()
	L8 = LabelClickable.Create()
	L9 = LabelClickable.Create()
	L10 = LabelClickable.Create()
	L11 = LabelClickable.Create()
	L12 = LabelClickable.Create()
	--
	loot_label = {}
	loot_label[1] = L1
	loot_label[2] = L2
	loot_label[3] = L3
	loot_label[4] = L4
	loot_label[5] = L5
	loot_label[6] = L6
	loot_label[7] = L7
	loot_label[8] = L8
	loot_label[9] = L9
	loot_label[10] = L10
	loot_label[11] = L11
	loot_label[12] = L12
	--
	for numindex, label in pairs(loot_label) do
		label:SetSize(Vector2(screen_size.x * .12, screen_size.y * .0350))
		label:SetTextSize(screen_size.x / 96)
		label:SetName(tostring(numindex))
	end
	--
	inv["Food"] = {} -- initialize categories
	inv["Weaponry"] = {}
	inv["Build"] = {}
	inv["Utility"] = {}
	inv["Raw"] = {}
	inv["Social"] = {}
	--
	--inv["Raw"][1] = "Scrap Metal (7)"
	--inv["Raw"][2] = "Platinum (1)"
	--inv["Raw"][3] = "Iron (2)"
	--inv["Utility"][1] = "Grapplehook (3)"
	--inv["Utility"][2] = "Parachute (1)"
	--
	ref_cat_names = {}
	ref_cat_names[1] = "Food"
	ref_cat_names[2] = "Weaponry"
	ref_cat_names[3] = "Build"
	ref_cat_names[4] = "Utility"
	ref_cat_names[5] = "Raw"
	ref_cat_names[6] = "Social"
	--
	-- Label set-up: labels[index] = label
	--				  labels have name that is index 1 - 72 (every 12 constitutes a category)
	--[[
	|
	|12 24
	|... ... 
	|4  16
	|3  15
	|2  14
    |1_13 _ _ _ _ _ _ _ _ _ _
	-]]
	labels = {}
	for i = 1, 72 do -- max inv space
		local name = "B" .. tostring(i)
		name = LabelClickable.Create()
		name:SetBackgroundVisible(false)
		name:SetName(tostring(i))
		name:SetDataBool("dropmode", false)
		name:SetDataNumber("dropvalue", 0)
		name:SetTextSize(screen_size.x / 96)
		name:SetTextColor(Color.Black)
		name:SetTextNormalColor(Color.Black)
		name:SetTextHoveredColor(Color.Black)
		name:SetTextPressedColor(Color.Red)
		name:SetTextDisabledColor(Color.Black)
		labels[i] = name
	end
	sync_timer = Timer()
	fix_timer = Timer()
	--
	DelayInit = Events:Subscribe("SecondTick", DelayedInit)
end

--function Load_WNO_Catcher(args)
	--caught_wnos[args.object:GetId()] = args.object
	--Chat:Print("Added WNO", Color.Green)
	--for name, val in pairs(args.object:GetValues()) do
	--	print(name, val)
	--end
--end
--load_wno_catcher_alyssa = Events:Subscribe("WorldNetworkObjectCreate", Load_WNO_Catcher)

function DelayedInit()
	RecalculateCSM()
	--
	--local uncaught_wnos = 0
	--Chat:Print("loadwnos: " .. tostring(load_wnos), Color.Red)
	--for id, iWNO in pairs(load_wnos) do
		--if not caught_wnos[id] then
		--	uncaught_wnos = uncaught_wnos + 1
		--	ClientLoot:WNOCreate({object = iWNO})
		---end
	--end
	--Chat:Print("Load WNOs Caught: " .. tostring(table.count(load_wnos)), Color.Red)
	--Chat:Print("Load WNOs Caught: " .. tostring(table.count(caught_wnos)), Color.Red)
	--Chat:Print("Uncaught WNOs: " .. tostring(uncaught_wnos), Color.Red)
	--caught_wnos = nil
	--
	Events:Unsubscribe(DelayInit)
	--Events:Unsubscribe(load_wno_catcher_alyssa)
end

function ClientLoot:ServerInit(args)
	if inv then inv = nil end
	inv = args.inventory
	RecalculateCSM()
	ClientLoot:UpdateCryptoInv()
	if debugOn then dprint("received inventory") end
	for k, v in pairs(inv) do
		if debugOn then dprint(k) end
		for k2, v2 in pairs(v) do
			if debugOn then dprint(v2) end
		end
	end
	ReceivedInv = true
	InventoryChangeEvent()
end

function RenderLootBoxIndicator()
	--1 tier1, 2 is tier2, 3 is tier3, 4 is dropbox, 5 is garbage storage
	if not IsValid(currententity) then return end
	if arenderId == 1 then
		local pos,t = Render:WorldToScreen(currententity:GetPosition() + Vector3(0,1.25,0))
		if not t then return end
		T1_IMG:Draw(pos - (T1_IMG:GetPixelSize() / 1.6), T1_IMG:GetPixelSize() * 1.25, Vector2(0,0), Vector2(1,1))
	elseif arenderId == 2 then
		local pos,t = Render:WorldToScreen(currententity:GetPosition() + Vector3(0,1.25,0))
		if not t then return end
		T2_IMG:Draw(pos - (T2_IMG:GetPixelSize() / 1.6), T2_IMG:GetPixelSize() * 1.25, Vector2(0,0), Vector2(1,1))
	elseif arenderId == 3 then
		local pos,t = Render:WorldToScreen(currententity:GetPosition() + Vector3(0,0.75,0))
		if not t then return end
		T3_IMG:Draw(pos - (T3_IMG:GetPixelSize() / 1.6), T3_IMG:GetPixelSize() * 1.25, Vector2(0,0), Vector2(1,1))
	elseif arenderId == 4 then
		local pos,t = Render:WorldToScreen(currententity:GetPosition() + Vector3(0,0.75,0))
		if not t then return end
		Dropbox_IMG:Draw(pos - (Dropbox_IMG:GetPixelSize()/3), Dropbox_IMG:GetPixelSize()/1.5, Vector2(0,0), Vector2(1,1))
	elseif arenderId == 5 then
		local pos,t = Render:WorldToScreen(currententity:GetPosition() + Vector3(0,0.75,0))
		if not t then return end
		Storage_Image:Draw(pos - (Dropbox_IMG:GetPixelSize()/3), Dropbox_IMG:GetPixelSize()/1.5, Vector2(0,0), Vector2(1,1))
	else
		local pos,t = Render:WorldToScreen(currententity:GetPosition() + Vector3(0,1.25,0))
		if not t then return end
		Default_Item:Draw(pos - (Default_Item:GetPixelSize()/3), Default_Item:GetPixelSize()/1.5, Vector2(0,0), Vector2(1,1))
	end
end
function ClientLoot:CheckView()
	--
	check_view_ticks = check_view_ticks + 1
	if check_view_ticks < 5 then return end
	check_view_ticks = 0
	--
	local aimtarget = LocalPlayer:GetAimTarget()
	if aimtarget.entity then
		if aimtarget.entity.__type == "StaticObject" then
			if triggermodel[aimtarget.entity:GetModel()] then -- if lootbox or dropbox or storage
				local model = aimtarget.entity:GetModel()
				if model == "pickup.boost.vehicle.eez/pu02-a.lod" then -- dropbox
					IsDropBox = true
					IsLoot = false
					IsStorage = false
					arenderId = 4
				elseif model == "f1t16.garbage_can.eez/go225-a.lod" or model == "37x10.flz/go231-b.lod" then -- storage
					IsStorage = true
					IsLoot = false
					IsDropBox = false
					arenderId = 5
				elseif model == "general.blz/go155-a.lod" or model == "km03.gamblinghouse.flz/key032_01-f.lod" or model == "geo.cbb.eez/go152-a.lod" then
					if model == "general.blz/go155-a.lod" then
						arenderId = 1
					elseif model == "km03.gamblinghouse.flz/key032_01-f.lod" then
						arenderId = 2
					elseif model == "geo.cbb.eez/go152-a.lod" then
						arenderId = 3
					end
					IsLoot = true
					IsDropBox = false
					IsStorage = false
				end
				local playerpos = LocalPlayer:GetPosition()
				local objectpos = aimtarget.entity:GetPosition()
				objectID = aimtarget.entity:GetId()
				--if currentbox ~= objectID then
				if ShowLoot == false then
					if playerpos:Distance(objectpos) <= 3.75 then
						currentbox = objectID
						currententity = aimtarget.entity
						ShowSelection = true
					else
						ShowLoot = false
						Mouse:SetVisible(false)
						if Game:GetState() == GUIState.Game then
							Mouse:SetPosition(Vector2(screen_size.x * .5, screen_size.y * .505))
						end
						ShowSelection = false
						for num, label in pairs(loot_label) do label:SetVisible(false) end
						currentbox = ""
						IsDropBox = false
						IsStorage = false
						IsLoot = false
					end
				elseif ShowLoot == true and playerpos:Distance(objectpos) > 3.75 then
					ShowLoot = false
					Mouse:SetVisible(false)
					if Game:GetState() == GUIState.Game then
						Mouse:SetPosition(Vector2(screen_size.x * .5, screen_size.y * .505))
					end
					ShowSelection = false
					for num, label in pairs(loot_label) do label:SetVisible(false) end
					currentbox = ""
					IsDropBox = false
					IsStorage = false
					IsLoot = false
				end
			else
				ShowLoot = false
				Mouse:SetVisible(false)
				--Mouse:SetPosition(Vector2(screen_size.x * .5, screen_size.y * .505))
				ShowSelection = false
				for num, label in pairs(loot_label) do label:SetVisible(false) end
				currentbox = ""
				IsDropBox = false
				IsStorage = false
				IsLoot = false
			end
		end
	else
		ShowLoot = false
		ShowSelection = false
		for num, label in pairs(loot_label) do label:SetVisible(false) end
		currentbox = ""
		IsDropBox = false
		IsStorage = false
		IsLoot = false
	end
	if sync_timer:GetSeconds() > 25 then
		Network:Send("SyncInventory", {inventory = inv})
		sync_timer:Restart()
	end
	if LocalPlayer:GetValue("self.ammo") and ReceivedInv == true then
		if GetAmmo() ~= LocalPlayer:GetValue("self.ammo") and LocalPlayer:GetValue("HasReloaded") == true then
			if fix_timer:GetSeconds() > 5 then
				--dprint("self.ammo: " .. tostring(LocalPlayer:GetValue("self.ammo")))
				--dprint("getammo: " .. tostring(GetAmmo()))
				--dprint("slot: " .. tostring(LocalPlayer:GetEquippedSlot()))
				ClientLoot:EquipItem(LocalPlayer:GetValue("CurrentWeapon"))
				fix_timer:Restart()
				--dprint("NET SEND FIX AMMO")
			end
		end
		--dprint(LocalPlayer:GetValue("HasReloaded"))
	end
end

function ClientLoot:RenderItems(object) -- receives StaticObject
	local id = object:GetId()
	if id == nil then return end
	if not opened[id] then
		opened[id] = true
		if object:GetValue("LTier") then
			if object:GetValue("LTier") ~= 34 then
				local last_looted = object:GetValue("LastLooted")
				local ilooted = object:GetValue("iLooted")
				if not last_looted and not ilooted then
					Network:Send("OpenLootboxEvent", {tier = object:GetValue("LTier")}) -- for giving exp and credits for looting
					object:SetValue("iLooted", true)
				else
					if last_looted ~= tostring(LocalPlayer:GetSteamId().id) and not ilooted then
						Network:Send("OpenLootboxEvent", {tier = object:GetValue("LTier")}) -- for giving exp and credits for looting
						object:SetValue("iLooted", true)
					end
				end
			end
		end
	end
	
	local tier = object:GetValue("LTier")
	local opened = object:GetValue("Opened")
	if tier and tier ~= 34 then
		if opened and opened == 0 then
			Network:Send("InsertLootQueue", {id = id})
		end
	end
	
	for k, v in pairs(renderloot) do renderloot[k] = nil end
	renderloot = {}

	for i = 1, 12 do
		if i == 1 and not object:GetValue("L" .. tostring(i)) then
			--Chat:Print("Loot Info not synced to client", Color(0, 255, 0))
		end
		if object:GetValue("L" .. tostring(i)) then
			renderloot[i] = object:GetValue("L" .. tostring(i))
		end
		ShowLoot = true
	end
	--
	for index, lbl in pairs(loot_label) do
		lbl:SetVisible(false)
		lbl:SetText("")
	end
	--
	numloot_g = table.count(renderloot) -- global
	local start_pos = Vector2(screen_size.x * .5 - (L1:GetWidth() / 2), screen_size.y * .5 - (L1:GetHeight() * 1.3))
	for i = 1, numloot_g do
		local label = loot_label[i]
		label:SetText(tostring(renderloot[i]))
		label:SetVisible(true)
		label:SetPosition(start_pos)
		label:SetTextSize(screen_size.x / 96)
		label:SetTextColor(Color.Black)
		label:SetTextNormalColor(Color.Black)
		label:SetTextHoveredColor(Color.Black)
		label:SetTextPressedColor(Color.Red)
		label:SetTextDisabledColor(Color.Black)
		--
		start_pos.y = start_pos.y - (label:GetSize().y * 1.1)
	end
	--
	for k, v in pairs(renderloot) do if debugOn then Chat:dPrint(tostring(v), Color(255, 255, 0)) end end
end

function ClientLoot:EntitySpawn(args) -- when client streams in entities
	
end

function ClientLoot:EntityDespawn(args) -- when client exits entity's streaming distance or entity removed
	
end

function ClientLoot:EntityValueChange(args)
	if currententity and IsValid(currententity) then
		if currententity:GetPosition() ~= args.object:GetPosition() then return end
	end
	
	if args.object:GetValue("LTier") == nil and args.object:GetValue("STier") == nil then return end -- if not loot and not storage

	for i = 1, 12 do
		if args.key == "L" .. tostring(i) then
			if currententity and IsValid(currententity) then
				if ShowLoot == true and currententity:GetPosition() == args.object:GetPosition() then
					ClientLoot:RenderItems(currententity) -- only called if another player has the same thing open since it auto closes when u drop smth in the storage
					break
				end
			end
		end
	end
end

function MagicMike2(l) --wonderful
	Render:DrawLine(l:GetPosition(), l:GetPosition() + Vector2(l:GetWidth(), 0), Color(255, 255, 255, 255)) -- top across
	Render:DrawLine(l:GetPosition(), l:GetPosition() + Vector2(0, l:GetHeight()), Color(255, 255, 255, 255)) -- left down
	Render:DrawLine(l:GetPosition() + Vector2(l:GetWidth(), l:GetHeight()), l:GetPosition() + Vector2(l:GetWidth(), l:GetHeight()) - Vector2(0, l:GetHeight()), Color(150, 150, 150, 255)) -- right up
	Render:DrawLine(l:GetPosition() + Vector2(0, l:GetHeight()), l:GetPosition() + Vector2(l:GetWidth(), l:GetHeight()), Color(150, 150, 150, 255)) -- down across
end
function MagicMike(l) --wonderful
	Render:DrawLine(l:GetPosition(), l:GetPosition() + Vector2(l:GetWidth(), 0), Color(150, 150, 150, 255)) -- top across
	Render:DrawLine(l:GetPosition(), l:GetPosition() + Vector2(0, l:GetHeight()), Color(150, 150, 150, 255)) -- left down
	Render:DrawLine(l:GetPosition() + Vector2(l:GetWidth(), l:GetHeight()), l:GetPosition() + Vector2(l:GetWidth(), l:GetHeight()) - Vector2(0, l:GetHeight()), Color(255, 255, 255, 255)) -- right up
	Render:DrawLine(l:GetPosition() + Vector2(0, l:GetHeight()), l:GetPosition() + Vector2(l:GetWidth(), l:GetHeight()), Color(255, 255, 255, 255)) -- down across
end
function MagicMikeRed2(l) --wonderful
	Render:DrawLine(l:GetPosition(), l:GetPosition() + Vector2(l:GetWidth(), 0), Color(240, 0, 0, 255)) -- top across
	Render:DrawLine(l:GetPosition(), l:GetPosition() + Vector2(0, l:GetHeight()), Color(240, 0, 0, 255)) -- left down
	Render:DrawLine(l:GetPosition() + Vector2(l:GetWidth(), l:GetHeight()), l:GetPosition() + Vector2(l:GetWidth(), l:GetHeight()) - Vector2(0, l:GetHeight()), Color(150, 0, 0, 255)) -- right up
	Render:DrawLine(l:GetPosition() + Vector2(0, l:GetHeight()), l:GetPosition() + Vector2(l:GetWidth(), l:GetHeight()), Color(150, 0, 0, 255)) -- down across
end
function MagicMikeRed(l) --wonderful
	Render:DrawLine(l:GetPosition(), l:GetPosition() + Vector2(l:GetWidth(), 0), Color(150, 0, 0, 255)) -- top across
	Render:DrawLine(l:GetPosition(), l:GetPosition() + Vector2(0, l:GetHeight()), Color(150, 0, 0, 255)) -- left down
	Render:DrawLine(l:GetPosition() + Vector2(l:GetWidth(), l:GetHeight()), l:GetPosition() + Vector2(l:GetWidth(), l:GetHeight()) - Vector2(0, l:GetHeight()), Color(240, 0, 0, 255)) -- right up
	Render:DrawLine(l:GetPosition() + Vector2(0, l:GetHeight()), l:GetPosition() + Vector2(l:GetWidth(), l:GetHeight()), Color(240, 0, 0, 255)) -- down across
end
function StarWarsTheForceAwakens(lbl)
	local size = screen_size.x / 250
	local pos = lbl:GetPosition() + Vector2(lbl:GetSize().x - (screen_size.x / 150), (lbl:GetSize().y * 0.5) - (size / 2))
	Render:FillCircle(pos, size, Color(54,255,124,255))
	Render:DrawCircle(pos, size, Color(0,0,0,255))
end
function ClientLoot:Render()
	--for pos, id in pairs(WorldNetworkObjects) do
		--local vtype = 1
		--local vec = {}
		--for i in string.gmatch(pos, "%,") do vtype = vtype + 1 end
		--for i = 1, vtype do
		--	vec[i] = tonumber(string.match(pos, '%-?%d+'))
			--pos = string.gsub(pos, '%d+', "", 1)
			--pos = string.gsub(pos, '%,', "", 1)
			--pos = string.gsub(pos, '%d+', "", 1)
		--end
		--local vector3 = Vector3(vec[1], vec[2], vec[3])
		--if debugOn then Render:DrawCircle(vector3, 1, Color(255, 0, 255)) end
	--end
	--if InventoryOpen == false and ShowLoot == false then Mouse:SetVisible(false) end
-- START INVENTORY RENDERING ----------------
	if InventoryOpen == true then
		local screen_size = Render.Size
		LocalPlayer:SetValue("Inv_Open", true)
		Mouse:SetVisible(true)
		if current_loot_hover2 then
			Mouse:SetCursor(11)
			local l = current_loot_hover2
			MagicMike(l)
		end
		--if InvFirstRender == true then -- position labels / FirstRender
			local iterator_index = 1
			local size = Vector2(screen_size.x * .12, screen_size.y * .0350)
			y_mod_temp = screen_size.y - size.y
			x_mod_temp = screen_size.x * .075
			for i = 1, 6 do -- cats
				y_mod_temp = screen_size.y - size.y
				for ii = 1, 12 do -- slots
					labels[iterator_index]:SetPosition(Vector2(x_mod_temp, y_mod_temp))
					labels[iterator_index]:SetSize(size)
					iterator_index = iterator_index + 1
					y_mod_temp = y_mod_temp - (size.y * 1.1)
				end
				x_mod_temp = x_mod_temp + (size.x * 1.1)
			end
			--InvFirstRender = false
		--end
		--
		local size = Vector2(screen_size.x * .12, screen_size.y * .0350)
		x_mod = screen_size.x * 0.1
		y_mod = screen_size.y - size.y
		local textSize = screen_size.x / 58 --lower number = bigger section font
		for i = 1, 72 do
			local lbl = labels[i]
			lbl:SetText("")
			lbl:SetVisible(false)
		end
	local socialStr = tostring(LocalPlayer:GetValue("SOCIAL_Hat")).." "..
	tostring(LocalPlayer:GetValue("SOCIAL_Disguise")).." "..
	tostring(LocalPlayer:GetValue("SOCIAL_Back")).." "..
	tostring(LocalPlayer:GetValue("SOCIAL_Hand")).." "..
	tostring(LocalPlayer:GetValue("SOCIAL_Face")).." "..
	tostring(LocalPlayer:GetValue("SOCIAL_Wingsuit"))
	local parachuteV = string.trim(tostring(LocalPlayer:GetValue("Equipped_Parachute")))
	local gunV = string.trim(tostring(LocalPlayer:GetValue("Equipped_Weapon")))
	local grappleV = string.trim(tostring(LocalPlayer:GetValue("Equipped_Grapple")))
		for i = 1, 6 do -- 6 categories
			y_mod = screen_size.y - size.y
			local category_render = inv[ref_cat_names[i]]
			if #category_render == 0 then
				--local lbl = labels[((i - 1) * 12) + 1]
				local cat = ref_cat_names[i]
				local str = cat .. " (0" .. "/" .. tostring(categoryslotmaxes[cat]) .. ")"
				local color2 = GetCategoryColorSectionThingHAHA(cat) --i call this beautification, not butchering
				local textsizevector = Render:GetTextSize(str,textSize)
				local pos2 = Vector2((screen_size.x / 6 * i) - (textsizevector.x / 2) - (screen_size.x / 14), screen_size.y - textsizevector.y)
				Render:DrawText(pos2,str, Color(0, 0, 0), textSize)
				Render:DrawText(pos2 - (screen_size / 1000),str, color2, textSize)
				Render:FillArea(pos2 + Vector2(0,textsizevector.y/1.1), Vector2(textsizevector.x, textsizevector.y / 10), Color.Black)
				Render:FillArea(pos2 + Vector2(0,textsizevector.y/1.1) - (screen_size / 1000), Vector2(textsizevector.x, textsizevector.y / 10), color2)
			end
			for numindex, lootstring in pairs(category_render) do -- 0-12 iterations
				local item = GetLootName(lootstring)
				local item_amount = GetLootAmount(lootstring)
				local lbl = labels[((i - 1) * 12) + numindex]
				if lbl:GetVisible() == false then lbl:SetVisible(true) end
				lbl:SetText(lootstring)
				lbl:SetTextColor(Color.Black)
				lbl:SizeToContents()
				lbl:SetSize(Vector2(lbl:GetSize().x + screen_size.x * .0125, screen_size.y * .0350))
				local width = lbl:GetWidth()
				lbl:SetPosition(Vector2(x_mod - (width / 2), lbl:GetPosition().y))
				local color = DetermineRarityColor(lootstring)
				--lbl:BringToFront()
				if lbl:GetDataBool("dropmode") == true then
					lbl:SetText(lbl:GetText() .. tostring(" (" .. tostring(lbl:GetDataNumber("dropvalue")) .. "/" .. tostring(item_amount) .. ")"))
					lbl:SizeToContents()
					lbl:SetSize(Vector2(lbl:GetSize().x + screen_size.x * .0125, screen_size.y * .0350))
					local width = lbl:GetWidth()
					lbl:SetPosition(Vector2(x_mod - (width / 2), lbl:GetPosition().y))
					Render:FillArea(lbl:GetPosition(), lbl:GetSize(), Color(color.r, color.g, color.b, 150))
					if current_loot_hover2 ~= lbl then MagicMikeRed2(lbl) else MagicMikeRed(lbl) end
				else
					if current_loot_hover2 ~= lbl then MagicMike2(lbl) else MagicMike(lbl) end
					Render:FillArea(lbl:GetPosition(), lbl:GetSize(), Color(color.r, color.g, color.b, 150))
				end
				local a,b = string.find(socialStr, item, 0, true)
				if a and b then
					socialStr = string.sub(socialStr, 0, a-1)..string.sub(socialStr, b+1, string.len(socialStr))
					StarWarsTheForceAwakens(lbl)
				end
				if string.find(gunV, item, 0, true) then
					StarWarsTheForceAwakens(lbl)
					gunV = ""
				elseif string.find(parachuteV, item, 0, true) then
					StarWarsTheForceAwakens(lbl)
					parachuteV = ""
				elseif string.find(grappleV, item, 0, true) then
					StarWarsTheForceAwakens(lbl)
					grappleV = ""
				end
				y_mod = y_mod - (size.y * 1.1)
				if numindex == #category_render then
					local cat = ref_cat_names[i]
					--Render:SetFont(AssetLocation.SystemFont, "Calibri")
					--local text_width = Render:GetTextWidth(cat, screen_size.x/64)
					local str = cat .. " (" .. tostring(#category_render) .. "/" .. tostring(categoryslotmaxes[cat]) .. ")"
					local color2 = GetCategoryColorSectionThingHAHA(cat) --i call this beautification, not butchering
					local textsizevector = Render:GetTextSize(str,textSize)
					local pos2 = lbl:GetPosition() - Vector2(0,lbl:GetSize().y * 1.5) + (lbl:GetSize() / 2) - Vector2(textsizevector.x/2, 0)
					Render:DrawText(pos2,str, Color(0, 0, 0), textSize)
					Render:DrawText(pos2 - (screen_size / 1000),str, color2, textSize)
					Render:FillArea(pos2 + Vector2(0,textsizevector.y/1.1), Vector2(textsizevector.x, textsizevector.y / 10), Color.Black)
					Render:FillArea(pos2 + Vector2(0,textsizevector.y/1.1) - (screen_size / 1000), Vector2(textsizevector.x, textsizevector.y / 10), color2)
				end
			end
			x_mod = x_mod + (size.x * 1.35)
		end
	else
		for i = 1, 72 do labels[i]:SetVisible(false) end
		LocalPlayer:SetValue("Inv_Open", nil)
	end
-- END INVENTORY RENDERING ------------------
--
-- START LOOT RENDERING ---------------------
	if ShowSelection == true then
		RenderLootBoxIndicator()
		--Render:FillCircle(Vector2(screen_size.x * .5, screen_size.y * .5), 25, Color(0, 255, 0, 200))
	end
	if ShowLoot == true then
		for numindex, lootstring in pairs(renderloot) do
			local label = loot_label[numindex]
			label:SizeToContents()
			label:SetSize(Vector2(label:GetSize().x + screen_size.x * .02, screen_size.y * .0350))
			local color = DetermineRarityColor(lootstring)
			Render:FillArea(label:GetPosition(), label:GetSize(), Color(color.r, color.g, color.b, 150))
			MagicMike2(label)
		end
		--
		if current_loot_hover ~= 34 then
			Mouse:SetCursor(11)
			local l = current_loot_hover
			MagicMike(l)
		end
		if IsStorage == true then
			if currententity and IsValid(currententity) then
				local render_count = #renderloot
				if render_count == 0 then
					local width = Render:GetTextWidth("Storage is empty", TextSize.Default * 1.25)
					Render:DrawText(Vector2((screen_size.x * .5) - (width / 2), screen_size.y * .52), "Storage is empty", Color(170, 193, 213, 200), TextSize.Default * 1.25)
				else -- render how full storage is
					local text = tostring(render_count) .. " / 8"
					local w = Render:GetTextWidth(text, TextSize.Default * 1.25)
					local h = Render:GetTextHeight(text, TextSize.Default * 1.25)
					local lbl = loot_label[render_count]
					local pos = lbl:GetPosition()
					local label_h = lbl:GetHeight()
					local label_w = lbl:GetWidth()
					Render:DrawText(Vector2((pos.x + (label_w / 2)) - (w / 2), pos.y - h), text, Color(170, 193, 213, 200), TextSize.Default * 1.25)
				end

				if currententity:GetValue("Owner") then
					if currententity:GetValue("Owner") == LocalPlayer:GetSteamId().id then
						local screen_size = Render.Size
						local w = Render:GetTextWidth("Press ' N ' to pick up storage", TextSize.Default * 1.25)
						Render:DrawText(Vector2(screen_size.x - w, screen_size.y * .05), "Press ' N ' to pick up storage", Color(255, 255, 0, 200), TextSize.Default * 1.25)
					end
				elseif currententity:GetValue("Faction") then
					local faction = currententity:GetValue("Faction")
					if faction == LocalPlayer:GetValue("Faction") then
						if tonumber(LocalPlayer:GetValue("FactionRank")) == 3 then
							local screen_size = Render.Size
							local w = Render:GetTextWidth("Press ' N ' to pick up storage", TextSize.Default * 1.25)
							Render:DrawText(Vector2(screen_size.x - w, screen_size.y * .05), "Press ' N ' to pick up storage", Color(255, 255, 0, 200), TextSize.Default * 1.25)
						end
					end
				end
			end
		end
	end
-- END LOOT RENDERING -----------------------
end

function ClientLoot:UltraRender()
	
end

function GetCategoryColorSectionThingHAHA(cat)
	if cat == "Utility" then
		return Color(74,119,255)
	elseif cat == "Raw" then
		return Color(179,119,55)
	elseif cat == "Social" then
		return Color(255,120,235)
	elseif cat == "Weaponry" then
		return Color(200,200,200)
	elseif cat == "Build" then
		return Color(110,255,202)
	elseif cat == "Food" then
		return Color(131,255,110)
	else
		return Color(255,255,255)
	end
end

function ClientLoot:KeyDown(args)
	if args.key == string.byte("G") then
		InventoryOpen = not InventoryOpen
		Mouse:SetVisible(InventoryOpen)
		if InventoryOpen == true then -- opening inventory
			local achs = LocalPlayer:GetValue("Achievements")
			if not achs.ach_openinv or achs.ach_openinv.progress == false then
				Network:Send("Ach_OpenINV")
			end
			Chat:SetEnabled(false)
			screen_size = Render.Size
			for index, lbl in pairs(labels) do
				lbl:SetEnabled(true)
			end
		elseif InventoryOpen == false then -- closing inventory
			current_dropping = nil
			current_dropping_index = nil
			Chat:SetEnabled(true)
			for i = 1, 72 do
				labels[i]:SetVisible(false)
				labels[i]:SetText("")
			end
			local drop_args = {}
			local cats_affected = {}
			local DidDrop = false
			local drop_counter = 0
			for i = 1, 72 do
				if labels[i]:GetDataBool("dropmode") == true then drop_counter = drop_counter + 1 end
			end
			if drop_counter > 4 then
				for i = 1, 72 do
					labels[i]:SetDataBool("dropmode", false)
					labels[i]:SetDataNumber("dropvalue", 0)
				end
				Chat:Print("You can only drop a maximum of 4 items at a time", Color(255, 255, 0))
			end
			if LocalPlayer:InVehicle() then
				for i = 1, 72 do
					labels[i]:SetDataBool("dropmode", false)
					labels[i]:SetDataNumber("dropvalue", 0)
				end
				Chat:Print("You cannot drop items while in a vehicle!",Color.Red)
			end
			for index, lbl in pairs(labels) do
				if lbl:GetDataBool("dropmode") == true then
					local itemstring = GetItemFromInvIndex(index)
					if itemstring ~= nil then
						item_g = GetLootName(itemstring)
						local item_amount = GetLootAmount(itemstring)
						local drop_amount = lbl:GetDataNumber("dropvalue")
						if drop_amount <= item_amount and drop_amount <= stacklimit[item_g] and drop_amount > 0 then
							local cat_index =  GetLocalCategoryIndex(tonumber(lbl:GetName()))
							local new_amount = tostring(item_amount - drop_amount)
							local total_amount = Copy(item_amount)
							if new_amount == "0" then
								inv[reference[item_g]][cat_index] = nil
							else
								inv[reference[item_g]][cat_index] = item_g .. " (" .. new_amount .. ")" -- subtract drop from total
							end
							cats_affected[reference[item_g]] = true
							table.insert(drop_args, item_g .. " (" .. tostring(drop_amount) .. ")") -- item creation occurrence
							DidDrop = true
							ClientLoot:UpdateCryptoInv()
							InventoryChangeEvent()
						else -- hax detected
							if debugOn then Chat:dPrint("HAX DETECTED", Color(255, 0, 0)) end -- works
							for cat_string, bool in pairs(cats_affected) do ShiftCategoryIndexes(cat_string) end
						end
					end
					lbl:SetDataNumber("dropvalue", 0)
					lbl:SetDataBool("dropmode", false)
				end
				lbl:SetEnabled(false)
			end
			for k, v in pairs(drop_args) do
				if debugOn then Chat:dPrint(tostring(k) .. ": " .. tostring(v), Color(0, 255, 0)) end
			end
			local tcount = table.count(drop_args)
			if not numloot_g then numloot_g = table.count(renderloot) end
			if tcount > 0 and tcount <= 4 then
				if IsStorage == true and ShowLoot == true then
					if numloot_g + tcount <= 8 then
-----------------------------------------------------------------------------------------------------------------------------------------------------------					
----------------------------------------- START STORAGE STACKING CODE -------------------------------------------------------------------------------------
						if currentstoragetable then for k, v in pairs(currentstoragetable) do currentstoragetable[k] = nil end end
						currentstoragetable = Copy(renderloot)
						for index, item_string in pairs(drop_args) do
							local item = GetLootName(item_string)
							local text = item_string
							local hasextra = false
							local hasdonetotalfill = false
							local newslot = GetOpenIndex(currentstoragetable)
							local createnew = true
							local number = GetLootAmount(item_string)
							--
							for key, value in pairs(currentstoragetable) do -- value is concatenated lootstring
								local lootitem = GetLootName(value)
								if lootitem == item then -- if same items
									if debugOn then dprint("item match: " .. tostring(value), Color(255, 0, 0)) end
									local amount = GetLootAmount(value) -- amount of existing item
									local total_amount = Copy(amount)
									local amountofexistingitem = amount
									if debugOn then dprint("amount: " .. tostring(amount) .. " ||| stacklimit[lootitem]: " .. tostring(stacklimit[lootitem]), Color(255, 0, 0)) end
									if amount < stacklimit[lootitem] then -- if existing stack is not full
										if debugOn then dprint("amount < stacklimit[lootitem]", Color(255, 0, 0)) end
										amount = amount + number -- current = current + new
										if amount > stacklimit[lootitem] then -- if added stacks are too large (worst case scenario)
											if debugOn then dprint("amount > stacklimit[lootitem]", Color(255, 0, 0)) end
											local availablespace = stacklimit[lootitem] - amountofexistingitem
											if hasdonetotalfill == false then
												currentstoragetable[key] = tostring(item) .. " (" .. tostring(stacklimit[lootitem]) .. ")" -- fill existing slot with as much as can be added
												extra = amount - stacklimit[lootitem] -- this is extra AFTER availablespace has been FILLED with item
												if extra > 0 then hasextra = true end
												if debugOn then Chat:dPrint("Extra: " .. tostring(extra), Color(0, 255, 0)) end
												hasdonetotalfill = true
											end
										else -- if no overload (best case scenario)
											createnew = false
											if debugOn then dprint("no overload - normal fill", Color(255, 0, 0)) end
											if hasextra == true then
												local newamountwithextra = extra + GetLootAmount(value)
												currentstorage[key] = tostring(lootitem) .. " (" .. tostring(newamountwithextra) .. ")" -- need to add extra to current
												if debugOn then dprint("newamountwithextra: " .. newamountwithextra) end
											else
												currentstoragetable[key] = tostring(lootitem) .. " (" .. tostring(amount) .. ")"
											end
											break -- need to break when new slot is created?
										end
									elseif amount >= stacklimit[lootitem] then -- if amount >= stacklimit, if matching item stack is already full
										-- check for extras and add them unless you want all or nothing loot grabs (players would be able to certain numbers of the item and then that would have to be synced - this would be hard because it would not simply by nilling that value, it would be subtracting one)
										createnew = true
										if debugOn then dprint("createnew = true in loop", Color(0, 255, 0)) end
									end
								end 
							end
							-----------------------------
							if createnew == true then
								if debugOn then dprint("createnew = true outside loop", Color(0, 255, 0)) end
								if table.count(currentstoragetable) == 8 then -- check slot count vs. max slot count
									Chat:dPrint("Storage Is Full", Color(255, 34, 34))
									mustreturn = true
									return
								else
									if extra then -- untested - works?
										currentstoragetable[newslot] = GetLootName(text) .. " (" .. tostring(extra) .. ")"
										extra = nil
									else
										currentstoragetable[newslot] = text -- make new slot
									end
									if debugOn then dprint("NEWSLOT THAT LOOT IS BEING ADDED TO: " .. tostring(newslot), Color(0, 255, 0)) end
								end
							end
						end
----------------------------------------- END STORAGE STACKING CODE ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------
						Network:Send("AddToStorage", {item_table = currentstoragetable, id = currententity:GetId(), inventory = inv})
						ClientLoot:UpdateCryptoInv()
						InventoryChangeEvent()
						CloseRenderloot()
						for k, v in pairs(currentstoragetable) do
							if debugOn then dprint(tostring(k) .. ": " .. tostring(v)) end
						end
						for i = 1, 72 do
							labels[i]:SetDataBool("dropmode", false)
							labels[i]:SetDataNumber("dropvalue", 0)
						end
					else
						Chat:Print("Storage is full", Color(255, 255, 0))
						for index, itemstring in pairs(drop_args) do
							ClientLoot:AddToInventory({add_item = GetLootName(itemstring), add_amount = GetLootAmount(itemstring), no_sync = true})
						end
					end
				else
					if LocalPlayer:GetBaseState() == AnimationState.SUprightIdle then
						Network:Send("SpawnDropbox", {spawn_table = drop_args, pos = LocalPlayer:GetPosition(), ang = LocalPlayer:GetAngle(), inventory = inv})
					else
						local ray = Physics:Raycast(LocalPlayer:GetPosition(), LocalPlayer:GetAngle() * Vector3.Down, 0, 1000)
						Network:Send("SpawnDropbox", {spawn_table = drop_args, pos = ray.position, ang = LocalPlayer:GetAngle(), inventory = inv})
					end
					for i = 1, 72 do
						labels[i]:SetDataBool("dropmode", false)
						labels[i]:SetDataNumber("dropvalue", 0)
					end
					for cat_string, bool in pairs(cats_affected) do ShiftCategoryIndexes(cat_string) end
					ClientLoot:UpdateCryptoInv()
					InventoryChangeEvent()
				end
			else
				if DidDrop == false then return end
				if debugOn then Chat:dPrint("Invalid Amount of Item Drops", Color(255, 34, 34)) end
			end
		end
		for i = 1, 72 do
			labels[i]:SetDataBool("dropmode", false)
			labels[i]:SetDataNumber("dropvalue", 0)
		end
	elseif args.key == string.byte("E") and ShowSelection == true then
		if Vector3.Distance(LocalPlayer:GetPosition(), currententity:GetPosition()) > 3.75 then
			ShowSelection = false
			Mouse:SetVisible(false)
			if Game:GetState() == GUIState.Game then
				Mouse:SetPosition(Vector2(screen_size.x * .5, screen_size.y * .505))
			end
			return
		end
		
		if currententity and IsValid(currententity) then
			if currententity:GetValue("STier") then
				local owner = currententity:GetValue("Owner")
				local faction = currententity:GetValue("Faction")
				--if (owner and owner == tostring(LocalPlayer:GetSteamId().id)) or (faction and faction == LocalPlayer:GetValue("Faction")) then
					ShowSelection = false
					ShowLoot = true
					ClientLoot:RenderItems(currententity)
					Mouse:SetVisible(true)
					if Game:GetState() == GUIState.Game then
						Mouse:SetPosition(Vector2(screen_size.x * .5, screen_size.y * .505))
					end
				--else
					--if debugOn then Chat:dPrint("You do not have access to this stash", Color(255, 0, 0)) end
				--end	
			else
				ClientLoot:RenderItems(currententity)
				ShowLoot = true
				ShowSelection = false
				Mouse:SetVisible(true)
				if Game:GetState() == GUIState.Game then
					Mouse:SetPosition(Vector2(screen_size.x * .5, screen_size.y * .505))
				end
			end
		end
	elseif args.key == string.byte("E") and ShowLoot == true then
		CloseRenderloot()
	elseif args.key == string.byte("E") and ShowLoot == false then
		Mouse:SetVisible(false)
	elseif args.key == string.byte("N") then
		if ShowLoot == true and IsStorage == true then
			if currententity and IsValid(currententity) then
				local owner = currententity:GetValue("Owner")
				local faction = currententity:GetValue("Faction")
				if owner and owner == LocalPlayer:GetSteamId().id then
					local drop_args = {}
					local val_table = {}
					for i = 1, 12 do
						local identifier = "L" .. tostring(i)
						local loot_val = currententity:GetValue(identifier)
						if loot_val then
							table.insert(drop_args, loot_val)
						end
					end
					--
					local ray = Physics:Raycast(LocalPlayer:GetPosition(), LocalPlayer:GetAngle() * Vector3.Down, 0, 1000)
					Network:Send("DismountPlayerStorage", {static_id = currententity:GetId(), item_table = drop_args, pos = ray.position})
					Events:Fire("AddToInventory", {add_item = "Garbage Bin", add_amount = 1})
					ShowLoot = false
					ShowSelection = false
					for numindex, label in pairs(loot_label) do label:SetVisible(false) end
					Mouse:SetVisible(false)
					if Game:GetState() == GUIState.Game then
						Mouse:SetPosition(Vector2(screen_size.x * .5, screen_size.y * .505))
					end
				elseif faction and faction == LocalPlayer:GetValue("Faction") and tonumber(LocalPlayer:GetValue("FactionRank")) == 3 then
					local drop_args = {}
					local val_table = {}
					for i = 1, 12 do
						local identifier = "L" .. tostring(i)
						local loot_val = currententity:GetValue(identifier)
						if loot_val then
							table.insert(drop_args, loot_val)
						end
					end
					local ray = Physics:Raycast(LocalPlayer:GetPosition(), LocalPlayer:GetAngle() * Vector3.Down, 0, 1000)
					Network:Send("DismountFactionStorage", {static_id = currententity:GetId(), item_table = drop_args, pos = ray.position})
					ShowLoot = false
					ShowSelection = false
					for numindex, label in pairs(loot_label) do label:SetVisible(false) end
					Mouse:SetVisible(false)
					if Game:GetState() == GUIState.Game then
						Mouse:SetPosition(Vector2(screen_size.x * .5, screen_size.y * .505))
					end
				end
			end
		end
	end
end

function ClientLoot:LocalPlayerInput(args)
	if args.input == Action.FireGrapple then
		if LocalPlayer:GetValue("Equipped_Grapple") == "Grapplehook" 
		or LocalPlayer:GetValue("Equipped_Grapple") == "Super Grapple" then
			Game:FireEvent("ply.grappling.enable")
		else
			Game:FireEvent("ply.grappling.disable")
			return false
		end
	elseif args.input == Action.ParachuteOpenClose or args.input == Action.DeployParachuteWhileReelingAction then
		if LocalPlayer:GetValue("Equipped_Parachute") ~= "Parachute" then
			return false
		end
	elseif LocalPlayer:GetBaseState() == AnimationState.SParachute 
	and LocalPlayer:GetValue("Equipped_Parachute") ~= "Parachute" then
		LocalPlayer:SetBaseState(AnimationState.SSkydive)
	end
	--
	if InventoryOpen == true then
		if args.input == Action.FireLeft or args.input == Action.FireRight or args.input == Action.McFire or args.input == Action.LookDown or args.input == Action.LookLeft or args.input == Action.LookRight or args.input == Action.LookUp then
			return false
		end
	end
	--
	if ShowLoot == true then
		if args.input == Action.FireLeft or args.input == Action.FireRight 
		or args.input == Action.McFire or args.input == Action.LookDown 
		or args.input == Action.LookLeft or args.input == Action.LookRight 
		or args.input == Action.LookUp then
			return false
		elseif args.input == Action.MoveBackward or
		args.input == Action.MoveForward or
		args.input == Action.MoveLeft or
		args.input == Action.MoveRight then
			if debugOn then Chat:dPrint("false", Color.Red) end
			CloseRenderloot()
			Mouse:SetVisible(false)
		end
	end
end

function ClientLoot:OverWriteEquipped(args) -- receives new
	equipped = nil
	equipped = args.new
end

function ClientLoot:LootTake(clicked_label)
	local reference_num = tonumber(clicked_label:GetName())
-- START INV STACKING LOGIC ----------
	local item = GetLootName(renderloot[reference_num])
	local category = reference[item]
	local newslot = GetOpenSlot(category)
	local catslotcount = table.count(inv[category])
	local number = GetLootAmount(renderloot[reference_num])
	if CanAddItem(item, number, category) == false then
		Chat:Print("Inventory category is full", Color(255, 255, 0, 200))
		return
	end
	clicked_label:SetVisible(false)
	--
	ClientLoot:AddToInventory({add_item = item, add_amount = number, no_sync = true}) -- no_sync because inventory is sent with other NetSend
-- END INV STACKING LOGIC ----------
	renderloot[reference_num] = nil
	local total_index = 0
	if IsStorage == true then
		total_index = 12
	else
		total_index = 12
	end
	Network:Send("DeleteLootFromWNO", {index = reference_num, id = currententity:GetId(), max_index = total_index, inventory = inv})
	-- update renderloot to match server-side renderloot
	if reference_num == total_index then return end
	for index, label in pairs(loot_label) do
		label:SetVisible(false)
		label:SetText("")
	end
	for i = reference_num, total_index do
		renderloot[i] = renderloot[i + 1] -- shift indexes
	end
	numloot_g = table.count(renderloot) -- global
	local start_pos = Vector2(screen_size.x * .5 - (L1:GetWidth() / 2), screen_size.y * .5 - (L1:GetHeight() * 1.3))
	for i = 1, numloot_g do
		local label = loot_label[i]
		label:SetText(tostring(renderloot[i]))
		label:SetVisible(true)
		label:SetPosition(start_pos)
		--
		start_pos.y = start_pos.y - (label:GetSize().y * 1.1)
	end
	if #renderloot == 0 then Mouse:SetVisible(false) end
	for k, v in pairs(renderloot) do
		if debugOn then dprint(tostring(k) .. ": " .. tostring(v)) end
	end
end

function ClientLoot:LootHoverEnter(hovered_label)
	current_loot_hover = hovered_label
end

function ClientLoot:LootHoverLeave(unhovered_label)
	current_loot_hover = 34
	Mouse:SetCursor(0)
end

function ClientLoot:LootHoverEnter2(hovered_label)
	current_loot_hover2 = hovered_label
end

function ClientLoot:LootHoverLeave2(unhovered_label)
	current_loot_hover2 = nil
	Mouse:SetCursor(0)
end

function ClientLoot:DeleteFromInventory(args) -- receives sub_item and sub_amount -OR- args.itable in form table[sub_item] = sub_amount .. optional arg: no_sync = true or nil
	if not args.itable then -- single remove
		local category = reference[args.sub_item]
		local isub = Copy(args.sub_amount)
		for index, lootstring in pairs(inv[category]) do
			local item = GetLootName(lootstring)
			if item == args.sub_item then
				local original_amount = GetLootAmount(lootstring)
				while isub ~= 0 do
					if original_amount - 1 == 0 then
						inv[category][index] = nil
						isub = isub - 1
						break
					else
						inv[category][index] = item .. " (" .. tostring(original_amount - 1) .. ")" -- subtract one by one
						isub = isub - 1
						original_amount = original_amount - 1
					end
				end
			end
			if isub == 0 then break end
		end
		if isub > 0 and debugOn then Chat:dPrint("Error in Delete From Inventory: Tried to subtract too much", Color(255, 255, 0)) end
		ShiftCategoryIndexes(category) -- adjust indexes
	else -- multiple remove
		for sub_item, sub_amount in pairs(args.itable) do
			if debugOn then Chat:dPrint(tostring(sub_item) .. " || " .. tostring(sub_amount), Color(255, 0, 255)) end
			local category = reference[sub_item]
			local isub = Copy(sub_amount)
			for index, lootstring in pairs(inv[category]) do
				local item = GetLootName(lootstring)
				if item == sub_item then
					local original_amount = GetLootAmount(lootstring)
					while isub ~= 0 do
						if original_amount - 1 == 0 then
							inv[category][index] = nil
							isub = isub - 1
							break
						else
							inv[category][index] = item .. " (" .. tostring(original_amount - 1) .. ")" -- subtract one by one
							isub = isub - 1
							original_amount = original_amount - 1
						end
					end
				end
				if isub == 0 then break end
			end
			ShiftCategoryIndexes(category) -- adjust indexes
		end
	end
	if not args.no_sync then
		Network:Send("SyncInventory", {inventory = inv}) -- sync inventory
	end
	ClientLoot:UpdateCryptoInv()
	InventoryChangeEvent()
end

function ClientLoot:AddToInventory(args) -- receives add_item and add_amount -OR- args.itable in form table[add_item] = add_amount .. optional arg - no_sync = true or nil
	if not args.itable then
		local category = reference[args.add_item]
		local iadd = Copy(args.add_amount)
		for index, lootstring in pairs(inv[category]) do
			local item = GetLootName(lootstring)
			if item == args.add_item then
				local original_amount = GetLootAmount(lootstring)
				while iadd ~= 0 do
					if original_amount >= stacklimit[item] then
						break
					else
						original_amount = original_amount + 1
						iadd = iadd - 1
						inv[category][index] = item .. " (" .. tostring(original_amount) .. ")" -- add one by one
					end
				end
			end
			if iadd == 0 then break end
		end
		ShiftCategoryIndexes(category) -- adjust indexes
		if iadd > 0 then -- if has iterated and no existing package can be added to and still amount left to add
			local openslot = GetOpenSlot(category)
			while openslot ~= 34 and iadd > 0 do
				original_amount = 0
				while iadd ~= 0 do
					if original_amount >= stacklimit[args.add_item] then
						break
					else
						original_amount = original_amount + 1
						iadd = iadd - 1
						inv[category][openslot] = args.add_item .. " (" .. tostring(original_amount) .. ")" -- add one by one
					end
				end
				ShiftCategoryIndexes(category)
				openslot = GetOpenSlot(category)
			end
		end
		ShiftCategoryIndexes(category) -- adjust indexes
		-- DROPBOX SPAWN ON OVERLOAD CODE
		--if iadd > 0 then
			--Chat:dPrint("Inventory Overload - dropping on the ground", Color(255, 255, 0))
			--local ray = Physics:Raycast(LocalPlayer:GetPosition(), LocalPlayer:GetAngle() * Vector3.Down, 0, 1000)
			--local drop_args = {}
			--item_count = 0
			--while iadd > 0 do
			--	if not drop_args[item_count] then
			--		item_count = item_count + 1
			--		drop_args[item_count] = args.add_item .. " (" .. 1 .. ")"
			--		iadd = iadd - 1
			--	elseif drop_args[item_count] then
			--		local amount = GetLootAmount(drop_args[item_count])
			--		if amount < stacklimit[args.add_item] then
			--			amount = amount + 1
			--			drop_args[item_count] = args.add_item .. " (" .. amount .. ")"
			--			iadd = iadd - 1
			--		else
			--			item_count = item_count + 1
			--			drop_args[item_count] = args.add_item .. " (" .. 1 .. ")"
			--			iadd = iadd - 1
			--		end
			--	end
			--end
			--Network:Send("SpawnDropbox", {spawn_table = drop_args, pos = ray.position, inventory = inv})
		--end
		--
	else -- if multiple add
		for add_item, add_amount in pairs(args.itable) do
			local category = reference[add_item]
			local iadd = Copy(add_amount)
			for index, lootstring in pairs(inv[category]) do
				local item = GetLootName(lootstring)
				if item == add_item then
					local original_amount = GetLootAmount(lootstring)
					while iadd ~= 0 do
						if original_amount >= stacklimit[item] then
							break
						else
							original_amount = original_amount + 1
							iadd = iadd - 1
							inv[category][index] = item .. " (" .. tostring(original_amount) .. ")" -- add one by one
						end
					end
				end
				if iadd == 0 then break end
			end
			--
			if iadd > 0 then -- if has iterated and no existing package can be added to and still amount left to add
			local openslot = GetOpenSlot(category)
			while openslot ~= 34 and iadd > 0 do
				original_amount = 0
				while iadd ~= 0 do
					if original_amount >= stacklimit[add_item] then
						break
					else
						original_amount = original_amount + 1
						iadd = iadd - 1
						inv[category][openslot] = add_item .. " (" .. tostring(original_amount) .. ")" -- add one by one
					end
				end
				ShiftCategoryIndexes(category)
				openslot = GetOpenSlot(category)
			end
		end	
		ShiftCategoryIndexes(category) -- adjust indexes
		end
	end
	if not args.no_sync then
		Network:Send("SyncInventory", {inventory = inv}) -- sync inventory
	end
	ClientLoot:UpdateCryptoInv()
	InventoryChangeEvent()
end

function ClientLoot:UpdateSharedObjectInventory()
	local so = SharedObject.GetByName("ClientSharedInventory")
	so:SetValue("INV", nil)
	so:SetValue("INV", inv)
end

function ClientLoot:UpdateClientEquipped()
	local so = SharedObject.GetByName("ClientEquipped")
	so:SetValue("Equipped", nil)
	so:SetValue("Equipped", equipped)
end
function IKnowYouHateTheseTypesOfNames(level) --death drop generator
	local deathDrop = {} --table with items the person will lose
	local items = {} --table of all items person has
	local itemIndexes = {} --for shifting the items in the category
    for category_string, loot_table in pairs(inv) do
        if type(loot_table) == "table" then
            for numindex, lootstring in pairs(loot_table) do
				table.insert(items, lootstring) --add all items in big table
				table.insert(itemIndexes, numindex) --add all indexes to table
			end
		end
	end
	if #items <= 1 + math.floor(level / 20) and #items > 0 then
		for index, item in pairs(items) do
			Events:Fire("DeleteFromInventory", {sub_item = GetLootName(item), sub_amount = GetLootAmount(item)})
			local category = reference[GetLootName(item)]
			ShiftCategoryIndexes(category)
			table.insert(deathDrop, item) --add to deathdrop
			items[index] = nil --remove from inv table so that we dont use it again
			Chat:Print("Dropping "..item, Color.Orange) --tell the player what they dropped
		end
	else
		for i = 1, 1 + math.floor(level / 20) do --equation for calculating death drop amt
			local item = table.randomvalue(items) --get random item from inv
			if item then
				local index = 0 --because table.remove is dumb we have to find the index
				local category = reference[GetLootName(item)]
				for _, lootstring in pairs(items) do
					if lootstring == item then index = _ end
				end
				Events:Fire("DeleteFromInventory", {sub_item = GetLootName(item), sub_amount = GetLootAmount(item)})
				ShiftCategoryIndexes(category)
				table.insert(deathDrop, item) --add to deathdrop
				items[index] = nil --remove from inv table so that we dont use it again
				Chat:Print("Dropping "..item, Color.Orange) --tell the player what they dropped
			end
		end
	end
	return deathDrop
end
function ClientLoot:PlayerDeath()
	if Suicide == true then
		Suicide = false
		return
	end
    local level = tonumber(LocalPlayer:GetValue("Level"))
    if not level then level = 1 end
    if level < 10 then return end
    --local death_drop = {}
    local death_drop = IKnowYouHateTheseTypesOfNames(level)
    --[[local drop_chance
    local stack_mod
	-- Why do you make this so complex?
    if level < 20 then
        drop_chance = 20
        stack_mod = 2.0
    elseif level < 40 then
        drop_chance = 22
        stack_mod = 1.9
    elseif level < 60 then
        drop_chance = 24
        stack_mod = 1.8
    elseif level < 70 then
        drop_chance = 26
        stack_mod = 1.7
    elseif level < 90 then
        drop_chance = 28
        stack_mod = 1.6
    elseif level < 110 then
        drop_chance = 30
        stack_mod = 1.5
    elseif level < 130 then
        drop_chance = 32
        stack_mod = 1.4
    elseif level < 150 then
        drop_chance = 34
        stack_mod = 1.3
    elseif level < 170 then
        drop_chance = 35
        stack_mod = 1.2
    elseif level < 190 then
        drop_chance = 36
        stack_mod = 1.1
    elseif level < 200 then
        drop_chance = 38
        stack_mod = 1.05
    end
    local ray = Physics:Raycast(LocalPlayer:GetPosition(), LocalPlayer:GetAngle() * Vector3.Down, 0, 1000)
    --
    for category_string, loot_table in pairs(inv) do
        if type(loot_table) == "table" then
            for numindex, itemloot in pairs(loot_table) do
                if #death_drop < 5 then
                    local rand = math.random(1, math.floor((100 / drop_chance) + .5))
                    if rand == 1 then -- 33% chance of dropping a part of an item
                        local item = GetLootName(itemloot)
                        local amount = GetLootAmount(itemloot)
						local total_amount = Copy(amount)
                        local dropmax = math.floor(amount / stack_mod)
                        if dropmax == 0 then dropmax = 1 end
                        rand = math.random(1, dropmax) -- drop between 1 -> 50% of stack
                        amount = amount - rand
                        if amount == 0 then
                            inv[category_string][numindex] = nil
                            ShiftCategoryIndexes(category_string)
                        else
                            inv[category_string][numindex] = item .. " (" .. amount .. ")"
                        end
                        table.insert(death_drop, item .. " (" .. rand .. ")")
						Chat:Print("Dropping " .. tostring(item) .. " (" .. tostring(rand) .. ")", Color.Orange)
                    end
                end
            end
        end
    end--]]
	local ray = Physics:Raycast(LocalPlayer:GetPosition() + Vector3.Up, LocalPlayer:GetAngle() * Vector3.Down, 0, 1000)
	if table.count(death_drop) > 0 then --if theres actually items in the deathdrop
		Network:Send("SpawnDropbox", {spawn_table = death_drop, pos = ray.position, inventory = inv})
		ClientLoot:UpdateCryptoInv()
		InventoryChangeEvent()
	end
    for i = 1, 72 do
		labels[i]:SetDataBool("dropmode", false)
		labels[i]:SetDataNumber("dropvalue", 0)
	end
	Events:Fire("DeathDropFinderPos", ray.position)
    ClientLoot:UpdateCryptoInv()
	InventoryChangeEvent()
end
function ClientLoot:ModuleUnload()
	for index, obj in pairs(storages) do
		if IsValid(obj) and tostring(obj) == "ClientStaticObject" then
			obj:Remove()
		end
	end
end

------ START CONVENIENCE FUNCTIONS ----------------------------------
function CloseRenderloot()
	ShowLoot = false
	ShowSelection = false
	for numindex, label in pairs(loot_label) do label:SetVisible(false) end
	Mouse:SetVisible(false)
	if Game:GetState() == GUIState.Game then
		Mouse:SetPosition(Vector2(screen_size.x * .5, screen_size.y * .505))
	end
	for i = 1, 72 do
		labels[i]:SetDataBool("dropmode", false)
		labels[i]:SetDataNumber("dropvalue", 0)
	end
	for k, v in pairs(renderloot) do
		renderloot[k] = nil
	end
end

function CheckInvOverflow()
	local drops = {}
	local drops2 = {}
	local drops3 = {}
	for category, loot_table in pairs(inv) do
		if #loot_table > categoryslotmaxes[category] then
			local overflow_count = #loot_table - categoryslotmaxes[category]
			for i = 1, overflow_count do
				table.insert(drops, inv[category][i])
				ClientLoot:DeleteFromInventory({sub_item = GetLootName(inv[category][i]), sub_amount = GetLootAmount(inv[category][i]), no_sync = true})
			end
		end
	end
	
	local num_drops = #drops
	
	if num_drops > 4 then
		for i = 5, num_drops do 
			if i < 8 then
				table.insert(drops2, drops[i])
			elseif i < 12 then
				table.insert(drops3, drops[i])
			end
		end
	end
	
	if #drops > 4 then
		for i = 5, #drops do
			drops[i] = nil
		end
	end
	
	if #drops > 0 then
		Chat:Print("Inventory Overflow, dropping items", Color(255, 0, 0))
		local ray = Physics:Raycast(LocalPlayer:GetPosition(), LocalPlayer:GetAngle() * Vector3.Down, 0, 1000)
		Network:Send("SpawnDropbox", {spawn_table = drops, pos = ray.position, ang = Angle(0, 0, 0), inventory = inv})
		RecalculateCSM()
		if InventoryOpen == true then
			ClientLoot:KeyDown({key = string.byte("G")})
		end
	end
	if #drops2 > 0 then
		local ray = Physics:Raycast(LocalPlayer:GetPosition(), LocalPlayer:GetAngle() * Vector3.Down, 0, 1000)
		Network:Send("SpawnDropbox", {spawn_table = drops2, pos = ray.position + Vector3(0, .75, 0), ang = Angle(0, 0, 0), inventory = inv})
		RecalculateCSM()
	end
	if #drops3 > 0 then
		local ray = Physics:Raycast(LocalPlayer:GetPosition(), LocalPlayer:GetAngle() * Vector3.Down, 0, 1000)
		Network:Send("SpawnDropbox", {spawn_table = drops3, pos = ray.position + Vector3(0, 1.25, 0), ang = Angle(0, 0, 0), inventory = inv})
		RecalculateCSM()
	end
end

function CanAddItem(item, number, category)
	if table.count(inv[category]) < categoryslotmaxes[category] then return true end
	for index, lootstring in pairs(inv[category]) do
		if GetLootName(lootstring) == item then
			if GetLootAmount(lootstring) + number <= stacklimit[item] then
				return true
			end
		end
	end
	return false
end

function DetermineRarityColor(lootstring)
	local number = tonumber(string.match(lootstring, '%d+'))
	if number < 10 then
		item = string.sub(lootstring, 1, string.len(lootstring) - 4)
	elseif number >= 10 then
		item = string.sub(lootstring, 1, string.len(lootstring) - 5)
	elseif number >= 100 then
		item = string.sub(lootstring, 1, string.len(lootstring) - 6)
	elseif number >= 1000 then
		item = string.sub(lootstring, 1, string.len(lootstring) - 7)
	end
	local tier = rarity[item]
	if not tier then return end
	return raritycolor[tier]
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

function GetOpenSlot(icategory)
	local openindex = 34
	for i = 1, categoryslotmaxes[icategory] do -- iterate until not nil
		if inv[icategory][i] == nil then
			openindex = i
			return openindex
		end
	end
	if openindex == 34 then -- do flag check on receive function argument
		if debugOn then dprint("openindex: 34") end
		return openindex
	end
end

function GetOpenIndex(itable) -- receives table
	local openindex = 34
	for i = 1, 12 do -- iterate until not nil
		if itable[i] == nil then
			openindex = i
			if debugOn then dprint("openindex: " .. tostring(openindex)) end
			return openindex
		end
	end
	if openindex == 34 then -- do flag check on receive function argument
		if debugOn then dprint("openindex: 34") end
		return openindex
	end
end

function GetItemFromInvIndex(index)
	local cat_index
	if index <= 12 then
		cat_index = 1
	elseif index <= 24 then
		cat_index = 2
	elseif index <= 36 then
		cat_index = 3
	elseif index <= 48 then
		cat_index = 4
	elseif index <= 60 then
		cat_index = 5
	elseif index <= 72 then
		cat_index = 6
	end
	return inv[ref_cat_names[cat_index]][((index - (cat_index * 12))) + 12]
end

function GetGlobalIndex(index)
	local cat_index
	if index <= 12 then
		return index
	elseif index <= 24 then
		cat_index = 1
	elseif index <= 36 then
		cat_index = 2
	elseif index <= 48 then
		cat_index = 3
	elseif index <= 60 then
		cat_index = 4
	elseif index <= 72 then
		cat_index = 5
	end
	return index + (cat_index * 12)
end

function GetLocalCategoryIndex(index)
	local cat_index
	if index <= 12 then
		cat_index = 1
	elseif index <= 24 then
		cat_index = 2
	elseif index <= 36 then
		cat_index = 3
	elseif index <= 48 then
		cat_index = 4
	elseif index <= 60 then
		cat_index = 5
	elseif index <= 72 then
		cat_index = 6
	end
	return (index - (cat_index * 12)) + 12
end

function ShiftCategoryIndexes(category_name)
	local counter = 1
	for old_index, lootstring in pairs(inv[category_name]) do
		inv[category_name][old_index] = nil
		inv[category_name][counter] = lootstring
		counter = counter + 1
	end
	-- auto sort inventory here
end

function FormatSQL(val_table) -- receives 1 table
	local s = ""
	for index, lootstring in pairs(val_table) do
		local item = GetLootName(lootstring)
		if reference[item] then
			s = s .. SQLFormat[item] .. GetLootAmount(lootstring) .. "."
		end
	end
	ReverseFormatSQL(s)
	return s
end

function ReverseFormatSQL(s)
	local t = {}
	local s_split = string.split(s, ".")
	for k, v in pairs(s_split) do
		if string.len(v) > 0 then
			local num = tonumber(string.match(v, '%d+'))
			local item = table.find(SQLFormat, string.gsub(v, num, ""))
			table.insert(t, item .. " (" .. num .. ")")
		end
	end
	if debugOn then dprint("-- start reverse format --") end
	for k, v in pairs(t) do
		if debugOn then dprint(v) end
	end
end

function GetAmmo()
	local ammo_count = 0
	for index, lootstring in pairs(inv["Utility"]) do
		if GetLootName(lootstring) == "Ammo" then
			ammo_count = ammo_count + GetLootAmount(lootstring)
		end
	end
	return ammo_count
end

function GetItemCount(item)
	local count = 0
	for index, lootstring in pairs(inv[reference[item]]) do
		if GetLootName(lootstring) == item then
			count = count + GetLootAmount(lootstring)
		end
	end
	return count
end

function RecalculateCSM()
	local level = tonumber(LocalPlayer:GetValue("Level"))
	if not level then level = 1 end
	if level < 5 then
		categoryslotmaxes["Food"] = 3
		categoryslotmaxes["Weaponry"] = 3
		categoryslotmaxes["Build"] = 2
		categoryslotmaxes["Utility"] = 3
		categoryslotmaxes["Raw"] = 7
		categoryslotmaxes["Social"] = 2
	elseif level < 10 then
		categoryslotmaxes["Food"] = 4
		categoryslotmaxes["Weaponry"] = 4
		categoryslotmaxes["Build"] = 3
		categoryslotmaxes["Utility"] = 4
		categoryslotmaxes["Raw"] = 7
		categoryslotmaxes["Social"] = 3
	elseif level < 15 then
		categoryslotmaxes["Food"] = 5
		categoryslotmaxes["Weaponry"] = 4
		categoryslotmaxes["Build"] = 3
		categoryslotmaxes["Utility"] = 5
		categoryslotmaxes["Raw"] = 8
		categoryslotmaxes["Social"] = 4
	elseif level < 20 then
		categoryslotmaxes["Food"] = 5
		categoryslotmaxes["Weaponry"] = 5
		categoryslotmaxes["Build"] = 4
		categoryslotmaxes["Utility"] = 5
		categoryslotmaxes["Raw"] = 8
		categoryslotmaxes["Social"] = 5
	elseif level < 25 then
		categoryslotmaxes["Food"] = 6
		categoryslotmaxes["Weaponry"] = 5
		categoryslotmaxes["Build"] = 5
		categoryslotmaxes["Utility"] = 6
		categoryslotmaxes["Raw"] = 9
		categoryslotmaxes["Social"] = 5
	elseif level <= 30 then
		categoryslotmaxes["Food"] = 6
		categoryslotmaxes["Weaponry"] = 6
		categoryslotmaxes["Build"] = 5
		categoryslotmaxes["Utility"] = 6
		categoryslotmaxes["Raw"] = 9
		categoryslotmaxes["Social"] = 6
	elseif level <= 35 then
		categoryslotmaxes["Food"] = 7
		categoryslotmaxes["Weaponry"] = 6
		categoryslotmaxes["Build"] = 5
		categoryslotmaxes["Utility"] = 7
		categoryslotmaxes["Raw"] = 10
		categoryslotmaxes["Social"] = 6
	elseif level <= 40 then
		categoryslotmaxes["Food"] = 7
		categoryslotmaxes["Weaponry"] = 7
		categoryslotmaxes["Build"] = 6
		categoryslotmaxes["Utility"] = 7
		categoryslotmaxes["Raw"] = 10
		categoryslotmaxes["Social"] = 7
	elseif level <= 45 then
		categoryslotmaxes["Food"] = 8
		categoryslotmaxes["Weaponry"] = 7
		categoryslotmaxes["Build"] = 6
		categoryslotmaxes["Utility"] = 8
		categoryslotmaxes["Raw"] = 11
		categoryslotmaxes["Social"] = 7
	elseif level <= 50 then
		categoryslotmaxes["Food"] = 8
		categoryslotmaxes["Weaponry"] = 8
		categoryslotmaxes["Build"] = 7
		categoryslotmaxes["Utility"] = 8
		categoryslotmaxes["Raw"] = 11
		categoryslotmaxes["Social"] = 8
	elseif level <= 100 then
		categoryslotmaxes["Food"] = 9
		categoryslotmaxes["Weaponry"] = 9
		categoryslotmaxes["Build"] = 8
		categoryslotmaxes["Utility"] = 9
		categoryslotmaxes["Raw"] = 12
		categoryslotmaxes["Social"] = 9
	elseif level <= 110 then
		categoryslotmaxes["Food"] = 10
		categoryslotmaxes["Weaponry"] = 10
		categoryslotmaxes["Build"] = 10
		categoryslotmaxes["Utility"] = 9
		categoryslotmaxes["Raw"] = 12
		categoryslotmaxes["Social"] = 10
	elseif level <= 120 then
		categoryslotmaxes["Food"] = 10
		categoryslotmaxes["Weaponry"] = 10
		categoryslotmaxes["Build"] = 11
		categoryslotmaxes["Utility"] = 11
		categoryslotmaxes["Raw"] = 12
		categoryslotmaxes["Social"] = 11
	else
		categoryslotmaxes["Food"] = 12
		categoryslotmaxes["Weaponry"] = 12
		categoryslotmaxes["Build"] = 12
		categoryslotmaxes["Utility"] = 12
		categoryslotmaxes["Raw"] = 12
		categoryslotmaxes["Social"] = 12
	end
	--
	local backpack_val = LocalPlayer:GetValue("SOCIAL_Back")
	if backpack_val then
		if backpack_val == "Backpack" then
			for name, maxes in pairs(categoryslotmaxes) do
				categoryslotmaxes[name] = categoryslotmaxes[name] + 2
			end
			current_backpack = "Backpack"
		elseif backpack_val == "Pocketed Vest" then
			for name, maxes in pairs(categoryslotmaxes) do
				categoryslotmaxes[name] = categoryslotmaxes[name] + 1
			end
			current_backpack = "Pocketed Vest"
		else
			current_backpack = ""
		end
	end
	
	for cat, max in pairs(categoryslotmaxes) do
		if max > 12 then categoryslotmaxes[cat] = 12 end
	end
	
	CheckInvOverflow()
	LocalPlayer:SetValue("CatMaxes", categoryslotmaxes)
end

function InventoryChangeEvent() -- function is called when inv is legitimately changed

end
------ END CONVENIENCE FUNCTIONS ------------------------------------
--
------ START GUI FUNCTIONS ------------------------------------------
function ClientLoot:LootLabelPress(lbl)
	local item = GetItemFromInvIndex(tonumber(lbl:GetName()))
	--Chat:Print("Item in label: " .. tostring(item), Color(0, 255, 0))
	if item == nil then
		lbl:SetDataBool("dropmode", false)
		lbl:SetDataNumber("dropvalue", 0)
		return
	end
	if debugOn then Chat:dPrint("Item: " .. tostring(item), Color(0, 255, 0)) end
	if lbl:GetDataBool("dropmode") == true then
		local dropvalue = lbl:GetDataNumber("dropvalue")
		if dropvalue < stacklimit[GetLootName(item)] and dropvalue < GetLootAmount(item) then
			dropvalue = dropvalue + 1
			lbl:SetDataNumber("dropvalue", dropvalue)
			current_dropping = lbl
			current_dropping_index = tonumber(lbl:GetName())
		else
			lbl:SetDataNumber("dropvalue", 1)
		end
		if debugOn then Chat:dPrint("dropvalue: " .. tostring(dropvalue), Color(0, 255, 0)) end
	else
		-- START ITEM LEFT-CLICK CODE
		local item_name = GetLootName(item)
		if LocalPlayer:GetValue("TradeMode") == true then -- if player is in trade menu
			Events:Fire("AddToTrade", {add_item = item_name})
		else
			local split = item_name:split(" ")
			local amt = 0
			for i=1, #vNames do
				if amt < #split and item_name ~= "Silver" then
					for j = 1, #split do
						if string.find(vNames[i], split[j]) then
							amt = amt + 1
						end
					end
					if amt == #split then
						Events:Fire("V_PlaceVehicleFromItem", item_name) --place a vehicle
					else
						amt = 0
					end
				end
			end
			if reference[item_name] == "Food" then
				if string.find(item_name, "Drug") then
					Events:Fire("UseDrug", item_name)
				end
				Events:Fire("HT_Consume", item_name) --eat food
			end
			if item_name == "Garbage Bin" then
				if LocalPlayer:GetValue("is_editing") == false then
					Events:Fire("EditMode", {type = "gbin"})
				end
			elseif item_name == "Faction Storage" then
				if LocalPlayer:GetValue("is_editing") == false then
					Events:Fire("EditMode", {type = "Faction Storage"})
				end
			elseif item_name == "Faction Guard" then
				if LocalPlayer:GetValue("is_editing") == false then
					if LocalPlayer:GetValue("InFactionBase") and LocalPlayer:GetValue("InFactionBase") == LocalPlayer:GetValue("Faction") then
						Events:Fire("EditMode", {type = "Faction Guard"})
					else
						Chat:dPrint("You must be in your faction base to use", Color(255, 255, 0))
					end
				end
			elseif item_name == "(F) Missile Turret" then
				if LocalPlayer:GetValue("is_editing") == false then
					if LocalPlayer:GetValue("InFactionBase") and LocalPlayer:GetValue("InFactionBase") == LocalPlayer:GetValue("Faction") then
						Events:Fire("EditMode", {type = "Missile Turret"})
					else
						Chat:dPrint("You must be in your faction base to use", Color(255, 255, 0))
					end
				end
			elseif item_name == "Companion Key" then
				Events:Fire("Pets_UseCompanionKey")
			elseif guns[item_name] then -- if weapon
				if LocalPlayer:GetValue("CurrentWeapon") ~= item_name then
					ClientLoot:UnequipItem(LocalPlayer:GetValue("CurrentWeapon"))
					LocalPlayer:SetValue("CurrentWeapon", item_name)
					ClientLoot:EquipItem(item_name)
				else
					ClientLoot:UnequipItem(item_name)
					LocalPlayer:SetValue("CurrentWeapon", "")
				end
			elseif item_name == "Vehicle Repair" then
				Events:Fire("AttemptVehicleRepair")
			elseif item_name == "Plastic Surgery Kit" then
				Events:Fire("UsePlasticSurgeryKit")
			elseif item_name == "Bandage" then
				Events:Fire("UseBandage")
				self:KeyDown({key = string.byte("G")})
			elseif item_name == "Death Drop Finder" then
				Events:Fire("UseDeathDropFinder")
				self:KeyDown({key = string.byte("G")})
			elseif item_name == "Med-Kit" then
				Events:Fire("UseMed-Kit")
				self:KeyDown({key = string.byte("G")})
			elseif item_name == "Full Restore" then
				Events:Fire("UseFullRestore")
				self:KeyDown({key = string.byte("G")})
			elseif item_name == "Small Build Heal" then
				Events:Fire("UseSmallBuildHeal")
			elseif item_name == "Medium Build Heal" then
				Events:Fire("UseMediumBuildHeal")
			elseif item_name == "Large Build Heal" then
				Events:Fire("UseLargeBuildHeal")
			elseif item_name == "Mine" then
				Events:Fire("PlaceMine")
				self:KeyDown({key = string.byte("G")})
			elseif item_name == "Hellfire" then
				Events:Fire("UseHellfire")
				self:KeyDown({key = string.byte("G")})
			elseif item_name == "Implosion Trap" then
                Events:Fire("INuke_Place", item_name)
                self:KeyDown({key = string.byte("G")})
			elseif string.find(item_name, "Car Trap") then
				Events:Fire("UseVehicleTrapItem", item_name)
			elseif item_name == "Vehicle Shield" then
				Events:Fire("UseVehicleShieldItem")
			elseif string.find(item_name, "Property Claim") then
				Events:Fire("LC_TryToPlace", item_name)
			elseif string.find(item_name, "Empty Gas Can") or string.find(item_name, "Filled Gas Can") then
				Events:Fire("UseGasItem", item_name)
			elseif item_name == "Parachute" or item_name == "Grapplehook" 
			or item_name == "Portal Gun" or item_name == "Super Grapple" or item_name == "Rope" then
				Network:Send("EquipOther", item_name)
			end
			if reference[item_name] == "Build" or item_name == "Mortar" then
				Events:Fire("LC_UseBuildItemCheck", item_name)
			end
			if reference[item_name] == "Social" then
				Events:Fire("SOCIAL_CheckItemUse", item_name)
			end
			--ClientLoot:KeyDown({key = string.byte("G")})
			--ClientLoot:KeyDown({key = string.byte("G")})
		end
		-- END ITEM LEFT-CLICK CODE
	end
end

function ClientLoot:EquipItem(item_name)
	if guns[item_name] then
		Network:Send("EquipItem", {gun_name = item_name, gun_id = guns[item_name], ply_equipped = equipped, ammo = GetAmmo()})
	end
end

function ClientLoot:UnequipItem(item_name)
	if guns[item_name] then
		Network:Send("UnequipItem", {ply_equipped = equipped})
	end
end

function ClientLoot:LootLabelRightPress(lbl)
	local item = GetItemFromInvIndex(tonumber(lbl:GetName()))
	if LocalPlayer:GetValue("TradeMode") ~= true then
		local dropmode_bool = lbl:GetDataBool("dropmode")
		if dropmode_bool == false then
			lbl:SetDataBool("dropmode", true)
			lbl:SetDataNumber("dropvalue", GetLootAmount(item)) -- initialize to 1
			current_dropping = lbl
			current_dropping_index = tonumber(lbl:GetName())
		elseif dropmode_bool == true then
			local dropvalue = lbl:GetDataNumber("dropvalue")
			if dropvalue > 1 then
				dropvalue = dropvalue - 1
				lbl:SetDataNumber("dropvalue", dropvalue)
				current_dropping = lbl
				current_dropping_index = tonumber(lbl:GetName())
			else -- 1 -> 0
				lbl:SetDataBool("dropmode", false)
				lbl:SetDataNumber("dropvalue", 0)
				current_dropping = nil
				current_dropping_index = nil
			end
			if debugOn then Chat:dPrint("dropvalue: " .. tostring(dropvalue), Color(0, 255, 0)) end
		end
	else -- trade right-click
		Events:Fire("SubtractFromTrade", {sub_item = GetLootName(item)})
	end
end

function ClientLoot:MouseScroll(args)
	if current_dropping and current_dropping_index then
		local item = GetItemFromInvIndex(current_dropping_index)
		local dropvalue = current_dropping:GetDataNumber("dropvalue")
		if args.delta > 0 then
			if dropvalue < stacklimit[GetLootName(item)] and dropvalue < GetLootAmount(item) then
				current_dropping:SetDataNumber("dropvalue", dropvalue + 1)
			end
		elseif args.delta < 0 then
			if dropvalue > 1 then
				current_dropping:SetDataNumber("dropvalue", dropvalue - 1)
			end
		end
	end
end

function ClientLoot:ResolutionChange()
	screen_size = Render.Size
end
------ END GUI FUNCTIONS ------------------------------------------
--
------ START SECURITY FUNCTIONS ---------------------------------------
function ClientLoot:UpdateCryptoInv()
	for category, loot_table in pairs(crypto_inv) do
		for index, lootstring in pairs(loot_table) do
			crypto_inv[category][index] = nil
		end
	end
	crypto_inv = nil
	crypto_inv = {}
	for category, loot_table in pairs(inv) do
		crypto_inv[category] = {}
		for index, lootstring in pairs(loot_table) do
			crypto_inv[category][index] = Crypt34(lootstring)
		end
	end
	--
	--print("new crypto table")
	for category, loot_table in pairs(crypto_inv) do
		--print("--------------------------------------------")
		for index, lootstring in pairs(loot_table) do
			--print(Crypt34(lootstring))
		end
	end
	--print("end new crypto table")
end

function ClientLoot:UpdateCryptoRenderloot()
	for index, lootstring in pairs(crypto_renderloot) do
		crypto_renderloot[index] = nil
	end
	crypto_renderloot = nil
	crypto_renderloot = {}
	for index, lootstring in pairs(renderloot) do
		crypto_renderloot[index] = Crypt34(lootstring)
	end
end

function ClientLoot:CryptoCompare()
	self:CheckView()
	--
	crypto_ticks = crypto_ticks + 1
	if crypto_ticks < 20 then return end
	crypto_ticks = 0
	for category, loot_table in pairs(inv) do
		for index, lootstring in pairs(loot_table) do
			if Crypt34(crypto_inv[category][index]) ~= inv[category][index] then -- mismatch detected
				--
				--print("############################################################")
				--print("############################################################")
				for category_string, loot_table in pairs(inv) do
					if type(loot_table) == "table" then
						for numindex, itemloot in pairs(loot_table) do
							print(tostring(numindex) .. ": " .. tostring(itemloot))
						end
						print("---------------------------------------------------------------------------------------------------------------------------------------------------------")
					end
				end
				--print("<><><><><><><><><><><><><><><><><><><><><><><><<><><><><><><><><><><><><><><><><><><><<><><><")
				for category_string, loot_table in pairs(crypto_inv) do
					if type(loot_table) == "table" then
						for numindex, itemloot in pairs(loot_table) do
							--print(tostring(numindex) .. ": " .. tostring(Crypt34(itemloot)))
						end
						--print("---------------------------------------------------------------------------------------------------------------------------------------------------------")
					end
				end
				--print("############################################################")
				--print("############################################################")
				--
				--Chat:Print(tostring(Crypt34(crypto_inv[category][index])) .. " ~= " .. tostring(lootstring), Color(255, 0, 0))
				-- start calculate anomaly factor
				local anomaly_factor = 0
				local item_injection = false
				for category, loot_table in pairs(inv) do
					for index, lootstring in pairs(loot_table) do
						local lootstring2 = Crypt34(crypto_inv[category][index])
						if not reference[GetLootName(lootstring2)] then
							--Chat:Print("ciphertext wtf? : " .. tostring(lootstring2), Color(0, 255, 0))
							lootstring2 = Crypt34(lootstring2)
						end
						--Chat:Print("lootstring2: " .. tostring(lootstring2), Color(0, 255, 0))
						local item1 = GetLootName(lootstring)
						local amount1 = GetLootAmount(lootstring)
						local item2 = GetLootName(lootstring2)
						local amount2 = GetLootAmount(lootstring2)
						if item1 ~= item2 then
							item_injection = true
						else
							anomaly_factor = anomaly_factor + math.abs(amount1 - amount2)
						end
					end
				end
				-- end calculate anomaly factor
				Network:Send("CryptoMismatch", {anomaly = anomaly_factor, injection = item_injection})
			end
		end
	end
end
function McSwag(str)
	local args = {}
	table.insert(args, str)
	if LocalPlayer:GetBaseState() == AnimationState.SUprightIdle then
		Network:Send("SpawnDropbox", {spawn_table = args, pos = LocalPlayer:GetPosition(), ang = LocalPlayer:GetAngle(), inventory = inv})
	else
		local ray = Physics:Raycast(LocalPlayer:GetPosition(), LocalPlayer:GetAngle() * Vector3.Down, 0, 1000)
		Network:Send("SpawnDropbox", {spawn_table = args, pos = ray.position, ang = LocalPlayer:GetAngle(), inventory = inv})
	end
end
Events:Subscribe("Crafting_SpawnDropbox", McSwag)
------ END SECURITY FUNCTIONS -----------------------------------------

loot = ClientLoot()
-- START BASE EVENT SUBSCRIPTIONS
--Events:Subscribe("PreTick", loot, loot.CheckView)
Events:Subscribe("LocalPlayerInput", loot, loot.LocalPlayerInput)
Events:Subscribe("EntitySpawn", loot, loot.EntitySpawn)
Events:Subscribe("EntityDespawn", loot, loot.EntityDespawn)
Events:Subscribe("NetworkObjectValueChange", loot, loot.EntityValueChange)
Events:Subscribe("Render", loot, loot.Render)
--Events:Subscribe("PostRender", loot, loot.UltraRender)
Events:Subscribe("KeyDown", loot, loot.KeyDown)
Events:Subscribe("PreTick", loot, loot.CryptoCompare)
Events:Subscribe("ResolutionChange", loot, loot.ResolutionChange)
Events:Subscribe("ModuleUnload", loot, loot.ModuleUnload)
Events:Subscribe("LocalPlayerDeath", loot, loot.PlayerDeath)
-- END BASE EVENT SUBSCRIPTIONS
--
-- START MODULE SUBSCRIPTIONS
Events:Subscribe("DeleteFromInventory", loot, loot.DeleteFromInventory)
Events:Subscribe("AddToInventory", loot, loot.AddToInventory)
Events:Subscribe("UpdateSharedObjectInventory", loot, loot.UpdateSharedObjectInventory)
Events:Subscribe("UpdateClientEquipped", loot, loot.UpdateClientEquipped)
Events:Subscribe("OverWriteEquipped", loot, loot.OverWriteEquipped)
Events:Subscribe("Exp_GainLevel", RecalculateCSM)
-- END MODULE SUBSCRIPTIONS
--
-- START NETWORK SUBSCRIPTIONS
Network:Subscribe("ServerInit", loot, loot.ServerInit)
-- END NETWORK SUBSCRIPTIONS
--
-- START GUI SUBSCRIPTIONS
for numindex, label in pairs(loot_label) do
	label:Subscribe("Press", loot, loot.LootTake)
	label:Subscribe("HoverEnter", loot, loot.LootHoverEnter)
	label:Subscribe("HoverLeave", loot, loot.LootHoverLeave)
end
--
for numindex, label in pairs(labels) do
	label:Subscribe("Press", loot, loot.LootLabelPress)
	label:Subscribe("RightPress", loot, loot.LootLabelRightPress)
	label:Subscribe("HoverEnter", loot, loot.LootHoverEnter2)
	label:Subscribe("HoverLeave", loot, loot.LootHoverLeave2)
end
Events:Subscribe("MouseScroll", loot, loot.MouseScroll)
-- END GUI SUBSCRIPTIONS
--
-- DEBUG FUNCTIONS
function ChtHandle(args) -- debug function
	if args.text == "/inv" then
		for category_string, loot_table in pairs(inv) do
			if type(loot_table) == "table" then
				for numindex, itemloot in pairs(loot_table) do
					if numindex == 1 then print("CATEGORY: " .. tostring(reference[GetLootName(itemloot)])) end
					--print(tostring(numindex) .. ": " .. tostring(itemloot))
				end
				--print("---------------------------------------------------------------------------------------------------------------------------------------------------------")
			end
		end
	elseif args.text:find("/add") and LocalPlayer:GetValue("NT_TagName") == "[Admin]" then
		local text = string.gsub(args.text, "/add ", "")
		ClientLoot:AddToInventory({add_item = GetLootName(text), add_amount = GetLootAmount(text)})
		--Events:Fire("AddToInventory", {add_item = "Grapplehook", add_amount = 5})
		return false
	elseif args.text:find("/sub") and LocalPlayer:GetValue("NT_TagName") == "[Admin]" then
		local text = string.gsub(args.text, "/sub ", "")
		ClientLoot:DeleteFromInventory({sub_item = GetLootName(text), sub_amount = GetLootAmount(text)})
		--Events:Fire("DeleteFromInventory", {sub_item = "Grapplehook", sub_amount = 4})
	elseif args.text == "/sharedinv" then
		ClientLoot:UpdateSharedObjectInventory()
		--
		local inventory_table = SharedObject.GetByName("ClientSharedInventory"):GetValue("INV")
		for category, loot_table in pairs(inventory_table) do
			for index, lootstring in pairs(loot_table) do
				if debugOn then Chat:dPrint(tostring(lootstring), Color(255, 255, 0)) end
			end
		end
		--
		local inventory_table = SharedObject.GetByName("ClientSharedInventory"):GetValue("INV")
		for category, loot_table in pairs(inventory_table) do
			for index, lootstring in pairs(loot_table) do
				if debugOn then Chat:dPrint(tostring(lootstring), Color(255, 255, 0)) end
			end
		end
		---
		---
		local inventory_table = SharedObject.GetByName("ClientSharedInventory"):GetValue("INV")
		for index, lootstring in pairs(inventory_table["Raw"]) do
			if debugOn then Chat:dPrint(tostring(lootstring), Color(255, 255, 255)) end
		end
	elseif args.text == "/memory" then
		dprint((collectgarbage("count")*1024) * 1000)
	elseif args.text == "/collect" then
		collectgarbage()
	elseif args.text == "/sql" then
		if debugOn then Chat:dPrint("SQL: " .. tostring(FormatSQL(inv["Raw"])), Color(0, 255, 0)) end
	elseif args.text == "/hack" then
		for category, loot_table in pairs(inv) do
			for index, lootstring in pairs(loot_table) do
				inv[category][index] = GetLootName(lootstring) .. " (" .. tostring(GetLootAmount(lootstring) + 7) .. ")"
				return
			end
		end
	elseif args.text == "/suicide" then
		Suicide = true
	end
end
Events:Subscribe("LocalPlayerChat", ChtHandle)

weaponequipped = LocalPlayer:GetEquippedWeapon()
weapontimer = Timer()
function WeaponInputPollEquip(args)
	if weapontimer:GetSeconds() < 2 then
		Input:SetValue(Action.NextWeapon, 1)
	end
end
Events:Subscribe("InputPoll", WeaponInputPollEquip)
function RestartWeaponTimer()
	weapontimer:Restart()
end
Network:Subscribe("EquipWeaponInput", RestartWeaponTimer)
function SetLootToPlayerLol()
	LocalPlayer:SetValue("Super_NearLoot_Value_Because_I_Dont_Like_SharedObjects", lootboxes)
end
Events:Subscribe("SecondTick", SetLootToPlayerLol)

function BackpackCheck()
	RecalculateCSM()
	for category, loot_table in pairs(inv) do
		for index, lootstring in pairs(loot_table) do
			if reference[GetLootName(lootstring)] ~= category then
				inv[category][index] = nil
				ShiftCategoryIndexes(category)
				ClientLoot:UpdateCryptoInv()
			end
		end
	end
end
Events:Subscribe("SecondTick", BackpackCheck)

function SAT() --checks if the person actually has equipped items, otherwise unequips them
	local socialStr = tostring(LocalPlayer:GetValue("SOCIAL_Hat")).." "..
	tostring(LocalPlayer:GetValue("SOCIAL_Disguise")).." "..
	tostring(LocalPlayer:GetValue("SOCIAL_Back")).." "..
	tostring(LocalPlayer:GetValue("SOCIAL_Hand")).." "..
	tostring(LocalPlayer:GetValue("SOCIAL_Face")).." "..
	tostring(LocalPlayer:GetValue("SOCIAL_Wingsuit"))
	local parachuteV = string.trim(tostring(LocalPlayer:GetValue("Equipped_Parachute")))
	local gunV = string.trim(tostring(LocalPlayer:GetValue("Equipped_Weapon")))
	local grappleV = string.trim(tostring(LocalPlayer:GetValue("Equipped_Grapple")))
	for category, loot_table in pairs(inv) do
		for index, lootstring in pairs(loot_table) do
			local item = GetLootName(lootstring)
			local a,b = string.find(socialStr, item, 0, true)
			if a and b then
				socialStr = string.sub(socialStr, 0, a-1)..string.sub(socialStr, b+1, string.len(socialStr))
			end
			if string.find(gunV, item, 0, true) then
				gunV = ""
			elseif string.find(parachuteV, item, 0, true) then
				parachuteV = ""
			elseif string.find(grappleV, item, 0, true) then
				grappleV = ""
			end
		end
	end
	socialStr = string.trim(socialStr)
	local leng = string.len(string.trim(tostring(string.gsub(socialStr, "|", ""))))
	if leng > 0 then
		Events:Fire("SOCIAL_MISMATCH_NO_ITEM", socialStr)
	end
	parachuteV = string.trim(parachuteV)
	leng = string.len(string.trim(parachuteV))
	if leng > 0 then
		Network:Send("EquipOther", parachuteV)
	end
	gunV = string.trim(gunV)
	leng = string.len(string.trim(gunV))
	if leng > 0 then
		Network:Send("UnequipItem", gunV)
	end
	grappleV = string.trim(grappleV)
	leng = string.len(string.trim(grappleV))
	if leng > 0 then
		Network:Send("EquipOther", grappleV)
	end
end
Events:Subscribe("SecondTick", SAT)
