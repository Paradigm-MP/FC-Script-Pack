class 'Factions'

function Factions:__init()
	wno_bases = {}
	--
	convert_key = {}
	convert_key[65] = "a"
	convert_key[66] = "b"
	convert_key[67] = "c"
	convert_key[68] = "d"
	convert_key[69] = "e"
	convert_key[70] = "f"
	convert_key[71] = "g"
	convert_key[72] = "h"
	convert_key[73] = "i"
	convert_key[74] = "j"
	convert_key[75] = "k"
	convert_key[76] = "l"
	convert_key[77] = "m"
	convert_key[78] = "n"
	convert_key[79] = "o"
	convert_key[80] = "p"
	convert_key[81] = "q"
	convert_key[82] = "r"
	convert_key[83] = "s"
	convert_key[84] = "t"
	convert_key[85] = "u"
	convert_key[86] = "v"
	convert_key[87] = "w"
	convert_key[88] = "x"
	convert_key[89] = "y"
	convert_key[90] = "z"
	convert_key[32] = " "
	convert_key[190] = "."
	convert_key[49] = "1"
	convert_key[50] = "2"
	convert_key[51] = "3"
	convert_key[52] = "4"
	convert_key[53] = "5"
	convert_key[54] = "6"
	convert_key[55] = "7"
	convert_key[56] = "8"
	convert_key[57] = "9"
	convert_key[48] = "0"
    --Network:Subscribe("FactionMembers", function(args) factionMembers = args end)
    self.mySteamID = LocalPlayer:GetSteamId().id
	self.faction_menu_open = false
    self.screen_size = Render.Size
	self.ticks = 0
	self.currentselect_name = ""
	self.currentselect_steamid = ""
	self.rank = 1
	LocalPlayer:SetValue("FactionRank", self.rank)
	self.basepos = ""
	self.render_area = false
	self.first_render_area = true
	self.notice = ""
	self.type = false
	self.old_text = ""
	list_items = {}
	self.render_message = false
	self.message = ""
	self.credits = "loading..."
	self.clan_level = 0
	bases = {}
	triggers = {}
	reference_triggers = {}
	
    -- Receive table with faction members in format: {[steamid] = {"FactionName", Color(1,2,3)}}
    Network:Subscribe("FactionMembers", self, self.ReceiveMembers)
    -- Receive table with allied factions in format: {[faction] = {["Faction1"] = true,["Faction2"] = true}}
    Network:Subscribe("AlliedFactions", self, self.ReceiveAllies)
    -- Receive table with enemy factions in format: {[faction] = {["Faction1"] = true,["Faction2"] = true}}
    Network:Subscribe("EnemyFactions", self, self.ReceiveEnemies)
    -- Render Faction tags
    Events:Subscribe( "Render", self, self.Render)
    
    Events:Subscribe("LocalPlayerExplosionHit", self, self.HandleDamage)
    Events:Subscribe("LocalPlayerBulletHit", self, self.HandleDamage)
    Events:Subscribe("LocalPlayerForcePulseHit", self, self.HandleDamage)
	--
	Network:Subscribe("SendTables", self, self.InitTables)
	Network:Subscribe("UpdateFactionMembers", self, self.UpdateFactionMembers)
	Network:Subscribe("ReceiveNewNotice", self, self.NewNotice)
	Network:Subscribe("UpdateFactionBase", self, self.NewBase)
	Network:Subscribe("RenderFactionMessage", self, self.ReceiveMessage)
	Network:Subscribe("UpdateClanCredits", self, self.NewCredits)
	Network:Subscribe("UpdateClanLevel", self, self.NewLevel)
	Network:Subscribe("JoinFactionInit", self, self.JoinFactionInit)
	Network:Subscribe("UpdateAllFactionBases", self, self.UpdateAllFactionBases)
	--
	Events:Subscribe("KeyDown", self, self.KeyDown)
	Events:Subscribe("PreTick", self, self.PreTick)
	Events:Subscribe("PostTick", self, self.PostTick)
	Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
	Events:Subscribe("GameRender", self, self.GameRender)
	Events:Subscribe("MouseDown", self, self.MouseDown)
	Events:Subscribe("ShapeTriggerEnter", self, self.ShapeTriggerEnter)
	Events:Subscribe("ShapeTriggerExit", self, self.ShapeTriggerExit)
	Events:Subscribe("WorldNetworkObjectCreate", self, self.WNOCreate)
	Events:Subscribe("WorldNetworkObjectDestroy", self, self.WNODestroy)
	Events:Subscribe("NetworkObjectValueChange", self, self.WNOValueChange)
	Events:Subscribe("LocalPlayerChat", self, self.LocalPlayerChat)
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
	-- START GUI CODE --------------
	base = Window.Create()
	base:SetSize(Vector2(self.screen_size.x * .4, self.screen_size.y * .45))
	base:SetPosition(Vector2(self.screen_size.x * .55, self.screen_size.y * .125))
	base:SetTitle("Clan Menu")
	base:SetVisible(false)
	base:Subscribe("WindowClosed", self, self.WindowClose)
	--
	list = SortedList.Create(base)
	list:SetButtonsVisible( true )
	list:SetSize(Vector2(base:GetSize().x * .45, base:GetSize().y * .95))
	list:AddColumn("Name", list:GetSize().y * .27)
	list:AddColumn("Rank", list:GetSize().y * .1)
	list:AddColumn("Level", list:GetSize().y * .1)
	list:AddColumn("Last Seen", list:GetSize().y * .27)
	list:SetVisible(true)
	list:Subscribe("RowSelected", self, self.RowSelect)
	--
	admin_btn = Button.Create(base, "admin_btn")
	admin_btn:SetPositionRel(Vector2(.475, .025))
	admin_btn:SetSize(Vector2(base:GetSize().x * .175, base:GetSize().y * .125))
	admin_btn:SetVisible(true)
	admin_btn:SetText("Admin Panel")
	admin_btn:Subscribe("Press", self, self.ButtonPress)
	admin_btn:SetDataBool("InPanel", false)
	--
	notice_btn = Button.Create(base, "notice_btn")
	notice_btn:SetPositionRel(Vector2(.75, .025))
	notice_btn:SetSize(Vector2(base:GetSize().x * .175, base:GetSize().y * .125))
	notice_btn:SetVisible(true)
	notice_btn:Subscribe("Press", self, self.ButtonPress)
	notice_btn:SetText("Read Notice")
	--
	base_btn = Button.Create(base, "base_btn")
	base_btn:SetPositionRel(Vector2(.75, .5))
	base_btn:SetSize(Vector2(base:GetSize().x * .175, base:GetSize().y * .125))
	base_btn:SetVisible(true)
	base_btn:Subscribe("Press", self, self.ButtonPress)
	base_btn:SetDataBool("InPanel", false)
	base_btn:SetText("Return to base")
	--
	notice_window = Window.Create()
	notice_window:SetSize(Vector2(self.screen_size.x * .4, self.screen_size.y * .45))
	notice_window:SetPosition(Vector2(self.screen_size.x * .10, self.screen_size.y * .125))
	notice_window:SetTitle("Notice")
	notice_window:SetVisible(false)
	notice_window:Subscribe("WindowClosed", self, self.WindowClose)
	--
	notice_window_lbl = Window.Create()
	notice_window_lbl:SetSize(Vector2(self.screen_size.x * .4, self.screen_size.y * .45))
	notice_window_lbl:SetPosition(Vector2(self.screen_size.x * .10, self.screen_size.y * .125))
	notice_window_lbl:SetTitle("Notice")
	notice_window_lbl:SetVisible(false)
	notice_window_lbl:Subscribe("WindowClosed", self, self.WindowClose)
	--
	notice_txtbx = TextBoxMultiline.Create(notice_window)
	notice_txtbx:SetDock(GwenPosition.Fill)
	notice_txtbx:SetLineSpacing(1.5)
	notice_txtbx:SetTextSize(TextSize.Default * 1.15)
	notice_txtbx:SetWrap(true)
	notice_txtbx:SetText("Test clan notice")
	--notice_txtbx:SetAlignment(GwenPosition.CenterH)
	--
	notice_lbl = Label.Create(notice_window_lbl)
	notice_lbl:SetDock(GwenPosition.Fill)
	notice_lbl:SetLineSpacing(1.5)
	notice_lbl:SetTextSize(TextSize.Default * 1.15)
	notice_lbl:SetWrap(true)
	notice_lbl:SetText("Test clan notice")
	--notice_lbl:SetAlignment(GwenPosition.CenterH)
	--
	admin_btn_kick = Button.Create(base, "admin_btn_kick")
	admin_btn_ban = Button.Create(base, "admin_btn_ban")
	admin_btn_promote = Button.Create(base, "admin_btn_promote")
	admin_btn_notice = Button.Create(base, "admin_btn_notice")
	admin_btn_landclaim = Button.Create(base, "admin_btn_landclaim")
	admin_btn_upgrade = Button.Create(base, "admin_btn_upgrade")
	--
	admin_btn_notice:SetDataBool("Editing", false)
	admin_btn_landclaim:SetDataBool("Claiming", false)
	--
	admin_btn_kick:SetText("Kick")
	admin_btn_ban:SetText("Ban")
	admin_btn_promote:SetText("Set Rank: ")
	admin_btn_notice:SetText("Edit Notice")
	admin_btn_landclaim:SetText("Choose Clan Base")
	admin_btn_upgrade:SetText("Upgrade Clan")
	--
	admin_btns = {} -- admin panel buttons
	admin_btns[1] = admin_btn_kick
	admin_btns[2] = admin_btn_ban
	admin_btns[3] = admin_btn_promote
	admin_btns[4] = admin_btn_notice
	admin_btns[5] = admin_btn_landclaim
	admin_btns[6] = admin_btn_upgrade
	--
	base_gui = {} -- main menu gui
	base_gui[1] = admin_btn
	base_gui[2] = notice_btn
	base_gui[3] = base_btn
	--
	admin_btn_kick:SetPositionRel(Vector2(.475, .2))
	admin_btn_ban:SetPositionRel(Vector2(.475, .35))
	admin_btn_promote:SetPositionRel(Vector2(.475, .5))
	admin_btn_notice:SetPositionRel(Vector2(.75, .2))
	admin_btn_landclaim:SetPositionRel(Vector2(.75, .5))
	admin_btn_upgrade:SetPositionRel(Vector2(.475, .65))
	--
	for index, btn in pairs(admin_btns) do
		btn:SetSize(Vector2(base:GetSize().x * .1, base:GetSize().y * .1))
		btn:SetVisible(false)
		btn:Subscribe("Press", self, self.ButtonPress)
	end
	admin_btn_landclaim:SetSize(Vector2(base:GetSize().x * .175, base:GetSize().y * .125))
	admin_btn_upgrade:SetSize(Vector2(base:GetSize().x * .175, base:GetSize().y * .125))
	--
	admin_btn_upgrade:SetToolTip("Upgrade clan with clan credits for higher capacity, larger base, and more")
	--
	admin_rank_numeric = Numeric.Create(base, "admin_rank_numeric")
	admin_rank_numeric:SetPositionRel(Vector2(admin_btn_promote:GetPositionRel().x + admin_btn_promote:GetSizeRel().x, admin_btn_promote:GetPositionRel().y + (admin_btn_promote:GetSizeRel().y / 4)))
	admin_rank_numeric:SetSize(Vector2(base:GetSize().x * .05, base:GetSize().y * .05))
	admin_rank_numeric:SetMaximum(3)
	admin_rank_numeric:SetMinimum(1)
	admin_rank_numeric:SetNegativeAllowed(false)
	admin_rank_numeric:SetVisible(false)
	--
	admin_broadcast = TextBoxMultiline.Create(base, "admin_broadcast")
	admin_broadcast:SetSize(Vector2(base:GetSize().x * .525, base:GetSize().y * .085))
	admin_broadcast:SetPositionRel(Vector2(.45, .825))
	admin_broadcast:SetVisible(false)
	admin_broadcast:SetTextSize(TextSize.Default * 1.2)
	admin_broadcast:Subscribe("TabPressed", self, self.TabPressed)
	admin_broadcast:SetToolTip("Broadcast a message to all the faction members online(press Tab to send)")
	--
	baseset = Vector2(base:GetSize().x * .01, base:GetSize().y * .135)
	--
	donate_btn = Button.Create(base, "donate_btn")
	donate_btn:SetPositionRel(Vector2(.475, .5))
	donate_btn:SetSize(Vector2(base:GetSize().x * .12, base:GetSize().y * .10))
	donate_btn:SetVisible(true)
	donate_btn:SetText("Donate:")
	donate_btn:Subscribe("Press", self, self.ButtonPress)
	--
	donate_numeric = Numeric.Create(base, "donate_numeric")
	donate_numeric:SetPositionRel(Vector2(donate_btn:GetPositionRel().x + donate_btn:GetSizeRel().x, donate_btn:GetPositionRel().y + (donate_btn:GetSizeRel().y / 5.5)))
	donate_numeric:SetSize(Vector2(base:GetSize().x * .095, base:GetSize().y * .065))
	donate_numeric:SetMaximum(999999)
	donate_numeric:SetMinimum(1)
	donate_numeric:SetNegativeAllowed(false)
	donate_numeric:SetVisible(true)
	--
	credits_lbl = Label.Create(base)
	credits_lbl:SetPositionRel(Vector2(donate_btn:GetPositionRel().x, donate_btn:GetPositionRel().y - .025))
	credits_lbl:SetSize(Vector2(base:GetSize().x * .175, base:GetSize().y * .035))
	credits_lbl:SetVisible(true)
	credits_lbl:SetTextColor(Color(0, 255, 0))
	credits_lbl:SetText("Clan Credits: " .. tostring(self.credits))
	--
	main_gui = {} -- disappear when go to Admin Panel
	main_gui[1] = donate_btn
	main_gui[2] = donate_numeric
	main_gui[3] = credits_lbl
	main_gui[4] = buymenu_btn
	-- END GUI CODE ----------------
	network_timer = Timer()
	render_timer = Timer()
	donation_timer = Timer()
