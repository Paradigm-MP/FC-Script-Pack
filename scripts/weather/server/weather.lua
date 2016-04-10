class 'Weather'
function Weather:__init()
	self.changetime = 500 --minutes it takes to change the weather, by chance
	self.chancetochange = 1 --% chance to change weather at given interval
	self.minutes = 0
	Events:Subscribe("TimeChange", self, self.Change)
	Events:Subscribe("ModuleUnload", self, self.Unload)
end
function Weather:Unload()
	DefaultWorld:SetWeatherSeverity(0)
end
function Weather:Change()
	self.minutes = self.minutes + 1
	if self.minutes >= self.changetime then
		local rando = math.random(0,100)
		if rando <= self.chancetochange then
			local severity = DefaultWorld:GetWeatherSeverity()
			if severity > 0 then
				DefaultWorld:SetWeatherSeverity(0)
				--Chat:Broadcast("COOLMAN", Color(110,191,235), 	": The weather has changed to a severity of 0.", Color(255,255,255))
				print("Weather severity set to 0.")
			elseif severity == 0 then
				DefaultWorld:SetWeatherSeverity(math.random(0.0,2.0))
			end
		end
	end
	if self.minutes >= self.changetime then
		self.minutes = 0
	end
end
Weather = Weather()