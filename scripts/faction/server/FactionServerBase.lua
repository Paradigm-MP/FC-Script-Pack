class 'AWGFactions'

function AWGFactions:__init()
    --==== Global Faction Admins ====--
    -- Add SteamIDs (STEAM_0:0* format) to this table to give certain players ability to delete factions
    self.globalAdmins = {"STEAM_0:1:4264226"}
    --==== DO NOT EDIT BELOW THIS UNLESS YOU KNOW WHAT YOU'RE DOING ====--
    
    self.timer = Timer()
    self.numTicks = 0
    self.delay = 1
    print("Initializing serverside awgFactions.lua...")
    -- Init tables
    SQL:Execute("CREATE TABLE IF NOT EXISTS awg_members (name VARCHAR, steamid VARCHAR UNIQUE, faction VARCHAR, rank INTEGER, last_seen DATETIME DEFAULT CURRENT_TIMESTAMP)")
    SQL:Execute("CREATE TABLE IF NOT EXISTS awg_factions (faction VARCHAR UNIQUE, color VARCHAR, num_members INTEGER, banned VARCHAR, allies VARCHAR, enemies VARCHAR, passwd VARCHAR DEFAULT NULL, salt VARCHAR, created_on DATETIME DEFAULT CURRENT_DATE, notice VARCHAR, basepos VARCHAR, credits INTEGER DEFAULT 0, level INTEGER DEFAULT 1)")
    
    -- Indices supported???
    --SQL:Execute("CREATE INDEX steamid_index ON awg_factions(steamid)")
    
    
    -- SQL
    self.sqlPassSalt = "SELECT passwd,salt FROM awg_factions WHERE faction = (?) LIMIT 1"
    self.sqlLastSeen = "SELECT last_seen FROM awg_members WHERE steamid = (?) LIMIT 1"
    self.sqlIsFaction = "SELECT rowid FROM awg_factions WHERE faction = (?) LIMIT 1"
    self.sqlListFactions = "SELECT faction,num_members FROM awg_factions"
    --self.sqlFactionEst = "SELECT created_on FROM awg_factions WHERE faction = (?)"
    --self.sqlCountMembers = "SELECT num_members FROM awg_factions WHERE faction = (?)"
    self.sqlSetPass = "UPDATE awg_factions SET passwd = (:pass), salt = (:salt) WHERE faction = (:faction)"
    self.sqlSetRank = "UPDATE awg_members SET rank = (?) WHERE steamid = (?)"
    self.sqlGetRank = "SELECT rank FROM awg_members WHERE steamid = (?) LIMIT 1"
    self.sqlUpdateNumMembers = "UPDATE awg_factions SET num_members = (SELECT COUNT(steamid) FROM awg_members WHERE faction = (:faction)) WHERE faction = (:faction)"
    self.sqlNewFaction = "INSERT INTO awg_factions (faction,passwd,salt,color) VALUES (?,?,?,?)"
    self.sqlDelFaction = "DELETE FROM awg_factions WHERE faction = (?)"
    self.sqlDelMembers = "DELETE FROM awg_members WHERE faction = (?)"
    self.sqlAddMember = "INSERT OR REPLACE INTO awg_members (name,steamid,faction,rank) VALUES (?,?,?,?)"
    self.sqlDelMember = "DELETE FROM awg_members WHERE steamid = (?)"
    self.sqlInFaction = "SELECT m.faction,f.color FROM awg_members m JOIN awg_factions f ON m.faction=f.faction WHERE m.steamid = (?)"
    self.sqlGetMembers = "SELECT steamid FROM awg_members WHERE faction = (?)"
    self.sqlGetLeader = "SELECT steamid FROM awg_members WHERE rank = (?) AND faction = (?)"
    self.sqlSetColor = "UPDATE awg_factions SET color = (:color) WHERE faction = (:faction)"
    self.sqlIsColorUsed = "SELECT faction FROM awg_factions WHERE color = (?)"
    self.sqlAllMembers = "SELECT m.steamid,m.faction,f.color FROM awg_members m JOIN awg_factions f ON m.faction=f.faction"
    self.sqlGetBans = "SELECT banned FROM awg_factions WHERE faction = (?)"
    self.sqlSetBans = "UPDATE awg_factions SET banned = (:bans) WHERE faction = (:faction)"
    self.sqlGetAllies = "SELECT allies FROM awg_factions WHERE faction = (?) LIMIT 1"
    self.sqlSetAllies = "UPDATE awg_factions SET allies = (:allies) WHERE faction = (:faction) LIMIT 1"
    self.sqlGetEnemies = "SELECT enemies FROM awg_factions WHERE faction = (?) LIMIT 1"
    self.sqlSetEnemies = "UPDATE awg_factions SET enemies = (:enemies) WHERE faction = (:faction)"
    --self.queryLastSeen = SQL:Query(self.sqlLastSeen)
    --self.queryFactionEst = SQL:Query(self.sqlFactionEst)
    --self.queryCountMembers = SQL:Query(self.sqlCountMembers)

    Events:Subscribe("ClientModuleLoad", self, self.SendTables)
	Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
	--
	Network:Subscribe("GUIKick", self, self.GUIKick)
	Network:Subscribe("GUIBan", self, self.GUIBan)
	Network:Subscribe("GUIPromote", self, self.GUIPromote)
	Network:Subscribe("UpdateFactionNotice", self, self.UpdateNotice)
	Network:Subscribe("CreateFactionBase", self, self.CreateFactionBase)
	Network:Subscribe("BroadcastFactionMessage", self, self.BroadcastFactionMessage)
	Network:Subscribe("SendDonation", self, self.HandleDonation)
	Network:Subscribe("AttemptUpgradeFaction", self, self.AttemptUpgradeFaction)
	Network:Subscribe("ReturnToBase", self, self.ReturnToBase)
    --Events:Subscribe("ModuleLoad", self, self.BroadcastFactionTables)
    self.initialDelay = Events:Subscribe("PreTick", self, self.InitialDelay)
	--
	faction_bases = {}
	bases = self:GetAllFactionBases()
	wno_bases = {}
	for index, itable in pairs(bases) do
		local pos = string.split(tostring(itable.basepos), ",")
		wno_bases[itable.faction] = WorldNetworkObject.Create({angle = Angle(0, 0, 0), position = Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3]))})
		wno_bases[itable.faction]:SetNetworkValue("fFaction", itable.faction)
		wno_bases[itable.faction]:SetNetworkValue("fLevel", itable.level)
		wno_bases[itable.faction]:SetNetworkValue("fShield", false)
		wno_bases[itable.faction]:SetNetworkValue("fType", "Base")
		wno_bases[itable.faction]:SetStreamDistance(1000)
	end
end

function AWGFactions:BroadcastFactionTables(args)
    self:BroadcastMembers()
    self:BroadcastAllies()
    self:BroadcastEnemies()
end

function AWGFactions:CheckDB()
    print("Checking to see if tables need updating...")
    local updated = 0
    local numColumns = 9
    local tableCheck = SQL:Query("PRAGMA table_info(awg_factions)")
    local result = tableCheck:Execute()
    if #result ~= 9 then 
        self:UpdateDB()
        updated = 1
    end
    if updated ~= 1 then
        print("Database already up to date")
    end
end

function AWGFactions:UpdateDB()
    -- Update the database
    -- This can be run from server console by typing "lua awgfactions AWGFactions:UpdateDB()"
    -- You must reload the module after doing this, otherwise you're going to get errors :P
    print("Updating database...")
    --SQL:Execute('ALTER TABLE awg_factions ADD color VARCHAR DEFAULT "darkred"')
    --SQL:Execute('ALTER TABLE awg_factions ADD banned VARCHAR')
    --SQL:Execute("ALTER TABLE awg_factions ADD allies VARCHAR")
    --SQL:Execute("ALTER TABLE awg_factions ADD enemies VARCHAR")
    print("Database updated.")
    return true
end

function AWGFactions:WipeDB()
    -- Wipe the database
    -- This can be run from server console by typing "lua awgfactions AWGFactions:WipeDB()"
    -- You must reload the module after doing this, otherwise you're going to get errors :P
    print("Wiping database...")
    SQL:Execute("DROP TABLE IF EXISTS awg_members")
    SQL:Execute("DROP TABLE IF EXISTS awg_factions")
    print("Database wiped.")
    return true
end

