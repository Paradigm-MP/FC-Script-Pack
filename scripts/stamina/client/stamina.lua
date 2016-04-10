class 'Stamina'
function Stamina:__init()
	--print("Stamina loaded")
	self.staminaChecker = Events:Subscribe("SecondTick", self, self.CheckStam)
	evadeTimer = Timer()
end
function Decrypt(value)
	if value then
		value = tonumber(Crypt34(tostring(value)))
		return value
	end
end
function Encrypt(value)
	if value then
		value = Crypt34(tostring(value))
		return value
	end
end
function Stamina:CheckStam()
	if LocalPlayer:GetValue("StaminaRegen") then
		Events:Unsubscribe(self.staminaChecker)
		self.staminaChecker = nil
		self.regen1 = LocalPlayer:GetValue("StaminaRegen")
		self.regen = (Decrypt(self.regen1) / 5) / 100
		self.swimdeduct1 = LocalPlayer:GetValue("StaminaSwim")
		self.swimdeduct = ((Decrypt(self.swimdeduct1) / 500) + 1)
		self.stuntdeduct1 = LocalPlayer:GetValue("StuntEnergy")
		self.stuntdeduct = ((Decrypt(self.stuntdeduct1) / 500) + 1)
		self.sprintdeduct1 = LocalPlayer:GetValue("SprintEnergy")
		self.sprintdeduct = ((Decrypt(self.sprintdeduct1) / 500) + 1)
		self.energyMax1 = LocalPlayer:GetValue("StaminaMax")
		self.energyMax = Decrypt(self.energyMax1)
		self.regenstill = tonumber(Decrypt(LocalPlayer:GetValue("regenstill")))/50 --if velocity is zero, in stamina gained per second
		self.regenwalk = tonumber(Decrypt(LocalPlayer:GetValue("regenwalk")))/50 --if in walk state, in stamina gained per second
		self.regenrun = tonumber(Decrypt(LocalPlayer:GetValue("regenrun")))/50 --if in normal run state, in stamina gained per second
		self.regentired = tonumber(Decrypt(LocalPlayer:GetValue("regentired")))/50 --if negative stamina, PUNISH, in stamina gained per second
		self.regenswimsurface = tonumber(Decrypt(LocalPlayer:GetValue("regenswimsurface")))/50 --swimming on the surface of the water
		self.regenswimunder = tonumber(Decrypt(LocalPlayer:GetValue("regenswimunder")))/50 --swimming under the surface of the water
		self.regenstunt = tonumber(Decrypt(LocalPlayer:GetValue("regenstunt")))/50 --stunt position on an unmoving vehicle
		self.regenstuntmove = tonumber(Decrypt(LocalPlayer:GetValue("regenstuntmove")))/50 --stunt position on a slowly moving vehicle
		self.regenstuntmovefast = tonumber(Decrypt(LocalPlayer:GetValue("regenstuntmovefast")))/50 --stunt position on a fast moving vehicle
		self.regenstuntmoveveryfast = tonumber(Decrypt(LocalPlayer:GetValue("regenstuntmoveveryfast")))/50 --stunt position on a very fast moving vehicle
		self.stuntstamina = tonumber(Decrypt(LocalPlayer:GetValue("stuntstamina")))/50 --initial stunt position deduction (AKA the jump)
		self.percent = Decrypt(LocalPlayer:GetValue("StaminaMax")) * 0.05
		self.percent1 = Decrypt(LocalPlayer:GetValue("StaminaMax")) * 0.1
		self.percent2 = Decrypt(LocalPlayer:GetValue("StaminaMax")) * 0.2
		self.percent4 = Decrypt(LocalPlayer:GetValue("StaminaMax")) * 0.25
		LocalPlayer:SetValue("Stamina", LocalPlayer:GetValue("StaminaMax"))
		self.stamina = self.energyMax
		Events:Subscribe("Stamina_DecreaseKick", self, self.DecreaseKick)
		Events:Subscribe("PostTick", self, self.Regen)
		Events:Subscribe("LocalPlayerDeath", self, self.Death)
		Events:Subscribe("LocalPlayerSpawn", self, self.Respawn)
		Events:Subscribe("LocalPlayerInput", self, self.DisableStuff)
		Network:Subscribe("StaminaUpdateMelee", self, self.UpdateMelee)
	end
end
function Stamina:DecreaseKick(amt)
	self.stamina = self.stamina - amt
	if self.stamina < 0 then self.stamina = 0 end
end
function AddHelp()
    Events:Fire( "HelpAddItem",
        {
            name = "Stamina",
            text = 
                "Your stamina amount is indicated by the Stamina Dude on the bottom right. "..
                "Everything you do affects your stamina - running, for example, will decrease it. " ..
                "If you run out of stamina, you will be forced to walk for a bit to recover and "..
				"will not be able to jump during this time.  Aspects of your stamina can be upgraded "..
				"in the IP menu."
       } )
end

function RemoveHelp()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Stamina"
        } )
end

