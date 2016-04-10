class 'Building'

function Building:__init()
	speed = 100 --smaller number = faster rotation
	screen_size = Render.Size
	WorldNetworkObjects = {}
	post_ticks = 0
	post_ticks2 = 0
	current_selection = 0
	current_selection_id = -1
	current_selection_model = ""
	current_selection_WNOID = -1
	duplicate = nil
	duplicate_args = {}
	duplicate_collision_temp = 0
	is_editing = false
	create_new = false
	timer_disable = Timer()
	--
	dupeset = {}
	dupeset["f1t16.garbage_can.eez/go225-a.lod"] = 2
	--
	buildargs = {}
	buildargs.angle = Angle(math.pi/2,0,0)
	--
	net_info = {}
	LocalPlayer:SetValue("is_editing", false)
	current_item = ""
	current_item_sub = 0
	Events:Subscribe("ModulesLoad", self, self.AddHelp)
	Events:Subscribe("ModuleUnload", self, self.RemoveHelp)

end

function Building:AddHelp()
    Events:Fire( "HelpAddItem",
        {
            name = "Building",
            text = 
                "There are many items you can place down to create a base with. "..
                "One such item is the trash can storage, a way to store your items for later. " ..
                "When building, always follow the prompts to ensure that your building "..
				"goes along smoothly."
        } )
    Events:Fire( "HelpAddItem",
        {
            name = "Storage",
            text = 
                "One way to store items is to use a storage.  One type of storage is a Garbage "..
                "Bin.  These can be placed on the ground and you can store your items in them for " ..
                "easy access.  You can also pick up your placed storages by following the prompts "..
				"when opening a storage."
        } )
end

function Building:RemoveHelp()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Building"
        } )
    Events:Fire( "HelpRemoveItem",
        {
            name = "Storage"
        } )
end


function Building:MouseLeftClickFunction()
	--if args.button == 2 then
		if is_editing == false and create_new == false then
			if type(current_selection) == "number" then return end
			if not IsValid(current_selection) then
				--Chat:Print("ClientStatic Spawn Error", Color(255, 0, 0))
			end
			is_editing = true
			wno_id_g = WorldNetworkObjects[tostring(current_selection:GetPosition())]
			if not wno_id_g or not IsValid(WorldNetworkObject.GetById(wno_id_g)) then return end
			LocalPlayer:SetValue("is_editing", true)
			duplicate_args.position = current_selection:GetPosition()
			duplicate_args.angle = current_selection:GetAngle()
			duplicate_args.model = current_selection:GetModel()
			duplicate_args.collision = ""
			duplicate_collision_temp = current_selection:GetCollision()
			duplicate = ClientStaticObject.Create(duplicate_args)
			create_new = false
			buildargs.collision = nil
			move_event = Events:Subscribe("PostTick", building, building.MoveDuplicate)
		elseif is_editing == true then
			is_editing = false
			Events:Unsubscribe(move_event)
			if identifier == "gbin" then
				if create_new == false then
					if current_selection_WNOID == -1 then return end
					--Chat:Print("Client - is sending wno_id of " .. tostring(current_selection_WNOID), Color(0, 255, 0))
					Network:Send("UpdateObjectPosition", {pos = duplicate:GetPosition(), wno_id = current_selection_WNOID})
					timer_disable:Restart()
				elseif create_new == true then
					buildargs.position = duplicate:GetPosition()
					buildargs.angle = duplicate:GetAngle()
					local info_table = {}
					info_table["STier"] = 1
					info_table["Owner"] = tostring(LocalPlayer:GetSteamId().id)
					if LocalPlayer:GetValue("StorageCount") and LocalPlayer:GetValue("StorageCount") < GetStorageMax() then
						Network:Send("CreateNewNetworkedObject", {b_args = buildargs, info = info_table, name = identifier})
						Events:Fire("DeleteFromInventory", {sub_item = current_item, sub_amount = current_item_sub})
					else
						Chat:Print("You already have the maximum allowed storages for your level", Color(255, 255, 0))
					end
					Chat:dPrint("Client Create Gbin", Color(0, 255, 0))
				end
			elseif identifier == "Faction Storage" then
				if create_new == false then -- moving existing
					Chat:dPrint("Moving Existing Faction Storage", Color(0, 255, 0))
				elseif create_new == true then -- creating new
					if LocalPlayer:GetValue("Faction") then
						local info_table = {}
						info_table["STier"] = 2
						info_table["Faction"] = LocalPlayer:GetValue("Faction")
						buildargs.position = duplicate:GetPosition()
						buildargs.angle = duplicate:GetAngle()
						if LocalPlayer:GetValue("StorageCount") and LocalPlayer:GetValue("StorageCount") < GetStorageMax() then
							Network:Send("CreateNewNetworkedObject", {b_args = buildargs, info = info_table, name = identifier})
							Events:Fire("DeleteFromInventory", {sub_item = current_item, sub_amount = current_item_sub})
						else
							Chat:Print("You already have the maximum allowed # of storages", Color(255, 255, 0))
						end
						--Chat:Print("Client created new WNO?", Color(0, 255, 0))
					end
				end
			elseif identifier == "Faction Guard" then
				if create_new == false then -- moving existing
					
				elseif create_new == true then
					if LocalPlayer:GetValue("Faction") and LocalPlayer:GetValue("Faction") ~= "" then
						buildargs.position = duplicate:GetPosition()
						buildargs.angle = duplicate:GetAngle()
						Network:Send("PlaceFactionGuard", {pos = duplicate:GetPosition()})
						Events:Fire("DeleteFromInventory", {sub_item = current_item, sub_amount = current_item_sub})
					end
				end
			elseif identifier == "Missile Turret" then
				if create_new == false then -- moving existing
					
				elseif create_new == true then
					if LocalPlayer:GetValue("Faction") and LocalPlayer:GetValue("Faction") ~= "" then
						buildargs.position = duplicate:GetPosition()
						buildargs.angle = duplicate:GetAngle()
						Network:Send("PlaceFactionTurret", {pos = duplicate:GetPosition() + Vector3(0, 6.0, 0)})
						Events:Fire("DeleteFromInventory", {sub_item = current_item, sub_amount = current_item_sub})
					end
				end
			end
			duplicate:Remove()
			current_selection = 0
			LocalPlayer:SetValue("is_editing", false)
			create_new = false
		end
	--end