function AWGFactions:ParseChat(args)
    if args.text:sub(1,3) == "/f " then
        --local msg = string.gsub(args.text, "/f ", "")
        local msg = string.split(args.text, " ")
        local mySteamID = args.player:GetSteamId().id
        local myName = args.player:GetName()
        local myFaction = args.player:GetValue("Faction")
		
        if msg[2] == "join" then
            if table.count(msg) > 4 then
                args.player:SendChatMessage(
                    "There are too many spaces. Faction names and passwords must NOT contain spaces! Press F5 for help.",
                    awgColors["neonorange"] )
            elseif table.count(msg) > 2 then
                local factionName = msg[3]
				if args.player:GetValue("Faction") == factionName then return false end
                -- Should not contain non alphanumeric chars
                if factionName:match("%W") then
                    args.player:SendChatMessage(
                        "Faction name contains invalid chars. Only alphanumeric allowed!",
                        awgColors["neonorange"] )
                else
                    self.queryIsFaction = SQL:Query(self.sqlIsFaction)
                    self.queryIsFaction:Bind(1, factionName)
                    local result = self.queryIsFaction:Execute()
                    if #result > 0 then -- Faction exists
                        local rank = 1
                        self.queryPassSalt = SQL:Query(self.sqlPassSalt)
                        self.queryPassSalt:Bind(1, factionName)
                        result = self.queryPassSalt:Execute()
                        local dbPass = result[1].passwd
                        local salt = result[1].salt
                        if string.len(dbPass) > 0 then -- There's a faction password
                            if table.count(msg) ~= 4 then
                                print("INFO: " .. myName .. " tried to join private faction " .. factionName .. " without supplying a password")
                                args.player:SendChatMessage(
                                    "There is a password required to join this faction. You must provide the correct password to join. Usage: Usage: /f join <faction> <password>",
                                    awgColors["neonorange"] )
                            else
                                local factionPass = msg[4]
                                if factionPass:match("%W") then
                                    args.player:SendChatMessage(
                                        "Faction password contains invalid chars. Only alphanumeric allowed!",
                                        awgColors["neonorange"] )
                                else
                                    factionPass = SHA256.ComputeHash(salt .. factionPass)
                                    if factionPass == dbPass then
                                        local result = self:GetFaction(mySteamID)
                                        if #result > 0 then -- if result > 0, player is in a faction already
                                            args.player:SendChatMessage("You are already in a faction", Color(255, 255, 0))
											return false
                                        end
                                        if not self:IsBanned(mySteamID,factionName) then
											if self:GetMaxFactionCapacity(factionName) > self:GetFactionMemberCount(factionName) then
												if self:JoinFaction(factionName,mySteamID,rank,myName) then
													print("INFO: " .. myName .. " successfully joined private faction " .. factionName)
													self:UpdateSendMembers(factionName)
													args.player:SendChatMessage("Successfully joined private faction: " .. factionName,
														awgColors["neonlime"] )
													args.player:SetNetworkValue("Faction", factionName)
													Network:Send(args.player, "JoinFactionInit", {info = self:GetInitFactionInfo(factionName)})
												else
													print("ERROR: " .. myName .. " was unable to join private faction " .. factionName .. " . But the password was correct")
													args.player:SendChatMessage("ERROR: Failed to join " .. factionName,awgColors["red"] )
												end
											else
												args.player:SendChatMessage("Faction is full", Color(255, 0, 0))
											end
                                        else
                                            args.player:SendChatMessage("You are banned from faction: " .. factionName,awgColors["red"] )
                                        end
                                    else
                                        print("WARN: " .. myName .. " supplied the wrong password for private faction " .. factionName)
                                        args.player:SendChatMessage(
                                            "Wrong faction password! Get lost punk!",
                                            awgColors["neonorange"] )
                                    end
                                end
                            end
                        else -- No password, go ahead and join
                            if not self:IsBanned(mySteamID,factionName) then
                                local result = self:GetFaction(mySteamID)
                                if #result > 0 then -- if result > 0, player is in a faction already
                                    args.player:SendChatMessage("You are already in a faction", Color(255, 255, 0))
									return false
                                end
								if self:GetMaxFactionCapacity(factionName) > self:GetFactionMemberCount(factionName) then
									if self:JoinFaction(factionName,mySteamID,rank,myName) then
										print("INFO: " .. myName .. " successfully joined public faction " .. factionName)
										self:UpdateSendMembers(factionName)
										args.player:SendChatMessage(
											"Successfully joined public faction: " .. factionName,
											awgColors["neonlime"] )
										args.player:SetNetworkValue("Faction", factionName)
										Network:Send(args.player, "JoinFactionInit", {info = self:GetInitFactionInfo(factionName)})
									else
										print("ERROR: " .. myName .. " was unable to join public faction " .. factionName)
										args.player:SendChatMessage(
											"ERROR: Failed to join public faction: " .. factionName,
											awgColors["red"] )
									end
								else
									args.player:SendChatMessage("Faction is full", Color(255, 0, 0))
								end
                            else
                                args.player:SendChatMessage("You are banned from faction: " .. factionName,awgColors["red"] )
                            end
                        end
                    else -- Faction doesn't exist, create it
						if args.player:GetValue("Faction") ~= "" then
							args.player:SendChatMessage("You are already in a faction", Color(255, 255, 0))
							return false
						end
                        if table.count(msg) > 3 then -- password supplied
                            local plaintextPass = msg[4]
                            if plaintextPass:match("%W") then
                                args.player:SendChatMessage(
                                    "Faction password contains invalid chars. Only alphanumeric allowed!",
                                    awgColors["neonorange"] )
                            else
                                local salt = self.RandString()
                                factionPass = SHA256.ComputeHash(salt .. plaintextPass)
								if args.player:GetMoney() >= 10000 then
									if self:AddFaction(factionName,factionPass,mySteamID,salt,myName) then
										print("INFO: " .. myName .. " successfully created private faction " .. factionName)
										self:UpdateSendMembers(factionName)
										args.player:SendChatMessage(
											"Successfully created private faction: " .. factionName .. " Password: " .. plaintextPass,
											awgColors["neonlime"] )
										args.player:SetNetworkValue("Faction", factionName)
									else
										print("ERROR: " .. myName .. " was unable to create private faction " .. factionName)
										args.player:SendChatMessage(
											"ERROR: Failed to create new private faction: " .. factionName,
											awgColors["red"] )
									end
									args.player:SetMoney(args.player:GetMoney() - 10000)
								else
									args.player:SendChatMessage("You need 10,000 credits to make a faction", Color(255, 255, 0))
								end
                            end
                        else -- no password supplied, give it a blank password
                            local factionPass = ""
                            local factionSalt = ""
							if args.player:GetMoney() >= 10000 then
								if self:AddFaction(factionName,factionPass,mySteamID,factionSalt,myName) then
									print("INFO: " .. myName .. " successfully created public faction " .. factionName)
									self:UpdateSendMembers(factionName)
									args.player:SendChatMessage(
										"Successfully created public faction: " .. factionName,
										awgColors["neonlime"] )
									args.player:SetNetworkValue("Faction", factionName)
									local t = {}
									t[1] = {}
									t[1].credits = 0
									t[1].notice = ""
									t[1].basepos = nil
									t[1].level = 1
									Network:Send(args.player, "JoinFactionInit", {info = t})
									args.player:SetMoney(args.player:GetMoney() - 10000)
								else
									print("ERROR: " .. myName .. " was unable to create private faction " .. factionName)
									args.player:SendChatMessage(
										"ERROR: Failed to create new public faction: " .. factionName,
										awgColors["red"] )
								end
							else
								args.player:SendChatMessage("You need 10,000 credits to make a faction", Color(255, 255, 0))
							end
                        end
                    end
                end
            else -- Show usage help for "/f join"
                args.player:SendChatMessage(
                    "Join a faction. If faction does not exist, it is created. Password is optional. Usage: /f join <faction> <password>",
                    awgColors["aquamarine"] )
            end
        elseif msg[2] == "leave" then
            local result = self:GetFaction(mySteamID)
            if #result > 0 then -- If any rows are returned, player is in a faction
                local myFaction = result[1].faction
                if self:QuitFaction(mySteamID,myFaction,myName) then
                    print("INFO: " .. myName .. " left faction " .. myFaction)
                    args.player:SendChatMessage(
                        "You left " .. myFaction,
                        awgColors["neonlime"] )
                    local leaveMsg = myName .. " has left the faction!"
					self:UpdateSendMembers(myFaction)
                    self:MsgFaction(myFaction, leaveMsg, awgColors["deeppink"])
					args.player:SetNetworkValue("Faction", "")
                else
                    print("ERROR: " .. myName .. " was unable to leave faction " .. myFaction)
                    args.player:SendChatMessage(
                        "ERROR: Failed to leave faction " .. myFaction,
                        awgColors["red"] )
                end
            else
                args.player:SendChatMessage(
                    "You are not currently in any faction!",
                    awgColors["neonorange"] )
            end
        elseif msg[2] == "setrank" then -- check 2 args (rank, playername)
            local result = self:GetFaction(mySteamID)
            if #result > 0 then
                local myFaction = result[1].faction
                if mySteamID == self:GetLeader(myFaction) then
                    if #msg > 3 then
                        local numRank = msg[3]
                        if numRank:match('%D') then
                            args.player:SendChatMessage(
                                    "Invalid rank number specified. Rank must be a number between 1 (lowest rank) and " .. tostring(#awgRanks) .. " (Leader rank). Press F5 for detailed help.",
                                    awgColors["neonorange"] )
                        else
                            numRank = tonumber(numRank)
                            if numRank > 0 and numRank <= #awgRanks then
                                table.remove(msg, 3)
                                table.remove(msg, 2)
                                table.remove(msg, 1)
                                local memberName = table.concat(msg, " ")
                                local memberObj = self:GetPlayerByName(memberName)
                                if memberObj ~= nil then -- Make sure player is online
                                    local memberSteamID = memberObj:GetSteamId().id
                                    local myFactionMembers = self:GetMemberIDs(myFaction)
                                    if myFactionMembers[memberSteamID] then
                                        if numRank == #awgRanks then -- player is transferring leadership
                                            local myNewRank = #awgRanks - 1
                                            self:SetRank(memberSteamID,numRank)
                                            self:SetRank(mySteamID,myNewRank)
                                            local transferMsg = myName .. " has transferred leadership of " .. myFaction .. " to " .. memberName
                                            self:MsgFaction(myFaction,transferMsg,awgColors["neonlime"])
                                            print(myName .. " has transferred leadership of " .. myFaction .. " to " .. memberName)
                                        else
                                            self:SetRank(memberSteamID,numRank)
                                            memberObj:SendChatMessage(myName .. " just set your rank to: " .. awgRanks[numRank],
                                            awgColors["neonlime"] )
                                            args.player:SendChatMessage(memberName .. " is now rank: " .. awgRanks[numRank],
                                            awgColors["neonlime"] )
                                            print(myName .. " has set a new rank for " .. memberName .. " : " .. awgRanks[numRank])
                                        end
										self:UpdateSendMembers(myFaction)
                                    else
                                        args.player:SendChatMessage("Specified player is not in your faction! You can only set the rank of your own faction members!", awgColors["neonorange"] )
                                    end
                                else
                                    args.player:SendChatMessage("Specified player is not online! Player must be online to change their rank!", awgColors["neonorange"] )
                                end
                            else
                                args.player:SendChatMessage(
                                        "Invalid rank number specified. Rank must be a number between 1 (lowest rank) and " .. tostring(#awgRanks) .. " (Leader rank). Press F5 for detailed help.",
                                        awgColors["neonorange"] )
                            end
                        end
                    else
                        args.player:SendChatMessage("You must specify a desired rank (number) and a faction member's name.  Press F5 for detailed help.  Usage: /f setrank <rank> <playername>", awgColors["neonorange"] )
                    end
                else
                    args.player:SendChatMessage("You are not the faction leader! Only the faction leader can set ranks for members!", awgColors["neonorange"] )
                end
            else
                args.player:SendChatMessage("You are not in a faction!", awgColors["neonorange"] )
            end
        elseif msg[2] == "players" then -- list online faction members
            local result = self:GetFaction(mySteamID)
            if #result > 0 then
                local myFaction = result[1].faction
                local theMembers = self:GetMembersOnline(myFaction)
                if #theMembers > 0 then
                    args.player:SendChatMessage("****** " .. myFaction .. " ******", awgColors["neonlime"] )
                    args.player:SendChatMessage("------ Online Members ------", awgColors["neonlime"] )
                    self:ShowList(theMembers,args.player,awgColors["mediumturquoise"])
                else
                    print("ERROR: Unable to find any members online for faction: " .. myFaction)
                end
            else
                args.player:SendChatMessage("You are not in a faction, there is no member list to view!", awgColors["neonorange"] )
            end
        elseif msg[2] == "list" then -- list online faction members
            self.queryListFactions = SQL:Query(self.sqlListFactions)
            local result = self.queryListFactions:Execute()
            if #result > 0 then
                args.player:SendChatMessage("****** AWG Factions ******", awgColors["neonlime"] )
                local factionList = {}
                for i = 1, #result do
                    table.insert(factionList, result[i].faction .. " (" .. result[i].num_members .. ")")
                end
                self:ShowList(factionList,args.player,awgColors["mediumturquoise"])
            else
                args.player:SendChatMessage("No factions found!", awgColors["neonorange"] )
            end
        elseif msg[2] == "goto" then -- teleport to faction member
			--[[
            --self.queryInFaction:Bind(1, mySteamID)
            --local result = self.queryInFaction:Execute()
            local result = self:GetFaction(mySteamID)
            if #result > 0 then -- If any rows are returned, player is in a faction
                local myFaction = result[1].faction
                if #msg < 3 then
                    args.player:SendChatMessage("No faction member specified. Press F5 for detailed help. Usage: /f goto <player name>",
                    awgColors["neonorange"] )
                else
                    table.remove(msg, 2)
                    table.remove(msg, 1)
                    local gotoName = table.concat(msg, " ")
                    local found = false
                    for op in Server:GetPlayers() do
                        if op:GetName() == gotoName then
                            found = true
                            local myMembers = self:GetMemberIDs(myFaction)
                            if myMembers[op:GetSteamId().id] then -- Selected player is in their faction
                                local gotoPos = op:GetPosition()
                                args.player:SetPosition(gotoPos)
                                args.player:SendChatMessage("Teleported to " .. gotoName, awgColors["neonlime"] )
                            else -- Selected player is not in their faction
                                args.player:SendChatMessage(gotoName .. " is not in your faction! You can only teleport to your own faction members!",
                                awgColors["neonorange"] )
                            end
                        end
                    end
                    if not found then
                        args.player:SendChatMessage("No online player found with name: " .. gotoName, awgColors["neonorange"] )
                    end
                end
            else
                args.player:SendChatMessage(
                    "You are not currently in any faction! You must be in a faction to use /f goto. Press F5 for detailed help.",
                    awgColors["neonorange"] )
            end
			--]]
        elseif msg[2] == "setcolor" then -- set faction color
            local result = self:GetFaction(mySteamID)
            if #result > 0 then
                local myFaction = result[1].faction
                if mySteamID == self:GetLeader(myFaction) then
                    local setColor = msg[3]
                    if awgColors[setColor] ~= nil then
                        if self:IsColorUsable(setColor) then
                            if self:SetColor(myFaction,setColor) then
                                args.player:SendChatMessage("You've successfully changed your faction color to " .. setColor .. "!", awgColors["neonlime"] )
                            else
                                args.player:SendChatMessage("ERROR: There was an error setting your faction color.", awgColors["red"] )
                            end
                        else
                            args.player:SendChatMessage("That color is already being used by another faction!", awgColors["neonorange"] )
                        end
                    else
                        args.player:SendChatMessage("That is not a valid color! To see a list of valid colors, press F5 and check out the AWG Factions tab.", awgColors["neonorange"] )
                    end
                else
                    args.player:SendChatMessage("You are not the faction leader! Only the faction leader can set the faction color!", awgColors["neonorange"] )
                end
            else
                args.player:SendChatMessage("You are not in a faction!", awgColors["neonorange"] )
            end
        elseif msg[2] == "setpass" then -- change faction password
            local result = self:GetFaction(mySteamID)
            if #result > 0 then
                local myFaction = result[1].faction
                if mySteamID == self:GetLeader(myFaction) then
                    if #msg == 3 then
                        local plaintextPass = msg[3]
                        if plaintextPass:match("%W") then
                            args.player:SendChatMessage(
                                "Faction password contains invalid chars. Only alphanumeric allowed!",
                                awgColors["neonorange"] )
                        else
                            local salt = self.RandString()
                            factionPass = SHA256.ComputeHash(salt .. plaintextPass)
                            if self:SetPass(myFaction,factionPass,salt) then
                                print(myName .. " successfully set a new password for faction: " .. myFaction)
                                args.player:SendChatMessage(
                                    "Successfully set a new password for faction: " .. myFaction .. " Password: " .. plaintextPass,
                                    awgColors["neonlime"] )
                            else
                                print("ERROR: " .. myName .. " was unable to set a new password for faction: " .. myFaction)
                                args.player:SendChatMessage(
                                    "ERROR: Failed to set a new password for faction: " .. myFaction,
                                    awgColors["red"] )
                            end
                        end
                    else
                        args.player:SendChatMessage("Set a faction password. Password must NOT contain spaces. Usage: /f setpass <password>", awgColors["neonorange"] )
                    end
                else
                    args.player:SendChatMessage("You are not the faction leader! Only the faction leader can set the faction password!", awgColors["neonorange"] )
                end
            else
                args.player:SendChatMessage("You are not in a faction!", awgColors["neonorange"] )
            end
        elseif msg[2] == "kick" then -- kick player from faction
            local result = self:GetFaction(mySteamID)
            if #result > 0 then
                if mySteamID == self:GetLeader(myFaction) then
                    if #msg > 2 then
                        table.remove(msg, 2)
                        table.remove(msg, 1)
                        local memberName = table.concat(msg, " ")
                        local memberObj = self:GetPlayerByName(memberName)
                        if memberObj ~= nil then -- Make sure player is online
                            local memberSteamID = memberObj:GetSteamId().id
                            local myFactionMembers = self:GetMemberIDs(myFaction)
                            if myFactionMembers[memberSteamID] then
                                local kickMsg = myName .. " has kicked " .. memberName .. " from " .. myFaction
                                self:QuitFaction(memberSteamID,myFaction,memberName)
                                self:MsgFaction(myFaction,kickMsg,awgColors["neonlime"])
								self:UpdateSendMembers(myFaction)
                                memberObj:SendChatMessage("You were kicked from the faction!",awgColors["neonlime"])
								memberObj:SetNetworkValue("Faction", "")
                                print(myName .. " kicked " .. memberName .. " from faction: " .. myFaction)
                            else
                                args.player:SendChatMessage("Specified player is not in your faction!", awgColors["neonorange"])
                            end
                        else
                            args.player:SendChatMessage("Specified player is not online!", awgColors["neonorange"] )
                        end
                    else
                        args.player:SendChatMessage("Kick member from faction. You must specify a faction member's name. Press F5 for detailed help.  Usage: /f kick <playername>", awgColors["neonorange"] )
                    end
                else
                    args.player:SendChatMessage("You are not the faction leader! Only the faction leader can do this!", awgColors["neonorange"] )
                end
            else
                args.player:SendChatMessage("You are not in a faction!", awgColors["neonorange"] )
            end
        elseif msg[2] == "ban" then -- ban player from faction
            local result = self:GetFaction(mySteamID)
            if #result > 0 then
                local myFaction = result[1].faction
                if mySteamID == self:GetLeader(myFaction) then
                    if #msg > 2 then
                        table.remove(msg, 2)
                        table.remove(msg, 1)
                        local memberName = table.concat(msg, " ")
                        local memberObj = self:GetPlayerByName(memberName)
                        if memberObj ~= nil then -- Make sure player is online
                            local memberSteamID = memberObj:GetSteamId().id
                            local myFactionMembers = self:GetMemberIDs(myFaction)
                            if myFactionMembers[memberSteamID] then
                                local kickMsg = myName .. " has banned " .. memberName .. " from " .. myFaction
                                self:QuitFaction(memberSteamID,myFaction,memberName)
                                if self:AddBan(memberSteamID,myFaction) then
                                    self:MsgFaction(myFaction,kickMsg,awgColors["neonlime"])
									UpdateSendMembers(myFaction)
                                    memberObj:SendChatMessage("You were banned from the faction!",awgColors["neonlime"])
									memberObj:SetNetworkValue("Faction", "")
                                    print(myName .. " banned " .. memberName .. " from faction: " .. myFaction)
                                else
                                    args.player:SendChatMessage("Specified player is already banned from your faction!", awgColors["neonorange"])
                                end
                            else
                                args.player:SendChatMessage("Specified player is not in your faction!", awgColors["neonorange"])
                            end
                        else
                            args.player:SendChatMessage("Specified player is not online!", awgColors["neonorange"] )
                        end
                    else
                        args.player:SendChatMessage("Ban member from faction. You must specify a faction member's name. Press F5 for detailed help.  Usage: /f ban <playername>", awgColors["neonorange"] )
                    end
                else
                    args.player:SendChatMessage("You are not the faction leader! Only the faction leader can do this!", awgColors["neonorange"] )
                end
            else
                args.player:SendChatMessage("You are not in a faction!", awgColors["neonorange"] )
            end
        elseif msg[2] == "unban" then -- unban player from faction
            local result = self:GetFaction(mySteamID)
            if #result > 0 then
                local myFaction = result[1].faction
                if mySteamID == self:GetLeader(myFaction) then
                    if #msg > 2 then
                        table.remove(msg, 2)
                        table.remove(msg, 1)
                        local memberName = table.concat(msg, " ")
                        local memberObj = self:GetPlayerByName(memberName)
                        if memberObj ~= nil then -- Make sure player is online
                            local memberSteamID = memberObj:GetSteamId().id
                            local myFactionMembers = self:GetMemberIDs(myFaction)
                            local unbanMsg = myName .. " has unbanned " .. memberName .. " from " .. myFaction
                            if self:DelBan(memberSteamID,myFaction) then
                                self:MsgFaction(myFaction,unbanMsg,awgColors["neonlime"])
                                memberObj:SendChatMessage("You were unbanned from the faction: " .. myFaction,awgColors["neonlime"])
                                print(myName .. " unbanned " .. memberName .. " from faction: " .. myFaction)
                            else
                                args.player:SendChatMessage("Specified player is not banned from your faction!", awgColors["neonorange"])
                            end
                        else
                            args.player:SendChatMessage("Specified player is not online!", awgColors["neonorange"] )
                        end
                    else
                        args.player:SendChatMessage("Unban member from faction. You must specify a player's name. Press F5 for detailed help.  Usage: /f unban <playername>", awgColors["neonorange"] )
                    end
                else
                    args.player:SendChatMessage("You are not the faction leader! Only the faction leader can do this!", awgColors["neonorange"] )
                end
            else
                args.player:SendChatMessage("You are not in a faction!", awgColors["neonorange"] )
            end
        elseif msg[2] == "ally" then -- toggle ally with faction
            --[[
            local result = self:GetFaction(mySteamID)
            if #result > 0 then
                local myFaction = result[1].faction
                if mySteamID == self:GetLeader(myFaction) then
                    if #msg > 2 then
                        local factionName = msg[3]
                        -- Should not contain non alphanumeric chars
                        if factionName:match("%W") then
                            args.player:SendChatMessage("Faction name contains invalid chars. Only alphanumeric allowed!",
                            awgColors["neonorange"] )
                        else
                            if self:IsFaction(factionName) then
                                if self:IsAlly(myFaction,factionName) then -- is already an ally
                                    self:DelAlly(myFaction,factionName)
                                    local allyMsg = myFaction .. " is no longer allied with " .. factionName
                                    self:MsgFaction(myFaction,allyMsg,awgColors["neonlime"])
                                    self:MsgFaction(factionName,allyMsg,awgColors["neonlime"])
                                else
                                    self:AddAlly(myFaction,factionName)
                                    local allyMsg = myFaction .. " is now allied with " .. factionName
                                    self:MsgFaction(myFaction,allyMsg,awgColors["neonlime"])
                                    self:MsgFaction(factionName,allyMsg,awgColors["neonlime"])
                                end
                            else
                                args.player:SendChatMessage("Specified faction does not exist!",awgColors["neonorange"] )
                            end
                        end
                    else
                        args.player:SendChatMessage("Ally or un-ally with faction. You must specify a faction name. Press F5 for detailed help.  Usage: /f ally <faction>", awgColors["neonorange"] )
                    end
                else
                    args.player:SendChatMessage("You are not the faction leader! Only the faction leader can do this!", awgColors["neonorange"] )
                end
            else
                args.player:SendChatMessage("You are not in a faction!", awgColors["neonorange"] )
            end
			--]]
        elseif msg[2] == "enemy" then -- toggle enemy with faction
			--[[
            local result = self:GetFaction(mySteamID)
            if #result > 0 then
                local myFaction = result[1].faction
                if mySteamID == self:GetLeader(myFaction) then
                    if #msg > 2 then
                        local factionName = msg[3]
                        -- Should not contain non alphanumeric chars
                        if factionName:match("%W") then
                            args.player:SendChatMessage("Faction name contains invalid chars. Only alphanumeric allowed!",
                            awgColors["neonorange"] )
                        else
                            if self:IsFaction(factionName) then
                                if self:IsEnemy(myFaction,factionName) then -- is already an enemy
                                    self:DelEnemy(myFaction,factionName)
                                    local enemyMsg = myFaction .. " is no longer enemies with " .. factionName
                                    self:MsgFaction(myFaction,enemyMsg,awgColors["lightsteelblue"])
                                    self:MsgFaction(factionName,enemyMsg,awgColors["lightsteelblue"])
                                else
                                    self:AddEnemy(myFaction,factionName)
                                    local enemyMsg = myFaction .. " is now enemies with " .. factionName
                                    self:MsgFaction(myFaction,enemyMsg,awgColors["crimson"])
                                    self:MsgFaction(factionName,enemyMsg,awgColors["crimson"])
                                end
                            else
                                args.player:SendChatMessage("Specified faction does not exist!",awgColors["neonorange"] )
                            end
                        end
                    else
                        args.player:SendChatMessage("Enemy or un-enemy a faction. You must specify a faction name. Press F5 for detailed help.  Usage: /f enemy <faction>", awgColors["neonorange"] )
                    end
                else
                    args.player:SendChatMessage("You are not the faction leader! Only the faction leader can do this!", awgColors["neonorange"] )
                end
            else
                args.player:SendChatMessage("You are not in a faction!", awgColors["neonorange"] )
            end
			--]]
        elseif msg[2] == "del" then
            local mySteamIDstring = args.player:GetSteamId().string
            for _,v in pairs(self.globalAdmins) do
                if v == mySteamIDstring then
                    local factionName = msg[3]
                    -- Should not contain non alphanumeric chars
                    if factionName:match("%W") then
                        args.player:SendChatMessage("Faction name contains invalid chars. Only alphanumeric allowed!",
                            awgColors["neonorange"] )
                    else
                        self:DelFaction(factionName)
                        print("Admin " .. myName .. " deleted faction: " .. factionName)
                        args.player:SendChatMessage("Deleted faction if it existed and removed any orphaned members: " .. factionName,
                        awgColors["neonlime"] )
                    end
                    break
                end
            end
        else -- If not a faction command, treat as faction chat
            local msg = string.gsub(args.text, "/f ", "")
            --self.queryInFaction:Bind(1, mySteamID)
            --local result = self.queryInFaction:Execute()
            local result = self:GetFaction(mySteamID)
            if #result > 0 then
                local myFaction = result[1].faction
                local factionColor = awgColors[result[1].color]
                msg = "[" .. myFaction .. "] " .. myName .. ": " .. msg
                if not self:MsgFaction(myFaction,msg,factionColor) then
                    print("ERROR: " .. myName .. " was unable to use faction chat for faction: " .. myFaction)
                    args.player:SendChatMessage(
                        "ERROR: Error sending faction chat message",
                        awgColors["red"] )
                end
            else
                args.player:SendChatMessage(
                    "You are trying to use faction chat, but you are not in a faction! Press F5 for help",
                    awgColors["neonorange"] )
            end
        end
        return false
    elseif args.text == "/f" then -- Show usage help
        args.player:SendChatMessage(
            "AWG Factions Mod. Press F5 for detailed help. Example Usage: /f join <faction> <password>",
            awgColors["aquamarine"] )
        return false
    end
end

-- Return player object or nil
function AWGFactions:GetPlayerByName(name)
    for p in Server:GetPlayers() do
        if name == p:GetName() then
            return p
        end
    end
    return nil
end

-- Return player object or nil
function AWGFactions:GetPlayerBySteamID(steamid)
    for p in Server:GetPlayers() do
        if steamid == p:GetSteamId().id then
            return p
        end
    end
    return nil
end

function AWGFactions:IsColorUsable(color)
    self.queryIsColorUsed = SQL:Query(self.sqlIsColorUsed)
    self.queryIsColorUsed:Bind(1, color)
    local result = self.queryIsColorUsed:Execute()
    if #result > 0 then
        return false
    end
    return true
end

-- Returns bool
function AWGFactions:AddFaction(faction,passwd,steamid,salt,myName)
    --local transaction = SQL:Transaction()
    local color = self:GetRandomColor()
    self.queryNewFaction = SQL:Command(self.sqlNewFaction)
    self.queryNewFaction:Bind(1, faction)
    self.queryNewFaction:Bind(2, passwd)
    self.queryNewFaction:Bind(3, salt)
    self.queryNewFaction:Bind(4, color)
    self.queryNewFaction:Execute()
    --transaction:Commit()
    local rank = #awgRanks
    if self:JoinFaction(faction,steamid,rank,myName) then
        print("INFO: " .. myName .. " joined newly created faction " .. faction .. " as leader")
    else
        print("ERROR: " .. myName .. " failed to join newly create faction " .. faction .. " as leader")
    end
    return true
end

-- Returns bool
function AWGFactions:DelFaction(faction)
	local online_faction_members = self:GetFactionMembersPlayerObject(faction)
	for _, player in pairs(online_faction_members) do
		player:SetNetworkValue("Faction", "")
	end
    local disbandMsg = faction .. " has been disbanded!"
	if faction_bases[faction] then faction_bases[faction] = nil end
    self:MsgFaction(faction, disbandMsg, awgColors["tomato"])
    --local transaction = SQL:Transaction()
    self.queryDelFaction = SQL:Command(self.sqlDelFaction)
    self.queryDelFaction:Bind(1, faction)
    self.queryDelFaction:Execute()
    -- Delete all members of factions as well
    self.queryDelMembers = SQL:Command(self.sqlDelMembers)
    self.queryDelMembers:Bind(1, faction)
    self.queryDelMembers:Execute()
    --transaction:Commit()
	if wno_bases[faction] and IsValid(wno_bases[faction]) then
		wno_bases[faction]:Remove()
		Network:Broadcast("UpdateAllFactionBases", {allbases = bases})
	end
	Events:Fire("FactionDeleteNPCs", {fact = faction})
	Events:Fire("FactionDeleteTurrets", {fact = faction})
    return true
end

-- Return bool
function AWGFactions:JoinFaction(faction,steamid,rank,name)
    --local transaction = SQL:Transaction()
    local joinMsg = name .. " has joined the faction!"
    self:MsgFaction(faction, joinMsg, awgColors["hotpink"])
    self.queryAddMember = SQL:Command(self.sqlAddMember)
	self.queryAddMember:Bind(1, name)
    self.queryAddMember:Bind(2, steamid)
    self.queryAddMember:Bind(3, faction)
    self.queryAddMember:Bind(4, rank)
    self.queryAddMember:Execute()
    -- Update awg_factions.num_players
    self.queryUpdateNumMembers = SQL:Command(self.sqlUpdateNumMembers)
    self.queryUpdateNumMembers:Bind(':faction', faction)
    self.queryUpdateNumMembers:Execute()
    self:BroadcastMembers()
    self:BroadcastAllies()
    self:BroadcastEnemies()
    --transaction:Commit()
    return true
end

-- Return bool
function AWGFactions:QuitFaction(steamid,faction,name)
    if self:GetRank(steamid) == #awgRanks then -- player is faction leader, so delete faction too
        local leaderQuitMsg = "Faction Leader " .. name .. " has quit the faction!"
        self:MsgFaction(faction, leaderQuitMsg, awgColors["firebrick"])
        if self:DelFaction(faction) then
            print("INFO: Deleted faction (Leader left faction): " .. faction .. "  Player: " .. name)
        else
            print("ERROR: Unable to delete faction (Leader left faction): " .. faction .. "  Player: " .. name)
        end
    else
        --local transaction = SQL:Transaction()
        self.queryDelMember = SQL:Command(self.sqlDelMember)
        self.queryDelMember:Bind(1, steamid)
        self.queryDelMember:Execute()
        -- Update awg_factions.num_players
        self.queryUpdateNumMembers = SQL:Command(self.sqlUpdateNumMembers)
        self.queryUpdateNumMembers:Bind(':faction', faction)
        self.queryUpdateNumMembers:Execute()
        self:BroadcastMembers()
        self:BroadcastAllies()
        self:BroadcastEnemies()
        --transaction:Commit()
    end
    return true
end

-- Return table
function AWGFactions:GetFaction(steamid)
    self.queryInFaction = SQL:Query(self.sqlInFaction)
    self.queryInFaction:Bind(1, steamid)
    local result = self.queryInFaction:Execute()
    return result
end

-- Return bool
function AWGFactions:IsFaction(faction)
    self.queryIsFaction = SQL:Query(self.sqlIsFaction)
    self.queryIsFaction:Bind(1, faction)
    local result = self.queryIsFaction:Execute()
    if #result > 0 then -- Faction exists
        return true
    end
    return false
end

-- Return table
function AWGFactions:GetFactionMembersPlayerObject(faction) -- RETURNS PLAYER OBJECT FOR USE IN NETWORKING SENDING
    local memberNames = {}
    for p in Server:GetPlayers() do
        if p:GetValue("Faction") == faction then
            table.insert(memberNames, p)
        end
    end
    return memberNames
end

function AWGFactions:GetFactionMembersPlayerObjectSteamID(faction, steamid_table) -- RETURNS PLAYER OBJECT FOR USE IN NETWORKING SENDING
    local memberNames = {}
    for p in Server:GetPlayers() do
        if table.find(steamid_table, tostring(p:GetSteamId().id)) then
            table.insert(memberNames, p)
        end
    end
    return memberNames
end

function AWGFactions:GetMembersOnline(faction) -- returns player names in table
    local factionMembers = self:GetMemberIDs(faction)
    local memberNames = {}
    for p in Server:GetPlayers() do
        if p:GetValue("Faction") == faction then
            table.insert(memberNames, p:GetName())
        end
    end
    return memberNames
end

-- Return table (steamids stored as keys)
function AWGFactions:GetMemberIDs(faction)
    self.queryGetMembers = SQL:Query(self.sqlGetMembers)
    self.queryGetMembers:Bind(1, faction)
    local result = self.queryGetMembers:Execute()
    local factionMembers = {}
    for i = 1, #result do
        factionMembers[result[i].steamid] = true
    end
    return factionMembers
end

-- Return INT - SteamId().id or 0
function AWGFactions:GetLeader(faction)
    local leaderRank = #awgRanks
    self.queryGetLeader = SQL:Query(self.sqlGetLeader)
    self.queryGetLeader:Bind(1, leaderRank)
    self.queryGetLeader:Bind(2, faction)
    local result = self.queryGetLeader:Execute()
    if #result > 0 then
        return result[1].steamid
    end
    return 0
end

-- Return bool
function AWGFactions:MsgFaction(myFaction,msg,color)
    local factionMembers = self:GetMemberIDs(myFaction)
    for p in Server:GetPlayers() do
        if factionMembers[p:GetSteamId().id] then -- send message to faction members
            p:SendChatMessage(msg, color)
        end
    end
    return true
end

function AWGFactions:ShowList(list,player,color)
    local cnt = 0
    local numLeft = #list
    local line = ""
    for i = 1, #list do
        --print("iterating list")
        cnt = cnt + 1
        numLeft = numLeft - 1
        if i == #list then
            line = line .. list[i]
        else
            --print("Adding member to line")
            line = line .. list[i] .. ", "
        end
        if cnt == 5 or numLeft == 0 then
            --print("Count reached 5")
            cnt = 0
            player:SendChatMessage(line, color)
            line = ""
        end
    end
end

-- Returns pseudorandom 16 byte string
function AWGFactions:RandString()
    math.randomseed(os.time())
    local randString = ""
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
    for i = 1, 16 do
        rnd = math.random(#chars)
        randString = randString.. string.sub(chars, rnd, rnd)
    end
    return randString
end

-- Return bool
function AWGFactions:SetPass(faction,pass,salt)
    self.querySetPass = SQL:Command(self.sqlSetPass)
    self.querySetPass:Bind(':pass', pass)
    self.querySetPass:Bind(':salt', salt)
    self.querySetPass:Bind(':faction', faction)
    self.querySetPass:Execute()
    return true
end

-- Return bool
function AWGFactions:SetRank(steamid,rank)
    self.querySetRank = SQL:Command(self.sqlSetRank)
    self.querySetRank:Bind(1, rank)
    self.querySetRank:Bind(2, steamid)
    self.querySetRank:Execute()
    return true
end

-- Return INT
function AWGFactions:GetRank(steamid)
    self.queryGetRank = SQL:Query(self.sqlGetRank)
    self.queryGetRank:Bind(1, steamid)
    local result = self.queryGetRank:Execute()
    if #result > 0 then
        return tonumber(result[1].rank)
    end
    return 0
end

-- Return table of allied factions. format: {["faction"] = true}
function AWGFactions:GetAllies(faction)
    local allies = {}
    self.queryGetAllies = SQL:Query(self.sqlGetAllies)
    self.queryGetAllies:Bind(1, faction)
    local result = self.queryGetAllies:Execute()
    if #result > 0 then
        local alliesString = result[1].allies
        if alliesString ~= nil then
            local alliesTmp = alliesString:split(',')
            for i=1,#alliesTmp do
                if string.len(alliesTmp[i]) > 1 then
                    allies[alliesTmp[i]] = true
                end
            end
        end
    end
    return allies
end

-- Return bool, input a TABLE
function AWGFactions:SetAllies(faction,listTable)
    local listString = ""
    for k,v in pairs(listTable) do
        listString = listString .. k .. ","
    end
    self.querySetAllies = SQL:Command(self.sqlSetAllies)
    self.querySetAllies:Bind(':allies', listString)
    self.querySetAllies:Bind(':faction', faction)
    self.querySetAllies:Execute()
    
    self:BroadcastAllies()
    return true
end

-- Return table of enemy factions
function AWGFactions:GetEnemies(faction)
    local enemies = {}
    self.queryGetEnemies = SQL:Query(self.sqlGetEnemies)
    self.queryGetEnemies:Bind(1, faction)
    local result = self.queryGetEnemies:Execute()
    if #result > 0 then
        local enemiesString = result[1].enemies
        if enemiesString ~= nil then
            local enemiesTmp = enemiesString:split(',')
            for i=1,#enemiesTmp do
                if string.len(enemiesTmp[i]) > 1 then
                    enemies[enemiesTmp[i]] = true
                end
            end
        end
    end
    return enemies
end

-- Return bool, input a TABLE
function AWGFactions:SetEnemies(faction,listTable)
    local listString = ""
    for k,v in pairs(listTable) do
        listString = listString .. k .. ","
    end
    self.querySetEnemies = SQL:Command(self.sqlSetEnemies)
    self.querySetEnemies:Bind(':enemies', listString)
    self.querySetEnemies:Bind(':faction', faction)
    self.querySetEnemies:Execute()
    
    self:BroadcastEnemies()
    return true
end

-- Return table of faction banned steamids
function AWGFactions:GetBans(faction)
    local banned = {}
    self.queryGetBans = SQL:Query(self.sqlGetBans)
    self.queryGetBans:Bind(1, faction)
    local result = self.queryGetBans:Execute()
    if #result > 0 then
        local bannedString = result[1].banned
        if bannedString ~= nil then
            local bannedTmp = bannedString:split(',')
            for i=1,#bannedTmp do
                if string.len(bannedTmp[i]) > 1 then
                    banned[bannedTmp[i]] = true
                end
            end
        end
    end
    return banned
end

-- Return bool, input bans is a TABLE
function AWGFactions:SetBans(faction,bans)
    --print("In SetBans")
    local bannedString = ""
    for k,v in pairs(bans) do
        bannedString = bannedString .. k .. ","
    end
    self.querySetBans = SQL:Command(self.sqlSetBans)
    self.querySetBans:Bind(':bans', bannedString)
    self.querySetBans:Bind(':faction', faction)
    self.querySetBans:Execute()
    --print("String: " .. bannedString)
    return true
end

-- Return bool
function AWGFactions:IsBanned(steamid,faction)
    local banned = self:GetBans(faction)
    if banned[steamid] then
        return true
    end
    return false
end

-- Return bool
function AWGFactions:IsAlly(faction1,faction2)
    local listTable = self:GetAllies(faction1)
    if listTable[faction2] then
        return true
    end
    return false
end

-- Return bool
function AWGFactions:IsEnemy(faction1,faction2)
    local listTable = self:GetEnemies(faction1)
    if listTable[faction2] then
        return true
    end
    return false
end

-- Return bool
function AWGFactions:AddAlly(faction1,faction2)
    if self:IsEnemy(faction1,faction2) then
        self:DelEnemy(faction1,faction2)
    end
    -- Add faction2 to faction1's allies list
    local listTable = self:GetAllies(faction1)
    listTable[faction2] = true
    self:SetAllies(faction1,listTable)
    -- Add faction1 to faction2's allies list
    listTable = self:GetAllies(faction2)
    listTable[faction1] = true
    self:SetAllies(faction2,listTable)
    return true
end

-- Return bool
function AWGFactions:DelAlly(faction1,faction2)
    local listTable = self:GetAllies(faction1)
    listTable[faction2] = nil
    self:SetAllies(faction1,listTable)
    
    listTable = self:GetAllies(faction2)
    listTable[faction1] = nil
    self:SetAllies(faction2,listTable)
    return true
end

-- Return bool
function AWGFactions:AddEnemy(faction1,faction2)
    if self:IsAlly(faction1,faction2) then
        self:DelAlly(faction1,faction2)
    end
    
    local listTable = self:GetEnemies(faction1)
    listTable[faction2] = true
    self:SetEnemies(faction1,listTable)
    
    listTable = self:GetEnemies(faction2)
    listTable[faction1] = true
    self:SetEnemies(faction2,listTable)
    return true
end

-- Return bool
function AWGFactions:DelEnemy(faction1,faction2)
    local listTable = self:GetEnemies(faction1)
    listTable[faction2] = nil
    self:SetEnemies(faction1,listTable)
    
    listTable = self:GetEnemies(faction2)
    listTable[faction1] = nil
    self:SetEnemies(faction2,listTable)
    return true
end

-- Return bool
function AWGFactions:AddBan(steamid,faction)
    if not self:IsBanned(steamid,faction) then
        local banned = self:GetBans(faction)
        banned[steamid] = true
        self:SetBans(faction,banned)
        return true
    end
    return false
end

-- Return bool
function AWGFactions:DelBan(steamid,faction)
    if self:IsBanned(steamid,faction) then
        local banned = self:GetBans(faction)
        banned[steamid] = nil
        self:SetBans(faction,banned)
        return true
    end
    return false
end

-- Return bool
function AWGFactions:SetColor(faction,color)
    self.querySetColor = SQL:Command(self.sqlSetColor)
    self.querySetColor:Bind(':faction', faction)
    self.querySetColor:Bind(':color', color)
    self.querySetColor:Execute()
    print(faction .. " changed their color to " .. color)
    self:BroadcastMembers()
    return true
end

-- Return STRING
function AWGFactions:GetRandomColor()
    local colorList = self:GetColorList()
    local n = math.random(1,#colorList)
    return colorList[n]
end

-- Return table
function AWGFactions:GetColorList()
    local colorList = {}
    for k,_ in pairs(awgColors) do
        table.insert(colorList, k)
    end
    return colorList
end

-- Return factionMembers table. format: {[steamid] = {"FactionName", Color(1,2,3)}}
function AWGFactions:GetAllFactionMembers()
    local allMembers = {}
    self.queryAllMembers = SQL:Query(self.sqlAllMembers)
    local result = self.queryAllMembers:Execute()
    if #result > 0 then
        local onlineSteamIDs = {}
        for ply in Server:GetPlayers() do
            onlineSteamIDs[ply:GetSteamId().id] = true
        end
        for i = 1, #result do
            if onlineSteamIDs[result[i].steamid] then
                local factionColor = awgColors[result[i].color]
                allMembers[result[i].steamid] = {result[i].faction, factionColor}
            end
        end
    end
    return allMembers
end

-- Return alliedFactions table. format: {[faction] = {["Faction1"] = true,["Faction2"] = true}}
function AWGFactions:GetAlliedFactions()
    local onlineMembers = self:GetAllFactionMembers()
    local factionTable = {}
    for k,v in pairs(onlineMembers) do
        if factionTable[v[1]] == nil then
            local otherFactions = self:GetAllies(v[1])
            --print(v[1] .. " is allied with:")
            --for k,v in pairs(otherFactions) do
            --    print(k)
            --end
            factionTable[v[1]] = otherFactions
        end
    end
    return factionTable
end

-- Return enemyFactions table. format: {[faction] = {["Faction1"] = true,["Faction2"] = true}}
function AWGFactions:GetEnemyFactions()
    local onlineMembers = self:GetAllFactionMembers()
    local factionTable = {}
    for k,v in pairs(onlineMembers) do
        if factionTable[v[1]] == nil then
            local otherFactions = self:GetEnemies(v[1])
            --print(v[1] .. " is enemies with:")
            --for k,v in pairs(otherFactions) do
            --    print(k)
            --end
            factionTable[v[1]] = otherFactions
        end
    end
    return factionTable
end

-- Broadcast enemyFactions table to all players
function AWGFactions:BroadcastEnemies()
    local allMembers = self:GetEnemyFactions()
    Network:Broadcast("EnemyFactions", allMembers)
end

-- Broadcast alliedFactions table to all players
function AWGFactions:BroadcastAllies()
    local allMembers = self:GetAlliedFactions()
    Network:Broadcast("AlliedFactions", allMembers)
end

-- Broadcast factionMembers table to all players
function AWGFactions:BroadcastMembers()
    local allMembers = self:GetAllFactionMembers()
    Network:Broadcast("FactionMembers", allMembers)
end

-- Send factionMembers table to a player
function AWGFactions:SendMembers(args)
    local allMembers = self:GetAllFactionMembers()
    Network:Send(args.player, "FactionMembers", allMembers)
end

function AWGFactions:InitialDelay(args)
    self.numTicks = self.numTicks + 1
    if self.timer:GetSeconds() > self.delay then
        print("Initializing...")
        -- Check to make sure tables are updated
        self:CheckDB()
        -- Send out initial tables of faction players
        self:BroadcastMembers()
        self:BroadcastAllies()
        self:BroadcastEnemies()
        Events:Subscribe("PlayerChat", self, self.ParseChat)
        Events:Subscribe("PlayerJoin", self, self.BroadcastFactionTables)
        Events:Subscribe("PlayerQuit", self, self.BroadcastFactionTables)
        Events:Subscribe("PlayerDeath", self, self.OnPlayerDeath)
        self.timer:Restart()
        numTicks = 0
		faction_bases["AdminTest"] = Vector3(-6480.072, 225, -3334.978)
		local qry = SQL:Query("SELECT faction, basepos FROM awg_factions")
		local result = qry:Execute()
		for index, itable in pairs(result) do
			if itable.faction ~= nil and itable.basepos ~= nil and string.len(tostring(itable.basepos)) > 4 then
				local pos = string.split(tostring(itable.basepos), ",")
				faction_bases[itable.faction] = Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3]))
			end
		end
		Events:Unsubscribe(self.initialDelay)
    end
end

function AWGFactions:OnPlayerDeath(args)
    if args.killer then
        local killerID = args.killer:GetSteamId().id
        local victimID = args.player:GetSteamId().id
        local result1 = self:GetFaction(victimID)
        local result2 = self:GetFaction(killerID)
        if #result1 > 0 and #result2 > 0 then
            local victimFaction = result1[1].faction
            local killerFaction = result2[1].faction
            if self:IsEnemy(victimFaction,killerFaction) then
                local leader = 0
                if victimID == self:GetLeader(victimFaction) then
                    leader = 1
                end
                if leader == 1 then
                    local bonus = 10000
                    args.killer:SendChatMessage("You've received a $10,000 bonus for killing an enemy faction leader! Excellent work!",
                    awgColors["neonlime"] )
                else
                    local bonus = 5000
                    args.killer:SendChatMessage("You've received a $5,000 bonus for killing an enemy faction member! Nice job!",
                    awgColors["neonlime"] )
                end
                args.killer:SetMoney(args.killer:GetMoney()+bonus)
            end
        end
    end
end

function AWGFactions:GetFactionMembers(faction_name)
	local member_table = {}
	local qry = SQL:Query("SELECT name, steamid, rank, last_seen FROM awg_members WHERE faction = (?) LIMIT 50")
	qry:Bind(1, faction_name)
	local result = qry:Execute()
	local i = 1
	for k, v in pairs(result) do
		member_table[i] = {}
		for description, value in pairs(v) do
			--Chat:Broadcast("k: " .. tostring(description) .. " |||| " .. "v: " .. tostring(value), Color(0, 255, 0))
			member_table[i][tostring(description)] = value
		end
		i = i + 1
	end
	return member_table
end

function AWGFactions:GetFactionNotice(faction_name)
	local qry = SQL:Query("SELECT notice FROM awg_factions WHERE faction = (?) LIMIT 1")
	qry:Bind(1, faction_name)
	local result = qry:Execute()
	return result[1].notice
end

function AWGFactions:GetFactionBasepos(faction_name)
	local qry = SQL:Query("SELECT basepos FROM awg_factions WHERE faction = (?) LIMIT 1")
	qry:Bind(1, faction_name)
	local result = qry:Execute()
	if #result > 0 and string.len(tostring(result[1].basepos)) > 4 then
		local pos = string.split(tostring(result[1].basepos), ",")
		return Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3]))
	else
		return nil
	end
