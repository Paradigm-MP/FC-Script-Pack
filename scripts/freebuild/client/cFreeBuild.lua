class 'FreeBuild'
function FreeBuild:__init()
	--X_ICON = Image.Create(AssetLocation.Resource, "X_IMG")
	--CHECK_ICON = Image.Create(AssetLocation.Resource, "CHECK_IMG")
	maxplacedistance = 20
	self.angle = Angle(0,0,0)
	self.rotateTimer = Timer()
	self.rotateOther = math.pi/2
	self.angle2 = Angle(0,0,0)
	self.timer = Timer() --delay for localplayerinput to be blocked
	self.speed = 100 --smaller number = faster rotation
	Events:Subscribe("LC_PlaceBuildingItem", self, self.InitPlacing)
	Events:Subscribe("ModuleUnload", self, self.Unload)
	--Events:Subscribe("LocalPlayerChat", self, self.Chat)
	Events:Subscribe("LC_UseBuildItemCheck", self, self.CheckItem)
	Network:Subscribe("LC_RefundBuildingItem", self, self.Refund)
	
	self.LMBImage 	= 	Image.Create(AssetLocation.Resource, "LMB")
	self.RMBImage	= 	Image.Create(AssetLocation.Resource, "RMB")
	self.YesImage 	= 	Image.Create(AssetLocation.Resource, "Yes")
	self.NoImage	= 	Image.Create(AssetLocation.Resource, "No")
	
end
function FreeBuild:CheckItem(item)
	if not objects[item] then return end
	self:InitPlacing(item)
end
function FreeBuild:Unload()
	if IsValid(self.object) then self.object:Remove() end
end
--[[function FreeBuild:Chat(args)
	if args.text == "/b" then
		self:InitPlacing("Strong Metal Sheet")
	end
end--]]
function FreeBuild:Refund(item)
	Events:Fire("UpdateSharedObjectInventory")
	if CanAddItem(item, 1, reference[item]) then
		Events:Fire("AddToInventory", {add_item = item, add_amount = 1})
	else
		local lootstring = tostring(item).." (1)"
		Events:Fire("Crafting_SpawnDropbox", lootstring)
		Chat:Print("Inventory overflow!", Color.Yellow)
	end
end
function FreeBuild:RaycastToGround()
	local r1 = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, maxplacedistance)
	local r2 = Physics:Raycast(r1.position + Vector3(0,0.05,0), Vector3.Down, 0, 99)
	if r1.distance == maxplacedistance then
		r1.position = r2.position
	end
	r2.entity = r1.entity
	if canberotated[self.iname] then
		return r1
	else
		return r2
	end
end
function FreeBuild:InitPlacing(name)
	self.iname = name
	self.angle2 = Angle(0,0,0)
	if not objects[self.iname] then Chat:Print("Invalid building name!", Color.Red) return end
	self.angle = Angle(0,0,0)
	if IsValid(self.object) then self.object:Remove() self.object = nil end
	if not self.rendersub then
		self.rendersub = Events:Subscribe("Render", self, self.RenderText)
		FadeInTimer = Timer()
	end
	if not self.inputsub then
		self.inputsub = Events:Subscribe("LocalPlayerInput", self, self.LPI)
	end
	spawnArgs = {}
	spawnArgs.position = self:RaycastToGround().position
	spawnArgs.angle = self.angle
	--spawnArgs.model = "areaset01.blz/gb090-g.lod"
	spawnArgs.model = objects[self.iname]
	-- NEVER USE COLLISION WHEN CLIENT PLACING OBJECT
	self.object = ClientStaticObject.Create(spawnArgs)
end
function FreeBuild:ExitPlacing()
	--subscribe events
	self.distances = nil	
	if self.rendersub then
		Events:Unsubscribe(self.rendersub)
		FadeInTimer = nil
	end
	self.rendersub = nil
	self.id = nil
	self.name = nil
	self.iname = nil
	self.object:Remove()
	self.object = nil
	self.timer:Restart()
end
function FreeBuild:LPI(args)
	--block firing
	if args.input == Action.FireRight or args.input == Action.FireLeft or args.input == Action.Fire
	or args.input == Action.Reload then
		return false
	end
	if self.timer:GetSeconds() > 1 and not self.rendersub then
		if self.inputsub then
			Events:Unsubscribe(self.inputsub)
			self.inputsub = nil
		end
	end