end

function Building:MoveDuplicate()
	-- start conditions
	if identifier == "Faction Guard" or identifier == "Missile Turret" then
		if not LocalPlayer:GetValue("InFactionBase") then
			CancelPlacement()
		end
	end
	-- end conditions
	if not IsValid(duplicate) then
		--Chat:Print("Duplicate is not Valid", Color(0, 255, 0))
		return
	else
		--Chat:Print("Duplicate is Valid", Color(255, 0, 0))
		--Chat:Print("Duplicate Pos: " .. tostring(duplicate:GetPosition()), Color(0, 255, 0))
	end
	
	local raycast = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, 20)
	if raycast.position then
		local raycast_2 = Physics:Raycast(raycast.position + Vector3(0, .75, 0), Vector3.Down, 0, 100)
		if raycast_2.distance >= 99 then -- no hit
			local raycast_3 = Physics:Raycast(raycast.position + Vector3(0, .75, 0), Vector3.Up, 0, 100)
			if raycast_3.distance >= 99 then -- no hit
				CancelPlacement()
				Chat:dPrint("Object being placed was put too far away - try again", Color(255, 255, 0))
			end
			duplicate:SetPosition(raycast_3.position)
		else
			duplicate:SetPosition(raycast_2.position)
		end
	end
end

function CancelPlacement()
	Events:Unsubscribe(move_event)
	is_editing = false
	LocalPlayer:SetValue("is_editing", false)
	if IsValid(duplicate) then
		duplicate:Remove()
	end
end

function Building:iRaycast()
	if is_editing == true then return end
	post_ticks = post_ticks + 1
	if post_ticks < 30 then return end
	post_ticks = 0
	if timer_disable:GetSeconds() < 2 then return end -- must have this to prevent nil id bug
	--
	local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, 10)
	if ray.entity then
		if ray.entity.__type == "ClientStaticObject" then
			if buildobject[ray.entity:GetModel()] then
				if tostring(current_selection) == "ClientStaticObject" and IsValid(current_selection) == false then return end
				if current_selection ~= ray.entity then
					current_selection_model = ray.entity:GetModel()
					if has_networked_attributes[current_selection_model] == true then
						--for k, v in pairs(WorldNetworkObjects) do Chat:Print("No Network Bug", Color(0, 255, 0)) end
						if table.count(WorldNetworkObjects) == 0 then
							--Chat:Print("Network Object Bug(initialization failure)", Color(255, 0, 0))
							LocalPlayer:SetLinearVelocity(Vector3(0, 10000, 0))
							return
						end
						current_selection_WNOID = WorldNetworkObjects[tostring(ray.entity:GetPosition())]
						Chat:dPrint("New CS_WNOID @ " .. tostring(ray.entity:GetPosition()) .. ": " .. tostring(current_selection_WNOID), Color(255, 255, 0))
						dprint("------------------------------------------------------------")
						for k, v in pairs(WorldNetworkObjects) do
							Chat:dPrint("k: " .. tostring(k) .. "|||| v: " .. tostring(v), Color(0, 0, 255))
						end
						dprint("------------------------------------------------------------")
					else
						Chat:dPrint("Object Has No Networked Attributes", Color(0, 255, 0))
					end
					current_selection = Copy(ray.entity)
					current_selection_id = ray.entity:GetId()
					current_selection_model = ray.entity:GetModel()
					is_editing = false
				end
			end
		end
	end