end

function AWGFactions:GetFactionLevel(faction_name)
	local qry = SQL:Query("SELECT level FROM awg_factions WHERE faction = (?) LIMIT 1")
	qry:Bind(1, faction_name)
	local result = qry:Execute()
	return result[1].level
end

function AWGFactions:SetFactionLevel(faction_name, new_level)
	local update = SQL:Command("UPDATE awg_factions SET level = (?) WHERE faction = (?)")
	update:Bind(1, new_level)
	update:Bind(2, faction_name)
	update:Execute()
	--
	local member_table = self:GetFactionMembers(faction_name)
	local send_player = self:GetFactionMembersPlayerObject(faction_name)
	Network:SendToPlayers(send_player, "UpdateClanLevel", {level = new_level})
	print(faction_name .. " clan is now level " .. new_level)
	--
	if wno_bases[faction_name] then
		bases = self:GetAllFactionBases()
		Network:Broadcast("UpdateAllFactionBases", {allbases = bases})
	end
end

-- send a specific player allies, enemies, faction
function AWGFactions:SendTables(args) -- on ClientModuleLoad
	local steamid = args.player:GetSteamId().id
	local result = self:GetFaction(steamid) -- not table with members
	if table.count(result) ~= 0 then
		local ifaction = result[1].faction -- faction name
		local ifaction_members = self:GetFactionMembers(ifaction)
		local name = args.player:GetName()
		local qry = SQL:Query("SELECT name FROM awg_members WHERE steamid = (?) LIMIT 1")
		qry:Bind(1, steamid)
		local db_name = qry:Execute()
		args.player:SetNetworkValue("Faction", ifaction)
		if name ~= db_name then
			local cmd = SQL:Command("UPDATE awg_members SET name = (?) WHERE steamid = (?)")
			cmd:Bind(1, name)
			cmd:Bind(2, steamid)
			cmd:Execute()
		end
		Network:Send(args.player, "SendTables", {myfaction = ifaction_members, allies = self:GetAllies(ifaction), enemies = self:GetEnemies(ifaction), notice = self:GetFactionNotice(ifaction), basepos = self:GetFactionBasepos(ifaction), credits = self:GetFactionCredits(ifaction), level = self:GetFactionLevel(ifaction)})
		Network:Send(args.player, "UpdateAllFactionBases", {allbases = bases})
		-- split info into 1 query and iterate table on client
	else -- if player is factionless
		Network:Send(args.player, "SendTables", {myfaction = {}, allies = {}, enemies = {}, notice = "", basepos = ""})
		Network:Send(args.player, "UpdateAllFactionBases", {allbases = bases})
		args.player:SetNetworkValue("Faction", "")
	end
