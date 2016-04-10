class 'Crafting'
function Crafting:__init()
	--print("Crafting Initialized")
	
	foodLvlReq = 0
	socialLvlReq = 2
	rawLvlReq = 3
	weaponryLvlReq = 10
	utilityLvlReq = 5
	buildLvlReq = 10
	
	selecteditem = "none"
	currentsection = ""
	
	InMainScreen = true
	
	UtilityImg = Image.Create(AssetLocation.Resource, "Utility")
	UtilityGrayImg = Image.Create(AssetLocation.Resource, "UtilityGray")
	RawImg = Image.Create(AssetLocation.Resource, "Raw")
	RawGrayImg = Image.Create(AssetLocation.Resource, "RawGray")
	BuildImg = Image.Create(AssetLocation.Resource, "Build")
	BuildGrayImg = Image.Create(AssetLocation.Resource, "BuildGray")
	SocialImg = Image.Create(AssetLocation.Resource, "Social")
	SocialGrayImg = Image.Create(AssetLocation.Resource, "SocialGray")
	WeaponryImg = Image.Create(AssetLocation.Resource, "Weaponry")
	WeaponryGrayImg = Image.Create(AssetLocation.Resource, "WeaponryGray")
	FoodImg = Image.Create(AssetLocation.Resource, "Food")
	FoodGrayImg = Image.Create(AssetLocation.Resource, "FoodGray")
	
	
	self.Window = Window.Create()
	self.Window:Hide()
	self.sizeX = Render.Size.x
	self.sizeY = Render.Size.y
	self.windowpos = Vector2(self.sizeX / 2, self.sizeY / 2) - Vector2(self.sizeX / 5, self.sizeY / 5)
	self.windowsize = Vector2(self.sizeX / 2.5, self.sizeY / 2.5)
	self.Window:SetSize(self.windowsize)
	self.Window:SetPosition(self.windowpos)
	self.Window:SetTitle("Crafting Menu")
	self.Window:Subscribe("PostRender", self, self.RenderImg)
	self.Window:Subscribe("WindowClosed", self, self.Close)
	
	textscale = 0.05
	textsize = self.Window:GetSize().x * textscale
	
	basepos = self.Window:GetPosition() + Vector2(self.sizeX / 500, self.sizeY / 30)
	basesize = Vector2(self.Window:GetSize().x / 3.1, self.Window:GetSize().y / 2.25)
	basex2 = Vector2(basesize.x + (basesize.x / 50), 0)
	basex3 = basex2 + Vector2(basesize.x,0)
	basey = Vector2(0,basesize.y + (basesize.y / 50))
	
	self.MBs = {}
	for i=1,6 do
		local name = "MB"..tostring(i)
		local name2 = name
		local func1 = name.."_HoverEnter"
		local func2 = name.."_HoverLeave"
		name = Button.Create()
		name:SetText("")---------------------------- 1   2   3
		name:SetSize(basesize) --------------------- 4   5   6
		self:SetMBPosition(i,name)
		name:Subscribe("HoverEnter", self, self.HoverEnterMB)
		name:Subscribe("HoverLeave", self, self.HoverLeaveMB)
		name:Subscribe("Press", self, self.PressMB)
		name:SetBackgroundVisible(false)
		name:SetEnabled(false)
		name:SetName(name2)
		self.MBs[name2] = name
		self.MBs[name2].alpha = 0
		self.MBs[name2].timer = Timer()
		self.MBs[name2].timerstate = 0
	end
	
	lists = {}
	lists["foodList"] = SortedList.Create(self.Window)
	lists["weaponryList"] = SortedList.Create(self.Window)
	lists["socialList"] = SortedList.Create(self.Window)
	lists["utilityList"] = SortedList.Create(self.Window)
	lists["rawList"] = SortedList.Create(self.Window)
	lists["buildList"] = SortedList.Create(self.Window)
	for name, list in pairs(lists) do
		list:AddColumn("Item Name")
		list:AddColumn("Rarity", self.Window:GetSize().y / 9)
		list:Hide()
		list:Subscribe("RowSelected", self, self.SelectRow)
	end
	craftbtn = Button.Create(self.Window)
	local btntext = ""
	craftbtn:SetText(btntext)
	craftbtn:SetTextSize(15)
	craftbtn:SetSize(Vector2(self.Window:GetSize().x / 10,self.Window:GetSize().y  / 12))
	craftbtn:SetPositionRel(Vector2(0.66 - (craftbtn:GetWidthRel()/2),0.825))
	craftbtn:Hide()
	craftbtn:SetToggleable(true)
	craftbtn:Subscribe("Press", self, self.CraftButtonPress)
	
	backbtn = Button.Create(self.Window)
	backbtn:SetText("Back")
	backbtn:SetTextSize(15)
	backbtn:SetSize(Vector2(self.Window:GetSize().x / 10,self.Window:GetSize().y  / 12))
	backbtn:SetPositionRel(Vector2(0.33,0.8))
	backbtn:Hide()
	backbtn:Subscribe("Press", self, self.BackButtonPress)
	craftingTimer = Timer()
	for name,tb in pairs(cRecipes) do 
		self:AddToSection(name)
	end
	for name, list in pairs(lists) do
		list:Sort(1)
	end
	--Events:Subscribe("LocalPlayerChat", self, self.ChatOpen)
	Events:Subscribe("ModuleUnload", self, self.Unload)
	LocalPlayer:SetValue("Crafting_Initialized", 1)
	Events:Subscribe("ModulesLoad", self, self.AddHelp)
	Events:Subscribe("ModuleUnload", self, self.RemoveHelp)