end

function Factions:ReceiveMembers(args)
    --dprint("Receiving list of all online faction players")
   -- factionMembers = args
    --for k,v in pairs(factionMembers) do
      --  dprint(k .. " : { " .. v[1])
  --  end
end

function Factions:ReceiveAllies(args)
    --dprint("Receiving list of allied factions")
    alliedFactions = args
	--[[
    for k,v in pairs(alliedFactions) do
        dprint(k .. " allies:")
        for i,d in pairs(v) do
            dprint(i)
        end
    end]]--
end

function Factions:ReceiveEnemies(args)
    --dprint("Receiving list of enemy factions")
    enemyFactions = args
	--[[
    for k,v in pairs(enemyFactions) do
        dprint(k .. " enemies:")
        for i,d in pairs(v) do
			dprint(i)
        end
    end]]--
end

function Factions:ClientGetFaction(steamid)
    local theFaction = ""
    if factionMembers[steamid] ~= nil then
        theFaction = factionMembers[steamid][1]
    end
    return theFaction
end

function Factions:IsMyEnemy(steamid)
    local myFaction = self:ClientGetFaction(LocalPlayer:GetSteamId().id)
    local theirFaction = self:ClientGetFaction(steamid)
    if myFaction:len() > 0 and theirFaction:len() > 0 then
        local myEnemies = enemyFactions[myFaction]
        if myEnemies[theirFaction] then
            --dprint(myFaction .. " is enemies with " .. theirFaction)
            return true
        end
    end
    return false
