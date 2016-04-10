class "AchievementPanel"

function AchievementPanel:__init(achobj, initvertoffset, size)
	self.achobj 	= achobj
	self.offset 	= initvertoffset
	self.size 		= size
	self.hasimage 	= self.achobj.parent.b64img ~= nil
	self.color 		= GenerateColor(self.achobj.parent.codename)
	self.angle 		= (math.random() * math.pi / 4) - (math.pi / 8)
end

function AchievementPanel:Render(base, scrolloffset) 	--at this point you may be wondering why I have a self.offset and a scroll offset here.
														--essentially the self.offset is the offset of the panel from the first panel
														--and the scroll offset is how much the user has scrolled
	local corner = base + Vector2(0, self.offset - scrolloffset)
	local imgpos = corner + Vector2(self.size.x / 20, self.size.y / 10)
	local imgsize = Vector2(self.size.y / 2, self.size.y / 2)
	Render:FillArea(corner, self.size, Color(20, 20, 20))
	if self.hasimage then
		if not self.imageobj then
			self.imageobj = Image.Create(AssetLocation.Base64, self.achobj.parent.b64img)
		end
		
		self.imageobj:SetPosition(imgpos)
		self.imageobj:SetSize(imgsize) --having both as y is intentional, we want a square
		self.imageobj:Draw()
	else
		Render:FillArea(imgpos, imgsize, self.color)
	end
	
	
	local titlesize = Render.Height * (50 / 1080)
	local titlepos = corner + Vector2(2 * self.size.x / 20 + imgsize.x, self.size.y / 10)
	local descpos = titlepos + Vector2(0, Render:GetTextHeight(self.achobj.parent.dispname, titlesize) + (self.size.y / 20))
	local descsize = Vector2((18 * self.size.x / 20) - (2 * self.size.x / 20 + imgsize.x), (imgpos.y + imgsize.y) - descpos.y)
	
	Render:DrawText(titlepos, self.achobj.parent.dispname, Color.White, titlesize)
	
	Textbox(self.achobj.parent.description, Color(200, 200, 200), Render.Height * (20 / 1080), descpos, descsize)
	
	local barpos = imgpos + Vector2(0, (self.size.y / 10) + imgsize.y)
	local barsize = Vector2(18 * self.size.x / 20, 2 * self.size.y / 20)
	
	Render:FillArea(barpos - Vector2(2, 2), barsize + Vector2(4, 4), Color(150, 150, 150))
	
	local prog = self.achobj:GetProgress()
	if type(prog) == nil then
		prog = 0
	elseif type(prog) == "boolean" then
		if prog then
			prog = 1
		else
			prog = 0
		end
	end
	local maxprog = self.achobj.parent.maxprogress
	if maxprog == nil then
		maxprog = 1
	end
	
	local filledbarsize = Vector2(math.clamp(prog / maxprog, 0, 1) * barsize.x, barsize.y)
	Render:FillArea(barpos, filledbarsize, Color.Green)
	
	local progtext = tostring(prog) .. " / " .. tostring(maxprog)
	local progtextsize = Render.Height * (18 / 1080)
	local progtextpos = (barpos + barsize) - Vector2(Render:GetTextWidth(progtext, progtextsize), 0 - (self.size.y / 40))
	Render:DrawText(progtextpos, progtext, Color(150, 150, 150), progtextsize)
	
	if self.achobj:IsComplete() then
		local comptext = "COMPLETE"
		local comptextsize = Render.Height * (50 / 1080)
		
		local transform = Transform2()
		transform:Translate(barpos + (barsize / 2))
		transform:Rotate(self.angle)
		transform:Translate(-(barpos + (barsize / 2)))
		Render:SetTransform(transform)
		
		--Render:SetFont(AssetLocation.Disk, "impact.ttf")
		Render:DrawText(barpos + (barsize / 2) - (Render:GetTextSize(comptext, comptextsize) / 2) + Vector2(comptextsize / 12, comptextsize / 12), comptext, Color(50, 50, 50, 200), comptextsize)
		Render:DrawText(barpos + (barsize / 2) - (Render:GetTextSize(comptext, comptextsize) / 2), comptext, Color(255, 0, 0), comptextsize)
		
		Render:ResetTransform()
	end
	
	Render:DrawLine(corner + Vector2(0, self.size.y) - Vector2(0, 1), corner + self.size - Vector2(0, 1), Color.White)
	
end

function Textbox(str, color, textsize, base, size)
	if Render:GetTextHeight(str, textsize) <= size.y then
		if Render:GetTextWidth(str, textsize) > size.x then
			local splittable = string.split(str, " ")
			local currentword = 1
			local heightsofar = 0
			
			while currentword < #splittable do
				for i = #splittable, currentword, -1 do
					local joined = table.join(splittable, currentword, i)
					if Render:GetTextWidth(joined, textsize) <= size.x then
						local height = Render:GetTextHeight(joined, textsize)
						if (height + heightsofar) <= size.y then
							Render:DrawText(base + Vector2(0, heightsofar), joined, color, textsize)
							currentword = i + 1
							heightsofar = heightsofar + height
							break
						else
							return
						end
					end
				end
			end
			
		else
			Render:DrawText(base, str, color, textsize)
		end
	end
end

function table.join(letable, start, last)
	local retstr = ""
	for i, str in ipairs(letable) do
		if i >= start then
			retstr = retstr .. str .. " "
			if i >= last then break end
		end
	end
	return retstr
end

function GenerateColor(str)
	local hash = SHA256.ComputeHash(str)
	return Color(tonumber("0x" .. hash:sub(1,2)), tonumber("0x" .. hash:sub(3,4)), tonumber("0x" .. hash:sub(5,6)))
end