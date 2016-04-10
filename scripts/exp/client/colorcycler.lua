class 'ColorCycler'
function ColorCycler:__init(...)
	self.timer = Timer()
	self.c1 = 255
	self.c2 = 0
	self.c3 = 0
	self.alpha = 255
	Events:Subscribe("PostTick", self, self.ColorGen)
end
function ColorCycler:ColorGen()
	self.timerS = self.timer:GetSeconds()
	self.duration = 1
	self.orig = 255 / self.duration
	if self.timerS <= self.duration then
		self.c2 = self.orig * self.timerS
	elseif self.timerS <= (self.duration * 2) and self.timerS > self.duration then
		self.c1 = 255 - ((self.timerS - (self.duration * 1)) * self.orig)
	elseif self.timerS <= (self.duration * 3) and self.timerS > (self.duration * 2) then
		self.c3 = (self.timerS - (self.duration * 2)) * self.orig
	elseif self.timerS <= (self.duration * 4) and self.timerS > (self.duration * 3) then
		self.c2 = 255 - ((self.timerS - (self.duration * 3)) * self.orig)
	elseif self.timerS <= (self.duration * 5) and self.timerS > (self.duration * 4) then
		self.c1 = (self.timerS - (self.duration * 4)) * self.orig
	elseif self.timerS <= (self.duration * 6) and self.timerS > (self.duration * 5) then
		self.c3 = 255 - ((self.timerS - (self.duration * 5)) * self.orig)
	elseif self.timerS > (self.duration * 6) then
		self.timer:Restart()
	end
	if self.c1 < 3 then
		self.c1 = 0
	elseif self.c2 < 3 then
		self.c2 = 0 
	elseif self.c3 < 3 then
		self.c3 = 0
	end
	self.color = Color(self.c1,self.c2,self.c3,self.alpha)
	--print("color ", color)
end
function ModuleLoad(...)
	ColorCycler = ColorCycler()
end
Events:Subscribe("ModuleLoad", ModuleLoad)