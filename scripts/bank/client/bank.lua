class 'Bank'

function Bank:__init()
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "LocalPlayerMoneyChange", self, self.LocalPlayerMoneyChange )
    Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
	
	self.timer 				= Timer()
	
end

function Bank:ModulesLoad()
    Events:Fire( "HelpAddItem",
        {
            name = "Credits",
            text = 
                "Your credits are stored and saved automatically.  You can send "..
                "money to others using /sendmoney playername amount - " ..
                "You earn 100 credits when you kill a person.  You can see your"..
				" amount of credits in the top right."
        } )
end

function Bank:ModuleUnload()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Bank"
        } )
end

function Bank:Render()
	if Game:GetState() ~= GUIState.Game then return end

	if FadeInTimer or DelayTimer or FadeOutTimer then
		
		if FadeInTimer ~= nil then
			RAlpha = math.clamp(0 + (FadeInTimer:GetSeconds() * 720), 0, 180)
			TAlpha = math.clamp(0 + (FadeInTimer:GetSeconds() * 800), 0, 200)
			if RAlpha >= 180 or TAlpha >= 200 then
				RAlpha = 180
				TAlpha = 200
				DelayTimer 		= 	Timer()
				FadeInTimer		= 	nil
			end
		end
			
		if DelayTimer ~= nil then
			if DelayTimer:GetSeconds() >= 5 then
				FadeOutTimer = Timer()
				DelayTimer = nil
			end
		end
			
		if FadeOutTimer ~= nil then
			RAlpha = math.clamp(180 - (FadeOutTimer:GetSeconds() * 720), 0, 180)
			TAlpha = math.clamp(200 - (FadeOutTimer:GetSeconds() * 800), 0, 200)
			if RAlpha <= 0 or TAlpha <= 0 then
				RAlpha = 0
				TAlpha = 0
				FadeOutTimer	= 	nil
			end
		end
		
	local NumTxt	= 	self.message
	local CredTxt	= 	"credits"
	local NumTxtS	=	Render:GetTextWidth(NumTxt, 38)
	local CredTxtS	=	Render:GetTextWidth(CredTxt, 38)
	local FullTxtS	=	NumTxtS + CredTxtS
		
	Render:FillArea(Vector2((Render.Width / 2 - 135),85), Vector2((270),50), Color(0,0,0,RAlpha))
	Render:FillArea(Vector2((Render.Width / 2 - 135),85), Vector2((270),1), Color(170,170,170,RAlpha))
	Render:FillArea(Vector2((Render.Width / 2 - 135),135), Vector2((270),1), Color(170,170,170,RAlpha))

	Render:FillArea(Vector2((Render.Width / 2 - 135),85), Vector2((1),50), Color(170,170,170,RAlpha))
	Render:FillArea(Vector2((Render.Width / 2 + 135),85), Vector2((1),50), Color(170,170,170,RAlpha))
		
	Render:DrawText(Vector2((Render.Width / 2 ) - (NumTxtS / 2 ) - (CredTxtS / 2) - 10, 95), NumTxt, Color(200,200,200,TAlpha), 38)
	Render:DrawText(Vector2((Render.Width / 2 ) - (CredTxtS / 2 ) + (NumTxtS / 2) + 10, 95), CredTxt, Color(140,140,140,TAlpha), 38)
		
	end
	
end

function Bank:LocalPlayerMoneyChange( args )
	local diff = args.new_money - args.old_money

	if diff > 0 and self.timer:GetSeconds() > 2 then
		FadeInTimer = Timer()
		self.message = "+ " .. tostring(diff)
	end
	
	if diff < 0 and self.timer:GetSeconds() > 2 then
		local diff1 = tostring(diff) * - 1
		FadeInTimer = Timer()
		self.message = "- " .. tostring(diff1)
	end
	
end

bank = Bank()