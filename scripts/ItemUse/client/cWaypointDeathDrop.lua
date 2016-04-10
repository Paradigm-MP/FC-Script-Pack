class 'cWaypointDeathDrop'

function cWaypointDeathDrop:__init()

	self.pos = nil
	
	Events:Subscribe("UseDeathDropFinder", self, self.SetWaypoint)
	Events:Subscribe("DeathDropFinderPos", self, self.SetPosition)
	
end

function cWaypointDeathDrop:SetWaypoint()
	
	if self.pos then
		Waypoint:SetPosition(self.pos)
		Events:Fire("DeleteFromInventory", {sub_item = "Death Drop Finder", sub_amount = 1})
	end
	
end

function cWaypointDeathDrop:SetPosition(pos)
	self.pos = pos
end

cWaypointDeathDrop = cWaypointDeathDrop()