end
function FreeBuild:CheckBoundingBox()
	if not IsValid(self.object) then return false end
	if not tempObj and not self.distances then
		tempObj = ClientStaticObject.Create({
			position = self.object:GetPosition() - Vector3(0,100,0),
			angle = Angle(0,0,0),
			model = self.object:GetModel()})
	end
	if IsValid(tempObj) then
		local b1, b2 = self.object:GetBoundingBox()
		local div = 1.25 --increase to 1.25 to give the player more leeway when placing into other objs
		if self.iname == "Bed" then div = 0.75 end
		self.distances = Vector3(math.abs(b1.x - b2.x)/div,math.abs(b1.y - b2.y)/div,math.abs(b1.z - b2.z)/div)
		tempObj:Remove()
		tempObj = nil
	end
	local base = self.object:GetPosition()
	local angle = self.object:GetAngle()
	local xAdj = (angle * Vector3(self.distances.x,0,0))
	local yAdj = (angle * Vector3(0,self.distances.y,0))
	local zAdj = (angle * Vector3(0,0,self.distances.z))
	local yAddRay = 0.25
	local p1 = base + (xAdj/2) + (zAdj/2) + yAdj
	local p2 = base + (xAdj/2) - (zAdj/2) + yAdj
	local p3 = base - (xAdj/2) + (zAdj/2) + yAdj
	local p4 = base - (xAdj/2) - (zAdj/2) + yAdj
	--[[Render:FillCircle(p1 - yAdj, 0.1, Color.Red)
	Render:FillCircle(p2 - yAdj, 0.1, Color.Orange)
	Render:FillCircle(p3 - yAdj, 0.1, Color.Yellow)
	Render:FillCircle(p4 - yAdj, 0.1, Color.Green)
	Render:FillCircle(base, 0.1, Color.Blue)--]]
	local ray1 = Physics:Raycast(p1 + Vector3(0,yAddRay,0), angle * Vector3.Down, 0, yAdj.y + yAddRay)
	local ray2 = Physics:Raycast(p2 + Vector3(0,yAddRay,0), angle * Vector3.Down, 0, yAdj.y + yAddRay)
	local ray3 = Physics:Raycast(p3 + Vector3(0,yAddRay,0), angle * Vector3.Down, 0, yAdj.y + yAddRay)
	local ray4 = Physics:Raycast(p4 + Vector3(0,yAddRay,0), angle * Vector3.Down, 0, yAdj.y + yAddRay)
	local ray5 = Physics:Raycast(base + yAdj + Vector3(0,yAddRay,0), angle * Vector3.Down, 0, yAdj.y + yAddRay)
	local ray6 = Physics:Raycast(base + Vector3(0,yAddRay,0), angle * Vector3.Up, 0, yAdj.y + yAddRay)
	if ray1.distance < yAdj.y
	or ray2.distance < yAdj.y 
	or ray3.distance < yAdj.y 
	or ray4.distance < yAdj.y
	or ray5.distance < yAdj.y
	or ray6.distance < yAdj.y then
		return false
	end
	if not canberotated[self.iname] then
		if angle.roll > math.pi/4 or angle.roll < -math.pi/4
		or angle.pitch > math.pi/4 or angle.pitch < -math.pi/4 then
			return false
		end
	end
	if LocalPlayer:GetState() ~= 4 then
		--Chat:Print("bad8", Color.Red)
		return false
	end
	if Vector3.Distance(base, LocalPlayer:GetPosition()) > maxplacedistance then return false end
	for _, pos in pairs(restrictedAreas) do
		local radius = 500
		if _ == 7 then radius = 1450 end
		if Vector3.Distance(base, pos) < radius then
			return false
		end
	end
	for _, tbl in pairs(Airport) do
		if Vector3.Distance(base, tbl.position) < 500 then
			return false
		end
	end
	for index, tbl in pairs(cursed_locations) do
		if Vector3.Distance(tbl.position, base) < tbl.radius then
			return false
		end
	end
	if self.iname == "Air Generator" and base.y > 190 then return false end
	if math.abs(base.y - Physics:GetTerrainHeight(base)) > 850 then return false end
	return true
end
function FreeBuild:RenderText()
	
