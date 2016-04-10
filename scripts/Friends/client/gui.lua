-- Written by JaTochNietDan, with slight modifications by Philpax

class 'ListGUI'
friends = {} -- SteamID = true
requestedfriends = {} -- to other players . SteamID = true
requests = {} -- from other players

owntag = false --enable for own tag, lol, just for testing
function ListGUI:__init()
	self.active = false
	self.LastTick = 0
	self.ReceivedLastUpdate = true

	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.25, 0.8 ) )
	self.window:SetPositionRel( Vector2( 0.5, 0.5 ) - 
								self.window:GetSizeRel()/2 )
	self.window:SetTitle( "Total Players: 0" )
	self.window:SetVisible( self.active )

	self.list = SortedList.Create( self.window )
	self.list:SetDock( GwenPosition.Fill )
	self.list:SetMargin( Vector2( 4, 4 ), Vector2( 4, 0 ) )
	self.list:AddColumn( "ID", 64 )
	self.list:AddColumn( "Name" )
	self.list:AddColumn( "Friend", 64 )
	self.list:SetButtonsVisible( true )

	self.filter = TextBox.Create( self.window )
	self.filter:SetDock( GwenPosition.Bottom )
	self.filter:SetSize( Vector2( self.window:GetSize().x, 32 ) )	
	self.filter:SetMargin( Vector2( 4, 4 ), Vector2( 4, 4 ) )
	self.filter:Subscribe( "TextChanged", self, self.FilterChanged )

	self.filterGlobal = LabeledCheckBox.Create( self.window )
	self.filterGlobal:SetDock( GwenPosition.Bottom )
	self.filterGlobal:SetSize( Vector2( self.window:GetSize().x, 20 ) )	
	self.filterGlobal:SetMargin( Vector2( 4, 4 ), Vector2( 4, 0 ) )
	self.filterGlobal:GetLabel():SetText( "Search entire name" )
	self.filterGlobal:GetCheckBox():SetChecked( true )
	self.filterGlobal:GetCheckBox():Subscribe( "CheckChanged", self, self.FilterChanged )
	
	self.PlayerCount = 0
	self.Rows = {}

	self.sort_dir = false
	self.last_column = -1

	self.list:Subscribe( "SortPress",
		function(button)
			self.sort_dir = not self.sort_dir
		end)

	self.list:SetSort( 
		function( column, a, b )
			if column ~= -1 then
				self.last_column = column
			elseif column == -1 and self.last_column ~= -1 then
				column = self.last_column
			else
				column = 0
			end

			local a_value = a:GetCellText(column)
			local b_value = b:GetCellText(column)

			if column == 0 or column == 2 then
				local a_num = tonumber(a_value)
				local b_num = tonumber(b_value)

				if a_num ~= nil and b_num ~= nil then
					a_value = a_num
					b_value = b_num
				end
			end

			if self.sort_dir then
				return a_value > b_value
			else
				return a_value < b_value
			end
		end )

	self:AddPlayer(LocalPlayer)

	for player in Client:GetPlayers() do
		self:AddPlayer(player)
		-- Chat:Print(tostring(player:GetSteamId()), Color(255, 255, 255))
	end

	self.window:SetTitle("Total Players: "..tostring(self.PlayerCount))

	Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "SecondTick", self, self.PostTick )
	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )

	self.window:Subscribe( "WindowClosed", self, self.CloseClicked )
end

function ListGUI:GetActive()
	return self.active
end

function ListGUI:SetActive( state )
	self.active = state
	self.window:SetVisible( self.active )
	Mouse:SetVisible( self.active )
end

function ListGUI:KeyUp( args )
	if args.key == VirtualKey.F6 then
		self:SetActive( not self:GetActive() )
		if self:GetActive() == true then
			for player in Client:GetPlayers() do
				self:RemovePlayer(player)
			end
			for player in Client:GetPlayers() do
				self:AddPlayer(player)
			end
		end
	end
end

function ListGUI:LocalPlayerInput( args )
	if self:GetActive() and Game:GetState() == GUIState.Game then
		return false
	end
end

function ListGUI:PlayerJoin( args )
	self:AddPlayer(args.player)
	self.window:SetTitle("Total Players: "..tostring(self.PlayerCount))
end