end

function Crafting:AddHelp()
    Events:Fire( "HelpAddItem",
        {
            name = "Crafting",
            text = 
                "Crafting is an extremely good way to obtain rare items using other items. "..
                "To begin crafting, you must find a crafting table.  These are found in all " ..
                "safezones, but if you craft your own table you can place and use it anywhere. "..
				"Press E while looking at the table to use it.  Some sections are locked until "..
				"you reach a certain level.  The materials you have are listed in green while the "..
				"materials you do not have are listed in red.  Once you have all the required "..
				"materials, you can hit the craft button to begin crafting.  Feel free to navigate "..
				"other areas of the menu while you craft, but don't move or exit the menu, otherwise "..
				"the crafting will cancel and you will have to start over.  Some items take longer than "..
				"others to craft."
        } )
end

function Crafting:RemoveHelp()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Crafting"
        } )
end

function Crafting:CheckRightClick()
	if InMainScreen then return end
	if not Key:IsDown(VirtualKey.RButton) then return end
	for name, list in pairs(lists) do
		list:Hide()
	end
	InMainScreen = true
	backbtn:Hide()
	craftbtn:Hide()
	self:ToggleEnabledMBs()
	selecteditem = "none"
end
function Crafting:AddToSection(name)
	local section = string.lower(tostring(reference[name]))
	local sectionname = section.."List"
	local list = lists[sectionname]
	local add = list:AddItem(name)
	add:SetCellText(0, name)
	add:SetCellText(1, tostring(rarity[name]))
	add:SetBackgroundOddColor(raritycolor[rarity[name]])
	add:SetBackgroundEvenColor(raritycolor[rarity[name]])
	add:SetBackgroundHoverColor(Color(255,255,255,150))
	add:SetBackgroundHoverColor(Color(255,255,255,150))
	add:SetBackgroundOddSelectedColor(Color(255,255,255,100))
	add:SetBackgroundEvenSelectedColor(Color(255,255,255,100))
end
function Crafting:SelectRow(list)
	self:LoadPage(list:GetSelectedRow():GetCellText(0))
end
function Crafting:LoadPage(item)
	if not item then return end
	selecteditem = item
	if curcraftingitem then
		craftbtn:SetText("Cancel")
		craftbtn:SetTextNormalColor(Color(255,0,0))
		craftbtn:SetTextHoveredColor(Color(255,0,0))
		craftbtn:SetTextPressedColor(Color(255,0,0))
		craftbtn:SetToggleState(true)
	end
	if curcraftingitem then
		craftbtn:Show()
	elseif not curcraftingitem and selecteditem ~= "none" and CheckIfCanCraft() then
		craftbtn:Show()
		craftbtn:SetText("Craft "..cRecipes[item].amtGet)
		craftbtn:SetTextNormalColor(Color(255,255,255))
		craftbtn:SetTextHoveredColor(Color(255,255,255))
		craftbtn:SetTextPressedColor(Color(255,255,255))
	else
		craftbtn:Hide()
	end
