class "INukeManager"

function INukeManager:__init()
	self.INukes = {}
	self.IsPlacing = false
	self.LocalPlacingObject = nil
	self.PlacementModel = nil
	
	Events:Subscribe("INuke_Place", self, self.HandlePlacement)
	Events:Subscribe("Render", self, self.Render)
	Events:Subscribe("WorldNetworkObjectCreate", self, self.WorldNetworkObjectCreate)
	Events:Subscribe("WorldNetworkObjectDestroy", self, self.WorldNetworkObjectDestroy)
	Network:Subscribe("NearbyTrapsOnSpawn", self, self.NearbyTrapsOnSpawn)
end

function INukeManager:NearbyTrapsOnSpawn(trap_ids)
	for _, id in pairs(trap_ids) do
		local wno = WorldNetworkObject.GetById(id)
		self:CreateTrap(wno)
	end
end

function INukeManager:WorldNetworkObjectCreate(args)
	if args.object:GetValue("type") == "ImplosionTrap" then
		self:CreateTrap(args.object)
	end
end

function INukeManager:WorldNetworkObjectDestroy(args)
	local inuke = self.INukes[args.object:GetId()]
	if inuke then
		inuke:Remove()
		self.INukes[args.object:GetId()] = nil
	end
end

function INukeManager:CreateTrap(obj)
	local new_trap = INuke(obj)
	self.INukes[obj:GetId()] = new_trap
end

function INukeManager:HandlePlacement()
	self.IsPlacing = true
end

function INukeManager:Render(item_name)
	--print("S: " .. tostring(LocalPlayer:GetBaseState()), Color.Red, ", LAS: " .. tostring(LocalPlayer:GetLeftArmState()), Color.Green, ", UBS: " .. tostring(LocalPlayer:GetUpperBodyState()), Color.Blue)
	--Some borrowed from LF's build, ty
	if self.IsPlacing == true then
		local raycast_max_distance = 50
		local direction = Camera:GetAngle() * Vector3(0, 0, -1)
		local raycast = Physics:Raycast(Camera:GetPosition(), direction, 0.1, raycast_max_distance)
		local normal_angle = Angle.FromVectors(Vector3.Up, raycast.normal)
		local obj_pos = raycast.position + (raycast.normal:Normalized() * 0.35)
		
		local text = "Now placing Implosion Trap"
		local text2 = "Left click to place, right click to cancel"
		local text3 = "Valid Position!"
		local is_position_valid = true
		if raycast.distance == raycast_max_distance then
			text3 = "Invalid Position!"
			is_position_valid = false
		end
		if LocalPlayer:GetValue("CanHit") == false then
			is_position_valid = false
		end
		local size = Render.Size.y / 20
		local pos = Render.Size/2 - Vector2(Render:GetTextSize(text, size).x/2,0) + Vector2(0,Render.Size.y/3)
		local pos2 = Render.Size/2 - Vector2(Render:GetTextSize(text2, size).x/2,0) + Vector2(0,Render.Size.y/3) + Vector2(0,Render:GetTextSize(text,size).y)
		local pos3 = Render.Size/2 - Vector2(Render:GetTextSize(text3, size).x/2,0) + Vector2(0,Render.Size.y/3)+ Vector2(0,Render:GetTextSize(text,size).y) + Vector2(0,Render:GetTextSize(text2,size).y)
		local draw_color = Color.Green
		if is_position_valid == false then
			draw_color = Color.Red
		end
		Render:DrawText(pos, text, draw_color, size)
		Render:DrawText(pos2, text2, draw_color, size)
		Render:DrawText(pos3, text3, draw_color, size)
		
		if not self.PlacementModel and is_position_valid then
			self.PlacementModel = ClientStaticObject.Create({position = obj_pos, angle = normal_angle, model = "general.blz/go063-a1.lod"})
		end
		
		if is_position_valid then
			self.PlacementModel:SetPosition(obj_pos)
			self.PlacementModel:SetAngle(normal_angle)
		end
		
		if Key:IsDown(1) then
			Events:Fire("DeleteFromInventory", {sub_item = "Implosion Trap", sub_amount = 1})
			Network:Send("ImplosionTrapCreate", {position = obj_pos, angle = normal_angle})
			self.IsPlacing = false
		end
		if Key:IsDown(2) then
			self.IsPlacing = false
		end
	end
	
	if not self.IsPlacing and self.PlacementModel != nil then
		self.PlacementModel:Remove()
		self.PlacementModel = nil
	end
end

INM = INukeManager()