Tips = {
	"You can access the IP menu by pressing 'U'.",
	"You can access the vehicle menu by pressing F7.",
	"Many rare items can be created using a crafting table.",
	"As you progress, more sections of the crafting table become available.",
	"If you are in a faction, you can access the menu by pressing 'P'.",
	"You can open your inventory by pressing 'G'.",
	"You can earn experience from killing people and crafting items.",
	"When you die, you lose all your current experience, but keep your level.",
	"Keep an eye on your hunger and thirst levels. It might save your life.",
	"You can view your hunger and thirst levels when your inventory is open.",
	"The IP menu has many different skills you can raise.",
	"You can use a car, but if you want to own it you have to purchase it.",
	"The currency on Fallen Civilization is credits.",
	"When you gain a level, you also gain IP equal to your level.",
	"The GMI is an online shop where you can buy rare items.",
	"GMI is short for Global Market Interface.",
	"GMI terminals can only be found in tradezones.",
	"Tradezones are safe areas where you can trade.",
	"You can initiate a trade with someone by pressing '0'.",
	"There are certain cursed areas around Panau; they hold more risks and more rewards.",
	"You can check the Stamina Dude in the lowerright corner to see your stamina.",
	"Many different actions take stamina to perform.",
	"Press 'Q' to perform a standing kick.",
	"Press 'Q' while sprinting to perform a sliding kick.",
	"Press F7 to open up the vehicle management menu.",
	"You can join or create a faction by typing /f join <faction name>",
	"When you kill someone, you receive 100 credits.",
	"If you are in a faction, press 'P' to open the faction menu.",
	"The Companion Key is a very mysterious item.",
	"Press F5 to access the help menu.",
	"Press F8 to access the storages menu.",
	"You can right-click to easily return to the main menu of crafting when in a sub-section.",
	"If you are too hungry or thirsty, you will begin to lose health.",
	"Loot can be found in baskets and barrels all around Panau."
}

class 'Load'

function Load:__init( )

	self.BackgroundImage 		= 	Image.Create(AssetLocation.Resource, "BackgroundImage")
	self.LoadingCircle_Outer 	= 	Image.Create(AssetLocation.Resource, "LoadingCircle_Outer")
	self.LoadingCircle_Inner 	= 	Image.Create(AssetLocation.Resource, "LoadingCircle_Inner")
	
	Events:Subscribe("ModuleLoad", self, self.ModuleLoad)
	Events:Subscribe("GameLoad", self, self.GameLoad)
	Events:Subscribe("LocalPlayerDeath", self, self.LocalPlayerDeath)
	Events:Subscribe("PostRender", self, self.PostRender)
	
	IsJoining 	= 	false
	IsDead		=	false

end

function Load:ModuleLoad( )
	
	if Game:GetState() ~= GUIState.Loading then
		IsJoining = false
		
	else
		IsJoining 		= 	true
		FadeInTimer 	= 	Timer()
		FailSafeTimer 	= 	Timer()
		RenderTip 		= 	Tips[math.random(#Tips)]
		
	end
end

function Load:GameLoad()
	
	if FadeInTimer ~= nil then
		LoadedTimer		= 	Timer()
		FadeOutTimer	=	Timer()
	end
	
end

function Load:LocalPlayerDeath()
	
	DelayTimer 		= 	Timer()
	RenderTip 		= 	Tips[math.random(#Tips)]
	IsDead 			= 	true
	
end

function Load:PostRender()
	
	if not IsDead == true then 
		if not IsJoining == true then 
			return
		end
	end
	
	if DelayTimer then
		if DelayTimer:GetSeconds() <= 4.5 then
			return
		else
			DelayTimer 		= 	nil
			FadeInTimer 	= 	Timer()
			FailSafeTimer 	= 	Timer()
		end
	end
	
	local TxtSizePos 		= 		Render.Size.x / 60
	local TxtSize 			= 		Render:GetTextSize(RenderTip, TxtSizePos)
	local TxtPos 			= 		Vector2((Render.Size.x/2) - (TxtSize.x/2), Render.Size.y / 1.325)
	local CircleSize 		= 		Vector2(130,130)
	local TransformOuter 	= 		Transform2()
	local TransformInner 	= 		Transform2()
	local Rotation 			= 		self.GetRotation()
	
	if FailSafeTimer ~= nil then
	if LoadedTimer then
	
		if LoadedTimer:GetSeconds() >= 1 then
			TxtAlpha 	= 	math.clamp(255 - (FadeOutTimer:GetSeconds() * 128), 0, 255)
			ImageAlpha 	= 	math.clamp(1 - (FadeOutTimer:GetSeconds() - 1), 0, 1)
			
			if LoadedTimer:GetSeconds()>= 2.1 then
				FadeInTimer 	= 	nil
				FadeOutTimer 	= 	nil
				LoadedTimer 	= 	nil
				FailSafeTimer	=	nil
				IsJoining 	= 	false
				IsDead		= 	false
			end
		end
	
		elseif FailSafeTimer:GetSeconds() >= 20 then
			TxtAlpha 	= 	math.clamp(255 - ((FailSafeTimer:GetSeconds() - 19) * 128), 0, 255)
			ImageAlpha 	= 	math.clamp(1 - ((FailSafeTimer:GetSeconds() - 19) - 1), 0, 1)
			
			if FailSafeTimer:GetSeconds()>= 21.1 then
				FadeInTimer 	= 	nil
				FadeOutTimer 	= 	nil
				LoadedTimer 	= 	nil
				FailSafeTimer	=	nil
				IsJoining 	= 	false
				IsDead		= 	false
			end

		else
	
			TxtAlpha 	= 	math.clamp(0 + (FadeInTimer:GetSeconds() * 128), 0, 255)
			ImageAlpha 	= 	math.clamp(0 + (FadeInTimer:GetSeconds()), 0, 1)
		
		end
	end
	
	self.BackgroundImage:SetAlpha(ImageAlpha)
	self.BackgroundImage:SetPosition(Vector2(0,0))
	self.BackgroundImage:SetSize(Vector2(Render.Width, Render.Height))
	self.BackgroundImage:Draw()

	Render:DrawText(TxtPos, RenderTip, Color(255,255,255,TxtAlpha), TxtSizePos)
	
	TransformOuter:Translate((Render.Size / 2))
	TransformOuter:Rotate(math.pi * Rotation)
	TransformInner:Translate((Render.Size / 2))
	TransformInner:Rotate(-math.pi * Rotation )
	
	Render:SetTransform(TransformOuter)
	self.LoadingCircle_Outer:SetAlpha(ImageAlpha)
	self.LoadingCircle_Outer:Draw(-(CircleSize / 2), CircleSize, Vector2(0,0), Vector2(1,1))
	Render:ResetTransform()
	
	Render:SetTransform(TransformInner)
	self.LoadingCircle_Inner:SetAlpha(ImageAlpha)
	self.LoadingCircle_Inner:Draw(-(CircleSize / 2), CircleSize, Vector2(0,0), Vector2(1,1))
	Render:ResetTransform()

end

function Load:GetRotation()

	local RotationValue = FadeInTimer:GetSeconds()* 0.30
	return RotationValue
	
end

Load = Load()