end
function Crafting:CraftButtonPress(btn)
	if curcraftingitem then
		curcraftingitem = nil
		if selecteditem ~= "none" then
			Crafting:LoadPage(selecteditem)
		else
			craftbtn:Hide()
		end
		return
	end
	if selecteditem == "none" then return end
	if not LocalPlayer:GetValue("CraftingLevel") then return end
	if tonumber(Crypt34(LocalPlayer:GetValue("CraftingLevel"))) < cRecipes[selecteditem].craftReq then
		Chat:Print("You do not have enough ", Color.Red, "Crafting Proficiency ", Color(255,255,0), "to craft this item!", Color.Red)
		craftbtn:SetToggleState(false)
		return
	end
	curcraftingitem = selecteditem
	craftingTimer:Restart()
	craftbtn:SetText("Cancel")
	craftbtn:SetToggleState(true)
	craftbtn:SetTextNormalColor(Color(255,0,0))
	craftbtn:SetTextHoveredColor(Color(255,0,0))
	craftbtn:SetTextPressedColor(Color(255,0,0))
	--craftbtn:Hide()
	ostime = os.time()
end
function CheckIfCanCraft(item)
	if selecteditem == "none" and not curcraftingitem then return false end
	if not item then item = selecteditem end
	Events:Fire("UpdateSharedObjectInventory")
	
	local inventory_table = SharedObject.GetByName("ClientSharedInventory"):GetValue("INV")
	if not inventory_table then return false end
	local numMaterialsNeeded = (table.count(cRecipes[item])-3)/2
	local numMaterialsHave = 0
	for i=1,numMaterialsNeeded do
		local strp1 = "M"..tostring(i)
		local strp2 = strp1.."a"
		local itemneed = cRecipes[item][strp1]
		local amount = cRecipes[item][strp2]
		for category, loot_table in pairs(inventory_table) do
			for index, lootstring in pairs(loot_table) do
				if GetLootName(lootstring) == itemneed then
					amount = amount - GetLootAmount(lootstring)
				end
			end
		end
		if amount <= 0 then
			numMaterialsHave = numMaterialsHave + 1
		end
	end
	if numMaterialsHave == numMaterialsNeeded then return true end
	return false
end
function CheckHasItem(item, i)
	local inventory_table = SharedObject.GetByName("ClientSharedInventory"):GetValue("INV")
	if not inventory_table then return false end
	local strp1 = "M"..tostring(i)
	local strp2 = strp1.."a"
	local item = cRecipes[selecteditem][strp1]
	local amount = cRecipes[selecteditem][strp2]
	for index, lootstring in pairs(inventory_table[reference[item]]) do
		if GetLootName(lootstring) == item then
			amount = amount - GetLootAmount(lootstring)
		end
	end
	if amount <= 0 then
		return true
	end
	return false
end
	
function Crafting:BackButtonPress()
	for name, list in pairs(lists) do
		list:Hide()
	end
	InMainScreen = true
	backbtn:Hide()
	craftbtn:Hide()
	self:ToggleEnabledMBs()
	selecteditem = "none"
end
function Crafting:SetMBPosition(i,button)
	if i == 1 then
		button:SetPosition(basepos)
	elseif i == 2 then
		button:SetPosition(basepos + basex2)
	elseif i == 3 then
		button:SetPosition(basepos + basex3)
	elseif i == 4 then
		button:SetPosition(basepos + basey)
	elseif i == 5 then
		button:SetPosition(basepos + basey + basex2)
	elseif i == 6 then
		button:SetPosition(basepos + basey + basex3)
	end
end
function Crafting:SetMBSize(button)
	button:SetSize(basesize)
end
function Crafting:HoverEnterMB(btn)
	local name = btn:GetName()
	self.MBs[name].timerstate = 1
end
function Crafting:HoverLeaveMB(btn)
	local name = btn:GetName()
	self.MBs[name].timerstate = 2
end
function Crafting:PressMB(btn)
	if not self.Window:GetVisible()  then return end
	local name = btn:GetName()
	if not LocalPlayer:GetValue("Level") then return end
	if name == "MB1" and tonumber(LocalPlayer:GetValue("Level")) >= foodLvlReq then
		self:ShowFoodSection()
		backbtn:Show()
		currentsection = "Food"
	elseif name == "MB2" and tonumber(LocalPlayer:GetValue("Level")) >= weaponryLvlReq then
		self:ShowWeaponrySection()
		backbtn:Show()
		currentsection = "Weaponry"
	elseif name == "MB3" and tonumber(LocalPlayer:GetValue("Level")) >= socialLvlReq then
		self:ShowSocialSection()
		backbtn:Show()
		currentsection = "Social"
	elseif name == "MB4" and tonumber(LocalPlayer:GetValue("Level")) >= utilityLvlReq then
		self:ShowUtilitySection()
		backbtn:Show()
		currentsection = "Utility"
	elseif name == "MB5" and tonumber(LocalPlayer:GetValue("Level")) >= rawLvlReq then
		self:ShowRawSection()
		backbtn:Show()
		currentsection = "Raw"
	elseif name == "MB6" and tonumber(LocalPlayer:GetValue("Level")) >= buildLvlReq then
		self:ShowBuildSection()
		backbtn:Show()
		currentsection = "Build"
	end