end

function AWGFactions:PlayerQuit(args)
	--print(os.date("%x"))
	local update = SQL:Command("UPDATE awg_members SET last_seen = (?) WHERE steamid = (?)")
	update:Bind(1, tostring(os.date("%x")))
	update:Bind(2, tostring(args.player:GetSteamId().id))
	update:Execute() 
end

function AWGFactions:GUIKick(args, player) -- receives ply_name, ply_steamid, and faction_name
	if player:GetSteamId().id ~= self:GetLeader(args.faction_name) then return end
	local memberObj = self:GetPlayerByName(args.ply_name)
	local memberSteamID = args.ply_steamid
    local myFactionMembers = self:GetMemberIDs(args.faction_name)
	--
    local kickMsg = tostring(player:GetName()) .. " has kicked " .. args.ply_name .. " from " .. args.faction_name
    self:QuitFaction(memberSteamID,args.faction_name,args.ply_name)
    self:MsgFaction(args.faction_name,kickMsg,awgColors["neonlime"])
	self:UpdateSendMembers(args.faction_name)
	if memberObj ~= nil then -- if player being kicked is online
		memberObj:SendChatMessage("You were kicked from the faction!",awgColors["neonlime"])
		memberObj:SetNetworkValue("Faction", "")
	end
    print(player:GetName() .. " kicked " .. args.ply_name .. " from faction: " .. args.faction_name)
