class 'Personality'
function Personality:__init()
	self.pluswords = {}
	self.pluswords[1] = "love"
	self.pluswords[2] = "care"
	self.pluswords[3] = "loving"
	self.pluswords[4] = "caring"
	self.pluswords[5] = "help"
	self.pluswords[6] = "helping"
	self.pluswords[7] = "pretty"
	self.pluswords[8] = "beautiful"
	self.pluswords[9] = "charm"
	self.pluswords[10] = "charming"
	self.pluswords[11] = "cute"
	self.pluswords[12] = "elegant"
	self.pluswords[13] = "pleasant"
	self.pluswords[14] = "graceful"
	self.pluswords[15] = "great"
	self.pluswords[16] = "kind"
	self.pluswords[17] = "virtue"
	self.pluswords[18] = "wonderful"
	self.minuswords = {}
	self.minuswords[1] = "kill"
	self.minuswords[2] = "death"
	self.minuswords[3] = "fuck"
	self.minuswords[4] = "pussy"
	self.minuswords[5] = "bitch"
	self.minuswords[6] = "damn"
	self.minuswords[7] = "ass"
	self.minuswords[8] = "nigger"
	self.minuswords[9] = "nigga"
	self.minuswords[10] = "fool"
	self.minuswords[11] = "dumb"
	self.minuswords[12] = "dummy"
	self.minuswords[13] = "retard"
	self.minuswords[14] = "idiot"
	self.minuswords[15] = "stupid"
	self.minuswords[16] = "retard"
	self.minuswords[17] = "steal"
	self.minuswords[18] = "hell"
	self.minuswords[19] = "hitler"
	self.minuswords[20] = "robber"
	self.minuswords[21] = "cancer"
	self.minuswords[22] = "die"
	self.minuswords[23] = "haha"
	self.minuswords[24] = "pleb"
	self.minuswords[25] = "weak"
	self.minuswords[26] = "suck"
	self.deathalone = 1
	self.deathkilled = -1.5
	self.kill = -5
	self.badword = -2
	self.goodword = 2
	self.stunt = -0.5
	self.MG = -0.5
	self.fast = -3
	self.chat = -0.05
	self.nochat1min = 0.25
	for p in Server:GetPlayers() do
		if not p:GetValue("Personality") then
			p:SetNetworkValue("Personality", -1)
		end
	end
	Events:Subscribe("PlayerChat", self, self.Chat)
	Events:Subscribe("PlayerEnterStunt", self, self.Stunt)
	Events:Subscribe("PlayerEnterMG", self, self.MachineGun)
	Events:Subscribe("PlayerDeath", self, self.Death)
	Events:Subscribe("TimeChange", self, self.Velocity)
	Network:Subscribe("PersonalityCollide", self, self.Collide)
	Network:Subscribe("PersonalityExplode", self, self.Explode)
end
function Personality:Velocity()
	for p in Server:GetPlayers() do
		if not p:GetValue("PersonalityChat") then
			p:SetValue("PersonalityChat", 0)
		end
		local chat = p:GetValue("PersonalityChat")
		p:SetValue("PersonalityChat", chat + self.nochat1min)
		local velo = math.abs((-p:GetAngle() * p:GetLinearVelocity()).z)
		if velo > 50 and p:GetValue("Personality") then
			local personality = p:GetValue("Personality")
			p:SetNetworkValue("Personality", personality + self.fast)
		end
	end
end
function Personality:Explode(value, sender)
	if sender:GetValue("Personality") and value < 4 and value > -4 then
		local personality = sender:GetValue("Personality")
		sender:SetNetworkValue("Personality", personality + value)
	end
end
function Personality:Collide(value, sender)
	if sender:GetValue("Personality") and value < 3 and value > -6 then
		local personality = sender:GetValue("Personality")
		sender:SetNetworkValue("Personality", personality + value)
	end
end
function Personality:MachineGun(args)
	if args.player:GetValue("Personality") then
		local personality = args.player:GetValue("Personality")
		args.player:SetNetworkValue("Personality", personality + self.MG)
	end
end
function Personality:Stunt(args)
	if args.player:GetValue("Personality") then
		local personality = args.player:GetValue("Personality")
		args.player:SetNetworkValue("Personality", personality + self.stunt)
	end
end
function Personality:Death(args)
	if args.player:GetValue("Personality") then
		if not args.killer then
			local personality = args.player:GetValue("Personality")
			args.player:SetNetworkValue("Personality", personality + self.deathalone)
		else
			local personality = args.player:GetValue("Personality")
			args.player:SetNetworkValue("Personality", personality + self.deathkilled)
			if args.killer:GetValue("Personality") then
				local personality = args.killer:GetValue("Personality")
				args.killer:SetNetworkValue("Personality", personality + self.kill)
			end
		end
	end
end
function Personality:Chat(args)
	if not args.player:GetValue("PersonalityChat") then
		args.player:SetValue("PersonalityChat", 0)
	end
	if args.text == "/p" and args.player:GetValue("NT_TagName") == "[Admin]" then
		for p in Server:GetPlayers() do
			if p:GetValue("Personality") then
				Chat:Send(args.player, tostring(p).."'s super secret value: "..tostring(p:GetValue("Personality")), Color(255,255,255))
			end
		end
		return false
	end
	
	if args.text:find("/personality") and args.player:GetValue("NT_TagName") == "[Admin]" then
		
	end
	
	if string.find(args.text, "/") then
		return
	end
	if args.player:GetValue("PersonalityChat") then
		local personalitychat = args.player:GetValue("PersonalityChat")
		args.player:SetValue("PersonalityChat", personalitychat + self.chat)
	end
	if args.player:GetValue("Personality") then
		local number = 0
		for index, word in pairs(self.minuswords) do
			if string.find(args.text, word) then
				number = number + self.badword
			end
		end
		for index, word in pairs(self.pluswords) do
			if string.find(args.text, word) then
				number = number + self.goodword
			end
		end
		local personality = args.player:GetValue("Personality")
		args.player:SetNetworkValue("Personality", personality + number)
	end
end

function ModuleLoad()
	Personality = Personality()
end
Events:Subscribe("ModuleLoad", ModuleLoad)