end

function Factions:HandleDamage(args)
	if not args.attacker then return true end
    local attacker_faction = args.attacker:GetValue("Faction")
	if attacker_faction == "" then return true end -- if factionless
    if attacker_faction == self.myfaction or alliedFactions[attacker_faction] then
		if type(alliedFactions[attacker_faction]) == "table" then
			if table.count(alliedFactions[attacker_faction]) == 0 and attacker_faction ~= self.myfaction then return true end
		end
		--Chat:dPrint("Attacked by ally or faction member", Color(255, 0, 0))
        return false
    end
    return true
end

function Factions:Render()
	-- START BASEPOS PICK RENDER -------------
	if self.render_area == true then
		if self.first_render_area == true then
			self.center = LocalPlayer:GetPosition()
			self.first_render_area = false
		else
			local transform = Transform3()
			transform:Translate(self.center) -- move it down a bit
			transform:Rotate(Angle(0, 0.5 * math.pi, 0))
			Render:SetTransform(transform)
			Render:FillCircle(Vector3.Zero, 100, Color(255, 0, 0, 100))
			Render:ResetTransform()
		end
	end
	-- END BASEPOS PICK RENDER ---------------
	-- START MESSAGE RENDER ---------------
	if self.render_message == true then
		if render_timer:GetSeconds() > 10 then
			self.render_message = false
			self.message = ""
		else
			local width = Render:GetTextWidth(self.message, TextSize.Default * 4.0)
			Render:DrawText(Vector2(self.screen_size.x * .5 - (width / 2), self.screen_size.y * .125), self.message, Color(255, 0, 0), TextSize.Default * 4.0)
		end
	end
	-- END MESSAGE RENDER -----------------
