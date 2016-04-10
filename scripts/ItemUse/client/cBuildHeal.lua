function cUseSmallBuildHeal()
	if busy == false and LocalPlayer:GetHealth() > 0 and LocalPlayer:GetBaseState() == AnimationState.SUprightIdle then
		UseBuildHeal(200, 5, "Small Build Heal", 10, 15)
	end
end
Events:Subscribe("UseSmallBuildHeal", cUseSmallBuildHeal)

function cUseMediumBuildHeal()
	if busy == false and LocalPlayer:GetHealth() > 0 and LocalPlayer:GetBaseState() == AnimationState.SUprightIdle then
		UseBuildHeal(350, 7.5,  "Medium Build Heal", 15, 25)
	end
end
Events:Subscribe("UseMediumBuildHeal", cUseMediumBuildHeal)

function cUseLargeBuildHeal()
	if busy == false and LocalPlayer:GetHealth() > 0 and LocalPlayer:GetBaseState() == AnimationState.SUprightIdle then
		UseBuildHeal(500, 10, "Large Build Heal", 20, 35)
	end
end
Events:Subscribe("UseLargeBuildHeal", cUseLargeBuildHeal)

busy = false
class 'UseBuildHeal'
function UseBuildHeal:__init(health, time, item, affects, radius)
	self.radius = radius -- in meters
	self.affects = affects
	self.item = item
	self.health = health
	self.time = time -- time in seconds
	self.timer = Timer()
	self.event = Events:Subscribe("Render", self, self.Render)
	self.event2 = Events:Subscribe("LocalPlayerInput", self, self.Input)
	busy = true
	screen_size = Render.Size
end

function UseBuildHeal:Render()
	if self.timer:GetSeconds() < self.time then
		LocalPlayer:SetBaseState(15)
		Render:FillArea(Vector2(0, screen_size.y * .96), Vector2(screen_size.x * ((self.time * 1000 - self.timer:GetMilliseconds()) / (self.time * 1000)), screen_size.y), Color(0, 0, 255, 100))
	else
		self.timer = nil
		busy = false
		Events:Fire("DeleteFromInventory", {sub_item = self.item, sub_amount = 1})
		--
		local heal_count = 0
		local heal_table = {}
		local self_pos = LocalPlayer:GetPosition()
		for static in Client:GetStaticObjects() do
			if static:GetValue("IsClaimOBJ") then
				local health = static:GetValue("Health")
				local maxhp = HPamts[static:GetValue("model")]
				if health and maxhp then
					if health < maxhp then
						local distance = Vector3.Distance(self_pos, static:GetPosition())
						if distance < self.radius then
							local new_health = health + self.health
							if new_health > maxhp then
								new_health = maxhp
							end
							heal_table[static:GetId()] = new_health
							heal_count = heal_count + 1
						end
					end
				end
			end
			if heal_count >= self.affects then break end
		end
		if heal_count > 0 then
			Events:Fire("LC_SetObjectHealth", {objects = heal_table})
		end
		Chat:Print("Healed " .. tostring(heal_count) .. " objects", Color.Green)
		--
		Events:Unsubscribe(self.event)
	end
end

function UseBuildHeal:Input(args)
	if not self.timer then return end
	if self.timer:GetSeconds() < self.time then
		if busy == true then
			if args.input == Action.MoveLeft or args.input == Action.MoveRight or args.input == Action.MoveForward or args.input == Action.MoveBackward then
				self.timer = nil
				busy = false
				Events:Unsubscribe(self.event)
				Events:Unsubscribe(self.event2)
			end
		end
	else
		Events:Unsubscribe(self.event2)
	end
end