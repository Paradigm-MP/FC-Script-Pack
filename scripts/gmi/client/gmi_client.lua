class 'GMI'
function GMI:__init()
	selecteditem = "none"
	currentsection = ""
	price = 0
	
	InMainScreen = true
	
	GMI_MainImg = Image.Create(AssetLocation.Resource, "GMI_Main_Img")
	GMI_EnterRed = Image.Create(AssetLocation.Resource, "GMI_Main_EnterRed")
	GMI_EnterGreen = Image.Create(AssetLocation.Resource, "GMI_Main_EnterGreen")
	
	self.Window = Window.Create()
	self.Window:Hide()
	self.sizeX = Render.Size.x
	self.sizeY = Render.Size.y
	self.windowpos = Vector2(self.sizeX / 2, self.sizeY / 2) - Vector2(self.sizeX / 5, self.sizeY / 5)
	self.windowsize = Vector2(self.sizeX / 2.5, self.sizeY / 2.0)
	self.Window:SetSize(self.windowsize)
	self.Window:SetPosition(self.windowpos)
	self.Window:SetTitle("GMI (Global Market Interface)")
	self.Window:Subscribe("PostRender", self, self.RenderImg)
	self.Window:Subscribe("WindowClosed", self, self.Close)
	
	textscale = 0.05
	textsize = self.Window:GetSize().x * textscale
	basepos = self.Window:GetPosition() + Vector2(0, self.sizeY / 35)
	basesize = Vector2(self.Window:GetSize().x, self.Window:GetSize().y)
	
	EnterButton = Button.Create()
	EnterButton:SetText("")
	EnterButton:SetSize((basesize / 5) + Vector2((basesize.x/5) * 2.5, 0))
	EnterButton:SetPosition(basepos + (self.Window:GetPosition() / 1.25))
	EnterButton:Subscribe("HoverEnter", self, self.HoverEnterMain)
	EnterButton:Subscribe("HoverLeave", self, self.HoverLeaveMain)
	EnterButton:Subscribe("Press", self, self.PressMain)
	EnterButton:SetBackgroundVisible(false)
	EnterButton:SetEnabled(false)
	EnterButton:Hide()
	EnterButton:SetName("EnterButton")
	
	mlist = SortedList.Create(self.Window)
	mlist:AddColumn("Item Name")
	mlist:AddColumn("Price", self.Window:GetSize().y / 4)
	mlist:AddColumn("Rarity", self.Window:GetSize().y / 5.75)
	mlist:Hide()
	mlist:Sort(1)
	mlist:Subscribe("RowSelected", self, self.SelectRow)
	--
	craftbtn = Button.Create(self.Window)
	craftbtn:SetText("Buy")
	craftbtn:SetTextSize(15)
	craftbtn:SetSize(Vector2(self.Window:GetSize().x / 5,self.Window:GetSize().y  / 10))
	craftbtn:SetPositionRel(Vector2(.40, .8))
	craftbtn:Subscribe("Press", self, self.Purchase)
	
	backbtn = Button.Create(self.Window)
	backbtn:SetText("Back")
	backbtn:SetTextSize(15)
	backbtn:SetSize(Vector2(self.Window:GetSize().x / 10,self.Window:GetSize().y  / 12))
	backbtn:SetPositionRel(Vector2(0.33,0.8))
	backbtn:Hide()
	backbtn:Subscribe("Press", self, self.BackButtonPress)
	
	craftingTimer = Timer()
	for name, price in pairs(item_price) do 
		self:AddToSection(name)
	end
	mlist:Sort(2)
	Events:Subscribe("LocalPlayerChat", self, self.ChatOpen)
	--
	basepos = self.Window:GetPosition() + Vector2(self.sizeX / 500, self.sizeY / 30)
	basesize = Vector2(self.Window:GetSize().x / 3.1, self.Window:GetSize().y / 2.25)
	basex2 = Vector2(basesize.x + (basesize.x / 50), 0)
	basex3 = basex2 + Vector2(basesize.x,0)
	basey = Vector2(0,basesize.y + (basesize.y / 50))
	--
	Network:Subscribe("GiveGMIItem", GMI, GMI.GiveGMIItem)
end

function AddHelp()
    Events:Fire( "HelpAddItem",
        {
            name = "GMI",
            text = 
                "GMI is short for Global Market Interface, which is a shop where you can spend "..
                "credits to buy rare items.  These items will then be shipped to you.  GMI terminals " ..
                "are only found in safezones and cannot be crafted."
        } )
end

function RemoveHelp()
    Events:Fire( "HelpRemoveItem",
        {
            name = "GMI"
        } )
end

Events:Subscribe("ModulesLoad", AddHelp)
Events:Subscribe("ModuleUnload", RemoveHelp)
function GMI:AddToSection(name)
	local add = mlist:AddItem(name)
	add:SetCellText(0, name)
	add:SetCellText(1, tostring(item_price[name]))
	add:SetCellText(2, tostring(rarity[name]))
	add:SetBackgroundOddColor(raritycolor[rarity[name]])
	add:SetBackgroundEvenColor(raritycolor[rarity[name]])
	add:SetBackgroundHoverColor(Color(255,255,255,150))
	add:SetBackgroundHoverColor(Color(255,255,255,150))
	add:SetBackgroundOddSelectedColor(Color(255,255,255,100))
	add:SetBackgroundEvenSelectedColor(Color(255,255,255,100))