end

function Factions:InitTables(args)
	--Chat:dPrint(tostring(args.myfaction), Color(0, 255, 0))
	--Chat:dPrint(tostring(args.allies), Color(0, 255, 0))
	--Chat:dPrint(tostring(args.enemies), Color(0, 255, 0))
	if args.notice == nil then
		self.notice = "<empty>"
	else
		self.notice = args.notice
	end
	if args.basepos == nil then
		self.basepos = ""
	else
		if string.len(tostring(args.basepos)) > 4 then
			local pos = string.split(tostring(args.basepos), ",")
			self.basepos = Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3]))
			--Chat:dPrint("My Basepos is: " .. tostring(self.basepos), Color(255, 255, 0))
		end
	end
	if args.credits then
		self.credits = tonumber(args.credits)
		credits_lbl:SetText("Clan Credits: " .. tostring(self.credits))
	end
	if args.level then
		self.clan_level = tonumber(args.level)
	end
	notice_txtbx:SetText(self.notice)
	notice_lbl:SetText(self.notice)
	
	--notice_txtbx:SetAlignment(GwenPosition.CenterH)
	--notice_lbl:SetAlignment(GwenPosition.CenterH)
	
	if #self.notice > 100 then
		Chat:Print("Faction Notice: ", Color(250, 190, 50), string.sub(self.notice, 0, 100) .. "...", Color.White)
	else
		Chat:Print("Faction Notice: ", Color(250, 190, 50), self.notice, Color.White)
	end
	factionMembers = args.myfaction
	alliedFactions = args.allies
	enemyFactions = args.enemies
	for numindex, itable in pairs(factionMembers) do -- iterate through my faction
		if itable.name and itable.rank and itable.last_seen and itable.steamid then
			if itable.steamid == tostring(LocalPlayer:GetSteamId().id) then
				self.rank = itable.rank -- crypt this shit
				LocalPlayer:SetValue("FactionRank", tonumber(self.rank))
				if tonumber(self.rank) >= 2 then -- officer or higher
					admin_broadcast:SetVisible(true)
				end
				break
			end
		end
	end
end

function Factions:UpdateFactionMembers(args) -- server updates faction members
	for k, v in pairs(factionMembers) do factionMembers[k] = nil end
	factionMembers = args.myfaction
	--[[
	for k, v in pairs(args.myfaction) do
		dprint("k: " .. tostring(k) .. " |||| v: " .. tostring(v))
	end]]--
	
	--Chat:dPrint("Client just received update to Faction members", Color(0, 255, 0))
	--Chat:dPrint("I'm in Faction: " .. tostring(LocalPlayer:GetValue("Faction")), Color(255, 0, 0))
end

function Factions:KeyDown(args)
	if args.key == string.byte("P") then
		if LocalPlayer:GetValue("Faction") == "" then
			Chat:Print("You must be in a faction to access the faction menu", Color(255, 34, 34))
			self.basepos = ""
			self.clan_level = 0
			base:Hide()
			LocalPlayer:SetValue("FactionRank", nil)
			return
		elseif self.type == true then
			return
		end
		notice_window:SetVisible(false)
		notice_window:SetKeyboardInputEnabled(false)
		base:SetVisible(not base:GetVisible())
		self.faction_menu_open = base:GetVisible()
		Mouse:SetVisible(self.faction_menu_open)
		if self.faction_menu_open == true then -- opened faction menu
			local player_count = 0
			for numindex, itable in pairs(factionMembers) do -- iterate through my faction
				if itable.name and itable.rank and itable.last_seen and itable.steamid then
					if itable.steamid == tostring(LocalPlayer:GetSteamId().id) then
						self.rank = itable.rank -- crypt this shit
						LocalPlayer:SetValue("FactionRank", tonumber(self.rank))
					end
					--dprint("name: " .. itable.name)
					--dprint("rank: " .. itable.rank)
					--dprint("steamid: " .. itable.steamid)
					local table_row = list:AddItem(itable.name)
					table_row:SetBackgroundHoverColor(Color(0, 0, 255, 15))
					table_row:SetBackgroundEvenSelectedColor(Color(255, 0, 0, 50))
					table_row:SetBackgroundOddSelectedColor(Color(255, 0, 0, 50))
					table_row:SetCellText(1, itable.rank)
					table_row:SetCellText(3, itable.last_seen)
					table_row:SetDataString("steamid", itable.steamid)
					list_items[table_row] = true
					player_count = player_count + 1
				end
			end
			base:SetTitle("Clan Menu  -  " .. tostring(self.myfaction) .. "  -  (" .. tostring(player_count) .. " / " .. tostring(self.clan_level * 5 + 20) .. ") members")
		elseif self.faction_menu_open == false then -- closed faction menu
			for table_row, bool in pairs(list_items) do
				list:Clear()
			end
			for k, v in pairs(list_items) do list_items[k] = nil end
		end
	end