end
function Crafting:ToggleEnabledMBs()
	for name, button in pairs(self.MBs) do
		if button:GetEnabled() then
			button:SetEnabled(false)
		else
			button:SetEnabled(true)
		end
	end
end
function CheckIfCraftingItemIfSoThenShowButton()
	if curcraftingitem then
		craftbtn:Show()
	end
end
function Crafting:ShowFoodSection()
	self:ToggleEnabledMBs()
	InMainScreen = false
	self.Window:BringToFront()
	lists["foodList"]:Show()
	lists["foodList"]:SetSize(basesize + Vector2(0,basesize.y))
	lists["foodList"]:BringToFront()
	CheckIfCraftingItemIfSoThenShowButton()
end
function Crafting:ShowWeaponrySection()
	self:ToggleEnabledMBs()
	InMainScreen = false
	self.Window:BringToFront()
	lists["weaponryList"]:Show()
	lists["weaponryList"]:SetSize(basesize + Vector2(0,basesize.y))
	lists["weaponryList"]:BringToFront()
	CheckIfCraftingItemIfSoThenShowButton()
end
function Crafting:ShowSocialSection()
	self:ToggleEnabledMBs()
	InMainScreen = false
	self.Window:BringToFront()
	lists["socialList"]:Show()
	lists["socialList"]:SetSize(basesize + Vector2(0,basesize.y))
	lists["socialList"]:BringToFront()
	CheckIfCraftingItemIfSoThenShowButton()
end
function Crafting:ShowUtilitySection()
	self:ToggleEnabledMBs()
	InMainScreen = false
	self.Window:BringToFront()
	lists["utilityList"]:Show()
	lists["utilityList"]:SetSize(basesize + Vector2(0,basesize.y))
	lists["utilityList"]:BringToFront()
	CheckIfCraftingItemIfSoThenShowButton()
end
function Crafting:ShowRawSection()
	self:ToggleEnabledMBs()
	InMainScreen = false
	self.Window:BringToFront()
	lists["rawList"]:Show()
	lists["rawList"]:SetSize(basesize + Vector2(0,basesize.y))
	lists["rawList"]:BringToFront()
	CheckIfCraftingItemIfSoThenShowButton()
