class 'Pets'
function Pets:__init()
	self.petobjs = {}
	self.petTimers = {} --wno id, timer .. used for up/down movements when heal/attack
	self.healdist = 4
	self.attackdsit = 3
	self.updowntime = 0.75
	self.timer = Timer()
	self.reddistance = 5000 --increase for smoother movement and more delay, decrease for opposite
	self.bluedistance = 15000 --increase for smoother movement and more delay, decrease for opposite
	self.healattamnt = 0.0000125
	Events:Subscribe("PostTick", self, self.Movement)
	Events:Subscribe("PlayerDeath", self, self.OwnerDie)
	Events:Subscribe("PlayerQuit", self, self.Quit)
	Events:Subscribe("ModuleUnload", self, self.Unload)
	Network:Subscribe("PetDataChange", self, self.PetDataChange)
	Network:Subscribe("PetSummon", self, self.PetSummon)
	Network:Subscribe("PetTerminate", self, self.PetTerminate)
	Network:Subscribe("Pets_PetRitualComplete", self, self.RitualComplete)
	Network:Subscribe("GuardOtherUpdateTarget", self, self.GuardOtherUpdateTarget)
end
function Pets:GuardOtherUpdateTarget(args, sender)
	if not IsValid(args.attacker) or not IsValid(args.obj) then return end
	if args.attacker == args.obj:GetValue("Owner") then return end
	args.obj:SetValue("GuardingTargetOther", sender)
	args.obj:SetNetworkValue("Target", args.attacker)
	args.obj:SetNetworkValue("State", "ATTACK")
end
function Pets:RitualComplete(args, sender)
	if IsValid(sender) and not sender:GetValue("Pet_Enabled") then
		sender:SetNetworkValue("Pet_Enabled", true)
		sender:SetPosition(Vector3(12264.432617, 268.835358, -3464.809570))
		Events:Fire("Pets_InsertSQL", sender)
	end
end
function Pets:Unload()
	for player in Server:GetPlayers() do
		player:SetNetworkValue("Pet_Enabled", nil)
	end
	for id, wnoid in pairs(self.petobjs) do
		local obj = WorldNetworkObject.GetById(wnoid)
		if IsValid(obj) then
			obj:Remove()
		end
	end
end
function Pets:OwnerDie(args)
	if args.player:GetValue("Pet_Enabled") and self.petobjs[args.player:GetId()] then
		self:KillPet(args.player:GetId(), args.player)
	end
end
function Pets:MakePetHealMove(seconds, obj)
	if seconds <= self.updowntime then
		obj:SetValue("extrapos", Vector3(0,-3,0))
	elseif seconds >= self.updowntime and seconds < (self.updowntime * 2) then
		obj:SetValue("extrapos", Vector3(0,3,0))
	end