if FadeInTimer then
	
	alpha1 = math.clamp(0 + (FadeInTimer:GetSeconds() * 340), 0, 170)
	if alpha1 >= 170 then alpha1 = 170 end
	
	alpha2 = math.clamp(0 + (FadeInTimer:GetSeconds() * 400), 0, 200)
	if alpha2 >= 200 then alpha2 = 200 end
	
	imagealpha	=	math.clamp(0 + (FadeInTimer:GetSeconds()), 0, 1)
	if imagealpha >= 1 then imagealpha = 1 end
	
	local Ptxt		=	"Can place:"
	local LMBtxt	=	"Place"
	local RMBtxt	=	"Cancel"
	local Rtxt		=	"to rotate"
	local Utxt		=	"Use"
	
	Render:FillArea(Vector2((Render.Width / 2 - 200),(Render.Height - 105)), Vector2(400,75), Color(0,0,0,200))
	
	Render:FillArea(Vector2((Render.Width / 2 - 50),(Render.Height - 105)), Vector2(1,75), Color(170,170,170,alpha1))
	Render:FillArea(Vector2((Render.Width / 2 + 50),(Render.Height - 105)), Vector2(1,75), Color(170,170,170,alpha1))
	
	Render:FillArea(Vector2((Render.Width / 2 - 200),(Render.Height - 105)), Vector2(1,75), Color(170,170,170,alpha1))
	Render:FillArea(Vector2((Render.Width / 2 + 200),(Render.Height - 105)), Vector2(1,75), Color(170,170,170,alpha1))
	Render:FillArea(Vector2((Render.Width / 2 - 200),(Render.Height - 105)), Vector2(400,1), Color(170,170,170,alpha1))
	Render:FillArea(Vector2((Render.Width / 2 - 200),(Render.Height - 30)), Vector2(400,1), Color(170,170,170,alpha1))
		
	Render:DrawText(Vector2((Render.Width / 2 ) - (Render:GetTextWidth(Ptxt, 16) / 2 ), Render.Height - 100), Ptxt, Color(170,170,170,alpha2), 16)
	Render:DrawText(Vector2((Render.Width / 2 + 89) - (Render:GetTextWidth(LMBtxt, 14) / 2 ), Render.Height - 50), LMBtxt, Color(170,170,170,alpha2), 14)
	Render:DrawText(Vector2((Render.Width / 2 + 160) - (Render:GetTextWidth(RMBtxt, 14) / 2 ), Render.Height - 50), RMBtxt, Color(170,170,170,alpha2), 14)
	Render:DrawText(Vector2((Render.Width / 2 - 125) - (Render:GetTextWidth(Utxt, 16) / 2 ), Render.Height - 100), Utxt, Color(170,170,170,alpha2), 16)
	Render:DrawText(Vector2((Render.Width / 2 - 125) - (Render:GetTextWidth(Rtxt, 16) / 2 ), Render.Height - 50), Rtxt, Color(170,170,170,alpha2), 16)
	
	if canberotated[self.iname] then
		local Btxt		=	"R  &  Z"
		Render:DrawText(Vector2((Render.Width / 2 - 125) - (Render:GetTextWidth(Btxt, 25) / 2 ), Render.Height - 78), Btxt, Color(200,200,200,alpha2), 25)
	else
		local Btxt		=	"R"
		Render:DrawText(Vector2((Render.Width / 2 - 125) - (Render:GetTextWidth(Btxt, 25) / 2 ), Render.Height - 78), Btxt, Color(200,200,200,alpha2), 25)
	end
	
	if not self:CheckBoundingBox() then
		local Btxt		=	"R  &  Z"
		self.NoImage:SetAlpha(imagealpha)
		self.NoImage:Draw(Vector2((Render.Width / 2 - 22.5), Render.Height - 80), Vector2(45,45), Vector2(0,0),Vector2(1,1))
	else
		self.YesImage:SetAlpha(imagealpha)
		self.YesImage:Draw(Vector2((Render.Width / 2 - 22.5), Render.Height - 80), Vector2(45,45), Vector2(0,0),Vector2(1,1))
	end
	
	self.LMBImage:SetAlpha(imagealpha)
	self.RMBImage:SetAlpha(imagealpha)
	self.LMBImage:Draw(Vector2((Render.Width / 2 + 65), Render.Height - 105), Vector2(50,50), Vector2(0,0),Vector2(1,1))
	self.RMBImage:Draw(Vector2((Render.Width / 2 + 135), Render.Height - 105), Vector2(50,50), Vector2(0,0),Vector2(1,1))
	
	
	end
	self:AdjustPropPosition()
	if Key:IsDown(1) and self:CheckBoundingBox() and Game:GetState() == 4 then
		local args = {}
		args.pos = self.object:GetPosition()
		args.angle = self.object:GetAngle()
		args.id = self.id
		args.iname = self.iname
		Network:Send("LC_ClientObjectPlace", args)
		if self.iname then
			Events:Fire("DeleteFromInventory", {sub_item = self.iname, sub_amount = 1})
		end
		self:ExitPlacing()
	elseif Key:IsDown(2) then
		Chat:Print("Building placement cancelled.", Color.Red)
		self:ExitPlacing()
	end
