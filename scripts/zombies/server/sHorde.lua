class 'Horde'

function Horde:__init(master)
	self.master = master
	
	self.targets   = {}
	self.velocity  = 0
	self.reflect   = true
	
	self.chase_distance_max = 100

	self.current   = 0
	self.step      = 1

	self.horde    = WorldNetworkObject.Create({position = Vector3(), angle = Angle()})
	self.horde:SetStreamDistance(650)
	self.horde:SetNetworkValue("iHorde", true)
	
	self.zombies = {}
	
	for i = 1, 26 do
		self:AddZombie()
	end
end

function Horde:AddZombie()
	local zomb = Zombie(self.horde, self)
	table.insert(self.zombies, zomb)
	global_zombies[zomb:GetId()] = zomb
end

function Horde:Update()
	local position = self.horde:GetPosition()

	local distance = position - self.targets[self.current]
	local target_pos = self.targets[self.current]
	
	local ang = Angle.FromVectors(Vector3.Forward, target_pos - position)
	local horde_ang = Angle(ang.yaw, ang.pitch, 0) * Angle(math.pi, 0, 0)
	
	self.horde:SetAngle(horde_ang)

	position   = position - (horde_ang * Vector3.Forward) * self.velocity
	self.horde:SetPosition(position)
	
	if math.abs(distance.x) < targetDistance and math.abs(distance.z) < targetDistance then
		self:Select(self.current, false)
	end
	
	for i = 1, #self.zombies do
		self.zombies[i]:Update()
	end
end

function Horde:Select(index, place)
	local pos = self.targets[index]
	
	if place then self.horde:SetPosition(pos) end

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

function Horde:Parse(file)
	local file = io.open(file, "r")
	if file == nil then
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

function Horde:ZombieDeath(id, zomb)
	respawn_queue[id] = {time = self.master.timer:GetSeconds(), zombie = zomb}
	local drop_table = {}
	math.random()
end

function Horde:GetId()
	return self.horde:GetId()
end

function Horde:GetPosition()
	return self.horde:GetPosition()
end

function Horde:Remove()
	if IsValid(self.horde) then
		for i = 1, #self.zombies do
			self.zombies[i]:Remove()
			self.zombies[i] = nil
		end
		self.horde:Remove()
	end
end