end
function Pets:Movement()
	local timerTime = self.timer:GetMinutes()
	for id, wnoid in pairs(self.petobjs) do
		local obj = WorldNetworkObject.GetById(wnoid)
		if not IsValid(obj) then self.petobjs[id] = nil return end
		local state = obj:GetValue("State")
		local seconds = self.petTimers[obj:GetId()]:GetSeconds()
		local target = obj:GetValue("Target")
		if not IsValid(target) then
			obj:SetNetworkValue("Target", obj:GetValue("Owner"))
			obj:SetNetworkValue("State", "GUARD")
			state = "GUARD"
			target = obj:GetValue("Owner")
		end
		local extrapos = obj:GetValue("extrapos")
		local pickUpTime = tonumber(obj:GetValue("Time"))
		local sType = obj:GetValue("Type")
		if pickUpTime and timerTime - pickUpTime > 5 then
			obj:SetValue("Time", timerTime)
			if math.random(25) == 1 and obj:GetValue("Experience") then
				Network:Send(obj:GetValue("Owner"), "PetFindItem")
				obj:SetNetworkValue("Experience", obj:GetValue("Experience") + 60)
				self:CheckIfGainedLevel(obj)
			end
			if math.random(15) == 1 and obj:GetValue("Experience") then
				local owner = obj:GetValue("Owner")
				owner:SetMoney(owner:GetMoney() + math.random(40))
				obj:SetNetworkValue("Experience", obj:GetValue("Experience") + 20)
				self:CheckIfGainedLevel(obj)
				self:SendChatMessage(obj:GetValue("Name"), sType, obj:GetValue("Owner"), "FOUNDMONEY")
			end
		end
		if seconds > (self.updowntime * 2) and obj:GetValue("Experience") then
			self.petTimers[obj:GetId()]:Restart()
			if sType == "blue" then
				if state == "HEAL" then
					obj:SetNetworkValue("Experience", tonumber(obj:GetValue("Experience")) + 2.5)
				else
					obj:SetNetworkValue("Experience", tonumber(obj:GetValue("Experience")) + 1.5)
				end
			else
				if state == "ATTACK" then
					obj:SetNetworkValue("Experience", tonumber(obj:GetValue("Experience")) + 2)
				else
					obj:SetNetworkValue("Experience", tonumber(obj:GetValue("Experience")) + 1)
				end
			end
			self:CheckIfGainedLevel(obj)
		end
		local pos1 = obj:GetPosition()
		local rando = obj:GetValue("randompos")
		local speed = self.bluedistance
		local owner = obj:GetValue("Owner")
		if not IsValid(target) and IsValid(owner) then
			targetpos = owner:GetPosition()
		elseif IsValid(target) then
			targetpos = target:GetPosition()
		else
			targetpos = obj:GetPosition()
		end
		if rando then
			obj:SetValue("randompos", rando + Vector3(math.random(-0.01,0.01),math.random(-0.002,0.002),math.random(-0.01,0.01)))
		else
			obj:SetValue("randompos", Vector3(math.random(-0.01,0.01),math.random(-0.002,0.002),math.random(-0.01,0.01)))
		end
		if state == "PATROL" then
			targetpos = obj:GetValue("patrolpos")
			self:MakePetPatrol(state, sType, obj)
		end
		if rando and extrapos then
			pos3 = targetpos + Vector3(0,1.5,0) + rando + extrapos --TARGET POSITION
		elseif extrapos then
			pos3 = targetpos + Vector3(0,1.5,0) + extrapos --TARGET POSITION
		else
			pos3 = targetpos + Vector3(0,1.5,0) --TARGET POSITION
		end
		if state == "ATTACK" or state == "HEAL" then
			pos3 = targetpos + Vector3(0,2,0) + extrapos
			self:MakePetHealMove(seconds, obj)
			obj:SetValue("randompos", Vector3(0,0,0))
			if seconds == self.updowntime then
				obj:SetNetworkValue("Experience", obj:GetValue("Experience") + 8)
				self:CheckIfGainedLevel(obj)
			end
		elseif state == "FOLLOW" or state == "GUARD" then
			obj:SetValue("extrapos", Vector3(0,0,0))
		end
		local dist = Vector3.Distance(pos1, pos3)
		if dist > 500 then
			dist = 500
		end
		if sType == "red" and math.random() < 0.025 then
			self:MakePetLoiter(state, sType, obj)
		elseif sType == "blue" and math.random() < 0.0025 then
			self:MakePetLoiter(state, sType, obj)
		end
		if sType == "red" then
			speed = self.reddistance
		end
		local fraction = dist / speed
		local speed2 = 1 --HIGHER = SMOOTHER BUT SLOWER ... could be used to make pets faster with lvl idk
		if state == "PATROL" then
			dist = dist / 250
		end
		--local lerp = math.lerp(pos1, pos3, fraction * ((dist + 1) / speed2))
		if extrapos and extrapos.y ~= 0 then
			dist = dist * 4
		end
		local percentage = fraction * ((dist * 4) + 1)
		if percentage > 1 then percentage = 1 end
		local lerp = math.lerp(pos1, pos3, percentage)
		if IsNaN(lerp) then return end
		obj:SetPosition(lerp)
		if IsValid(target) and (target:GetValue("CanHit") == false or target:GetValue("Invincible")) then
			if state == "ATTACK" then
				if obj:GetValue("GuardingTargetOther") then
					obj:SetNetworkValue("Target", obj:GetValue("GuardingTargetOther"))
					obj:SetNetworkValue("State", "GUARD")
					obj:SetValue("GuardingTargetOther", nil)
					self:SendChatMessage(obj:GetValue("Name"), sType, obj:GetValue("Owner"), "NOATTACK")
				else
					obj:SetNetworkValue("Target", obj:GetValue("Owner"))
					obj:SetNetworkValue("State", "GUARD")
					self:SendChatMessage(obj:GetValue("Name"), sType, obj:GetValue("Owner"), "NOATTACK")
				end
			end
		end
		if state == "HEAL" and IsValid(target) and obj:GetValue("Type") == "blue" then
			local level = tonumber(obj:GetValue("Level"))
			local dist2 = Vector3.Distance(lerp, targetpos)
			if dist2 < self.healdist and target:GetHealth() > 0 and target:GetHealth() < 1 then
				target:Damage(-self.healattamnt * level)
				if target:GetHealth() == 1 then
					obj:SetNetworkValue("State", "GUARD")
					obj:SetValue("extrapos", Vector3(0,0,0))
				end
			elseif target:GetHealth() == 1 then
				obj:SetNetworkValue("State", "GUARD")
				obj:SetValue("extrapos", Vector3(0,0,0))
				self:SendChatMessage(obj:GetValue("Name"), sType, obj:GetValue("Owner"), "HEALED_PLAYER")
			elseif target:GetHealth() == 0 then
				obj:SetNetworkValue("State", "GUARD")
				obj:SetNetworkValue("Target", obj:GetValue("Owner"))
				obj:SetValue("extrapos", Vector3(0,0,0))
			end
		elseif state == "GUARD" and obj:GetValue("Type") == "blue" and IsValid(target) then
			if target:GetHealth() < 1 then
				obj:SetNetworkValue("State", "HEAL")
				obj:SetValue("extrapos", Vector3(0,0,0))
			end
		elseif state == "ATTACK" and IsValid(target) and obj:GetValue("Type") == "red" then
			local level = tonumber(obj:GetValue("Level"))
			local dmgReduct = 1
			if target:GetValue("SOCIAL_Back") == "Pocketed Vest" then
				dmgReduct = 0.75
			elseif target:GetValue("SOCIAL_Back") == "Armored Vest" then
				dmgReduct = 0.5
			end
			local dist = Vector3.Distance(targetpos, pos1)
			if dist < self.healdist then
				if target.__type == "Player" then
					local add = 1.25
					target:Damage(self.healattamnt * level * dmgReduct * add, DamageEntity.Bullet, obj:GetValue("Owner"))
					local rando = math.random(100) --crit chance, red pet is always superior
					if rando < 6 then
						target:Damage(self.healattamnt * level * dmgReduct * add, DamageEntity.Bullet, obj:GetValue("Owner"))
					end
					if rando < 2 then
						target:Damage(self.healattamnt * level * dmgReduct * add, DamageEntity.Bullet, obj:GetValue("Owner"))
					end
					if target:GetHealth() == 0 then
						if target:GetValue("Experience") and tonumber(target:GetValue("Experience")) > 0 then
							obj:SetNetworkValue("Experience", obj:GetValue("Experience") + CalcExpFromKilling(target:GetValue("Level")))
							self:CheckIfGainedLevel(obj)
						else
							obj:SetNetworkValue("Experience", obj:GetValue("Experience") + (CalcExpFromKilling(target:GetValue("Level"))/ 25))
							self:CheckIfGainedLevel(obj)
						end
						self:SendChatMessage(obj:GetValue("Name"), sType, obj:GetValue("Owner"), "KILLED_PLAYER")
						obj:SetValue("extrapos", Vector3(0,0,0))
						if obj:GetValue("GuardingTargetOther") then
							obj:SetNetworkValue("Target", obj:GetValue("GuardingTargetOther"))
							obj:SetNetworkValue("State", "GUARD")
							obj:SetValue("GuardingTargetOther", nil)
						else
							obj:SetNetworkValue("Target", obj:GetValue("Owner"))
							obj:SetNetworkValue("State", "GUARD")
						end
					end
				--[[elseif target.__type == "StaticObject" then
					if target:GetValue("IsClaimOBJ") then
					local hp = tonumber(target:GetValue("Health"))
					if hp - (self.healattamnt * level) <= 0 then
						obj:SetNetworkValue("Experience", obj:GetValue("Experience") + 50)
						CheckIfGainedLevel(obj)
						obj:SetValue("extrapos", Vector3(0,0,0))
						obj:SetNetworkValue("State", "GUARD")
						obj:SetNetworkValue("Target", obj:GetValue("Owner"))
					end--]]
				end
			end
		end
	end