function ListGUI:PlayerQuit( args )
	self:RemovePlayer(args.player)
	self.window:SetTitle("Total Players: "..tostring(self.PlayerCount))
end

function ListGUI:CloseClicked( args )
	self:SetActive( false )
end

function ListGUI:AddPlayer( player )
	self.PlayerCount = self.PlayerCount + 1

	local item = self.list:AddItem( tostring(player:GetId()) )
	item:SetCellText( 1, player:GetName() )
	
	local SID = tostring(player:GetSteamId().id)
	if friends[SID] then -----------------------------------------------------------------
		item:SetCellText( 2, "YES" )
	elseif requestedfriends[SID] or requests[SID] then
		item:SetCellText( 2, "PENDING" )
	elseif player == LocalPlayer then
		item:SetCellText( 2, "" )
	else
		item:SetCellText( 2, "NO" )
	end

	self.Rows[player:GetId()] = item

	local text = self.filter:GetText():lower()
	local visible = (string.find( item:GetCellText(1):lower(), text ) == 1)

	item:SetVisible( visible )
end

function ListGUI:RemovePlayer( player )
	self.PlayerCount = self.PlayerCount - 1

	if self.Rows[player:GetId()] == nil then return end

	self.list:RemoveItem( self.Rows[player:GetId()] )
	self.Rows[player:GetId()] = nil
end

function ListGUI:FilterChanged()
	local text = self.filter:GetText():lower()

	local globalSearch = self.filterGlobal:GetCheckBox():GetChecked()

	if text:len() > 0 then
		for k, v in pairs(self.Rows) do
			--[[
			Use a plain text search, instead of a pattern search, to determine
			whether the string is within this row.
			If pattern searching is used, pattern characters such as '[' and ']'
			in names cause this function to error.
			]]

			local index = v:GetCellText(1):lower():find( text, 1, true )
			if globalSearch then
				v:SetVisible( index ~= nil )
			else
				v:SetVisible( index == 1 )
			end
		end
	else
		for k, v in pairs(self.Rows) do
			v:SetVisible( true )
		end
	end
end

function ListGUI:PostTick()
	if self:GetActive() then
		if Client:GetElapsedSeconds() - self.LastTick >= 5 then
			-- Network:Send("SendPingList", LocalPlayer)

			self.LastTick = Client:GetElapsedSeconds()
			self.ReceivedLastUpdate = false
		end
	end
end


function ListGUI:ModulesLoad()
    Events:Fire( "HelpAddItem",
        {
            name = "Player List",
            text = 
                "The player list is a basic list of players and whether you are friends with them. " ..
                "It can be accessed through F6.  To add a player as a friend, type /friend playerid - "..
				" and the playerid is the ID found in the F6 menu.  Once they have accepted, you will be "..
				"able to share vehicles and not damage each other.  If you want to unfriend someone, "..
				"type /unfriend playerid - using the player's ID found in the F6 menu."
        } )
end

function ListGUI:ModuleUnload()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Player List"
        } )
end

function ListGUI:Refresh()
for player in Client:GetPlayers() do
	self:RemovePlayer(player)
end
for player in Client:GetPlayers() do
	self:AddPlayer(player)
end
end

list = ListGUI()
-----------------------------------------------------------------------------------------------------------------------------------------------
function Count_Substring( s1, s2 )
local magic =  "[%^%$%(%)%%%.%[%]%*%+%-%?]"
local percent = function(s)return "%"..s end
return select( 2, s1:gsub( s2:gsub(magic,percent), "" ) )
end
-----------------------------------------------------------------------------------------------------------------------------------------------
function ChatHandle(args)
local text = args.text
if string.sub(args.text, 1,7) == "/friend" then
	if string.len(text) > 8 then
		local ID = tonumber(string.sub(text, 9))
		if type(ID) == "number" then
			local ply = Player.GetById(ID)
			if ply ~= nil and ply ~= LocalPlayer then
				local StmID = tostring(ply:GetSteamId().id)
				if not friends[StmID] and not requestedfriends[StmID] then -- SEND A FRIEND REQUEST
					requestedfriends[StmID] = true
					-- create concatenated strings, then send to server
					local RF = ""
					for key, value in pairs(requestedfriends) do -- need to give the server the entire string, so the server doesn't have to concatenate itself
						RF = RF .. " " .. tostring(key)
					end
					-- dprint("Requested Friends(RF): " .. tostring(RF))
					local ply2ID = ply:GetId()
					Network:Send("AddFriend", {SteamID = StmID, ReqFrnds = RF, p2ID = ply2ID}) -- send SteamID of other person, and the player's updated RequestedFriends
					Chat:Print("Sent " .. tostring(ply:GetName() .. " a friend request"), Color(0, 255, 0))
				end
			end
		end
	end
	return false