end

function AWGFactions:GUIBan(args, player) -- receives ply_name, ply_steamid, and faction_name
	if player:GetSteamId().id ~= self:GetLeader(args.faction_name) then return end
	local memberObj = self:GetPlayerByName(args.ply_name)
	local memberSteamID = args.ply_steamid
    local myFactionMembers = self:GetMemberIDs(args.faction_name)
	--
    local kickMsg = player:GetName() .. " has banned " .. args.ply_name .. " from " .. args.faction_name
    self:QuitFaction(memberSteamID,args.faction_name,args.ply_name)
    if self:AddBan(memberSteamID,args.faction_name) then
		self:MsgFaction(args.faction_name,kickMsg,awgColors["neonlime"])
		self:UpdateSendMembers(args.faction_name)
		if memberObj ~= nil then -- if player being banned is online
			memberObj:SendChatMessage("You were banned from the faction!",awgColors["neonlime"])
			memberObj:SetNetworkValue("Faction", "")
		end
	end
    print(player:GetName() .. " banned " .. args.ply_name .. " from faction: " .. args.faction_name)
end

function AWGFactions:GUIPromote(args, player) -- receives ply_name, ply_steamid, faction_name, and rank
	if player:GetSteamId().id ~= self:GetLeader(args.faction_name) then return end
	local memberObj = self:GetPlayerByName(args.ply_name)
    local memberSteamID = args.ply_steamid
    local myFactionMembers = self:GetMemberIDs(args.faction_name)
    if args.rank == #awgRanks then -- player is transferring leadership
		local myNewRank = #awgRanks - 1
		self:SetRank(args.ply_steamid,args.rank)
		self:SetRank(player:GetSteamId().id,myNewRank)
		local transferMsg = player:GetName() .. " has transferred leadership of " .. args.faction_name .. " to " .. args.ply_name
		self:MsgFaction(args.faction_name,transferMsg,awgColors["neonlime"])
		print(player:GetName() .. " has transferred leadership of " .. args.faction_name .. " to " .. args.ply_name)
    else
		self:SetRank(args.ply_steamid,args.rank)
		if memberObj ~= nil then -- if playing whose rank is being changed is online
			memberObj:SendChatMessage(player:GetName() .. " just set your rank to: " .. awgRanks[args.rank],
			awgColors["neonlime"] )
		end
		player:SendChatMessage(args.ply_name .. " is now rank: " .. awgRanks[args.rank],
		awgColors["neonlime"] )
		print(player:GetName() .. " has set a new rank for " .. args.ply_name .. " : " .. awgRanks[args.rank])
    end
	self:UpdateSendMembers(args.faction_name)