end
function Pets:CheckIfGainedLevel(obj)
	if not IsValid(obj) then return end
	local curLevel = tonumber(obj:GetValue("Level"))
	local curExp = tonumber(obj:GetValue("Experience"))
	local curMax = tonumber(obj:GetValue("ExperienceMax"))
	petData[tostring(obj:GetValue("Owner"):GetSteamId().id)].experience = curExp
	if curExp > curMax then
		local newExp = curExp - curMax
		obj:SetNetworkValue("Experience", newExp)
		obj:SetNetworkValue("Level", curLevel + 1)
		obj:SetNetworkValue("ExperienceMax", CalcMaxPetExp(curLevel + 1))
		petData[tostring(obj:GetValue("Owner"):GetSteamId().id)].experience = newExp
		petData[tostring(obj:GetValue("Owner"):GetSteamId().id)].level = curLevel + 1
		Network:SendNearby(obj:GetValue("Owner"), "PetGainLevel", obj:GetPosition())
		Network:Send(obj:GetValue("Owner"), "PetGainLevel", obj:GetPosition())
		self:SendChatMessage(obj:GetValue("Name"), obj:GetValue("Type"), obj:GetValue("Owner"), "LEVELUP")
		self:CheckIfGainedLevel(obj)
	end
	Pet_SQL:UpdateSQL(obj:GetValue("Owner"))