end

function Building:WNOCreate(args) -- when client streams in WNO's
	local pos = tostring(args.object:GetPosition())
	if WorldNetworkObjects[pos] or (args.object:GetValue("LTier") == nil and args.object:GetValue("STier") == nil) then return end -- if not loot and not storage or already tabled
	--
	--Chat:Print("POPULATED", Color(0, 255, 0))
	--print(pos)
	WorldNetworkObjects[pos] = args.object:GetId()
end

function Building:WNODestroy(args) -- when client exits WNO's streaming distance
	local pos = tostring(args.object:GetPosition())
	if WorldNetworkObjects[pos] then
		WorldNetworkObjects[pos] = nil
		--Chat:Print("Deleted WNO", Color(0, 255, 0))
	end
end

function Building:WNOPositionManager() -- when wno position is modified
	post_ticks2 = post_ticks2 + 1
	if post_ticks2 < 10 then return end
	post_ticks2 = 0
	for string_pos, wno_id in pairs(WorldNetworkObjects) do
		local iWNO = WorldNetworkObject.GetById(wno_id)
		if iWNO then
			if tostring(iWNO:GetPosition()) ~= string_pos then
				WorldNetworkObjects[tostring(iWNO:GetPosition())] = Copy(wno_id)
				WorldNetworkObjects[string_pos] = nil
				Chat:dPrint("WNO Position Adjust to " .. tostring(iWNO:GetPosition()), Color(255, 255, 0))
			end
		else
			Chat:dPrint("NOT A WNO", Color(255, 0, 0))
		end
	end
end

function Building:GetTask(args) -- receives type || creates new staticobject / staticobject+wno
	local iray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, 20)
	local iray2 = Physics:Raycast(iray.position + Vector3(0, .25, 0), Vector3.Down, 0, 1250)
	create_new = true
	is_editing = true
	LocalPlayer:SetValue("is_editing", true)
	if args.type == "gbin" then
		identifier = "gbin"
		current_item = "Garbage Bin"
		current_item_sub = 1
		buildargs.position = iray2.position
		buildargs.model = "f1t16.garbage_can.eez/go225-a.lod"
		buildargs.collision = nil
		duplicate = ClientStaticObject.Create(buildargs)
		buildargs.collision = "f1t16.garbage_can.eez/go225_lod1-a_col.pfx"
		for k, v in pairs(net_info) do net_info[k] = nil end
	
		current_selection_model = "f1t16.garbage_can.eez/go225-a.lod" -- necessary to have this
		move_event = Events:Subscribe("PostTick", building, building.MoveDuplicate)
	elseif args.type == "Faction Storage" then
		identifier = "Faction Storage"
		current_item = "Faction Storage"
		current_item_sub = 1
		buildargs.position = iray2.position
		buildargs.model = "37x10.flz/go231-b.lod"
		buildargs.collision = nil
		duplicate = ClientStaticObject.Create(buildargs)
		buildargs.collision = "37x10.flz/go231_lod1-b_col.pfx"
		for k, v in pairs(net_info) do net_info[k] = nil end
		
		current_selection_model = "37x10.flz/go231-b.lod"
		move_event = Events:Subscribe("PostTick", building, building.MoveDuplicate)
	elseif args.type == "Faction Guard" then
		identifier = "Faction Guard"
		current_item = "Faction Guard"
		current_item_sub = 1
		buildargs.position = iray2.position
		buildargs.model = "mc03_generalmasayo.eez/mc03-masayo.lod"
		buildargs.collision = nil
		duplicate = ClientStaticObject.Create(buildargs)
		buildargs.collision = "mc03_generalmasayo.eez/mc03_lod1-masayo_col.pfx"
		for k, v in pairs(net_info) do net_info[k] = nil end
		
		current_selection_model = "mc03_generalmasayo.eez/mc03-masayo.lod"
		move_event = Events:Subscribe("PostTick", building, building.MoveDuplicate)
	elseif args.type == "Missile Turret" then
		identifier = "Missile Turret"
		current_item = "(F) Missile Turret"
		current_item_sub = 1
		buildargs.position = iray2.position
		buildargs.model = "f2s04emp.flz/key040_1-part_b.lod"
		buildargs.collision = nil
		duplicate = ClientStaticObject.Create(buildargs)
		buildargs.collision = "f2s04emp.flz/key040_1_lod1-part_b_col.pfx"
		for k, v in pairs(net_info) do net_info[k] = nil end
		
		current_selection_model = "f2s04emp.flz/key040_1-part_b.lod"
		move_event = Events:Subscribe("PostTick", building, building.MoveDuplicate)
	end