end

function AWGFactions:UpdateNotice(args, player) -- receives new_notice and faction_name
	if player:GetSteamId().id ~= self:GetLeader(args.faction_name) then return end
	local update = SQL:Command("UPDATE awg_factions SET notice = (?) WHERE faction = (?)")
	update:Bind(1, args.new_notice)
	update:Bind(2, args.faction_name)
	update:Execute()
	local member_table = self:GetFactionMembers(args.faction_name)
	local send_player = self:GetFactionMembersPlayerObject(args.faction_name)
	Network:SendToPlayers(send_player, "ReceiveNewNotice", {notice = args.new_notice})
	print(player:GetName() .. " has updated the notice for faction: " .. args.faction_name)
end

function AWGFactions:CreateFactionBase(args, player) -- receives pos(vector3) and faction_name
	if player:GetSteamId().id ~= self:GetLeader(args.faction_name) then return end
	local new_pos = args.pos
	local ref_pos = Vector2(args.pos.x, args.pos.z)
	--print("ref pos: " .. tostring(ref_pos))
	local must_return = false
	for fac_name, vec in pairs(faction_bases) do
		if Vector2.Distance(Vector2(vec.x, vec.z), ref_pos) < 505 then -- 5m buffer zone
			must_return = true
			player:SendChatMessage("Too close to other base by " .. tostring(505 - Vector2.Distance(Vector2(vec.x, vec.z), ref_pos)), Color(255, 34, 34))
			break
		end
	end
	if must_return == true then return end
	--
	local update = SQL:Command("UPDATE awg_factions SET basepos = (?) WHERE faction = (?)")
	update:Bind(1, tostring(new_pos)) -- store Vector3
	update:Bind(2, args.faction_name)
	update:Execute()
	faction_bases[args.faction_name] = new_pos
	--
	player:SendChatMessage("Successfully created faction base", Color(255, 34, 34))
	local member_table = self:GetFactionMembers(args.faction_name)
	local send_player = self:GetFactionMembersPlayerObject(args.faction_name)
	Network:SendToPlayers(send_player, "UpdateFactionBase", {base_pos = new_pos})
	print(tostring(player:GetName()) .. " created a faction base for faction " .. tostring(args.faction_name) .. " at " .. tostring(new_pos))
	--
	if not bases then bases = {} end
	if not wno_bases then wno_bases = {} end
	for k, v in pairs(bases) do bases[k] = nil end
	wno_bases[args.faction_name] = WorldNetworkObject.Create({angle = Angle(0, 0, 0), position = args.pos})
	wno_bases[args.faction_name]:SetNetworkValue("fLevel", self:GetFactionLevel(args.faction_name))
	wno_bases[args.faction_name]:SetNetworkValue("fFaction", args.faction_name)
	wno_bases[args.faction_name]:SetNetworkValue("fShield", false)
	wno_bases[args.faction_name]:SetNetworkValue("fType", "Base")
	wno_bases[args.faction_name]:SetStreamDistance(1000)
	
	bases = self:GetAllFactionBases()
	for k, v in pairs(bases) do
		print("BASES: " .. tostring(v.basepos))
	end
	Network:Broadcast("UpdateAllFactionBases", {allbases = bases})
