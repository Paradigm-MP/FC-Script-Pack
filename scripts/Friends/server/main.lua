class 'Friends'

function Friends:__init()
SQL:Execute("CREATE TABLE IF NOT EXISTS FriendTable (steamID VARCHAR UNIQUE, Friends BLOB, Requests BLOB, RequestedFriends BLOB)") -- use concatenation to store multiple steamIDs
end
-- HOW TO STORE MULTIPLE FRIENDS WITH SQL? EVERY ROW WILL ONLY HOLD 1 VALUE PER COLUMN
function Friends:ClientLoaded(args)
	local TableFriends = {}
	local steamid = args.player:GetSteamId().id -- MUST USE .id
	--
	local qry3 = SQL:Query("SELECT steamID FROM FriendTable WHERE steamID = (?) LIMIT 1") -- return steamID and pos'es from 1 row with this steamID
	qry3:Bind(1, steamid)
	local result = qry3:Execute()
	if #result > 0 then -- if already in DB
		local qry = SQL:Query("SELECT Friends, Requests, RequestedFriends FROM FriendTable WHERE steamID = (?) LIMIT 1")
		qry:Bind(1, steamid)
		TableFriends = qry:Execute()
	else
		local command = SQL:Command("INSERT INTO FriendTable (steamID, Friends, Requests, RequestedFriends) VALUES (?, ?, ?, ?)") -- other columns are empty?
		command:Bind(1, steamid)
		command:Bind(2, " ")
		command:Bind(3, " ")
		command:Bind(4, " ")
		command:Execute() -- execute the SQL statement after binding parameters
		local qry2 = SQL:Query("SELECT Friends, Requests, RequestedFriends FROM FriendTable WHERE steamID = (?) LIMIT 1")
		qry2:Bind(1, steamid)
		TableFriends = qry2:Execute()
	end
	Network:Send(args.player, "GetSQLTable", {SQLTABLE = TableFriends})
	args.player:SetNetworkValue("Friends", TableFriends[1].Friends)
end
-----------------------------------------------------------------------------------------------------------------
function Friends:AddFriend(args, player) -- receives SteamID of other player, RF of ply1, and ID of ply2
	local ply1steamid = player:GetSteamId().id
	local ply2steamid = args.SteamID
	local ply2ID = args.p2ID
	local ply1RF = args.ReqFrnds
	local P1Table = {}
	local P2Table = {}
	-- update ply1's RF
	local qry = SQL:Query("SELECT RequestedFriends FROM FriendTable WHERE steamID = (?)") -- get ply2's R for concatenation
	qry:Bind(1, ply2steamid)
	RFsTable = qry:Execute()
	--
	local update = SQL:Command("UPDATE FriendTable SET RequestedFriends = ? WHERE steamID = (?)")
		update:Bind(1, ply1RF)
		update:Bind(2, ply1steamid)
		update:Execute()
	-- compare ply1's RF to ply2's RF to see if server should add them as friends
	local qry = SQL:Query("SELECT RequestedFriends, Requests FROM FriendTable WHERE steamID = (?)") -- get ply2's RF for comparison
	qry:Bind(1, ply2steamid)
	RFsTable = qry:Execute()
	local text = tostring(RFsTable[1].RequestedFriends)
	if text:find(ply1steamid) then -- if ply1's steamid is present in ply2's RF then add players as friends
		-- retrieve both ply's Friends and concatenate
		local qry = SQL:Query("SELECT * FROM FriendTable WHERE steamID = (?) or steamID = (?)") -- get ply2's RF for comparison
		qry:Bind(1, ply1steamid)
		qry:Bind(2, ply2steamid)
		FsTable = qry:Execute()
		local SID1 = FsTable[1].steamID
		local SID2 = FsTable[2].steamID
		local ply1Fs = ""
		local ply1Rs = ""
		local ply1RFs = ""
		local ply2Fs = ""
		local ply2Rs = ""
		local ply2RFs = ""
		if SID1 == tostring(ply1steamid) then
			ply1Fs = FsTable[1].Friends
			ply1Rs = FsTable[1].Requests
			ply1RFs = FsTable[1].RequestedFriends
			ply2Fs = FsTable[2].Friends
			ply2Rs = FsTable[2].Requests
			ply2RFs = FsTable[2].RequestedFriends
		else
			ply2Fs = FsTable[1].Friends
			ply2Rs = FsTable[1].Requests
			ply2RFs = FsTable[1].RequestedFriends
			ply1Fs = FsTable[2].Friends
			ply1Rs = FsTable[2].Requests
			ply1RFs = FsTable[2].RequestedFriends
		end
		-- concatenate Friends, RequestedFriends, and Requests
		-- need to delete ply1steamid from ply2 RF -AND- ply2steamid from ply1 RF
		-- need to delete ply1steamid from ply R -AND- ply2steamid from ply1 R - IF THEY EXIST
		ply2RFs = ply2RFs:gsub(ply1steamid, "") -- replace steamid with empty string
		ply1RFs = ply1RFs:gsub(ply2steamid, "")
		ply2Rs = ply2Rs:gsub(ply1steamid, "")
		ply1Rs = ply1Rs:gsub(ply2steamid, "")
		ply1Fs = ply1Fs .. " " .. tostring(ply2steamid) -- concatenate friends
		ply2Fs = ply2Fs .. " " .. tostring(ply1steamid) -- concatenate friends
		-- update both ply's Friends
		local update2 = SQL:Command("UPDATE FriendTable SET Friends = ?, Requests = ?, RequestedFriends = ? WHERE steamID = (?) ")
			update2:Bind(1, ply1Fs)
			update2:Bind(2, ply1Rs)
			update2:Bind(3, ply1RFs)
			update2:Bind(4, ply1steamid)
			update2:Execute()
		local update4 = SQL:Command("UPDATE FriendTable SET Friends = ?, Requests = ?, RequestedFriends = ? WHERE steamID = (?) ")
			update4:Bind(1, ply2Fs)
			update4:Bind(2, ply2Rs)
			update4:Bind(3, ply2RFs)
			update4:Bind(4, ply2steamid)
			update4:Execute()
		--
		local qry5 = SQL:Query("SELECT Friends, Requests, RequestedFriends FROM FriendTable WHERE steamID = (?) LIMIT 1")
		qry5:Bind(1, ply1steamid)
		P1Table = qry5:Execute()
		player:SetNetworkValue("Friends", P1Table[1].Friends)
		Network:Send(player, "GetSQLTable", {SQLTABLE = P1Table})
		--
		local qry6 = SQL:Query("SELECT Friends, Requests, RequestedFriends FROM FriendTable WHERE steamID = (?) LIMIT 1")
		qry6:Bind(1, ply2steamid)
		P2Table = qry6:Execute()
		local ply = Player.GetById(ply2ID)
		if ply ~= nil then
			ply:SetNetworkValue("Friends", P2Table[1].Friends)
			Network:Send(ply, "GetSQLTable", {SQLTABLE = P2Table})
		end
	else -- if ply1's steamid is not present in ply2's RF then
		-- add to ply2's Rs
		local ply2updatedR = tostring(RFsTable[1].Requests .. " " .. tostring(ply1steamid)) -- concatenate
		local update3 = SQL:Command("UPDATE FriendTable SET Requests = ? WHERE steamID = (?)")
		update3:Bind(1, ply2updatedR)
		update3:Bind(2, ply2steamid)
		update3:Execute()
		-- send chat message to receiver of request
		local ply = Player.GetById(ply2ID)
		if ply ~= nil then -- just in case(ply2 must be in server obviously)
			ply:SendChatMessage("You received a friend request from " .. tostring(player:GetName()) .. "! Type /friend (player ID) to accept", Color(0, 255, 0))
		end
		local qry7 = SQL:Query("SELECT Friends, Requests, RequestedFriends FROM FriendTable WHERE steamID = (?) LIMIT 1")
		qry7:Bind(1, ply1steamid)
		P1Table = qry7:Execute()
		player:SetNetworkValue("Friends", P1Table[1].Friends)
		Network:Send(player, "GetSQLTable", {SQLTABLE = P1Table})
		--
		local qry8 = SQL:Query("SELECT Friends, Requests, RequestedFriends FROM FriendTable WHERE steamID = (?) LIMIT 1")
		qry8:Bind(1, ply2steamid)
		P2Table = qry8:Execute()
		if ply ~= nil then
			ply:SetNetworkValue("Friends", P2Table[1].Friends)
			Network:Send(ply, "GetSQLTable", {SQLTABLE = P2Table})
		end
	end 
	-- Send updated SQL table to both players
