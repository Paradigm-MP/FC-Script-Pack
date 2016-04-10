GLOBAL_DEBUG_FLAG = true

function dprint(str)
	if GLOBAL_DEBUG_FLAG then
		print(str)
	end
end

class "AchievementHandler"

function AchievementHandler:__init()
	--set up SQL
	SQL:Execute("CREATE TABLE IF NOT EXISTS PlayerAchievements (steamID VARCHAR UNIQUE, achievements VARCHAR DEFAULT '', timeplayed INTEGER DEFAULT 0)")
	self.PlayersConnected = {} --used for storing how long they've been connected
	
	for i in Server:GetPlayers() do
		self.PlayersConnected[i:GetSteamId().string] = Timer()
	end
	
	for i in Server:GetPlayers() do
		local query = SQL:Query("SELECT * FROM PlayerAchievements WHERE steamID = ? LIMIT 1")
		query:Bind(1, i:GetSteamId().string)
		local result = query:Execute()
		if not result[1] then
			local command = SQL:Command("INSERT INTO PlayerAchievements (steamID) VALUES (?)")
			command:Bind(1, i:GetSteamId().string)
			command:Execute()
			dprint("Added player \"" .. i:GetName() ..  "\" to db that was found on module load!")
		else
			dprint("Found player \"" .. i:GetName() .. "\" on server with " .. tostring(result[1].timeplayed) .. " microseconds played")
		end
	end
	
	Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
	Events:Subscribe("ClientModuleLoad", self, self.ClientModuleLoad)
	Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
	Events:Subscribe("SetAchievementProgress", self, self.SetAchievementProgress) 	--takes a list with:
																					--args.player: the player to get the achievement
																					--args.achievement: the achievement to give (codename)
																					--args.progress: the progress to set (if the achievement is a bool, set to true/false)
	Console:Subscribe("SetAchProg", self, self.ConSetAchievementProgress)
	Console:Subscribe("GetAch", self, self.ConGetAchievements)
	Console:Subscribe("ListIds", function () for ply in Server:GetPlayers() do print("Name: " .. ply:GetName() .. ", ID: " .. tostring(ply:GetId())) end end)
end

function AchievementHandler:ConGetAchievements(args)
	local player = Player.GetById(tonumber(args[1]))
	if not player then
		print("That player id isn't valid!")
	end
	
	local query = SQL:Query("SELECT achievements FROM PlayerAchievements WHERE steamID = ? LIMIT 1")
	query:Bind(1, player:GetSteamId().string)
	local result = query:Execute()
	if not result[1] then
		print("Wut? Player not found in db!")
		return
	end
	
	local achlist = self:AchievementsFromStr(result[1].achievements)
	
	print("Player " .. player:GetName() .. " has achievements:")
	for achname, achobj in pairs(achlist) do
		print(tostring(achobj))
	end
end

function AchievementHandler:ConSetAchievementProgress(args)
	local calltable = {}
	calltable.player = Player.GetById(tonumber(args[1]))
	
	if not calltable.player then
		print("That player id isn't valid!")
	end
	
	calltable.achievement = args[2]
	achparent = Achievement.GetByCodename(args[2])
	
	local newprog = args[3]
	if achparent then
		if achparent.achtype == AchievementType.Boolean then
			newprog = args[3] == "true"
		elseif achparent.achtype == AchievementType.Progressive then
			newprog = tonumber(args[3])
		else
			error("[CRITICAL] An achievement was of a type that is not implemented!")
		end
	else
		print("That Achievement doesn't exist!")
		return
	end
	
	calltable.progress = newprog
	self:SetAchievementProgress(calltable)
end

function AchievementHandler:ClientModuleLoad(args)
	local player = args.player
	self:SetAchievementsOnPlayer(player)
end

function AchievementHandler:SetAchievementsOnPlayer(player)
	local query = SQL:Query("SELECT achievements FROM PlayerAchievements WHERE steamID = ? LIMIT 1")
	query:Bind(1, player:GetSteamId().string)
	local result = query:Execute()
	if not result[1] then
		print("Wut? Player not found in db on client module load")
	end
	
	local achlist = self:AchievementsFromStr(result[1].achievements)
	local basictable = {}
	for name, achobj in pairs(achlist) do
		basictable[name] = achobj:ToTable() -- name = codename
	end
	
	player:SetNetworkValue("Achievements", basictable)
end