end
function FreeBuild:AdjustPropPosition()
	if Key:IsDown(VirtualKey.LControl) then
		self.speed = 1000
	else
		self.speed = 100
	end
	if Key:IsDown(string.byte('R')) then -- r
		if Key:IsDown(VirtualKey.LShift) then
			self.angle = Angle(-math.pi/self.speed,0,0) * self.angle
		else
			self.angle = Angle(math.pi/self.speed,0,0) * self.angle
		end
	elseif Key:IsDown(string.byte('Z')) and canberotated[self.iname] then
		local baseA = canberotated[self.iname]
		if Key:IsDown(VirtualKey.LShift) then
			self.angle2 = Angle(-baseA.yaw/self.speed,-baseA.pitch/self.speed,-baseA.roll/self.speed) * self.angle2
		else
			self.angle2 = Angle(baseA.yaw/self.speed,baseA.pitch/self.speed,baseA.roll/self.speed) * self.angle2
		end
	elseif Key:IsDown(string.byte('X')) and canberotated[self.iname] then
		local entity = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, 10).entity
		if IsValid(entity) and entity.__type == "StaticObject" then
			self.angle = entity:GetAngle()
			self.angle2 = Angle(0,0,0)
		end
	end
	local ray = self:RaycastToGround()
	local pos = ray.position
	if not IsValid(self.object) then return end
	local angle = Angle.FromVectors(Vector3.Up, Angle.Inverse(self.angle) * ray.normal)
	self.object:SetAngle(self.angle * angle)
	self.object:SetAngle(self.object:GetAngle() * self.angle2)
	if canberotated[self.iname] then
		local biggest = self:CalcBiggest()
		pos = pos + Vector3(0,biggest,0) - Vector3(0,0.25,0)
	end
	self.object:SetPosition(pos)
end
function FreeBuild:CalcBiggest()
	--calculates stuff blah blah makes it sit on the ground when rotating
	if not self.distances then return 0 end
	local base = self.object:GetPosition()
	local angle = self.object:GetAngle()
	local xAdj = (angle * Vector3(self.distances.x,0,0))
	local yAdj = (angle * Vector3(0,self.distances.y,0))
	local zAdj = (angle * Vector3(0,0,self.distances.z))
	local p1 = base + (xAdj/2) + (zAdj/2) + yAdj
	local p2 = base + (xAdj/2) - (zAdj/2) + yAdj
	local p3 = base - (xAdj/2) + (zAdj/2) + yAdj
	local p4 = base - (xAdj/2) - (zAdj/2) + yAdj
	local biggest = CalcBasedOnPoints(p1,p2,p3,p4)
	biggest = biggest / 2
	return biggest
end
function CalcBasedOnPoints(p1,p2,p3,p4)
	biggest = 0
	if p1.y - p2.y > biggest then biggest = p1.y - p2.y end
	if p1.y - p3.y > biggest then biggest = p1.y - p3.y end
	if p1.y - p4.y > biggest then biggest = p1.y - p4.y end
	if p2.y - p1.y > biggest then biggest = p2.y - p1.y end
	if p2.y - p3.y > biggest then biggest = p2.y - p3.y end
	if p2.y - p4.y > biggest then biggest = p2.y - p4.y end
	if p3.y - p1.y > biggest then biggest = p3.y - p1.y end
	if p3.y - p2.y > biggest then biggest = p3.y - p2.y end
	if p3.y - p4.y > biggest then biggest = p3.y - p4.y end
	if p4.y - p2.y > biggest then biggest = p4.y - p2.y end
	if p4.y - p3.y > biggest then biggest = p4.y - p3.y end
	if p4.y - p1.y > biggest then biggest = p4.y - p1.y end
	return biggest
end
FreeBuild = FreeBuild()


function CanAddItem(item, number, category)
	local inv = SharedObject.GetByName("ClientSharedInventory"):GetValue("INV")
	if table.count(inv[category]) < LocalPlayer:GetValue("CatMaxes")[category] then return true end
		for index, lootstring in pairs(inv[category]) do
			if GetLootName(lootstring) == item then
				if GetLootAmount(lootstring) + number <= stacklimit[item] then
					return true
				end
			end
		end
	return false
end

function GetLootName(lootstring)
	local number = tonumber(string.match(lootstring, '%d+'))
	local item34 = ""
	if number == nil then return nil end
	if number < 10 then
		item34 = string.sub(lootstring, 1, string.len(lootstring) - 4)
	elseif number >= 10 then
		item34 = string.sub(lootstring, 1, string.len(lootstring) - 5)
	elseif number >= 100 then
		item34 = string.sub(lootstring, 1, string.len(lootstring) - 6)
	elseif number >= 1000 then
		item34 = string.sub(lootstring, 1, string.len(lootstring) - 7)
	end
	return item34
end

function GetLootAmount(lootstring)
	local number = tonumber(string.match(lootstring, '%d+'))
	return number
end