end
function CalcExpFromKilling(level)
	return (level * 10) + 75
end
function Pets:PetSummon(v, sender)
	--PERFORM ALL CHECKS TO SEE IF THEY CAN SUMMON HERE
	if sender:GetValue("Personality") and sender:GetValue("Level")
	and tonumber(sender:GetValue("Level")) >= 25 then
		local p = tonumber(sender:GetValue("Personality"))
		local id = sender:GetId()
		local haspet = sender:GetValue("Pet_Enabled") and IsValid(self.petobjs[sender:GetId()])
		if not haspet then
			local obj = WorldNetworkObject.Create(sender:GetPosition() + Vector3(0,3,0))
			local sType = ""
			local name
			if p < 0 then
				obj:SetNetworkValue("Type", "red")
				sType = "red"
				name = "Animosity Incarnation"
			elseif p > 0 then
				obj:SetNetworkValue("Type", "blue")
				sType = "blue"
				name = "Tonic Personification"
			end
			if not petData[tostring(sender:GetSteamId().id)] then
				petData[tostring(sender:GetSteamId().id)] = {
					experience = 0,
					level = 1,
					name = name
				}
			end
			obj:SetNetworkValue("Name", petData[tostring(sender:GetSteamId().id)].name)
			obj:SetStreamDistance(800)
			obj:SetNetworkValue("randompos", Vector3(math.random(-1,1),math.random(-1,1),math.random(-1,1)))
			obj:SetNetworkValue("State", "GUARD")
			obj:SetNetworkValue("Target", sender)
			obj:SetNetworkValue("Owner", sender)
			obj:SetNetworkValue("OwnerId", sender:GetId())
			obj:SetNetworkValue("patroltime", self.timer:GetSeconds())
			obj:SetNetworkValue("patrolpos", Vector3(0,0,0))
			obj:SetNetworkValue("extrapos", Vector3(0,0,0))
			obj:SetNetworkValue("IsPet", 1)
			obj:SetValue("Time", self.timer:GetMinutes())
			obj:SetNetworkValue("Level", petData[tostring(sender:GetSteamId().id)].level)
			obj:SetNetworkValue("Experience", petData[tostring(sender:GetSteamId().id)].experience)
			obj:SetNetworkValue("ExperienceMax", CalcMaxPetExp(petData[tostring(sender:GetSteamId().id)].level))
			self.petobjs[sender:GetId()] = obj:GetId()
			self.petTimers[obj:GetId()] = Timer()
			self:SendChatMessage(obj:GetValue("Name"), sType, sender, "GREET")
		else
			Chat:Send(sender, "You already have a pet!", Color(255,0,0))
		end
	end
end
function CalcMaxPetExp(level)
	return math.pow(level, 2.75) + (level * 50)
