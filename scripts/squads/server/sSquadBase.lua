class 'Squad'

function Squad:__init()
	self.targets   = {}
	self.velocity  = 0
	self.reflect   = true

	self.current   = 0
	self.step      = 1

	args = {}
	args.position  = Vector3()
	args.angle     = Angle()

	self.object    = WorldNetworkObject.Create(args)
	self.object:SetStreamDistance(650)
	self.object:SetNetworkValue("Squad", 15)
end

function Squad:Update()
	local position = self.object:GetPosition()
	--for p in Server:GetPlayers() do
	--	p:SetPosition(position)
	--end
	local distance = position - self.targets[self.current]
	--print("distance: " .. tostring(distance))
	self.object:SetAngle(Angle(-math.atan2(distance.z, distance.x) - (math.pi / 2), 0, 0))

	--print(self.velocity)

	position   = position - (self.object:GetAngle() * Vector3.Forward) * self.velocity
	--position.y = self.height
	self.object:SetPosition(position)

	if math.abs(distance.x) < targetDistance and math.abs(distance.z) < targetDistance then
		--print("selecting new")
		--print("distance.x: " .. tostring(distance.x))
		--print("distance.z: " .. tostring(distance.z))
		--print("self.current: " .. tostring(self.current))
		self:Select(self.current, false)
	end
end

function Squad:Select(index, place)
	local pos = self.targets[index]
	if place then self.object:SetPosition(pos) end

	index = index + self.step

	if index > #self.targets then
		index     = self.reflect and #self.targets - 1 or 1
		self.step = self.reflect and -1 or 1
	elseif index == 0 then
		index     = self.reflect and 2 or #self.reflect
		self.step = self.reflect and 1 or -1
	end

	self.current = index
end

function Squad:Parse(file, ship_type)
	local file = io.open(file, "r")
	if file == nil then
		print("file is nil")
		return false
	end

	local line, values
	local first = true
	for line in file:lines() do
		line   = line:gsub("\t", ""):gsub(" ", "")
		values = line:split(",")
		if first then
			self.velocity = tonumber(values[1])
			self.reflect  = values[2] == "true" and true or false
			first         = false
		else
			if #values >= 3 then
				table.insert(self.targets, Vector3(tonumber(values[1]), tonumber(values[2]), tonumber(values[3])))
			end
		end
	end

	if #self.targets < 2 then return false end

	self:Select(1, true)
	return true
end

function Squad:Remove()
	if IsValid(self.object) then
		self.object:Remove()
	end
end
