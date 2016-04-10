class 'ShootRender'

function ShootRender:__init(player)
	self.player = player
    self.timer = Timer()
    self.event = Events:Subscribe("Render", self, self.Rendr)
end
 
function ShootRender:Rendr()
    if self.timer:GetSeconds() < 5 then
		if IsValid(self.player) then
			local vect2 = Render:WorldToMinimap(self.player:GetPosition())
			Render:FillCircle(vect2, 3.2, Color(255, 0, 0))
		end
    else
		Events:Unsubscribe(self.event)
		self.timer = nil
		if IsValid(self.player) then
			self.player:SetValue("ShowMinimapDot", false)
		end
	end
end