end
function Crafting:ShowBuildSection()
	self:ToggleEnabledMBs()
	InMainScreen = false
	self.Window:BringToFront()
	lists["buildList"]:Show()
	lists["buildList"]:SetSize(basesize + Vector2(0,basesize.y))
	lists["buildList"]:BringToFront()
	CheckIfCraftingItemIfSoThenShowButton()
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
function DrawItemInfo()
	textmoveamt = Vector2(Render:GetTextWidth(selecteditem, textsize)/2,0)
	raritystr = "Rarity: "..rarity[selecteditem]
	descstr = "\""..itemdesc[selecteditem].."\""
	materialstr = "Required Materials:"
	lvlreqstr = "Required Crafting Proficiency: "..cRecipes[selecteditem].craftReq
	textmoveamt2 = Vector2(Render:GetTextWidth(raritystr, textsize /2)/2,0)
	textmoveamt3 = Vector2(Render:GetTextWidth(descstr, textsize /1.85)/2,0)
	textmoveamt4 = Vector2(Render:GetTextWidth(materialstr, textsize /2)/2,0)
	textmoveamt5 = Vector2(Render:GetTextWidth(lvlreqstr, textsize /2)/2,0)
	oldraritycol = raritycolor[rarity[selecteditem]]
	textraritycol = Color(oldraritycol.r,oldraritycol.g,oldraritycol.b)
	-- BIG ITEM TITLE
	DrawShadowedText(
		centertextpos - textmoveamt,
		selecteditem,
		Color(255,255,255),
		Color(0,0,0),
		textsize,
		(basesize / 100)
		)
	-- BIG ITEM TITLE UNDERLINE
	Render:DrawLine(
		centertextpos + textmoveamt + Vector2(0,Render:GetTextHeight(selecteditem, textsize) / 1.25),
		centertextpos - textmoveamt + Vector2(0,Render:GetTextHeight(selecteditem, textsize) / 1.25),
		Color(255,255,255)
		)
	--RARITY TITLE
	DrawShadowedText(
		centertextpos - textmoveamt2 + Vector2(0,Render:GetTextHeight(selecteditem, textsize)),
		raritystr,
		textraritycol,
		Color(0,0,0),
		textsize / 2,
		(basesize / 250)
		)
	--ITEM DESCRIPTION
	DrawShadowedText(
		centertextpos - textmoveamt3 + Vector2(0,Render:GetTextHeight(selecteditem, textsize)*2.25),
		descstr,
		Color(230,230,230),
		Color(0,0,0),
		textsize / 1.85,
		(basesize / 150)
		)
	--REQUIRED LEVEL TITLE
	DrawShadowedText(
		centertextpos - textmoveamt5 + Vector2(0,Render:GetTextHeight(selecteditem, textsize)*3.25),
		lvlreqstr,
		Color(225,221,0),
		Color(0,0,0),
		textsize / 2,
		(basesize / 250)
		)
	--MATERIALS TITLE
	DrawShadowedText(
		centertextpos - textmoveamt4 + Vector2(0,Render:GetTextHeight(selecteditem, textsize)*3.75),
		materialstr,
		Color(219,124,0),
		Color(0,0,0),
		textsize / 2,
		(basesize / 250)
		)
	--LIST MATERIALS NEEDED
	local numMaterialsNeeded = (table.count(cRecipes[selecteditem])-3)/2
	for i=1,numMaterialsNeeded do
		local strp1 = "M"..tostring(i)
		local strp2 = strp1.."a"
		local cmaterialstr = "("..cRecipes[selecteditem][strp2]..") "..cRecipes[selecteditem][strp1]
		local txtmoveamt = Vector2(Render:GetTextWidth(cmaterialstr, textsize /2.5)/2,0)
		local craftitem = cRecipes[selecteditem][strp1]
		local color = Color(200,0,0)
		if CheckHasItem(selecteditem, i) then color = Color(0,200,0) end
		--local rcolor = Color(raritycolor[rarity[craftitem]].r,raritycolor[rarity[craftitem]].g,raritycolor[rarity[craftitem]].b)
		ymoveamt = Vector2(0,Render:GetTextHeight(cmaterialstr, textsize)*i/1.75)
		DrawShadowedText(
			centertextpos - txtmoveamt + Vector2(0,Render:GetTextHeight(selecteditem, textsize)*3.75) + ymoveamt,
			cmaterialstr,
			--Color(75,75,75),
			--SET COLOR TO GRAY WHEN THE PERSON DOES NOT HAVE THE AMOUNT OF CERTAIN ITEM NEEDED
			color,
			Color(0,0,0),
			textsize / 2.5,
			(basesize / 300)
			)
	end
end


t = os.time()

init = Events:Subscribe("PreTick", function()

if os.time() == t then return end

t = os.time()
timer = Timer()
Events:Unsubscribe(init); init = nil
Events:Subscribe("PreTick", function()

if os.time() == t then return end

local speed = timer:GetSeconds() / (os.time() - t)
if speed < 0.8 or speed > 1.2 then
	speedhax = true
else
	speedhax = nil
end

t = os.time()
timer:Restart()

end)

end)

function CompleteCraft(item)
	local numMaterialsNeeded = (table.count(cRecipes[item])-3)/2
	local numMaterialsHave = 0
	for i=1,numMaterialsNeeded do
		local strp1 = "M"..tostring(i)
		local strp2 = strp1.."a"
		local itemneeded = cRecipes[item][strp1]
		local amount = cRecipes[item][strp2]
		Events:Fire("DeleteFromInventory", {sub_item = itemneeded, sub_amount = amount})
	end
	Network:Send("CompleteCraft_Exp", item)
	Events:Fire("SendNotification", {txt = "Item finished crafting", image = "Information"})
	local num = 0
	for i = 1, cRecipes[curcraftingitem].amtGet do
		if CanAddItem(curcraftingitem, 1, reference[curcraftingitem]) then
			Events:Fire("AddToInventory", {add_item = curcraftingitem, add_amount = 1})
		else
			num = num + 1
		end
	end
	if num > 0 then
		local lootstring = tostring(curcraftingitem).." ("..tostring(num)..")"
		Events:Fire("Crafting_SpawnDropbox", lootstring)
		Chat:Print("Inventory overflow!", Color.Yellow)
	end