end

function GMI:SelectRow(list)
	local item = list:GetSelectedRow():GetCellText(0)
	if item and reference[item] then
		selecteditem = item
		price = tonumber(list:GetSelectedRow():GetCellText(1)) or 0
	else
		return 
	end
end

function GMI:Purchase(btn)
	if not selecteditem or not price or selecteditem == "none" or not reference[selecteditem] or type(price) ~= "number" then return end -- error return
	if LocalPlayer:GetMoney() < price then
		Chat:Print("Not enough credits to buy item", Color(255, 255, 0))
	else
		if CanAddItemToInventory(selecteditem) == true then
			Network:Send("GMIBuy", {item = selecteditem})
			GMI:Close()
		else
			Chat:Print("Inventory Category Full", Color(255, 255, 0))
		end
	end
end

function GMI:BackButtonPress()
	for name, list in pairs(lists) do
		list:Hide()
	end
	InMainScreen = true
	backbtn:Hide()
	craftbtn:Hide()
	selecteditem = "none"
end
function GMI:HoverEnterMain(btn)
	local name = btn:GetName()
	if name == "EnterButton" then
		drawRedImg = true
	end
end
function GMI:HoverLeaveMain(btn)
	local name = btn:GetName()
	if name == "EnterButton" then
		drawRedImg = nil
	end
end
function GMI:PressMain(btn)
	if not self.Window:GetVisible() then return end
	local name = btn:GetName()
	print(tostring(name))
	if name == "EnterButton" then
		print("ENTERED")
		mlist:Show()
		InMainScreen = false
	end
end
function DrawShadowedText(pos,str,col1,col2,size,moveamt)
	Render:DrawText(
		pos + moveamt,
		str,
		col2,
		size
		)
	Render:DrawText(
		pos,
		str,
		col1,
		size
		)
end

function GMI:RenderImg()
	Mouse:SetCursor(0)
	basepos = self.Window:GetPosition() + Vector2(0, self.sizeY / 35)
	basesize = Vector2(self.Window:GetSize().x / 1.005, self.Window:GetSize().y / 1.1)
	if InMainScreen == false then
		mlist:SetSize(Vector2(basesize.x * .95, basesize.y * .85))
		craftbtn:SetPositionRel(Vector2(.40, .8))
		craftbtn:Show()
		return
	end
	EnterButton:SetSize((basesize / 5) + Vector2((basesize.x/6), 0) - Vector2(0,basesize.y/13))
	EnterButton:SetPosition(basepos + Vector2(self.Window:GetWidth()/3.2,self.Window:GetHeight()/1.4))
	EnterButton:BringToFront()
	
	if InMainScreen == true then
		GMI_MainImg:Draw(basepos, basesize, Vector2(0, 0), Vector2(1, 1))
		if drawRedImg then
			GMI_EnterGreen:Draw(basepos, basesize, Vector2(0, 0), Vector2(1, 1))
		else
			GMI_EnterRed:Draw(basepos, basesize, Vector2(0, 0), Vector2(1, 1))
		end
	end
end
function GMI:ChatOpen(args)
	if args.text == "/gmi" then
		self:Open()
		print(os.time())
		mlist:Sort(2)
		return false
	end
end
function GMI:RestrictMovement(args)
	if self.Window:GetVisible() then
		return false
	end
end
function GMI:Open()
	self.RestrictEvent = Events:Subscribe("LocalPlayerInput", self, self.RestrictMovement)
	Mouse:SetVisible(true)
	self.sizeX = Render.Size.x
	self.sizeY = Render.Size.y
	self.Window:Show()
	InMainScreen = true
	backbtn:Hide()
	craftbtn:Hide()
	selecteditem = "none"
	EnterButton:BringToFront()
	EnterButton:SetEnabled(true)
	EnterButton:Show()
end
function GMI:GetOpen()
	if not self.Window then return false end
	if self.Window:GetVisible() then
		return true
	end
	return false
end
function GMI:Close()
	if self.RestrictEvent then
		Events:Unsubscribe(self.RestrictEvent)
		self.RestrictEvent = nil
	end
	EnterButton:Hide()
	self.Window:SendToBack()
	mlist:SendToBack()
	EnterButton:SendToBack()
	curcraftingitem = nil
	Mouse:SetVisible(false)
	self.Window:Hide()
end

function GMI:GiveGMIItem(args) -- receives item
	if not reference[args.item] then return end
	Events:Fire("AddToInventory", {add_item = args.item, add_amount = 1})
	Chat:Print("Added Item", Color(0, 255, 0))
end

GMI = GMI()

function CanAddItemToInventory(item)
	local category = reference[item]
	if not category then return end
	Events:Fire("UpdateSharedObjectInventory")
	local inventory_table = SharedObject.GetByName("ClientSharedInventory"):GetValue("INV")
	local max_table = LocalPlayer:GetValue("CatMaxes")
	if max_table then
		max = max_table[category] -- canot be local or gets nil value
	end
	if table.count(inventory_table[category]) < max then -- if number of entries in category is less than the set max
		return true
	else
		local stack_count = 0
		local limit = stacklimit[item]
		for index, lootstring in pairs(inventory_table[reference[item]]) do
			stack_count = 0
			if GetLootName(lootstring) == item then
				if stack_count < limit then
					return true
				end
			end
		end
	end
	return false
end

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
	return tonumber(string.match(lootstring, '%d+'))
end
