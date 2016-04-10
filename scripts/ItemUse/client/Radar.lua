class 'Radar'
function Radar:__init()
	self.players = {}
	self.zombies = {}
	self.timer = Timer()
	Events:Subscribe("SecondTick", self, self.Seconds)
end
function Radar:Seconds()
	if self.timer:GetSeconds() >= 5 then
		self.timer:Restart()
		Events:Fire("UpdateSharedObjectInventory")
		local inventory_table = SharedObject.GetByName("ClientSharedInventory"):GetValue("INV")
		if not inventory_table then return false end
		local hasRadar = Crypt34("no")
		for category, loot_table in pairs(inventory_table) do
			for index, lootstring in pairs(loot_table) do
				if GetLootName(lootstring) == "Radar" then
					hasRadar = Crypt34("yes")
				end
			end
		end
		if Crypt34(hasRadar) == "yes" and not self.renderSub then
			self.renderSub = Events:Subscribe("Render", self, self.Render)
		elseif Crypt34(hasRadar) == "no" and self.renderSub then
			Events:Unsubscribe(self.renderSub)
			self.renderSub = nil
		end
		self.players = {}
		for p in Client:GetStreamedPlayers() do
			local dist = Vector3.Distance(p:GetPosition(), LocalPlayer:GetPosition())
			if dist <= 400 and p:GetPosition().y > 200 then
				self.players[p:GetId()] = p:GetPosition()
			end
		end
		self.zombies = LocalPlayer:GetValue("Zombies_Nearby")
	end
end
function Radar:Render()
	if Game:GetState() ~= GUIState.Game then return end
	local alpha = 255 - (255 / 5 * self.timer:GetSeconds())
	for id, pos in pairs(self.players) do
		local vect2 = Render:WorldToMinimap(pos)
		Render:FillCircle(vect2, 3.2, Color(255, 0, 0, alpha))
	end
	--for id, pos in pairs(self.zombies) do
		--local vect2 = Render:WorldToMinimap(pos)
		--Render:FillCircle(vect2, 3.2, Color(0, 196, 0, alpha)) --zombie
	--end
				
end
Radar = Radar()


function GetLootName(lootstring)
	local number = tonumber(string.match(lootstring, '%d+'))
	local item34 = ""
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