end
function DrawCraftingBar()
	if speedhax then
		curcraftingitem = nil
		if CheckIfCanCraft() then
			craftbtn:Show()
		end
	end
	if not curcraftingitem then return end
	local amt = cRecipes[curcraftingitem].amtGet
	local timetakes = cRecipes[curcraftingitem].craftTime
	local pos1 = Crafting.Window:GetPosition() + Vector2(0, Crafting.Window:GetHeight())
	local pos2 = Vector2(Crafting.Window:GetWidth(), Crafting.Window:GetHeight() / 15)
	local pos3 = Vector2(pos2.x * (craftingTimer:GetSeconds() / timetakes), pos2.y)
	if craftingTimer:GetSeconds() > timetakes then
		--finished crafting
		craftbtn:SetToggleState(false)
		if curcraftingitem and CheckIfCanCraft(curcraftingitem) then
			CompleteCraft(curcraftingitem)
			curcraftingitem = nil
			LocalPlayer:SetBaseState(438)
		end
		if CheckIfCanCraft() then
			craftbtn:Show()
			craftbtn:SetText("Craft "..cRecipes[selecteditem].amtGet)
			craftbtn:SetTextNormalColor(Color(255,255,255))
			craftbtn:SetTextHoveredColor(Color(255,255,255))
			craftbtn:SetTextPressedColor(Color(255,255,255))
		else
			craftbtn:Hide()
		end
		return
	end
	--local col = (craftingTimer:GetSeconds() * (255/timetakes))
	local col = 255
	Render:FillArea(pos1,pos2, Color(255,255,255,75))
	Render:FillArea(pos1,pos3, Color(0,175,0))
	local timeleft = string.format("%.1f", timetakes - craftingTimer:GetSeconds())
	local strtxt = "Crafting "..amt.." "..curcraftingitem.." ("..timeleft..")"
		DrawShadowedText(
			pos1 + Vector2(0,Crafting.Window:GetHeight() / 100) + Vector2(Crafting.Window:GetWidth()/2,0) - Vector2(Render:GetTextWidth(strtxt,textsize/2)/2,0),
			strtxt,
			Color(255,255,255),
			Color(0,0,0),
			textsize / 2,
			(basesize / 150)
			)
		
