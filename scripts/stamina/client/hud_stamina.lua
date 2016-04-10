class 'Stamina_Hud'
function Stamina_Hud:__init()
	man_Outline = Image.Create(AssetLocation.Resource, "OutlineIMG")
	man_Inner = Image.Create(AssetLocation.Resource, "InnerIMG")
	Events:Subscribe("SecondTick", self, self.CheckStamina)
end
function Stamina_Hud:CheckStamina()
	if Decrypt(LocalPlayer:GetValue("Stamina")) < 98 and not rendersub then
		rendersub = Events:Subscribe("Render", self, self.RenderImg)
	elseif Decrypt(LocalPlayer:GetValue("Stamina")) >= 98 and rendersub then
		Events:Unsubscribe(rendersub)
		rendersub = nil
	end
	oldstamina = stamina
end
function Decrypt(value)
	if value then
		value = tonumber(Crypt34(tostring(value)))
		return value
	end
end
function Encrypt(value)
	if value then
		value = Crypt34(tostring(value))
		return value
	end
end

function math.round(number, decimals)

		local multiply = 10 ^ (decimals or 0)
		
		if math.floor(number * multiply + 0.5) / multiply < 1 then
			return
		else
			return math.floor(number * multiply + 0.5) / multiply
		end
		
end


function Stamina_Hud:RenderImg()
	if Game:GetState() == GUIState.Game and not LocalPlayer:GetValue("Inv_Open") then
		local size = Vector2(Render.Size.x / 6.4, Render.Size.y / 1.8)/2.5
		local basepos = Vector2(Render.Size.x - size.x - (Render.Size.x / 40),Render.Size.y - size.y - (Render.Size.y / 20))
		stamina = Decrypt(LocalPlayer:GetValue("Stamina"))
		staminaMax = Decrypt(LocalPlayer:GetValue("StaminaMax"))

		if not stamina then return end
		if stamina > staminaMax then stamina = staminaMax end
		percent = stamina / staminaMax
		local pos = size.y - (size.y*percent)
		Render:SetClip(true, basepos + Vector2(0,pos), size)
		man_Inner:Draw(basepos, size, Vector2(0,0), Vector2(1,1))
		man_Inner:SetAlpha(0.7)
		Render:SetClip(false)
		man_Outline:Draw(basepos, size, Vector2(0,0), Vector2(1,1))
		man_Outline:SetAlpha(0.8)
	end
end
function subber()
	if LocalPlayer:GetValue("Stamina") and subf then
		Stamina_Hud = Stamina_Hud()
		Events:Unsubscribe(subf)
		subf = nil
	end
end
subf = Events:Subscribe("SecondTick", subber)