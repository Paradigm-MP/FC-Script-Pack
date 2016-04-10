-- Written by Philpax

class 'Help'

function Help:__init()
	self.active = false

	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.4, 0.5 ) )
	self.window:SetPositionRel( 
		Vector2( 0.5, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetTitle( "Help Window (Press 'F5' to close)" )
	self.tab_control = TabControl.Create( self.window )
	self.tab_control:SetDock( GwenPosition.Fill )
	self.tab_control:SetTabStripPosition( GwenPosition.Left )
	self.window:SetVisible(self.active)
	self.tabs = {}

	Events:Subscribe( "KeyUp", self,
		self.KeyUp )

	Events:Subscribe( "LocalPlayerInput", self,
		self.LocalPlayerInput )

	self.window:Subscribe( "WindowClosed", self, 
		self.WindowClosed )

	Events:Subscribe( "HelpAddItem", self, 
		self.AddItem )

	Events:Subscribe( "HelpRemoveItem", self, 
		self.RemoveItem )
	Chat:Print("Press F5 to access the rules and help menu.", Color.White)
end

function Help:GetActive()
	return self.active
end

function Help:SetActive( state )
	self.active = state
	self.window:SetVisible( self.active )
	Mouse:SetVisible( self.active )
end

function Help:KeyUp( args )
	if args.key == VirtualKey.F5 then
		self:SetActive( not self:GetActive() )
	end
end

function Help:LocalPlayerInput( args )
	if self:GetActive() and Game:GetState() == GUIState.Game then
		return false
	end
end

function Help:WindowClosed( args )
	self:SetActive( false )
end

function Help:AddItem( args )
	if self.tabs[args.name] ~= nil then
		self:RemoveItem( args )
	end

	local tab_button = self.tab_control:AddPage( args.name )

	local page = tab_button:GetPage()

	local scroll_control = ScrollControl.Create( page )
	scroll_control:SetMargin( Vector2( 4, 4 ), Vector2( 4, 4 ) )
	scroll_control:SetScrollable( false, true )
	scroll_control:SetDock( GwenPosition.Fill )

	local label = Label.Create( scroll_control )
	-- Ugly hack to make the text not render under the scrollbar.
	label:SetPadding( Vector2( 0, 0 ), Vector2( 14, 0 ) )
	label:SetText( args.text )
	label:SetTextSize(20)
	label:SetLineSpacing(1.25)
	label:SetWrap( true )
	
	-- Ugly hack to get word wrapping with ScrollControl working decently.
	label:Subscribe( "Render" , function(label)
		label:SetWidth( label:GetParent():GetWidth() )
		label:SizeToContents()
	end)

	self.tabs[args.name] = tab_button
end

function Help:RemoveItem( args )
	if self.tabs[args.name] == nil then return end

	self.tabs[args.name]:GetPage():Remove()
	self.tab_control:RemovePage( self.tabs[args.name] )
	self.tabs[args.name] = nil
end

help = Help()


function AddHelp()
    Events:Fire( "HelpAddItem",
        {
            name = "Reporting",
            text = 
                "Found a bug or glitch?  You can tell the nearest moderator or administrator.  No moderators "..
                "or administrators on?  Feel free to message the administrators on the forum or post it in the bugs " ..
                "discussion in the Steam group.\n\nFound a cheater? Report them directly to an administrator. "..
				"No administrators on?  Feel free to message them directly on the forums at jc-mp.com"
        } )
    Events:Fire( "HelpAddItem",
        {
            name = "Rules",
            text = 
                "The exploitation of glitches to give yourself or others an unfair advantage is strictly prohibited."..
                "\n\nIf you are found using glitches, hacks, exploits, or any other form of cheating, there will be severe consequences "..
                "for you and anyone else involved."..
                "If you find a glitch or bug, please report it immediately and refrain from exploiting it."..
                "The administrators reward those who find bugs, report them, and forget them."..
                "\n\nPlease do not try to hide glitches, exploits, or cheats from us. We will find out, "..
                "and when we do, there will be severe consequences."..
                "\n\nSome notable glitches include glitching inside of areas that are inaccessible through normal means, "..
                "such as on foot or by grapplehook. This give players an unfair advantage over those who cannot "..
                "enter the same area, and is strictly prohibited."..
                "\n\nIf you have any questions on what is allowed and what is not, please do not hesitate to ask a "..
                "moderator or administrator."
         } )
    Events:Fire( "HelpAddItem",
        {
            name = "Weapons",
            text = 
                "Weapons can be found in loot or crafted.  To equip a weapon, simply click it in your "..
                "inventory.  You'll need ammo in your inventory to use it.  If you run out of bullets " ..
                "but still have ammo in your inventory, simply re-equip the gun."
        } )
    Events:Fire( "HelpAddItem",
        {
            name = "Hit Detection",
            text = 
                "This server uses a custom hit detection system.  When you hit someone with a bullet, "..
                "you should see a green circle quickly flash in the center of your screen.  This means " ..
                "you hit them and did damage.  If you do not see the green circle, you did not hit them."
        } )
    Events:Fire( "HelpAddItem",
        {
            name = "Tutorial",
            text = 
                "Type /tutorial to view the tutorial again."
        } )
    Events:Fire( "HelpAddItem",
        {
            name = "PMs",
            text = 
                "You can open the private messaging GUI by pressing 'O'."
        } )
    Events:Fire( "HelpAddItem",
        {
            name = "Changelog",
            text = "Now maintained at \n http://fallen-civilization.wikia.com/wiki/Changelog"
        } )
    Events:Fire( "HelpAddItem",
        {
            name = "Loot",
            text = 
                "Throughout Panau, you can find lootboxes hidden in many different areas.  There are "..
                "three tiers of lootboxes.  To open one, look at it, and once you see an indicator, press E.\n\nThe lowest tier of lootbox looks like a white rice " ..
                "container, and contains the lowest tiers of items.  These are easy to find and will "..
				"display a dark gold indicator with one line above them when you look at it.\n\n"..
				"The middle tier lootbox looks like a brown barrel, and contains low to medium rarity items. "..
				"When you look at it, you will see a green indicator with two lines in it.\n\nThe third and "..
				"rarest type of lootbox looks like a grey suitcase of sorts.  These are hidden very well and "..
				"contain the rarest loot and highest tier items.  The indicator for this lootbox is purple "..
				"with three lines in it.\n\n\nThe best way to obtain items is by looting.  Travel across the "..
				"island and look around the darkest corners to find loot.  In Cursed areas, high tier loot is "..
				"much more common, but it comes at a price: danger.  More on Cursed areas in the Cursed section."
        } )
end

function RemoveHelp()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Reporting"
        } )
    Events:Fire( "HelpRemoveItem",
        {
            name = "Weapons"
        } )
    Events:Fire( "HelpRemoveItem",
        {
            name = "Hit Detection"
        } )
    Events:Fire( "HelpRemoveItem",
        {
            name = "Tutorial"
        } )
    Events:Fire( "HelpRemoveItem",
        {
            name = "Changelog"
        } )
end

Events:Subscribe("ModulesLoad", AddHelp)
Events:Subscribe("ModuleUnload", RemoveHelp)