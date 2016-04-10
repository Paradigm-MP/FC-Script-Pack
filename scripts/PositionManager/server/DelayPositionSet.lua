class("DelayedSpawn")
-- Instance class
function DelayedSpawn:__init(position, id, steamidentification, itime)
    self.position = position
	self.gameid = id
	self.id = steamidentification
    self.timer = Timer()
	self.time = itime
    self.event = Events:Subscribe("PreTick", self, self.PreTickFunction)
end
 
function DelayedSpawn:PreTickFunction()
    if self.timer:GetSeconds() > self.time then
        local ply = Player.GetById(self.gameid)
		if IsValid(ply) then
			if tostring(ply:GetSteamId()) == tostring(self.id) then
				ply:SetPosition(self.position)
				nogo[ply:GetSteamId()] = nil
			end
		end
		self.timer = nil
        Events:Unsubscribe(self.event)
    end
end
