class 'Zombie'

function Zombie:__init(horde_obj, horde)
	self.horde = horde -- class object
	self.horde_obj = horde_obj -- WNO
	
	self.zombie = WorldNetworkObject.Create({position = Vector3(), angle = Angle()})
	self.zombie:SetStreamDistance(500)
	self.zombie:SetNetworkValue("iZombie", 26)
	self.zombie:SetNetworkValue("Health", 1) -- 0 <-> 1
	self.zombie:SetNetworkValue("Targetting", nil)
	self.zombie:SetNetworkValue("EvadePreference", math.random(0, 1))
	
	self.id = self.zombie:GetId()
	
	self.health = 1
	self.offset = (Vector3.Forward * (math.random() + math.random(-12, 12))) + (Vector3.Right * (math.random() + math.random(-5, 5))) -- randomly shaped hordes
end

function Zombie:Update()
	if self.target then
		if IsValid(self.target) then
			if self.health > 0 then
				if self.target:GetHealth() > 0 then
					self.zombie:SetPosition(self.target:GetPosition())
				else
					self.zombie:SetNetworkValue("Targetting", nil)
					self.target = nil
				end
			end
		else
			self.zombie:SetNetworkValue("Targetting", nil)
			self.target = nil
		end
	else
		if IsValid(self.horde_obj) then
			if self.health > 0 then
				local angle = self.horde_obj:GetAngle()
				self.zombie:SetAngle(angle)
				self.zombie:SetPosition(self.horde_obj:GetPosition() + (angle * self.offset))
			end
		else
			self:Remove()
		end
	end
end

function Zombie:SetPosition(vector3)
	self.zombie:SetPosition(vector3)
end

function Zombie:SetAngle(angle)
	self.zombie:SetAngle(angle)
end

function Zombie:Damage(dmg)
	local new_health = self.zombie:GetValue("Health") - dmg
	self.zombie:SetNetworkValue("Health", new_health)
	self.health = new_health
	if new_health <= 0 then
		self.horde:ZombieDeath(self.id, self)
		self.zombie:SetNetworkValue("Targetting", nil)
		self.target = nil
	end
end

function Zombie:Respawn()
	self.health = 1
	self.zombie:SetNetworkValue("Health", 1)
end

function Zombie:SetTarget(ply)
	self.zombie:SetNetworkValue("Targetting", ply)
	self.target = ply
end

function Zombie:UnTarget()
	self.zombie:SetNetworkValue("Targetting", nil)
	self.target = nil
end

function Zombie:GetId()
	return self.id
end

function Zombie:GetPosition()
	return self.zombie:GetPosition()
end

function Zombie:GetHealth()
	return self.zombie:GetValue("Health")
end

function Zombie:IsValid()
	return IsValid(self.zombie)
end

function Zombie:Remove()
	if IsValid(self.zombie) then
		self.zombie:Remove()
	end
end