end

function AWGFactions:BroadcastFactionMessage(args) -- receives message and faction_name
	local send_player = self:GetFactionMembersPlayerObject(args.faction_name)
	Network:SendToPlayers(send_player, "RenderFactionMessage", {message = args.message})
end

function AWGFactions:GetFactionCredits(faction_name)
	local qry = SQL:Query("SELECT credits FROM awg_factions WHERE faction = (?) LIMIT 1")
	qry:Bind(1, faction_name)
	local result = qry:Execute()
	return result[1].credits
end

function AWGFactions:GetMaxFactionCapacity(faction_name)
	-- code this and check on player trying to join faction
	local qry = SQL:Query("SELECT level from awg_factions WHERE faction = (?) LIMIT 1")
	qry:Bind(1, faction_name)
	local result = qry:Execute()
	if #result > 0 then
		return (tonumber(result[1].level) * 5) + 20
	else
		return 0
	end
end

function AWGFactions:ModFactionCredits(faction_name, amount, ply_name) -- adds a certain number to faction credits (negative to subtract)
	local new_amount = self:GetFactionCredits(faction_name) + amount
	local update = SQL:Command("UPDATE awg_factions SET credits = (?) WHERE faction = (?)")
	update:Bind(1, new_amount)
	update:Bind(2, faction_name)
	update:Execute()
	--
	local member_table = self:GetFactionMembers(faction_name)
	local send_player = self:GetFactionMembersPlayerObject(faction_name)
	Network:SendToPlayers(send_player, "UpdateClanCredits", {credits = new_amount, donator = ply_name})
	print("new money amount for faction " .. faction_name .. " is: " .. new_amount)