end

function Factions:PreTick()
	self.ticks = self.ticks + 1
	if not self.myfaction then
		if LocalPlayer:GetValue("Faction") then
			self.myfaction = LocalPlayer:GetValue("Faction")
		end
	end
	if self.ticks > 100 then
		if LocalPlayer:GetValue("Faction") ~= self.myfaction then
			self.myfaction = LocalPlayer:GetValue("Faction")
		end
		self.ticks = 0
	end
end

function Factions:LocalPlayerInput(args)
	if self.faction_menu_open == true then
		if args.input == Action.FireLeft or args.input == Action.FireRight or args.input == Action.McFire or args.input == Action.LookDown or args.input == Action.LookLeft or args.input == Action.LookRight or args.input == Action.LookUp or args.input == Action.Accelerate or args.input == Action.TurnLeft or args.input == Action.TurnRight or args.input == Action.MoveLeft or args.input == Action.MoveRight or args.input == Action.MoveForward or args.input == Action.MoveBackward or args.input == Action.Jump then
			return false
		end
	end
end

function Factions:RowSelect() -- args is SortedList???
	local name = list:GetSelectedRow():GetCellText(0)
	local steamid = list:GetSelectedRow():GetDataString("steamid")
	--Chat:dPrint(tostring(name), Color(0, 255, 0))
	self.currentselect_name = name
	self.currentselect_steamid = steamid
end

function Factions:ButtonPress(btn)
	local name = btn:GetName()
	if name == "admin_btn" then
		if not self.rank or self.rank ~= "3" then
			Chat:Print("You must be of a certain rank to access the Admin Panel", Color(255, 34, 34))
			return
		end
		if btn:GetDataBool("InPanel") == false then -- go to admin panel
			for index, button in pairs(admin_btns) do button:SetVisible(true) end
			for index, gui_element in pairs(main_gui) do gui_element:SetVisible(false) end
			admin_rank_numeric:SetVisible(true)
			admin_rank_numeric:SetValue(1)
			btn:SetDataBool("InPanel", true)
			btn:SetText("Main Menu")
		else -- return to main menu
			for index, button in pairs(admin_btns) do button:SetVisible(false) end
			for index, gui_element in pairs(main_gui) do gui_element:SetVisible(true) end
			admin_rank_numeric:SetVisible(false)
			btn:SetDataBool("InPanel", false)
			btn:SetText("Admin Panel")
		end
	elseif name == "admin_btn_kick" then
		if self.currentselect_name == "" or self.currentselect_steamid == "" or self.currentselect_steamid == LocalPlayer:GetSteamId().id then return end
		Network:Send("GUIKick", {ply_name = self.currentselect_name, ply_steamid = self.currentselect_steamid, faction_name = LocalPlayer:GetValue("Faction")})
		list:RemoveItem(list:GetSelectedRow())
	elseif name == "admin_btn_ban" then
		if self.currentselect_name == "" or self.currentselect_steamid == "" or self.currentselect_steamid == LocalPlayer:GetSteamId().id then return end
		Network:Send("GUIBan", {ply_name = self.currentselect_name, ply_steamid = self.currentselect_steamid, faction_name = LocalPlayer:GetValue("Faction")})
		list:RemoveItem(list:GetSelectedRow())
	elseif name == "admin_btn_promote" then
		local new_rank = admin_rank_numeric:GetValue()
		if new_rank < 1 or new_rank > 3 then return end
		if self.currentselect_name == "" or self.currentselect_steamid == "" or self.currentselect_steamid == LocalPlayer:GetSteamId().id then return end
		Network:Send("GUIPromote", {ply_name = self.currentselect_name, ply_steamid = self.currentselect_steamid, faction_name = LocalPlayer:GetValue("Faction"), rank = new_rank})
	elseif name == "notice_btn" then
		if not notice_window:GetVisible() then
			--Chat:dPrint("setting false", Color.Red)
			notice_window_lbl:SetVisible(not notice_window_lbl:GetVisible())
		end
	elseif name == "admin_btn_notice" then
		local edit_bool = admin_btn_notice:GetDataBool("Editing")
		if edit_bool == false then
			notice_window_lbl:SetVisible(false)
			notice_txtbx:SetVisible(true)
			self.old_text = notice_txtbx:GetText()
			notice_window:SetVisible(true)
			self.type = true
			admin_btn_notice:SetText("Save Notice")
			admin_btn_notice:SetDataBool("Editing", true)
		elseif edit_bool == true then
			notice_window:SetVisible(false)
			self.type = false
			admin_btn_notice:SetText("Edit Notice")
			admin_btn_notice:SetDataBool("Editing", false)
			local text = notice_txtbx:GetText()
			if string.len(text) <= 1001 and text ~= self.old_text then
				Network:Send("UpdateFactionNotice", {new_notice = text, faction_name = LocalPlayer:GetValue("Faction")})
			else
				Chat:Print("Notice too long or not changed", Color(255, 34, 34))
				return
			end
			Chat:Print("Notice Saved", Color(255, 34, 34))
			self.type = false
			notice_window:SetTitle("Notice")
			self.notice = text
			notice_txtbx:SetText(self.notice)
		end
	elseif name == "admin_btn_landclaim" then
		if self.basepos ~= "" then
			Chat:Print("You already have a base", Color(255, 34, 34))
			return
		end
		local claim_bool = admin_btn_landclaim:GetDataBool("Claiming")
		if claim_bool == false then -- start claim land
			self.render_area = true
			self.first_render_area = true
			admin_btn_landclaim:SetDataBool("Claiming", true)
			admin_btn_landclaim:SetText("CLAIM(1 TIME ONLY)")
			Chat:Print("------------------------------------------", Color(255, 255, 0))
			Chat:Print("RIGHT-CLICK TO CANCEL", Color(255, 255, 0))
			Chat:Print("LEFT-CLICK TO ADJUST BASE POSITION TO YOUR POSITION", Color(255, 255, 0))
			Chat:Print("------------------------------------------", Color(255, 255, 0))
		elseif claim_bool == true then -- claim land
			self.basepos = ""
			Network:Send("CreateFactionBase", {pos = self.center, faction_name = LocalPlayer:GetValue("Faction")})
			admin_btn_landclaim:SetDataBool("Claiming", false)
			admin_btn_landclaim:SetText("Choose Clan Base")
			self.render_area = false
			self.first_render_area = true
		end
	elseif name == "donate_btn" then
		if donation_timer:GetSeconds() < 7.5 then
			Chat:Print("Please wait between sending donations", Color(255, 255, 0))
			return
		end
		local donation = donate_numeric:GetValue()
		-- LocalPlayer:GetMoney() can be hacked
		-- make sure never to update server money value based on client value
		if type(donation) == "number" then
			if donation > 0 and donation < 1000000 and donation <= LocalPlayer:GetMoney() then
				Network:Send("SendDonation", {faction_name = LocalPlayer:GetValue("Faction"), amount = math.floor(donation)})
				donate_numeric:SetValue(0)
				donation_timer:Restart()
			else
				Chat:Print("Invalid Donation Amount", Color(255, 34, 34))
			end
		end
	elseif name == "admin_btn_upgrade" then
		if self.clan_level and self.credits and type(self.credits) == "number" and factionlevels[self.clan_level + 1] <= self.credits then
			Network:Send("AttemptUpgradeFaction", {faction_name = LocalPlayer:GetValue("Faction")})
		else
			Chat:Print("Not enough clan credits for next upgrade. The clan needs " .. tostring(factionlevels[self.clan_level + 1] - self.credits) .. " more credits", Color(255, 255, 0))
		end
	elseif name == "base_btn" then
		if self.basepos and type(self.basepos) == "userdata" then
			Network:Send("ReturnToBase", {pos = self.basepos})
		else
			Chat:Print("Your clan does not have a base", Color(255, 255, 0))
		end
	end
