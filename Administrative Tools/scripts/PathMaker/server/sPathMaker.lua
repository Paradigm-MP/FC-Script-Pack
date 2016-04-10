class 'PathMaker'

function PathMaker:__init()
	existing_paths = {}
	paths = {}
	
	colors = {}
	table.insert(colors, Color(255, 255, 0)) -- yellow
	table.insert(colors, Color(255, 0, 0)) -- red
	table.insert(colors, Color(0, 0, 255)) -- blue
	table.insert(colors, Color(255, 0, 255)) -- pink
	table.insert(colors, Color(0, 0, 0)) -- black
	table.insert(colors, Color(255, 255, 255)) -- white
	table.insert(colors, Color(255, 128, 0)) -- orange
	table.insert(colors, Color(153, 76, 0)) -- brown
	table.insert(colors, Color(153, 76, 0)) -- brown
	table.insert(colors, Color(192, 160, 192)) -- gray
	table.insert(colors, Color(0, 255, 255)) -- cyan
	
	self:LoadExistingPath("epies1.txt")
	self:LoadExistingPath("epies2.txt")
	self:LoadExistingPath("epies3.txt")
	self:LoadExistingPath("epies4.txt")
	self:LoadExistingPath("epies5.txt")
	self:LoadExistingPath("epies6.txt")
	self:LoadExistingPath("epies7.txt")
	self:LoadExistingPath("epies8.txt")
	self:LoadExistingPath("epies9.txt")
	self:LoadExistingPath("epies10.txt")
	self:LoadExistingPath("epies11.txt")
	self:LoadExistingPath("epies12.txt")
	self:LoadExistingPath("epies13.txt")
	self:LoadExistingPath("epies14.txt")
	self:LoadExistingPath("epies15.txt")
	self:LoadExistingPath("epies16.txt")
	self:LoadExistingPath("epies17.txt")
	self:LoadExistingPath("epies18.txt")
	self:LoadExistingPath("epies19.txt")
	self:LoadExistingPath("epies20.txt")
	self:LoadExistingPath("epies21.txt")
	self:LoadExistingPath("epies22.txt")
	self:LoadExistingPath("epies23.txt")
	self:LoadExistingPath("epies24.txt")
	self:LoadExistingPath("epies25.txt")
	self:LoadExistingPath("epies26.txt")
	self:LoadExistingPath("epies27.txt")
	self:LoadExistingPath("epies28.txt")
	self:LoadExistingPath("epies29.txt")
	
	self:LoadExistingPath("test1.txt")
	self:LoadExistingPath("test2.txt")
	
	self:LoadExistingPath("GunungMerahRadarFacility.txt")
	self:LoadExistingPath("LembahCerah.txt")
	self:LoadExistingPath("PekanKerisPerak.txt")
	self:LoadExistingPath("SungaiCurah.txt")
end

function PathMaker:PlayerChat(args)
	if args.text == "/start" then
		paths[args.player:GetSteamId().id] = nil
		paths[args.player:GetSteamId().id] = {}
		args.player:SendChatMessage("Started New Path", Color(25, 255, 25))
		args.player:SetNetworkValue("PathMaking", true)
		return false
	elseif string.sub(args.text, 1, 4) == "/end" and string.len(args.text) > 4 then
		if paths[args.player:GetSteamId().id] then
			local text = args.text
			text = string.gsub(text, "/end ", "")
			local file = io.open(tostring(text) .. ".txt", "w")
			file:write(".2, true")
			local steamid = args.player:GetSteamId().id
			for i = 1, #paths[steamid] do
				file:write("\n", tostring(paths[steamid][i]))
			end
			file:close()
			args.player:SendChatMessage("Path " .. tostring(text) .. " Written to File", Color(25, 150, 255))
			args.player:SetNetworkValue("PathMaking", false)
		else
			args.player:SendChatMessage("No path to save", Color.Yellow)
		end
		return false
	end
end

function PathMaker:AddCoord(args, player)
	if paths[player:GetSteamId().id] then
		table.insert(paths[player:GetSteamId().id], args.pos)
		Network:Send(player, "UpdatePath", {path = paths[player:GetSteamId().id]})
		player:SendChatMessage("Placed Point #" .. tostring(#paths[player:GetSteamId().id]), Color(25, 255, 25))
	else
		player:SendChatMessage("No Current Path Found", Color.Red)
	end
end

function PathMaker:RemoveCoord(args, player)
	if paths[player:GetSteamId().id] then
		if paths[player:GetSteamId().id][args.index] then
			table.remove(paths[player:GetSteamId().id], args.index)
			Network:Send(player, "UpdatePath", {path = paths[player:GetSteamId().id]})
			player:SendChatMessage("Removed Point", Color(255, 0, 0))
		else
			player:SendChatMessage("Point with index does not exist", Color.Red)
		end
	else
		player:SendChatMessage("No Current Path Found", Color.Red)
	end
	
end

function PathMaker:ClientModuleLoad(args)
	Network:Send(args.player, "ExistingPaths", {paths = existing_paths})
	args.player:SetNetworkValue("PathMaking", false)
end

function PathMaker:GetExistingPaths(args) -- gets em all
	--existing_paths = args.path
end

function PathMaker:LoadExistingPath(file)
	local file = io.open(file, "r")
	
	if file == nil then return end
	
	local coords = {}
	local line, values
	local first = true
	for line in file:lines() do
		line   = line:gsub("\t", ""):gsub(" ", "")
		values = line:split(",")
		if first then
			--self.velocity = tonumber(values[1])
			--self.reflect  = values[2] == "true" and true or false
			first         = false
		else
			if #values >= 3 then
				table.insert(coords, Vector3(tonumber(values[1]), tonumber(values[2]), tonumber(values[3])))
			end
		end
	end
	
	existing_paths[tostring(file)] = {coords = coords, color = Color(math.random(0, 255), math.random(0, 150), math.random(0, 255))}
end

paths = PathMaker()

Events:Subscribe("PlayerChat", paths, paths.PlayerChat)
Events:Subscribe("ClientModuleLoad", paths, paths.ClientModuleLoad)
Events:Subscribe("SendExistingPaths", paths, paths.GetExistingPaths)
--
Network:Subscribe("AddCoord", paths, paths.AddCoord)
Network:Subscribe("RemoveCoord", paths, paths.RemoveCoord)