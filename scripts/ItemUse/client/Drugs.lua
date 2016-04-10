class 'Drugs'
function Drugs:__init()
	self.timer = Timer()
	self.players = {}
	self.vehicles = {}
	self.loot = {}
	self.Drug_Outline = Image.Create(AssetLocation.Resource, "Drug_Outline_IMG")
	self.Drug_LF = Image.Create(AssetLocation.Resource, "Drug_LF_IMG")
	self.Drug_PF = Image.Create(AssetLocation.Resource, "Drug_PF_IMG")
	self.Drug_VF = Image.Create(AssetLocation.Resource, "Drug_VF_IMG")
	self.Drug_MF = Image.Create(AssetLocation.Resource, "Drug_MF_IMG")
	self.Drug_NOS = Image.Create(AssetLocation.Resource, "Drug_NOS_IMG")
	Events:Subscribe("UseDrug", self, self.UseDrug)
	Events:Subscribe("SecondTick", self, self.GetNearbyThings)
end
function Drugs:GetNearbyThings()
	self.players = {}
	self.vehicles = {}
	for p in Client:GetStreamedPlayers() do
		self.players[p:GetId()] = p
	end
	for v in Client:GetVehicles() do
		self.vehicles[v:GetId()] = v
	end
end
function Drugs:Render()
	if Game:GetState() ~= GUIState.Game then return end
	if not currentdrug then return end
	local size = Vector2(Render.Size.x / 6.4, Render.Size.y / 10.8) / 1.2
	local basepos = Vector2(Render.Size.x / 1.75, Render.Size.y - size.y)
	local percent = self.timer:GetMinutes() / 5
	local pos = size.x - (percent * size.x)
	Render:SetClip(true, basepos + Vector2(pos,0) - Vector2(size.x,0), size)
	currentdrug:Draw(basepos, size, Vector2(0,0), Vector2(1,1))
	Render:SetClip(false)
	self.Drug_Outline:Draw(basepos, size, Vector2(0,0), Vector2(1,1))
	local alpha = 50
	color = Color(255,255,255,alpha)
	if drugname == "LF" then
		color = Color(170,0,255,alpha)
		for static in Client:GetStaticObjects() do
			if static:GetValue("LTier") then
				RenderIndicator(static, color)
			end
		end
	elseif drugname == "VF" then
		color = Color(255,138,0,alpha)
		for id, p in pairs(self.vehicles) do
			RenderIndicator(p, color)
		end
	elseif drugname == "NOS" then
		color = Color(255,93,13,alpha)
	elseif drugname == "PF" then
		color = Color(255,255,0,alpha)
		for id, p in pairs(self.players) do
			RenderIndicator(p, color)
		end
	elseif drugname == "MF" then
		for id, obj in pairs(mines) do
			if IsValid(obj.mine) then
				local dist = Vector3.Distance(obj.mine:GetPosition(), LocalPlayer:GetPosition())
				if dist > 50 then dist = 50 end
				if dist < 10 then dist = 50 end
				alpha = (((50 - dist) / 50) * 255)
				color = Color(255,108,180,alpha)
				RenderIndicator(obj.mine, color)
			end
		end
	end
	if self.timer:GetMinutes() >= 5 and rendersub and gamesub then
		Events:Unsubscribe(rendersub)
		Events:Unsubscribe(gamesub)
		rendersub = nil
		currentdrug = nil
		drugname = nil
	end
end
function RenderIndicator(p, color)
	if not IsValid(p) then return end
    local playerPos = p:GetPosition()
    local dist = playerPos:Distance2D(Camera:GetPosition())
	local tagPos3D = playerPos + Vector3(0,1,0)
	local tagPos2D, t = Render:WorldToScreen(tagPos3D)
	local size = 10
	if not t then return end
	size = size / 1.25
	--Render:DrawCircle(tagPos2D, size, Color(0,0,0,color.a))
	Render:DrawCircle(tagPos2D, size, color)
	Render:DrawCircle(tagPos2D, size / 1.5, color)
	Render:DrawCircle(tagPos2D, size / 2, color)
	Render:DrawCircle(tagPos2D, size / 2.5, color)
	Render:DrawCircle(tagPos2D, size / 3, color)
	Render:DrawCircle(tagPos2D, size / 3.5, color)
	Render:DrawCircle(tagPos2D, size / 4, color)
end
function Drugs:GameRender()
	if not color then return end
	local dist = 1
	Render:FillArea(Vector2(0,0), Render.Size, Color(color.r,color.g,color.b,150))
end
function Drugs:UseDrug(name)
	if name == "Lootfinder Drug" then
		drugname = "LF"
		currentdrug = self.Drug_LF
		self.timer:Restart()
		if not rendersub then
			rendersub = Events:Subscribe("Render", self, self.Render)
		end
		if not gamesub then
			gamesub = Events:Subscribe("GameRender", self, self.GameRender)
		end
	elseif name == "Playerfinder Drug" then
		drugname = "PF"
		currentdrug = self.Drug_PF
		self.timer:Restart()
		if not rendersub then
			rendersub = Events:Subscribe("Render", self, self.Render)
		end
		if not gamesub then
			gamesub = Events:Subscribe("GameRender", self, self.GameRender)
		end
	elseif name == "Vehiclefinder Drug" then
		drugname = "VF"
		currentdrug = self.Drug_VF
		self.timer:Restart()
		if not rendersub then
			rendersub = Events:Subscribe("Render", self, self.Render)
		end
		if not gamesub then
			gamesub = Events:Subscribe("GameRender", self, self.GameRender)
		end
	elseif name == "NoS Drug" then
		drugname = "NOS"
		currentdrug = self.Drug_NOS
		self.timer:Restart()
		if not rendersub then
			rendersub = Events:Subscribe("Render", self, self.Render)
		end
		if not gamesub then
			gamesub = Events:Subscribe("GameRender", self, self.GameRender)
		end
		Events:Fire("DeleteFromInventory", {sub_item = "NoS Drug", sub_amount = 1})
	elseif name == "Minefinder Drug" then
		drugname = "MF"
		currentdrug = self.Drug_MF
		self.timer:Restart()
		if not rendersub then
			rendersub = Events:Subscribe("Render", self, self.Render)
		end
		if not gamesub then
			gamesub = Events:Subscribe("GameRender", self, self.GameRender)
		end
		Events:Fire("DeleteFromInventory", {sub_item = "Minefinder Drug", sub_amount = 1})
	--[[elseif name == "Mind Game Drug" then
		currentdrug = "MG"
		self.timer:Restart()
		if not rendersub then
			rendersub = Events:Subscribe("Render", self, self.Render)
		end--]]
	end
end
--add more drugs like health regen, stamina, damage, etc
Drugs = Drugs()