end
--[[
function Factions:TypeManager(args) -- for editing notice
	--Chat:dPrint("Money: " .. tostring(LocalPlayer:GetMoney()), Color(0, 255, 0))
	if self.type == true then
		Chat:SetActive(false)
		if notice_window:GetVisible() == true then
			local text = notice_txtbx:GetText()
			notice_window:SetTitle("Notice ( " .. tostring(string.len(text)) .. " / 1000 )")
			if string.len(text) >= 1000 then -- configure char limit here
				notice_txtbx:SetText(string.sub(text, 0, string.len(text) - 1))
			end
			if convert_key[args.key] then
				notice_txtbx:SetText(notice_txtbx:GetText() .. convert_key[args.key])
			else
				if args.key == 8 then -- backspace
					notice_txtbx:SetText(string.sub(text, 0, string.len(text) - 1))
				end
			end
		end
	end
end ]]--

function Factions:WindowClose(window)
	if window == notice_window then
		local edit_bool = admin_btn_notice:GetDataBool("Editing")
		if edit_bool == true then
			notice_window:SetVisible(false)
			self.type = false
			admin_btn_notice:SetText("Edit Notice")
			admin_btn_notice:SetDataBool("Editing", false)
			local text = notice_txtbx:GetText()
			if string.len(text) <= 1001 and text ~= self.old_text then
				Network:Send("UpdateFactionNotice", {new_notice = text, faction_name = LocalPlayer:GetValue("Faction")})
			else
				Chat:Print("Notice too long or not changed", Color(255, 34, 34))
				return
			end
			Chat:Print("Notice Saved", Color(255, 34, 34))
			self.type = false
			notice_window:SetTitle("Notice")
			self.notice = text
			notice_txtbx:SetText(self.notice)
			
			admin_btn_notice:SetDataBool("Editing", false)
			admin_btn_notice:SetText("Edit Notice")
			notice_window:SetTitle("Notice")
			self.type = false
		end
	elseif window == base then
		notice_window:SetVisible(false)
		notice_window:SetKeyboardInputEnabled(true)
		base:SetVisible(not base:GetVisible())
		self.faction_menu_open = base:GetVisible()
		Mouse:SetVisible(self.faction_menu_open)
		for table_row, bool in pairs(list_items) do
			list:Clear()
		end
		for k, v in pairs(list_items) do list_items[k] = nil end
	end
end

function Factions:NewNotice(args) -- receives notice
	self.notice = args.notice
	Chat:Print("Your clan notice has been updated", Color(255, 34, 34))
	notice_lbl:SetText(self.notice)
	notice_txtbx:SetText(self.notice)
end

function Factions:NewCredits(args) -- receives credits, donator
	if args.donator then
		Chat:Print(tostring(args.donator) .. " has donated " .. tostring(args.credits - self.credits) .. " credits to the clan", Color(0, 255, 0, 185))
	end
	self.credits = tonumber(args.credits)
	credits_lbl:SetText("Clan Credits: " .. tostring(self.credits))
