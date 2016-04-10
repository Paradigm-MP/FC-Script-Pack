class 'SGUI'
function SGUI:__init()
	LocalPlayer:SetValue("StorageCount", 0)
	--THIS CLASS HANDLES ALL THE GUI FOR VEHICLES
	storageinfo = {}
	sbuttons = {}
	window = Window.Create()
	window:SetSize(Render.Size / 2)
	window:SetTitle("Storage Management Menu (".."0".." / 5)")
	window:SetPosition((Render.Size / 2) - (window:GetSize() / 2))
	window:SetVisible(false)
	window:Subscribe("WindowClosed", self, self.CloseWindow)
	window:Subscribe("Render", self, self.WindowRender)
	--
	tiers = {}
	tiers[1] = "Garbage Bin"
	--
	Events:Subscribe("KeyUp", self, self.KeyOpen)
	--
	Network:Subscribe("SendStoragesToClient", self, self.ReceiveStorages)
end

--MAKE TABLES FOR EACH PLAYER SERVERSIDE WHAT HOLD ALL THE VEHICLES
--THEY OWN SO THAT THE SERVER ONLY HAS TO SEND THE TABLE

--ON SERVER SEND VEHICLE TABLE
function GetMiddlePos(k, w)
	return (w:GetSize().x / 2) - (k:GetTextWidth() / 2)
end

function SGUI:ReceiveStorages(args) -- receives SQL table(sinfo) with storage info (tier, position, items)
	storageinfo = args.sinfo
	self:UpdateButtons()
	Chat:dPrint("Client Receives Storages", Color(255, 200, 0))
end

function SGUI:UpdateButtonText()
	--on open, update text like distance and hp, etc
	window:SetTitle("Storage Management Menu ("..table.count(sbuttons).." / " .. tostring(GetStorageMax()) .. ")")
	if table.count(sbuttons) == 0 then return end
	for index, _ in pairs(sbuttons) do
		local labeltier = sbuttons[index].labeltier
		local labeldist = sbuttons[index].labeldist
		local waypoint = sbuttons[index].waypoint
		local remov = sbuttons[index].remov
		waypoint:SetTextColor(Color.Yellow)
		waypoint:SetTextNormalColor(Color.Yellow)
		waypoint:SetTextHoveredColor(Color.Yellow)
		waypoint:SetTextPressedColor(Color.Yellow)
		remov:SetTextColor(Color.Red)
		remov:SetTextNormalColor(Color.Red)
		remov:SetTextHoveredColor(Color.Red)
		remov:SetTextPressedColor(Color.Red)
		local dist = Vector3.Distance(LocalPlayer:GetPosition(), SGUI:VectorFromString(waypoint:GetDataString("position")))
		local diststr = string.format("%.0f m away",tostring(dist))
		if dist > 1000 then
			dist = dist / 1000
			diststr = string.format("%.2f km away",tostring(dist))
		end
		labeldist:SetText(diststr)
	end
end