end

function Friends:RemoveFriend(args, player) -- receives SteamID of ply2, Fs of ply1, and p2ID
	local ply2steamid = args.SteamID
	local ply1steamid = tostring(player:GetSteamId().id)
	local ply1Fs = tostring(args.Fs)
	local ply2ID = args.p2ID
	-- update both ply's friends
	local update7 = SQL:Command("UPDATE FriendTable SET Friends = ? WHERE steamID = (?)")
		update7:Bind(1, ply1Fs)
		update7:Bind(2, ply1steamid)
		update7:Execute()
	-- retrieve ply2's Friends
	local qry7 = SQL:Query("SELECT Friends, RequestedFriends, Requests FROM FriendTable WHERE steamID = (?) LIMIT 1")
		qry7:Bind(1, ply2steamid)
		ply2FTable = qry7:Execute()
	local ply2FsCopy = {}
	local ply2Fs = ply2FTable[1].Friends
	ply2Fs = tostring(ply2Fs:gsub(ply1steamid, "")) -- remove ply1steamid from Fs
	ply2FTable[1].Friends = ply2Fs
	ply2FsCopy = ply2FTable
	local update8 = SQL:Command("UPDATE FriendTable SET Friends = ? WHERE steamID = (?)")
		update8:Bind(1, ply2Fs)
		update8:Bind(2, ply2steamid)
		update8:Execute()
	--
	player:SetNetworkValue("Friends", ply1Fs)
	local ply = Player.GetById(ply2ID)
	if ply ~= nil then
		ply:SetNetworkValue("Friends", ply2FsCopy[1].Friends)
		Network:Send(ply, "GetSQLTable", {SQLTABLE = ply2FsCopy})
		ply:SendChatMessage(player:GetName() .. " disbanded your friendship", Color(0, 255, 0))
	end
end

friend = Friends()

Events:Subscribe("ClientModuleLoad", friend, friend.ClientLoaded)
Network:Subscribe("AddFriend", friend, friend.AddFriend)
Network:Subscribe("RemoveFriend", friend, friend.RemoveFriend)