end

function Factions:NewBase(args)
	local pos = string.split(tostring(args.base_pos), ",")
	self.basepos = Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3]))
	Chat:Print("Your faction has created a base!", Color(255, 255, 0))
end

function Factions:NewLevel(args)
	self.level = args.level
	Chat:Print("Your faction is now level " .. tostring(self.level), Color(0, 255, 0))
end

function Factions:MouseDown(args)
	if args.button == 1 then
		if admin_btn_landclaim:GetDataBool("Claiming") == true then
			self.first_render_area = true -- force re-calc basepos
		end
	elseif args.button == 2 then
		admin_btn_landclaim:SetDataBool("Claiming", false)
		admin_btn_landclaim:SetText("Choose Clan Base")
		self.first_render_area = true
		self.render_area = false
	end
end

function Factions:TabPressed(textbox)
	if textbox == admin_broadcast then
		if network_timer:GetSeconds() > 10 then
			local text = textbox:GetText()
			if string.len(text) > 0 and string.len(text) < 75 then
				Network:Send("BroadcastFactionMessage", {message = text, faction_name = LocalPlayer:GetValue("Faction")})
				network_timer:Restart()
				textbox:SetText("")
				textbox:Remove()
				admin_broadcast = TextBoxMultiline.Create(base, "admin_broadcast")
				admin_broadcast:SetSize(Vector2(base:GetSize().x * .525, base:GetSize().y * .085))
				admin_broadcast:SetPositionRel(Vector2(.45, .825))
				admin_broadcast:SetVisible(true)
				admin_broadcast:SetTextSize(TextSize.Default * 1.2)
				admin_broadcast:Subscribe("TabPressed", self, self.TabPressed)
				admin_broadcast:SetToolTip("Broadcast a message to all the faction members online(press Tab to send)")
			else
				Chat:Print("Invalid message length", Color(255, 34, 34))
				network_timer:Restart()
				textbox:SetText("")
				textbox:Remove()
				admin_broadcast = TextBoxMultiline.Create(base, "admin_broadcast")
				admin_broadcast:SetSize(Vector2(base:GetSize().x * .525, base:GetSize().y * .085))
				admin_broadcast:SetPositionRel(Vector2(.45, .825))
				admin_broadcast:SetVisible(true)
				admin_broadcast:SetTextSize(TextSize.Default * 1.2)
				admin_broadcast:Subscribe("TabPressed", self, self.TabPressed)
				admin_broadcast:SetToolTip("Broadcast a message to all the faction members online(press Tab to send)")
			end
		else
			Chat:Print("Please wait 10 seconds between sending messages", Color(255, 34, 34))
		end
	end
end

function Factions:ReceiveMessage(args)
	if args.message then
		render_timer:Restart()
		self.message = args.message
		self.render_message = true
	end
end

function Factions:JoinFactionInit(args) -- receives info - SQL table with notice, level, credits, basepos
	if args.info[1].notice then
		self.notice = args.info[1].notice
		notice_txtbx:SetText(self.notice)
		--Chat:dPrint("1", Color(255, 255, 0))
	end
	if args.info[1].level then
		self.clan_level = args.info[1].level
		--Chat:dPrint("2", Color(255, 255, 0))
	end
	if args.info[1].credits then
		self.credits = args.info[1].credits
		credits_lbl:SetText("Clan Credits: " .. tostring(self.credits))
		--Chat:dPrint("3", Color(255, 255, 0))
	end
	if args.info[1].basepos then
		local pos = string.split(tostring(args.info[1].basepos), ",")
		self.basepos = Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3]))
		--Chat:dPrint("4", Color(255, 255, 0))
	end
	--Chat:dPrint("Received JoinFactionInitInfo", Color(255, 255, 0))
end

function Factions:UpdateAllFactionBases(args) -- receives SQL table - allbases(faction, basepos, level)
	for k, v in pairs(bases) do bases[k] = nil end
	for k, v in pairs(triggers) do triggers[k] = nil end
	if not args.allbases then return end
	for index, itable in pairs(args.allbases) do
		--[[
		for k2, v2 in pairs(itable) do
			dprint(v2)
		end]]--
		--dprint(itable.basepos)
		local pos = string.split(tostring(itable.basepos), ",")
		bases[index] = itable
		bases[index].basepos = Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3]))
		triggers[itable.faction] = ShapeTrigger.Create(
			{
				position = itable.basepos,
				angle = Angle(0, 0, 0),
				components = {
					{
						type = TriggerType.Sphere,
						size = Vector3(itable.level * 100, 1, itable.level * 100),
						position = Vector3(0, 500, 0),
					}
				},
				trigger_player = true, -- Do not trigger on players
				trigger_player_in_vehicle = true, -- Trigger on players in vehicles
				trigger_vehicle = false, -- Do not trigger on vehicles
				trigger_npc = true, -- Do not trigger on NPC (ClientActor),
				--vehicle_type = VehicleTriggerType.Car -- Because we are filtering Vehicles, we can use this to only include Cars
			})
		reference_triggers[triggers[itable.faction]:GetId()] = itable.faction
	end
	--Chat:dPrint("Client received updated Bases list", Color(0, 255, 0))
end

function Factions:ShapeTriggerEnter(args)
	--Chat:dPrint(tostring(args.entity) .. " has entered " .. tostring(reference_triggers[args.trigger:GetId()]) .. "'s faction base", Color(255, 0, 255))
end