end
function Pets:SendChatMessage(name, sType, sender, msgType)
	if not IsValid(sender) then return end
	local msg = tostring(msgs[sType][msgType][math.random(#msgs[sType][msgType])])
	local color = Color.White
	if sType == "blue" then
		color = Color(0,191,255)
	elseif sType == "red" then
		color = Color(255,85,0)
	end
	Chat:Send(sender, tostring(name), color, msg, Color.White)
end
function Pets:PetTerminate(v, sender)
	local id = sender:GetId()
	self:KillPet(id, sender)
end
function Pets:PetDataChange(data, sender)
	if data then
		-- PERFORM CHECKS HERE ON SENT DATA TO MAKE SURE ITS VALID
		local id = sender:GetId()
		if petData[tostring(sender:GetSteamId().id)] then
			petData[tostring(sender:GetSteamId().id)].name = data.petname
			Pet_SQL:UpdateSQL(sender)
		end
		if not self.petobjs[sender:GetId()] then return end
		local obj = WorldNetworkObject.GetById(self.petobjs[id])
		if not IsValid(obj) then return end
		local owner = obj:GetValue("Owner")
		local sType = tostring(obj:GetValue("Type"))
		local target = obj:GetValue("Target")
		if obj:GetValue("Level") and tonumber(obj:GetValue("Level")) > tonumber(sender:GetValue("Level")) then
			self:SendChatMessage(obj:GetValue("Name"), sType, sender, "REFUSE")
			return
		end
		obj:SetNetworkValue("Name", data.petname)
		obj:SetNetworkValue("Target", data.target)
		petData[tostring(sender:GetSteamId().id)].name = data.petname
		if obj:GetValue("State") == "ATTACK" and target:GetValue("CanHit") == false then
			obj:SetNetworkValue("State", "GUARD")
		end
		obj:SetNetworkValue("State", data.petstate)
		if not IsValid(target) then obj:SetNetworkValue("Target", owner) return end
		if data.target.__type == "Player" and owner == data.target and obj:GetValue("State") == "ATTACK" then
			obj:SetNetworkValue("State", "GUARD")
		end
		if obj:GetValue("State") == "PATROL" then
			self:SendChatMessage(obj:GetValue("Name"), sType, sender, "PATROL")
			obj:SetNetworkValue("patrolpos", sender:GetPosition())
			obj:SetNetworkValue("patroltime", self.timer:GetSeconds())
		end
		--print(data.petname)
		--print(data.target)
		--print(data.petstate)
	end
end
function Pets:KillPet(id, player)
	if self.petobjs[id] then
		local obj = WorldNetworkObject.GetById(self.petobjs[id])
		if not IsValid(obj) then self.petobjs[id] = nil return end
		local sType = obj:GetValue("Type")
		local name = obj:GetValue("Name")
		obj:Remove()
		self.petobjs[id] = nil
		if IsValid(player) then
			self:SendChatMessage(name, sType, player, "TERMINATE")
		end
	end
end
function Pets:Quit(args)
	if args.player:GetValue("Pet_Enabled") and self.petobjs[args.player:GetId()] then
		self:KillPet(args.player:GetId(), args.player)
	end
end
function Pets:MakePetPatrol(state, pType, obj)
	local patroltime = tonumber(obj:GetValue("patroltime"))
	local diff = self.timer:GetSeconds() - patroltime
	if pType == "red" and diff > 5 then
		local randomx = math.random(-30,30)
		local randomy = math.random(-1,5)
		local randomz = math.random(-30,30)
		obj:SetValue("randompos", Vector3(randomx, randomy, randomz))
		obj:SetValue("patroltime", self.timer:GetSeconds())
	elseif pType == "blue" and diff > 8 then
		local randomx = math.random(-15,15)
		local randomy = math.random(-0.75,3)
		local randomz = math.random(-15,15)
		obj:SetValue("randompos", Vector3(randomx, randomy, randomz))
		obj:SetValue("patroltime", self.timer:GetSeconds())
	end
end
function Pets:MakePetLoiter(state, pType, obj)
	if state == "FOLLOW" or state == "GUARD" then
			--MAKE THE PET LOITER AROUND WHEN NOT DOING ANYTHING
		if pType == "red" then
			local randomx = math.random(-7.5,7.5)
			local randomy = math.random(-1,1.5)
			local randomz = math.random(-7.5,7.5)
			obj:SetValue("randompos", Vector3(randomx, randomy, randomz))
		elseif pType == "blue" then
			local randomx = math.random(-6,6)
			local randomy = math.random(-1,1)
			local randomz = math.random(-6,6)
			obj:SetValue("randompos", Vector3(randomx, randomy, randomz))
		end
	end
end
Pets = Pets()