elseif text:find("/unfriend ") then
	if string.len(text) > 10 then
		local ID = tonumber(string.sub(text, 11))
		if type(ID) == "number" then
			local ply = Player.GetById(ID)
			if ply ~= nil and ply ~= LocalPlayer then
				local StmID = tostring(ply:GetSteamId().id)
				if friends[StmID] then
					friends[StmID] = nil
					local F = ""
					for key, value in pairs(friends) do -- need to give the server the entire string, so the server doesn't have to concatenate itself
						F = F .. " " .. tostring(key)
					end
					local ply2ID = ply:GetId()
					Network:Send("RemoveFriend", {SteamID = StmID, Fs = F, p2ID = ply2ID})
					Chat:Print("Removed " .. tostring(ply:GetName()) .. " as a friend", Color(0, 255, 0))
				end
			end
		end
	end
	return false
end
end
Events:Subscribe("LocalPlayerChat", ChatHandle)

function GetTableOnJoin(args) -- MUST SEND ALL ELEMENTS OF SQL TABLE TO THIS FUNCTION TO UPDATE
local TableSQL = {}
local TableSQL = args.SQLTABLE
--for key, value in pairs(TableSQL) do
--	Chat:Print("key: " .. tostring(key) .. " ... value: " .. tostring(value), Color(255, 255, 0))
	--for a, b in pairs(value) do
	--	Chat:Print("key2: " .. tostring(a) .. " ... value2: " .. tostring(b), Color(255, 0, 0))
	--end
--end
Chat:dPrint("Friends2: " .. tostring(TableSQL[1].Friends), Color(0, 255, 0)) -- split all this up into tables to help with referencing
--Chat:Print("Requests2: " .. tostring(TableSQL[1].Requests), Color(0, 255, 0))
--Chat:Print("RequestedFriends2: " .. tostring(TableSQL[1].RequestedFriends), Color(0, 255, 0))
local Friends2 = tostring(TableSQL[1].Friends)
local Requests2 = tostring(TableSQL[1].Requests)
local RequestedFriends2 = tostring(TableSQL[1].RequestedFriends)
local numfriends = Count_Substring(Friends2, " ")
local numrequests = Count_Substring(Requests2, " ")
local numrequestedfriends = Count_Substring(RequestedFriends2, " ")
--Chat:Print("numfriends: " .. tostring(numfriends), Color(255, 255, 255))
--Chat:Print("numrequests: " .. tostring(numrequests), Color(255, 255, 255))
--Chat:Print("numrequestedfriends: " .. tostring(numrequestedfriends), Color(255, 255, 255))
--
dprint("FRIENDS ------------")
for key, value in pairs(friends) do
	friends[key] = nil
end
for key, value in pairs(requests) do
	requests[key] = nil
end
for key, value in pairs(requestedfriends) do
	requestedfriends[key] = nil
end
for steamid in string.gmatch(Friends2, "%d+") do -- populate friends
	dprint(steamid)
	friends[steamid] = true
end
dprint("REQUESTS FROM OTHER PLAYERS ------")
for steamid in string.gmatch(Requests2, "%d+") do -- populate requests from other players
	dprint(steamid)
	requests[steamid] = true
end
dprint("REQUESTED FRIENDS ----------- ")
for steamid in string.gmatch(RequestedFriends2, "%d+") do -- populate requests from other players
	dprint(steamid)
	requestedfriends[steamid] = true
end

end
Network:Subscribe("GetSQLTable", GetTableOnJoin)
----------------------------------------------------------------------------------------------------
function HandleDamage(args)
if args.attacker then
	local attacker = tostring(args.attacker:GetSteamId().id)
	if friends[attacker] then
		--Chat:Print("Attacked By Friend", Color(0, 255 , 0))
		return false
	end
		return true