function Factions:ShapeTriggerExit(args)
	--Chat:dPrint(tostring(args.entity) .. " has exited " .. tostring(reference_triggers[args.trigger:GetId()]) .. "'s faction base", Color(255, 0, 255))
end

function Factions:WNOCreate(args)
	local id = args.object:GetId()
	if not wno_bases[id] and args.object:GetValue("fType") and args.object:GetValue("fType") == "Base" and args.object:GetValue("fLevel") and args.object:GetValue("fFaction") then
	
		local vertices = {}
		local fill_vertices = {}
		local ground_height_offset = .3
		local center = args.object:GetPosition()
		local height = Physics:GetTerrainHeight( center )
		center.y = height
		local ray = Physics:Raycast( center + Vector3(0, 5, 0), Vector3.Down, 0, 100 )
		center.y = ray.position.y + ground_height_offset
		
		-- circle params
		local radius = args.object:GetValue("fLevel") * 100 --m
		local quality = 10 -- inteval size
		local fill_alpha = 10

		local angle = Angle()
		-- generate ring positions
		local last_offset = nil
		local rad = math.rad
		for i=0, 360, quality do
			angle.yaw = rad(i)
			local offset = center + angle * (Vector3.Forward * radius)

			local height = Physics:GetTerrainHeight( offset )
			offset.y = height
				
			-- raycast
			local ray = Physics:Raycast( offset + Vector3(0, 2, 0), Vector3.Down, 0, 100 )
			offset.y = ray.position.y 
			if offset.y < 200 then
				offset.y = 200
			end

			-- raise slightly above ground / model
			offset.y = offset.y + ground_height_offset
			table.insert( vertices, Vertex( offset , Color.Red ) )
			if last_offset then
				table.insert( fill_vertices, Vertex( center, Color(255,0,0,0) ) )
				table.insert( fill_vertices, Vertex( last_offset, Color(255,0,0,fill_alpha) ) )
				table.insert( fill_vertices, Vertex( offset, Color(255,0,0,fill_alpha) ) )
			end
			last_offset = offset
		end

		local model = Model.Create( vertices )
		model:Set2D(false)
		model:SetTopology( Topology.LineStrip )
		--
		local model_fill = Model.Create( fill_vertices )
		model_fill:Set2D(false)
		model_fill:SetTopology( Topology.TriangleList )
		--
		wno_bases[id] = {level = args.object:GetValue("fLevel"), pos = args.object:GetPosition(), faction = args.object:GetValue("fFaction"), fbase = model, fbase_fill = model_fill}
	end
end

function Factions:WNODestroy(args)
	local id = args.object:GetId()
	if wno_bases[id] then
		wno_bases[id] = nil
	end
end

function Factions:WNOValueChange(args)
	local id = args.object:GetId()
	if wno_bases[id] and args.object:GetValue("fType") and args.object:GetValue("fType") == "Base" and args.object:GetValue("fLevel") and args.object:GetValue("fFaction") then
		wno_bases[id].level = args.object:GetValue("fLevel")
	end
end

function Factions:PostTick()
	local in_base = false
	local plypos = LocalPlayer:GetPosition()
	local ply2D = Vector2(plypos.x, plypos.z)
	for id, itable in pairs(wno_bases) do
		if Vector2.Distance(ply2D, Vector2(itable.pos.x, itable.pos.z)) < itable.level * 100 then -- inside circle
			if math.abs(plypos.y - itable.pos.y) < 5000 then
				if LocalPlayer:GetValue("InFactionBase") ~= itable.faction then
					LocalPlayer:SetValue("InFactionBase", itable.faction)
				end
				in_base = true
			end
		end
	end
	if in_base == false then
		LocalPlayer:SetValue("InFactionBase", nil)
	end
end

function Factions:GameRender()
	--for faction, itable in pairs(bases) do -- basepos, level, faction
		--local transform = Transform3()
		--transform:Translate(itable.basepos)
		--transform:Rotate(Angle(0, 0.5 * math.pi, 0))
		--Render:SetTransform(transform)
		--Render:FillCircle(Vector3.Zero, 100 * tonumber(itable.level), Color(255, 255, 0, 100))
		--Render:ResetTransform()
	--end
	--
	--Chat:dPrint("I'm in " .. tostring(LocalPlayer:GetValue("InFactionBase")), Color(0, 255, 0))
	--for id, itable in pairs(wno_bases) do -- level, pos
	--	local transform = Transform3()
	--	transform:Translate(itable.pos)
		--transform:Rotate(Angle(0, 0.5 * math.pi, 0))
		--Render:SetTransform(transform)
		--Render:FillCircle(Vector3.Zero, 100 * tonumber(itable.level), Color(255, 255, 0, 100))
		--Render:ResetTransform()
	--end
	
	for id, itable in pairs(wno_bases) do
		Render:ResetTransform()
		if IsValid(itable.fbase) and IsValid(itable.fbase_fill) then
			itable.fbase:Draw()
			itable.fbase_fill:Draw()
		end
	end
end

function Factions:LocalPlayerChat(args)
	if string.sub(args.text, 1, 8) == "/f leave" then
		self.basepos = ""
		self.clan_level = 0
		base:Hide()
		LocalPlayer:SetValue("FactionRank", nil)
		--Chat:dPrint("LEFT FACTION - RESET VARS", Color(0, 255, 0))
	end
end

function Factions:MakeBaseModel(position, level)

end

function Factions:ModuleUnload()
	for k, v in pairs(triggers) do
		if IsValid(v) then v:Remove() end
	end
end

local faction = Factions()