end

function Building:Render()
	if is_editing == true then
		local text = "Now placing "..tostring(current_item)
		local text2 = "Left click to place, right click to cancel"
		local text3 = "Hold R to rotate"
		local size = Render.Size.y / 20
		local pos = Render.Size/2 - Vector2(Render:GetTextSize(text, size).x/2,0) + Vector2(0,Render.Size.y/3)
		local pos2 = Render.Size/2 - Vector2(Render:GetTextSize(text2, size).x/2,0) + Vector2(0,Render.Size.y/3) + Vector2(0,Render:GetTextSize(text,size).y)
		local pos3 = Render.Size/2 - Vector2(Render:GetTextSize(text3, size).x/2,0) + Vector2(0,Render.Size.y/3)+ Vector2(0,Render:GetTextSize(text,size).y) + Vector2(0,Render:GetTextSize(text2,size).y)
		Render:DrawText(pos, text, Color.Red, size)
		Render:DrawText(pos2, text2, Color.Red, size)
		Render:DrawText(pos3, text3, Color.Red, size)
		--[[local width = Render:GetTextWidth("Press ' 0 ' to cancel", TextSize.Default * 2.0)
		Render:DrawText(Vector2(screen_size.x * .5 - (width / 2), screen_size.y * .06), "Press ' 0 ' to cancel", Color(255, 255, 0), TextSize.Default * 2.0)
		width = Render:GetTextWidth("Click Right-Mouse to place", TextSize.Default * 2.0)
		local height = Render:GetTextHeight("Press ' 0 ' to cancel", TextSize.Default * 2.0)
		Render:DrawText(Vector2(screen_size.x * .5 - (width / 2), (screen_size.y * .06) + height * 1.2), "Click Right-Mouse to place", Color(255, 255, 0), TextSize.Default * 2.0)--]]
		if duplicate and IsValid(duplicate) then
			local transform = Transform3()
			transform:Translate(duplicate:GetPosition())
			transform:Rotate(Angle(0, 0.5 * math.pi, 0))
			Render:SetTransform(transform)
			Render:FillCircle(Vector3.Zero, 1.5, Color(0, 255, 0, 50))
			transform:Rotate(Angle(0.5 * math.pi, 0, 0))
			Render:SetTransform(transform)
			Render:FillCircle(Vector3.Zero, 1.5, Color(0, 255, 0, 50))
			transform:Rotate(Angle(0, 0, 0.5 * math.pi))
			Render:SetTransform(transform)
			Render:FillCircle(Vector3.Zero, 1.5, Color(0, 255, 0, 50))
			Render:ResetTransform()
			Chat:dPrint("Rendered Circles", Color(0, 255, 0))
		end
		
		if Key:IsDown(82) then -- r
			buildargs.angle = Angle(math.pi/speed, 0,0) * buildargs.angle
			duplicate:SetAngle(buildargs.angle)
		end
		if Key:IsDown(1) then
			self:MouseLeftClickFunction()
		end
		if Key:IsDown(2) then
			if IsValid(duplicate) then duplicate:Remove() end
			Events:Unsubscribe(move_event)
			current_selection = 0
			create_new = false
			LocalPlayer:SetValue("is_editing", false)
			is_editing = false
		end
	end
end

building = Building()

Events:Subscribe("PostTick", building, building.iRaycast)
Events:Subscribe("PostTick", building, building.WNOPositionManager)
Events:Subscribe("WorldNetworkObjectCreate", building, building.WNOCreate)
Events:Subscribe("WorldNetworkObjectDestroy", building, building.WNODestroy)
Events:Subscribe("Render", building, building.Render)
--
Events:Subscribe("EditMode", building, building.GetTask)

function GetStorageMax()
	local level = tonumber(LocalPlayer:GetValue("Level"))
	if not level then return 0 end
	
	if level < 10 then
		return 5
	elseif level < 20 then
		return 5
	elseif level < 40 then
		return 5
	elseif level < 50 then
		return 6
	elseif level < 65 then
		return 7
	elseif level < 75 then
		return 8
	elseif level < 85 then
		return 9
	elseif level < 95 then
		return 10
	elseif level < 100 then
		return 11
	elseif level < 125 then
		return 12
	elseif level < 150 then
		return 13
	elseif level < 175 then
		return 14
	elseif level <= 200 then
		return 15
	else
		return 15
	end
end