end
function Crafting:RenderImg()
	Mouse:SetCursor(0)
	basepos = self.Window:GetPosition() + Vector2(self.sizeX / 500, self.sizeY / 30)
	basesize = Vector2(self.Window:GetSize().x / 3.1, self.Window:GetSize().y / 2.25)
	basesize2 = Vector2(self.Window:GetSize().x / 6, self.Window:GetSize().y / 2.25)
	basex2 = Vector2(basesize.x + (basesize.x / 50), 0)
	basex3 = basex2 + Vector2(basesize.x + (basesize.x / 50),0)
	basey = Vector2(0,basesize.y + (basesize.y / 50))
	if curcraftingitem then
		DrawCraftingBar()
	end
	if not InMainScreen then
		self:CheckRightClick()
		textsize = self.Window:GetSize().x * textscale
		centertextpos = basepos + basex2 + (basex3 / 2)
		craftbtn:SetPositionRel(Vector2(0.66 - (craftbtn:GetWidthRel()/2),0.825))
		backbtn:SetPositionRel(Vector2(0.33,0.8))
		if selecteditem == "none" then
			local strtxt = currentsection.." Section"
			textmoveamt = Vector2(Render:GetTextWidth(strtxt, textsize)/2,0)
			textmoveamt2 = Vector2(Render:GetTextWidth("Select an item to begin", textsize/2)/2,0)
			DrawShadowedText(
				centertextpos - textmoveamt + Vector2(0,basesize.y / 3),
				strtxt,
				Color(255,255,255),
				Color(50,50,50),
				textsize,
				(basesize / 100)
				)
			DrawShadowedText(
				centertextpos - textmoveamt2 + Vector2(0,basesize.y / 3) + Vector2(0,Render:GetTextHeight(strtxt, textsize)),
				"Select an item to begin",
				Color(255,255,255),
				Color(50,50,50),
				textsize /2,
				(basesize / 100)
				)
		else
			DrawItemInfo()
		end
		for name, list in pairs(lists) do
			list:SetSize(basesize + Vector2(0,basesize.y))
			if not list:GetOnTop() then
				list:BringToFront()
			end
		end
		return
	end
	for name, button in pairs(self.MBs) do
		local i = string.gsub(name, "MB", "")
		self:SetMBPosition(tonumber(i),button)
		self:SetMBSize(button)
		button:BringToFront()
		if self.MBs[name].timerstate == 1 then
			self.MBs[name].timer:Restart()
			self.MBs[name].timerstate = 4
		elseif self.MBs[name].timerstate == 2 then
			self.MBs[name].timer:Restart()
			self.MBs[name].timerstate = 3
		end
		if self.MBs[name].timerstate == 3 then
			self.MBs[name].alpha = self.MBs[name].alpha - (self.MBs[name].timer:GetSeconds() * 255)
		elseif self.MBs[name].timerstate == 4 then
			self.MBs[name].alpha = self.MBs[name].alpha + (self.MBs[name].timer:GetSeconds() * 255)
		end
		if self.MBs[name].alpha > 255 then self.MBs[name].alpha = 255 end
		if self.MBs[name].alpha < 0 then
			self.MBs[name].alpha = 0
			self.MBs[name].timerstate = 0
		end
	end
	
	FoodGrayImg:Draw(basepos, basesize, Vector2(0, 0), Vector2(1, 1))
	WeaponryGrayImg:Draw(basepos + basex2, basesize, Vector2(0, 0), Vector2(1, 1))
	SocialGrayImg:Draw(basepos + basex3, basesize, Vector2(0, 0), Vector2(1, 1))
	UtilityGrayImg:Draw(basepos + basey, basesize, Vector2(0, 0), Vector2(1, 1))
	RawGrayImg:Draw(basepos + basey + basex2, basesize, Vector2(0, 0), Vector2(1, 1))
	BuildGrayImg:Draw(basepos + basey + basex3, basesize, Vector2(0, 0), Vector2(1, 1))
	
	if not LocalPlayer:GetValue("Level") then return end
	if tonumber(LocalPlayer:GetValue("Level")) >= weaponryLvlReq then --level req for weaponry
		WeaponryImg:SetAlpha(self.MBs["MB2"].alpha / 255)
		WeaponryImg:Draw(basepos + basex2, basesize, Vector2(0, 0), Vector2(1, 1))
	end
	if tonumber(LocalPlayer:GetValue("Level")) >= foodLvlReq then --level req for food
		FoodImg:SetAlpha(self.MBs["MB1"].alpha / 255)
		FoodImg:Draw(basepos, basesize, Vector2(0, 0), Vector2(1, 1))
	end
	if tonumber(LocalPlayer:GetValue("Level")) >= socialLvlReq then --level req for social
		SocialImg:SetAlpha(self.MBs["MB3"].alpha / 255)
		SocialImg:Draw(basepos + basex3, basesize, Vector2(0, 0), Vector2(1, 1))
	end
	if tonumber(LocalPlayer:GetValue("Level")) >= utilityLvlReq then --level req for utility
		UtilityImg:SetAlpha(self.MBs["MB4"].alpha / 255)
		UtilityImg:Draw(basepos + basey, basesize, Vector2(0, 0), Vector2(1, 1))
	end
	if tonumber(LocalPlayer:GetValue("Level")) >= rawLvlReq then --level req for raw
		RawImg:SetAlpha(self.MBs["MB5"].alpha / 255)
		RawImg:Draw(basepos + basey + basex2, basesize, Vector2(0, 0), Vector2(1, 1))
	end
	if tonumber(LocalPlayer:GetValue("Level")) >= buildLvlReq then --level req for build
		BuildImg:SetAlpha(self.MBs["MB6"].alpha / 255)
		BuildImg:Draw(basepos + basey + basex3, basesize, Vector2(0, 0), Vector2(1, 1))
	end
end
function Crafting:ChatOpen(args)
	if args.text == "/craft" then
		self:Open()
		return false
	end
end
function Crafting:RestrictMovement(args)
	if self.Window:GetVisible() then
		if args.input == Action.MoveBackward or
		args.input == Action.MoveForward or
		args.input == Action.MoveLeft or
		args.input == Action.MoveRight then
			self:Close()
		else
			return false
		end
	end
end
function SetMainButtonsEnabled(button, name)
	if name == "MB1" and tonumber(LocalPlayer:GetValue("Level")) >= foodLvlReq then
		button:SetEnabled(true)
	elseif name == "MB2" and tonumber(LocalPlayer:GetValue("Level")) >= weaponryLvlReq then
		button:SetEnabled(true)
	elseif name == "MB3" and tonumber(LocalPlayer:GetValue("Level")) >= socialLvlReq then
		button:SetEnabled(true)
	elseif name == "MB4" and tonumber(LocalPlayer:GetValue("Level")) >= utilityLvlReq then
		button:SetEnabled(true)
	elseif name == "MB5" and tonumber(LocalPlayer:GetValue("Level")) >= rawLvlReq then
		button:SetEnabled(true)
	elseif name == "MB6" and tonumber(LocalPlayer:GetValue("Level")) >= buildLvlReq then
		button:SetEnabled(true)
	end