function SGUI:UpdateButtons() --CALLED WHENEVER THE TABLE IS CHANGED
	--reinitializes buttons due to tables 
	for k, v in pairs(sbuttons) do
		if IsValid(sbuttons[k].labeltier) then sbuttons[k].labeltier:Remove() end
		if IsValid(sbuttons[k].labeldist) then sbuttons[k].labeldist:Remove() end
		if IsValid(sbuttons[k].waypoint) then sbuttons[k].waypoint:Remove() end
		if IsValid(sbuttons[k].remov) then sbuttons[k].remov:Remove() end
	end
	sbuttons = {}
	local tnum = 0
	window:SetTitle("Storage Management Menu ("..table.count(storageinfo).." / 5)")
	local storage_count = 0
	for index, itable in pairs(storageinfo) do
		--makes buttons
		tnum = tnum + 1
		sbuttons[tnum] = {}
		sbuttons[tnum].labeltier = Label.Create(window)
		sbuttons[tnum].labeltier:SetText(tiers[tonumber(itable.tier)])
		sbuttons[tnum].labeldist = Label.Create(window)
		sbuttons[tnum].labeldist:SetText(tostring(Vector3.Distance(LocalPlayer:GetPosition(), SGUI:VectorFromString(itable.position))) .. "m away")
		sbuttons[tnum].waypoint = Button.Create(window)
		sbuttons[tnum].waypoint:SetName("Waypoint")
		sbuttons[tnum].waypoint:SetDataString("position", tostring(itable.position))
		sbuttons[tnum].remov = Button.Create(window)
		sbuttons[tnum].remov:SetName("Remove")
		sbuttons[tnum].waypoint:SetText("Waypoint")
		sbuttons[tnum].waypoint:SetTextColor(Color.Yellow)
		sbuttons[tnum].remov:SetText("Remove")
		sbuttons[tnum].remov:SetTextColor(Color.Red)
		sbuttons[tnum].remov:SetDataNumber("primary_key", tonumber(itable.storageID))
		storage_count = storage_count + 1
	end
	LocalPlayer:SetValue("StorageCount", storage_count)
	local baserel = Vector2(0.001, 0.01)
	local addrel = Vector2(0, 0.075)
	local addrel2 = Vector2(0.25, 0.0)
	local addrel3 = Vector2(0.45, 0.0)
	local siderel = Vector2(0.125, 0)
	local firstrel = Vector2(0.25, 0)
	local sizerel = Vector2(0.2,0.055)
	for i=1,table.count(sbuttons) do
		--sets button position, etc
		local labeltier = sbuttons[i].labeltier
		local labeldist = sbuttons[i].labeldist
		local waypoint = sbuttons[i].waypoint
		local remov = sbuttons[i].remov
		labeltier:SetPositionRel(baserel + (addrel * (i-1)))
		labeltier:SetSizeRel(Vector2(1,1))
		labeltier:SetTextSize(25)
		labeldist:SetPositionRel(labeltier:GetPositionRel() + (addrel2))
		labeldist:SetSizeRel(Vector2(1,1))
		labeldist:SetTextSize(25)
		waypoint:SetPositionRel(labeltier:GetPositionRel() + siderel + firstrel + Vector2(.1, 0))
		remov:SetPositionRel(labeltier:GetPositionRel() + (siderel * 3) + firstrel + Vector2(.1, 0))
		waypoint:SetSizeRel(sizerel)
		remov:SetSizeRel(sizerel)
		waypoint:SetTextSize(20)
		remov:SetTextSize(20)
		waypoint:SetTextColor(Color.Yellow)
		waypoint:SetTextNormalColor(Color.Yellow)
		waypoint:SetTextHoveredColor(Color.Yellow)
		waypoint:SetTextPressedColor(Color.Yellow)
		remov:SetTextColor(Color.Red)
		remov:SetTextNormalColor(Color.Red)
		remov:SetTextHoveredColor(Color.Red)
		remov:SetTextPressedColor(Color.Red)
		waypoint:Subscribe("Press", self, self.ButtonPress)
		remov:Subscribe("Press", self, self.ButtonPress)
		--ADJUST BUTTON HEIGHT AND POSITION HERE USING I
		--ALSO SUBSCRIBE BUTTONS TO FUNCTIONS
	end
end

function SGUI:ButtonPress(btn)
	if btn:GetName() == "Waypoint" then
		Waypoint:SetPosition(SGUI:VectorFromString(btn:GetDataString("position")))
	elseif btn:GetName() == "Remove" then
		Network:Send("GUIDismountStorage", {primary_key = btn:GetDataNumber("primary_key")})
		window:Hide()
		if movesub then
			Events:Unsubscribe(movesub)
			movesub = nil
		end
	end
end

function SGUI:KeyOpen(args)
	--opens the gui
	if args.key == 119 and not window:GetVisible() then --F8
		if table.count(sbuttons) > 0 then
			self:UpdateButtonText()
		end
		window:Show()
		Mouse:SetVisible(true)
		movesub = Events:Subscribe("LocalPlayerInput", self, self.BlockLooking)
	elseif args.key == 119 and window:GetVisible() then --F8
		window:Hide()
		if movesub then
			Events:Unsubscribe(movesub)
			movesub = nil
		end
		Mouse:SetVisible(false)
	end
end

function SGUI:BlockLooking(args)
	--blocks looking and firing while open
	if args.input == Action.LookLeft or args.input == Action.LookRight or
	args.input == Action.LookDown or args.input == Action.LookUp
	or args.input == Action.Fire or args.input == Action.FireRight
	or args.input == Action.FireLeft or args.input == Action.FireVehicleWeapon 
	or args.input == Action.McFire or args.input == Action. VehicleFireLeft 
	or args.input == Action.VehicleFireRight then return false end
end

function SGUI:CloseWindow()
	window:Hide()
	if movesub then
		Events:Unsubscribe(movesub)
		movesub = nil
	end
	Mouse:SetVisible(false)
end

function SGUI:WindowRender()
	Mouse:SetVisible(true)
end

function SGUI:VectorFromString(s)
	local pos = string.split(tostring(s), ",")
	return Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3]))
end

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

sgui = SGUI()