Events:Subscribe("ModulesLoad", AddHelp)
Events:Subscribe("ModuleUnload", RemoveHelp)
function Stamina:DisableStuff(args)
	if args.input == Action.Evade then 
		if self.stamina >= self.percent1 and evadeTimer:GetSeconds() >= 1 then
			evadeTimer:Restart()
			self.stamina = self.stamina - self.percent
		elseif args.input == Action.Evade then
			return false
		end
	end
	if args.input == Action.Kick then
		return false
	end
end
function Stamina:UpdateMelee(args)
	if args then
		--######################### DONT EVEN HAVE THE SERVER SEND IT BACK, JUST SUBTRACT ON CLIENT
		LocalPlayer:SetValue("Stamina", Encrypt(args.stamina))
	end
end
function Stamina:Poll()
	if self.stamina < self.percent4 then
		Input:SetValue(Action.Walk, 1)
	else
		Input:SetValue(Action.Walk, 0)
		Events:Unsubscribe(inputpollsub)
		inputpollsub = nil
	end
end
function Stamina:Regen()
		if LocalPlayer:GetHealth() > 0 then
			local velocity2 = -LocalPlayer:GetAngle() * LocalPlayer:GetLinearVelocity()
			local velocity = math.abs(-velocity2.z)
			local velocityY = -velocity2.y
			local pos = LocalPlayer:GetPosition()
			--print(velocity)
			if self.stamina < self.percent and not inputpollsub then
				inputpollsub = Events:Subscribe("InputPoll", self, self.Poll)
			end
			if LocalPlayer:InVehicle() then --if they are sitting in a vehicle
				if self.stamina < 0 then
					self.stamina = self.stamina + self.regentired + self.regen
				else
					self.stamina = self.stamina + self.regenstill + self.regen
				end
				if self.stamina > self.energyMax then
					self.stamina = self.energyMax
				end
			elseif pos.y < 200.15 and pos.y > 199 and velocity < 1 then --if they are unmoving in the water, no movement
				self.stamina = self.stamina + self.swimdeduct
			elseif pos.y < 200.15 and pos.y > 199 and velocity > 1 then --if they are moving in the water, slow degen
				self.stamina = self.stamina + (self.regenswimsurface / self.swimdeduct)
				if self.stamina <= 0 then
					self.stamina = 0
				end
			elseif pos.y < 199 then --underwater faster degen
				self.stamina = self.stamina + (self.regenswimunder / self.swimdeduct)
				if self.stamina <= 0 then
					self.stamina = 0
				end
			elseif LocalPlayer:GetState() == 5 and velocity < 1 then --stunt pos takes energy to maintain as well
				self.stamina = self.stamina + (self.regenstunt / self.stuntdeduct)
				if self.stamina <= 1 then
					Network:Send("Stunt_No_Energy")
				end
			elseif LocalPlayer:GetState() == 5 and velocity < 15 and velocity >= 1 then --stunt pos moving
				self.stamina = self.stamina + (self.regenstuntmove / self.stuntdeduct)
				if self.stamina <= 1 then
					Network:Send("Stunt_No_Energy")
				end
			elseif LocalPlayer:GetState() == 5 and velocity >= 15 and velocity < 50 then --stunt pos moving fast
				self.stamina = self.stamina + (self.regenstuntmovefast / self.stuntdeduct)
				if self.stamina <= 1 then
					Network:Send("Stunt_No_Energy")
				end
			elseif LocalPlayer:GetState() == 5 and velocity >= 50 then --stunt pos moving very fast
				self.stamina = self.stamina + (self.regenstuntmoveveryfast / self.stuntdeduct)
				if self.stamina <= 1 then
					Network:Send("Stunt_No_Energy")
				end
			elseif velocity < 1 and velocityY < 1 and velocityY > -1 then --if they are standing still
				if self.stamina < 0 then
					self.stamina = self.stamina + self.regentired + self.regen
				else
					self.stamina = self.stamina + self.regenstill + self.regen
				end
				if self.stamina > self.energyMax then
					self.stamina = self.energyMax
				end
			elseif velocity >= 1 and velocity < 6 and velocityY < 2 and velocityY > -2 then --if they are jogging
				if self.stamina > 0 then
					self.stamina = self.stamina + (self.regenwalk + self.regen)
				end
				if self.stamina > self.energyMax then
					self.stamina = self.energyMax
				end
			elseif velocity >= 6 and velocity < 9 and velocityY < 3 and velocityY > -3 then --if they are sprinting, negative regen
				self.stamina = self.stamina + (self.regenrun / self.sprintdeduct)
				if self.stamina <= 0 then
					self.stamina = 0
				end
			end
			LocalPlayer:SetValue("Stamina", Encrypt(self.stamina))
		end
end
function Stamina:Respawn()
	if LocalPlayer:GetValue("StaminaRespawn") == 1 then
		local stamMax1 = LocalPlayer:GetValue("StaminaMax")
		local stamMax = Decrypt(stamMax1)
		LocalPlayer:SetValue("Stamina", Encrypt(stamMax))
		LocalPlayer:SetValue("StaminaRespawn", 0)
	end
end
function Stamina:Death()
	if LocalPlayer then
		LocalPlayer:SetValue("StaminaRespawn", 1)
		LocalPlayer:SetValue("DisableKick", 0)
	end
end
Stamina = Stamina()