end
function Crafting:Open()
	self.MBs = {}
	for i=1,6 do
		local name = "MB"..tostring(i)
		local name2 = name
		local func1 = name.."_HoverEnter"
		local func2 = name.."_HoverLeave"
		name = Button.Create()
		name:SetText("")---------------------------- 1   2   3
		name:SetSize(basesize) --------------------- 4   5   6
		self:SetMBPosition(i,name)
		name:Subscribe("HoverEnter", self, self.HoverEnterMB)
		name:Subscribe("HoverLeave", self, self.HoverLeaveMB)
		name:Subscribe("Press", self, self.PressMB)
		name:SetBackgroundVisible(false)
		name:SetEnabled(false)
		name:SetName(name2)
		self.MBs[name2] = name
		self.MBs[name2].alpha = 0
		self.MBs[name2].timer = Timer()
		self.MBs[name2].timerstate = 0
	end
	
	craftbtn:SetToggleState(false)
	self.RestrictEvent = Events:Subscribe("LocalPlayerInput", self, self.RestrictMovement)
	Mouse:SetVisible(true)
	self.sizeX = Render.Size.x
	self.sizeY = Render.Size.y
	self.Window:Show()
	InMainScreen = true
	for name, list in pairs(lists) do
		list:Hide()
	end
	InMainScreen = true
	backbtn:Hide()
	craftbtn:Hide()
	selecteditem = "none"
	for name, button in pairs(self.MBs) do
		button:BringToFront()
		if not LocalPlayer:GetValue("Level") then return end
		SetMainButtonsEnabled(button, name)
	end
	if not LocalPlayer:GetValue("Level") then return end
	local level = tonumber(LocalPlayer:GetValue("Level"))
	if level < weaponryLvlReq then --level req for weaponry
		--print(self.MBs["MB2"])
		local str = "Unlocked at level "..tostring(weaponryLvlReq)
		self.MBs["MB2"]:SetToolTip(str)
	end
	if level < foodLvlReq then --level req for food
		local str = "Unlocked at level "..tostring(foodLvlReq)
		self.MBs["MB1"]:SetToolTip(str)
	end
	if level < socialLvlReq then --level req for social
		local str = "Unlocked at level "..tostring(socialLvlReq)
		self.MBs["MB3"]:SetToolTip(str)
	end
	if level < utilityLvlReq then --level req for utility
		local str = "Unlocked at level "..tostring(utilityLvlReq)
		self.MBs["MB4"]:SetToolTip(str)
	end
	if level < rawLvlReq then --level req for raw
		local str = "Unlocked at level "..tostring(rawLvlReq)
		self.MBs["MB5"]:SetToolTip(str)
	end
	if level < buildLvlReq then --level req for build
		local str = "Unlocked at level "..tostring(buildLvlReq)
		self.MBs["MB6"]:SetToolTip(str)
	end
end
function Crafting:GetOpen()
	if not self.Window then return false end
	if self.Window:GetVisible() then
		return true
	end
	return false
end
function Crafting:Unload()
	--LocalPlayer:SetValue("Crafting_Initialized", nil)
end
function Crafting:Close()
	if self.RestrictEvent then
		Events:Unsubscribe(self.RestrictEvent)
		self.RestrictEvent = nil
	end
	self.Window:SendToBack()
	for name, list in pairs(lists) do
		list:SendToBack()
	end
	for name, button in pairs(self.MBs) do
		button:SendToBack()
		button:Hide()
	end
	curcraftingitem = nil
	Mouse:SetVisible(false)
	Scanner.crafting_open = false
	self.Window:Hide()
	Events:Fire("Crafting_Closed")
end
Crafting = Crafting()


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
function CanAddItem(item, number, category)
	local inv = SharedObject.GetByName("ClientSharedInventory"):GetValue("INV")
	if table.count(inv[category]) < LocalPlayer:GetValue("CatMaxes")[category] then return true end
		for index, lootstring in pairs(inv[category]) do
			if GetLootName(lootstring) == item then
				if GetLootAmount(lootstring) + number <= stacklimit[item] then
					return true
				end
			end
		end
	return false
end
