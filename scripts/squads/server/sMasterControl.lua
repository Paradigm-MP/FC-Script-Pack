class 'TroopMaster'

function TroopMaster:__init()
	self.squads         = {}
	self.timer          = Timer()
	self.time           = 0
	self.lastRenderTime = 0
	subRender           = Events:Subscribe("PreTick", self, self.Ticker)
	Events:Subscribe("ModuleUnload", self, self.Unload)
end

function TroopMaster:Ticker()
	self.time = self.timer:GetMilliseconds()
	if self.time - self.lastRenderTime < 1000 / updatesPerSecond then return end
	
	local i = 1
	while i <= #self.squads do
		self.squads[i]:Update()
		i = i + 1
	end
	
	self.lastRenderTime = self.time
end

function TroopMaster:NewSquad(file)
	local squad  = Squad()
	local result = squad:Parse(file, height)
	if result then
		table.insert(self.squads, squad)
		--print("shark " .. file .. " - " .. " loaded")
	else
		print(file .. " is not a valid shark file!")
	end
end

function TroopMaster:Unload()
	local i = 1
	while i <= #self.squads do
		self.squads[i]:Remove()
		i = i + 1
	end
end
