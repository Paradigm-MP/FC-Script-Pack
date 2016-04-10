class 'NI'
function NI:__init()
	SQL:Execute("CREATE TABLE IF NOT EXISTS notnoobs (steamID INTEGER UNIQUE)")
	--Network:Subscribe("ncmake", self, self.Make)
	--num = #tips + 1
	Network:Subscribe("NI_LeaveNoobIsland", self, self.LeaveIsland)
	Events:Subscribe("ClientModuleLoad", self, self.Join)
	Events:Subscribe("Exp_GainLevel", self, self.CheckLevel)
	Network:Subscribe("Im_A_Noob", self, self.TpToSpawn)
end
noobislandpos = Vector3(-12489.040039, 216.655579, 15064.201172)
function NI:TpToSpawn(args, player)
	player:SetPosition(noobislandpos)
	Chat:Send(player, "You have strayed too far from ", Color.White, "Newbie Island", Color(0,255,255), "! If you want to leave, use the portal in the center of the three buildings!", Color.White)
end
function NI:CheckLevel(args)
	if not args.player:GetValue("Noob") then return end
	if args.level ~= 10 then return end
	self:LeaveIsland(args, args.player)
	Chat:Send(args.player, "You have achieved level 10, which means that you are no longer allowed on Newbie Island. You have been teleported to a safezone in the mainland. Good luck.", Color.Green)
end
function NI:Join(args)
	local cmd = SQL:Query('SELECT steamID FROM notnoobs WHERE steamID = ?')
	cmd:Bind(1, args.player:GetSteamId().id)
	local result = cmd:Execute(), nil
	if result[1] == nil then
		args.player:SetNetworkValue("Noob", 1)
	end
end
function NI:LeaveIsland(args, sender)
	local cmd2 = SQL:Command('INSERT INTO notnoobs (steamID) VALUES (?)')
	cmd2:Bind(1, sender:GetSteamId().id)
	cmd2:Execute()
	sender:SetNetworkValue("Noob", nil)
	sender:SetValue("LeftNoobIsland", 1)
	Events:Fire("NI_LeaveNoobIsland", sender)
end
function NI:SendTips(args)
	Network:Broadcast("NI_Tips", tips)
end
function NI:Make(args, sender)
	local word = "\ntips[33] = {\n\tpos = Vector3("..tostring(args.position).."),\n\tangle = Angle("..tostring(sender:GetAngle()).."),\n\tsize = 10,\n\tcolor = Color(255,255,255),\n\ttext = \"<><><>\"\n}"
	file = io.open("tips.lua", "a") --what textfile to write
	file:write(word)
	file:close()
	Chat:Send(sender, "Wrote to file", Color.Green)
	--table.insert(tips, {pos = args.position, angle = sender:GetAngle(), size = 50, color = Color(0,255,255), text = "Welcome to Fallen Civilization"})
	--Network:Broadcast("NI_Tips", tips)
	--num = #tips + 1
end
NI = NI()