function AchievementHandler:SetAchievementProgress(args)
	local query = SQL:Query("SELECT * FROM PlayerAchievements WHERE steamID = ? LIMIT 1")
	query:Bind(1, args.player:GetSteamId().string)
	local result = query:Execute()
	if not result[1] then
		print("Wut? Tried to grant achievement to player not in DB")
		return
	end
	local achlist = self:AchievementsFromStr(result[1].achievements)
	
	if not achlist[args.achievement] then
		achlist[args.achievement] = AchievementInstance(Achievement.GetByCodename(args.achievement), args.progress)
	else
		achlist[args.achievement]:SetProgress(args.progress)
	end
	
	local newachievements = self:AchievementsToStr(achlist)
	
	local command = SQL:Command("UPDATE PlayerAchievements SET achievements = ? WHERE steamID = ?")
	command:Bind(1, newachievements)
	command:Bind(2, args.player:GetSteamId().string)
	command:Execute()
	
	self:SetAchievementsOnPlayer(args.player)
	
	if achlist[args.achievement]:IsComplete() then
        Events:Fire("AchievementComplete", {player = args.player, achievement = args.achievement})
    end
end

function AchievementHandler:PlayerJoin(args)
	local query = SQL:Query("SELECT * FROM PlayerAchievements WHERE steamID = ? LIMIT 1")
	query:Bind(1, args.player:GetSteamId().string)
	local result = query:Execute()
	if not result[1] then
		local command = SQL:Command("INSERT INTO PlayerAchievements (steamID) VALUES (?)")
		command:Bind(1, args.player:GetSteamId().string)
		command:Execute()
		dprint("New player " .. args.player:GetName() .. " joined.")
	else
		dprint("Player " .. args.player:GetName() .. " joined with " .. tostring(result[1].timeplayed) .. " microseconds played.")
	end
	self:SetAchievementsOnPlayer(args.player)
	self.PlayersConnected[args.player:GetSteamId().string] = Timer()
end

function AchievementHandler:PlayerQuit(args)
	local player = args.player
	local timer = self.PlayersConnected[player:GetSteamId().string]
	local query = SQL:Query("SELECT timeplayed FROM PlayerAchievements WHERE steamID = ? LIMIT 1")
	query:Bind(1, player:GetSteamId().string)
	local result = query:Execute()
	if not result[1] then
		print("Wut? Player found on playerquit that wasn't in the db!")
		return
	end
	local newtime = result[1].timeplayed + timer:GetMicroseconds()
	dprint("Updating player " .. player:GetName() .. " from " .. tostring(result[1].timeplayed) .. " microseconds played to " .. tostring(newtime) .. " microseconds played.")
	local command = SQL:Command("UPDATE PlayerAchievements SET timeplayed = ? WHERE steamID = ?")
	command:Bind(1, newtime)
	command:Bind(2, player:GetSteamId().string)
	command:Execute()
end

function AchievementHandler:ModuleUnload()
	for player in Server:GetPlayers() do
		local timer = self.PlayersConnected[player:GetSteamId().string]
		local query = SQL:Query("SELECT timeplayed FROM PlayerAchievements WHERE steamID = ? LIMIT 1")
		query:Bind(1, player:GetSteamId().string)
		local result = query:Execute()
		if not result[1] then
			print("Wut? Player found on unload that wasn't in the db!")
			return
		end
		local newtime = result[1].timeplayed + timer:GetMicroseconds()
		dprint("Updating player " .. player:GetName() .. " from " .. tostring(result[1].timeplayed) .. " microseconds played to " .. tostring(newtime) .. " microseconds played.")
		local command = SQL:Command("UPDATE PlayerAchievements SET timeplayed = ? WHERE steamID = ?")
		command:Bind(1, newtime)
		command:Bind(2, player:GetSteamId().string)
		command:Execute()
	end
end

function AchievementHandler:AchievementsToStr(list)
	if list == {} then return "" end
	
	local retstr = ""
	
	for _, achobj in pairs(list) do
		retstr = retstr .. "|" .. achobj:Pickle()
	end
	
	return retstr
end

function AchievementHandler:AchievementsFromStr(strlist)
	if strlist == "" then return {} end
	
	local str = string.sub(strlist, 2)
	local rettable = {}
	
	--dprint(str)
	--dprint(strlist)
	
	for _, achstr in pairs(string.split(str, "|")) do
		--dprint(achstr)
		local achobj = AchievementInstance.FromPickle(achstr)
		rettable[achobj.parent.codename] = achobj
	end
	
	return rettable
end

achhandler = AchievementHandler()