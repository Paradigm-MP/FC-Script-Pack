class 'SurvivalHUD'

function SurvivalHUD:__init( )
	
	LocalPlayer:SetValue("RenderHunger", 75)
	LocalPlayer:SetValue("RenderThirst", 75)
	
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "ResolutionChange", self, self.ResolutionChange )
	Events:Subscribe( "PostTick", self, self.CheckExp )
	
	self.HungerImage 	= 	Image.Create(AssetLocation.Resource, "Hunger")
	self.ThirstImage	= 	Image.Create(AssetLocation.Resource, "Thirst")
	
	points				=	self:GetCircleCoordinates(Vector2((Render.Width / 2 ),32), 24, 50)
	points2				=	self:GetCircleCoordinates(Vector2((Render.Width / 2 ),32), 25, 50)
	points3				=	self:GetCircleCoordinates(Vector2((Render.Width / 2 ),32), 26, 50)
	points4				=	self:GetCircleCoordinates(Vector2((Render.Width / 2 ),32), 27, 50)
	
	timer 				= 	nil
	
	self.exp 			= 	tonumber(LocalPlayer:GetValue("Experience"))
	self.numtick 		= 	0
	
end

function SurvivalHUD:Render()
	
	if timer ~= nil then
		if timer:GetMilliseconds() >= 200 then
			points				=	self:GetCircleCoordinates(Vector2((Render.Width / 2 ),32), 24, 50)
			points2				=	self:GetCircleCoordinates(Vector2((Render.Width / 2 ),32), 25, 50)
			points3				=	self:GetCircleCoordinates(Vector2((Render.Width / 2 ),32), 26, 50)
			points4				=	self:GetCircleCoordinates(Vector2((Render.Width / 2 ),32), 27, 50)
			timer = nil
		end
	end
	
	local amount 		= 	tostring(LocalPlayer:GetMoney())
	local expnum 		= 	tonumber(LocalPlayer:GetValue("Experience"))
	local expmax 		= 	tonumber(LocalPlayer:GetValue("ExperienceMax"))
	local exppercent	=		expnum / expmax
	local lvltxt 		= 	tostring(LocalPlayer:GetValue("Level"))
	local credtxt 		= 	self:formatNumber(amount)
	
	local exppoints		=	51 - 50 * exppercent
	local hungerlvl		=	tonumber(LocalPlayer:GetValue("RenderHunger"))
	local thirstlvl		=	tonumber(LocalPlayer:GetValue("RenderThirst"))
	
	local lvltxt2 		= 	"Level"
	local credtxt2 		= 	"Credits"
	
	-- main rectangles
	Render:FillArea(Vector2((Render.Width / 2 - 125),0), Vector2((250),38), Color(0,0,0,150))
	Render:FillArea(Vector2((Render.Width / 2 - 25),38), Vector2((50),28), Color(0,0,0,150))
	
	-- triangles
	Render:FillTriangle(Vector2((Render.Width / 2 - 145),0), Vector2((Render.Width / 2 - 125),0), Vector2((Render.Width / 2 - 125),38), Color(0,0,0,150))
	Render:FillTriangle(Vector2((Render.Width / 2 + 125),0), Vector2((Render.Width / 2 + 145),0), Vector2((Render.Width / 2 + 125),38), Color(0,0,0,150))
	Render:FillTriangle(Vector2((Render.Width / 2 - 45),38), Vector2((Render.Width / 2 - 25),38), Vector2((Render.Width / 2 - 25),66), Color(0,0,0,150))
	Render:FillTriangle(Vector2((Render.Width / 2 + 25),38), Vector2((Render.Width / 2 + 45),38), Vector2((Render.Width / 2 + 25),66), Color(0,0,0,150))
	
	-- lines
	Render:FillArea(Vector2((Render.Width / 2 - 45 ),0), Vector2(1,38), Color(170,170,170,150))
	Render:FillArea(Vector2((Render.Width / 2 + 45 ),0), Vector2(1,38), Color(170,170,170,150))
	
	-- Hunger / Thirst
	Render:FillArea(Vector2((Render.Width / 2 - 65 ),8), Vector2(5,22), Color(170,170,170,80))
	Render:FillArea(Vector2((Render.Width / 2 - 95 ),8), Vector2(5,22), Color(170,170,170,80))
	
	Render:FillArea(Vector2((Render.Width / 2 - 25 ),66), Vector2(50,1), Color(170,170,170,150))
	Render:FillArea(Vector2((Render.Width / 2 - 125 ),38), Vector2(79,1), Color(170,170,170,150))
	Render:FillArea(Vector2((Render.Width / 2 + 45 ),38), Vector2(80,1), Color(170,170,170,150))
	
	Render:FillTriangle(Vector2((Render.Width / 2 - 46),38), Vector2((Render.Width / 2 - 44),38), Vector2((Render.Width / 2 - 25),66), Color(170,170,170,150))
	Render:FillTriangle(Vector2((Render.Width / 2 + 46),38), Vector2((Render.Width / 2 + 44),38), Vector2((Render.Width / 2 + 25),66), Color(170,170,170,150))	
	Render:FillTriangle(Vector2((Render.Width / 2 - 45),38), Vector2((Render.Width / 2 - 24),66), Vector2((Render.Width / 2 - 26),66), Color(170,170,170,150))
	Render:FillTriangle(Vector2((Render.Width / 2 + 45),38), Vector2((Render.Width / 2 + 24),66), Vector2((Render.Width / 2 + 26),66), Color(170,170,170,150))	

	Render:FillTriangle(Vector2((Render.Width / 2 - 146),0), Vector2((Render.Width / 2 - 144),0), Vector2((Render.Width / 2 - 125),38), Color(170,170,170,150))
	Render:FillTriangle(Vector2((Render.Width / 2 + 146),0), Vector2((Render.Width / 2 + 144),0), Vector2((Render.Width / 2 + 125),38), Color(170,170,170,150))	

	Render:FillTriangle(Vector2((Render.Width / 2 - 145),0), Vector2((Render.Width / 2 - 126),38), Vector2((Render.Width / 2 - 124),38), Color(170,170,170,150))
	Render:FillTriangle(Vector2((Render.Width / 2 + 145),0), Vector2((Render.Width / 2 + 126),38), Vector2((Render.Width / 2 + 124),38), Color(170,170,170,150))	

	-- circles
	Render:DrawCircle(Vector2((Render.Width / 2 ),32), 25, Color(70,70,70,150))
	Render:DrawCircle(Vector2((Render.Width / 2 ),32), 24, Color(70,70,70,150))
	Render:DrawCircle(Vector2((Render.Width / 2 ),32), 26, Color(70,70,70,150))
	Render:DrawCircle(Vector2((Render.Width / 2 ),32), 27, Color(70,70,70,150))
	
	--special circle
	for i = 1, #points-exppoints do Render:DrawLine(points[i], points[i+1], Color(0, 0, 205, 200)) end
	for i = 1, #points2-exppoints do Render:DrawLine(points2[i], points2[i+1], Color(0, 0, 205, 200)) end
	for i = 1, #points3-exppoints do Render:DrawLine(points3[i], points3[i+1], Color(0, 0, 205, 200)) end
	for i = 1, #points4-exppoints do Render:DrawLine(points4[i], points4[i+1], Color(0, 0, 205, 200)) end
	
	-- text
	if lvltxt ~= nil then
		Render:DrawText(Vector2((Render.Width / 2 ) - (Render:GetTextWidth(lvltxt, 23) / 1.9	 ), 19), lvltxt, Color(210,210,210,200), 23)
	end
	Render:DrawText(Vector2((Render.Width / 2 ) - (Render:GetTextWidth(lvltxt2, 10) / 1.9 ), 38), lvltxt2, Color(140,140,140,200), 10)
	
	Render:DrawText(Vector2((Render.Width / 2 + 87 ) - (Render:GetTextWidth(credtxt, 18) / 2 ), 7), credtxt, Color(210,210,210,200), 18)
	Render:DrawText(Vector2((Render.Width / 2 + 86 ) - (Render:GetTextWidth(credtxt2, 10) / 2 ), 23), credtxt2, Color(140,140,140,200), 10)
	
	-- images
	
	self.HungerImage:SetAlpha(0.8)
	self.HungerImage:Draw(Vector2((Render.Width / 2 - 117), 8), Vector2(20,20), Vector2(0,0),Vector2(1,1))
	
	self.ThirstImage:SetAlpha(0.8)
	self.ThirstImage:Draw(Vector2((Render.Width / 2 - 85), 7.5), Vector2(22,22), Vector2(0,0),Vector2(1,1))

	
	local hungerpos = Vector2((Render.Width / 2 - 95 ),8)
	local hungersize = Vector2(5,22)
	local hpercent = hungerlvl / 100
	local hpos = hungersize.y - (hungersize.y * hpercent)

	Render:SetClip(true, hungerpos + Vector2(0, hpos), hungersize)
	Render:FillArea(hungerpos, hungersize, Color(0,0,205,200))
	Render:SetClip(false)
	
	local thirstpos = Vector2((Render.Width / 2 - 65 ),8)
	local thirstsize = Vector2(5,22)
	local tpercent = thirstlvl / 100
	local tpos = thirstsize.y - (thirstsize.y * tpercent)	
	
	Render:SetClip(true, thirstpos + Vector2(0,tpos), thirstsize)
	Render:FillArea(thirstpos, thirstsize, Color(0,0,205,200))
	Render:SetClip(false)
	
	if ExpFadeInTimer or ExpFadeOutTimer then
	
		if ExpFadeInTimer ~= nil then
			CircleAlpha = math.clamp(0 + (ExpFadeInTimer:GetSeconds() * 510), 0, 255)
			if CircleAlpha >= 255 then
				ExpFadeOutTimer = Timer()
				ExpFadeInTimer 	= nil
			end
		end
	
		if ExpFadeOutTimer ~= nil then
			CircleAlpha = math.clamp(255 - (ExpFadeOutTimer:GetSeconds() * 96), 0, 255)
			if CircleAlpha <= 0 then
				ExpFadeOutTimer = nil
			end
		end
	
		Render:DrawCircle(Vector2((Render.Width / 2 ),32), 28, Color(150,150,150,CircleAlpha))
		Render:DrawCircle(Vector2((Render.Width / 2 ),32), 29, Color(150,150,150,CircleAlpha))
		Render:DrawCircle(Vector2((Render.Width / 2 ),32), 30, Color(100,100,100,CircleAlpha))
		Render:DrawCircle(Vector2((Render.Width / 2 ),32), 31, Color(50,50,50,CircleAlpha))
		
		Render:DrawCircle(Vector2((Render.Width / 2 ),32), 23, Color(150,150,150,CircleAlpha))
		Render:DrawCircle(Vector2((Render.Width / 2 ),32), 22, Color(150,150,150,CircleAlpha))
		Render:DrawCircle(Vector2((Render.Width / 2 ),32), 21, Color(100,100,100,CircleAlpha))
		Render:DrawCircle(Vector2((Render.Width / 2 ),32), 20, Color(50,50,50,CircleAlpha))
		
	end
	
end

function SurvivalHUD:ResolutionChange( )
	timer = Timer()
end

function SurvivalHUD:CheckExp()
	
	self.numtick = self.numtick + 1
	
	if self.numtick >= 20 then
		if self.exp ~= tonumber(LocalPlayer:GetValue("Experience")) then
			ExpFadeInTimer = Timer()
			self.exp = LocalPlayer:GetValue("Experience")
		end
		self.numtick = 0
	end
end

function SurvivalHUD:GetCircleCoordinates(position, radius, resolution)

    local coords = {}

    for theta = 0, 2 * math.pi, 2 * math.pi / resolution do
        local x = radius * math.sin(theta)
        local y = radius * math.cos(theta)
        local point = position - Vector2(-x,y)
        table.insert(coords, point)
    end

    return coords

end

function SurvivalHUD:formatNumber(amount)

		local formatted 			= 			tostring(amount);
	
		while true do  
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2');
			if (k==0) then
				break
			end
		end
	
		return formatted;
	
end

SurvivalHUD = SurvivalHUD()