end
end
Events:Subscribe("LocalPlayerExplosionHit", HandleDamage)
Events:Subscribe("LocalPlayerBulletHit", HandleDamage)
Events:Subscribe("LocalPlayerForcePulseHit", HandleDamage)
------------
function DrawShadowedText( pos, text, colour, size, scale )
    if scale == nil then scale = 1.0 end
    if size == nil then size = TextSize.Default end

    local shadow_colour = Color( 0, 0, 0, colour.a )
    shadow_colour = shadow_colour * 0.4

    Render:DrawText( pos + Vector3( 1, 1, 0 ), text, shadow_colour, size, scale )
    Render:DrawText( pos, text, colour, size, scale )
end
----------------
function DrawFactionTag(playerPos,dist,text,color,scaleText)
	Render:SetFont(AssetLocation.SystemFont, "Calibri")
    local scaleText = scaleText or 1.0
    local pos = playerPos + Vector3( 0, 2.34, 0 )
    --local angle = Angle( Camera:GetAngle().yaw, 0, math.pi ) * Angle( math.pi, 0, 0 )
	local angle = Camera:GetAngle() * Angle(math.pi,0,math.pi)

    local text_size = Render:GetTextSize( text, TextSize.Default * .80)
    
    local worldRange = 300
    local scaleRange = 0.016
    local scaleMin = 0.005
    
    local scale = ((dist * scaleRange) / worldRange) + scaleRange
	
    if dist < 25 then
		scale = scale
    elseif dist < 100 then
        scale = scale + .025
    elseif dist >= 100 and dist < 300 then
        scale = scale + .1
	elseif dist > 300 then
		scale = scale + .25
    end

    local t = Transform3()
    t:Translate( pos )
    t:Scale( scale )
    t:Rotate( angle )
    t:Translate( -Vector3( text_size.x, text_size.y, 0 )/2 )

    Render:SetTransform( t )

    DrawShadowedText( Vector3( 0, 0, 0 ), text, color, (TextSize.Default * 10), (scaleText / 10) )
end
--------------
function RPTag(ply, bool)
	if not IsValid(ply) then return end
    local playerPos = ply:GetPosition()
    local dist = playerPos:Distance2D(Camera:GetPosition())
	local tagPos3D = playerPos + Vector3(0,1,0)
	local tagPos2D, t = Render:WorldToScreen(tagPos3D)
	local alpha =  (dist * 3) - 100
	local size = 10
	if alpha > 255 then alpha = 255 end
	if alpha < 0 then alpha = 0 end
	if size < 0 then size = 0 end
	if not t then return end
	Render:FillCircle(tagPos2D, size, Color(0,0,0,alpha))
	Render:FillCircle(tagPos2D, size/1.25, Color(0,255,0,alpha))
	if bool then
		Render:FillCircle(tagPos2D, size, Color(0,0,255,alpha))
		Render:FillCircle(tagPos2D, size/1.25, Color(0,0,255,alpha))
	end
end
function RenderTag() -- ############################################################################################
    if Game:GetState() ~= GUIState.Game then return end
    --if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if owntag then
		RPTag(LocalPlayer)
	end
    for ply in Client:GetPlayers() do
		local local_faction = LocalPlayer:GetValue("Faction")
		local faction = ply:GetValue("Faction")
		if faction and local_faction and faction ~= "" and faction == local_faction then
			RPTag(ply, true)
		end
        if friends[tostring(ply:GetSteamId().id)] ~= nil then -- If in friends table, draw tag
            local playerPos = ply:GetPosition()
            if playerPos ~= nil then
                local dist = playerPos:Distance2D( Camera:GetPosition() )
                if dist < 500 then
                    local steamid = tostring(ply:GetSteamId().id)
                   -- DrawFactionTag(playerPos,dist,"[" .. ply:GetName() .. "]", Color(0, 255, 0))
                    if friends[steamid] then
						RPTag(ply)
                    elseif friends[steamid] == nil then -- doesnt work?
                        --local tagPos = playerPos + Vector3(0,0.3,0)
                        --DrawFactionTag(tagPos,dist,"(Enemy)", Color(255, 0, 0),0.8)
                    end
                end
            end
        end
    end
end
Events:Subscribe("Render", RenderTag)