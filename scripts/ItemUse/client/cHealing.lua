function cUseBandage()
	if busy == false and LocalPlayer:GetHealth() > 0 and LocalPlayer:GetBaseState() == AnimationState.SUprightIdle then
		UseHealthItem(-.25, 5, "Bandage")
	end
end
Events:Subscribe("UseBandage", cUseBandage)

function cUseMedKit()
	if busy == false and LocalPlayer:GetHealth() > 0 and LocalPlayer:GetBaseState() == AnimationState.SUprightIdle then
		UseHealthItem(-.45, 7.5, "Med-Kit")
	end
end
Events:Subscribe("UseMed-Kit", cUseMedKit)

function cUseFullRestore()
	if busy == false and LocalPlayer:GetHealth() > 0 and LocalPlayer:GetBaseState() == AnimationState.SUprightIdle then
		UseHealthItem(-1, 10, "Full Restore")
	end
end
Events:Subscribe("UseFullRestore", cUseFullRestore)

busy = false
class 'UseHealthItem'
function UseHealthItem:__init(health, time, item)
	self.item = item
	self.health = health
	self.time = time -- time in seconds
	self.timer = Timer()
	self.event = Events:Subscribe("Render", self, self.Render)
	self.event2 = Events:Subscribe("LocalPlayerInput", self, self.Input)
	busy = true
	screen_size = Render.Size
end

function UseHealthItem:Render()
	if self.timer:GetSeconds() < self.time then
		LocalPlayer:SetBaseState(15)
		Render:FillArea(Vector2(0, screen_size.y * .96), Vector2(screen_size.x * ((self.time * 1000 - self.timer:GetMilliseconds()) / (self.time * 1000)), screen_size.y), Color(0, 255, 0, 100))
	else
		self.timer = nil
		busy = false
		Events:Fire("DeleteFromInventory", {sub_item = self.item, sub_amount = 1})
		Network:Send("ModHealth", {mod = self.health})
		Events:Unsubscribe(self.event)
	end
end

function UseHealthItem:Input(args)
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