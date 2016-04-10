class 'ClientEvents'
function ClientEvents:__init()
	eventTime = os.time{year=2016, month=2, day=23, hour=6, minute=0, second=0}
	eventColor = Color(217,0,255,200)
	eventName = "Submarine Battle Event starting at 6:00 PM Eastern Standard Time!" --time left added to front
	eventEnabled = true --do you want the timer to show
	textSize = 25
	if eventEnabled then
		eventSub = Events:Subscribe("Render", self, self.Render)
	end
end
function ClientEvents:Render()
	--local timeTable = os.date("*t", eventTime - os.time())
	--local timeString = string.format("%.0f days %.0f hours %.0f minutes %.0f seconds",
	--							timeTable.day, timeTable.hour, timeTable.min, timeTable.sec)
	--local finishedString = timeString .. eventName
	--local finishedString = eventName
	--local pos1 = Vector2(0, Render.Size.y - Render:GetTextSize(finishedString, textSize).y)
	--Render:DrawText(pos1, finishedString, eventColor, textSize)
end
ClientEvents = ClientEvents()
function PrintGreetMessage()
	Chat:Print("Welcome to", Color.White, " Fallen Civilization", Color.Orange, "! If you have any issues, please report them on the forums or steam group.", Color(255,255,255))
end
Events:Subscribe("ModuleLoad", PrintGreetMessage)

function block()
	return false
end
Events:Subscribe("PlayerAchievementUnlock", block)