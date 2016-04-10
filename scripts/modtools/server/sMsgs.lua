class 'Msgs'
function Msgs:__init()
	self.msgs = {}
	self:LoadFile("msgs.txt")
	Events:Subscribe("ClientModuleLoad", self, self.ClientLoad)
	Network:Subscribe("Msgs_SayText", self, self.SendChat)
	Network:Subscribe("MSGS_Save", self, self.SaveMessage)
	Network:Subscribe("MSGS_Add", self, self.AddMessage)
end
function Msgs:AddMessage(msg, sender)
	if not CheckMod(sender) then return end
	table.insert(self.msgs, msg)
	self:UpdateFile()
end
function Msgs:SaveMessage(args, sender)
	if not CheckMod(sender) then return end
	self.msgs[args.index] = args.new
	self:UpdateFile()
end
function Msgs:UpdateFile()
    local file = io.open("msgs.txt", "w")
	local str = ""
	for index, text in pairs(self.msgs) do
		str = str..text.."\n"
	end
	file:write(str)
	file:close()
	for p in Server:GetPlayers() do
		self:SendData(p)
	end
end
function Msgs:ClientLoad(args)
	self:SendData(args.player)
end
function Msgs:SendData(p)
	if not CheckMod(p) then return end
	Network:Send(p, "MSGS_AllMsgsData", self.msgs)
end
function Msgs:LoadFile(filename)
    local file = io.open( filename, "r" )
    local timer = Timer()
    for line in file:lines() do
		line = string.trim(line)
		table.insert( self.msgs, string.trim(line) )
    end
    file:close()
	for p in Server:GetPlayers() do
		self:SendData(p)
	end
end
function CheckMod(p)
	if p:GetValue("NT_TagName") == "[Admin]" or
	p:GetValue("NT_TagName") == "[Mod]" then
		return true
	end
	return false
end
function Msgs:SendChat(msg, sender)
	if not CheckMod(sender) then return end
	local tag = tostring(sender:GetValue("NT_TagName"))
	local color = sender:GetValue("NT_TagColor")
	local str1 = tag.." "
	local str2 = sender:GetName()
	local str3 = ": "..msg
	Chat:Broadcast(str1, color, sender:GetName(), sender:GetColor(), str3, Color.White)
	print(str1..str2..str3)
end
Msgs = Msgs()