end

function AWGFactions:HandleDonation(args, player) -- receives faction_name, amount
	local ply_money = player:GetMoney()
	if args.amount <= ply_money then
		self:ModFactionCredits(args.faction_name, args.amount, player:GetName())
		player:SetMoney(ply_money - args.amount)
		player:SendChatMessage("Successfully donated " .. tostring(args.amount) .. " to the faction", Color(0, 255, 0))
		print(player:GetName() .. " donated " .. args.amount .. " to faction " .. args.faction_name)
	else
		player:SendChatMessage("Invalid Donation Amount", Color(255, 34, 34))
	end
end

function AWGFactions:AttemptUpgradeFaction(args, player) -- receives faction_name
	local clan_credits = tonumber(self:GetFactionCredits(args.faction_name))
	local clan_level = self:GetFactionLevel(args.faction_name)
	--
	if not factionlevels[clan_level + 1] then
		player:SendChatMessage("Your clan is already fully upgraded", Color(255, 255, 0))
		return
	end
	if clan_credits >= factionlevels[clan_level + 1] then
		self:ModFactionCredits(args.faction_name, factionlevels[clan_level + 1] * -1)
		self:SetFactionLevel(args.faction_name, clan_level + 1)
		if wno_bases[args.faction_name] then
			if IsValid(wno_bases[args.faction_name]) then
				wno_bases[args.faction_name]:SetNetworkValue("fLevel", clan_level + 1)
			end
		end
	else
		player:SendChatMessage("Not enough clan credits for next upgrade. The clan needs " .. tostring(factionlevels[clan_level + 1] - tonumber(clan_credits)) .. " more credits", Color(255, 255, 0))
	end
end

function AWGFactions:UpdateSendMembers(faction)
	local member_table = self:GetFactionMembers(faction)
	local steamid_table = {}
	for index, itable in pairs(member_table) do
		table.insert(steamid_table, itable["steamid"])
	end
	local send_player = self:GetFactionMembersPlayerObjectSteamID(faction, steamid_table)
	for k, v in pairs(send_player) do
		print("sendplayer: " .. tostring(v))
	end
	if table.count(send_player) == 0 then print("sendplayer is empty!!!!!!") end
	Network:SendToPlayers(send_player, "UpdateFactionMembers", {myfaction = member_table})
end

function AWGFactions:GetInitFactionInfo(faction)
	local qry = SQL:Query("SELECT notice, credits, level, basepos FROM awg_factions WHERE faction = (?) LIMIT 1")
	qry:Bind(1, faction)
	return qry:Execute()
end

function AWGFactions:ReturnToBase(args, player) -- receives pos
	player:SetPosition(args.pos)
end

function AWGFactions:GetAllFactionBases()
	local qry = SQL:Query("SELECT faction, basepos, level FROM awg_factions")
	local info = qry:Execute()
	for index, itable in pairs(info) do
		if itable.basepos == nil or string.len(tostring(itable.basepos)) < 4 then
			info[index] = nil
		end
	end
	--for k, v in pairs(info) do print(v.basepos) end
	return info
end

function AWGFactions:GetFactionMemberCount(faction)
	local qry = SQL:Query("SELECT num_members FROM awg_factions WHERE faction = (?) LIMIT 1")
	qry:Bind(1, faction)
	local result = qry:Execute()
	return tonumber(result[1].num_members)
end

function AWGFactions:ModuleUnload()
	for faction, iWNO in pairs(wno_bases) do
		if IsValid(iWNO) then iWNO:Remove() end
	end
end

awgFactions = AWGFactions()

