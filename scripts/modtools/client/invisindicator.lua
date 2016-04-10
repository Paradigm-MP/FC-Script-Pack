function ren()

	if LocalPlayer:GetValue("Invis") then
		Render:DrawText(Vector2(0,Render.Size.y / 2), "You are invisible.", Color.White, 25)
	end
	if LocalPlayer:GetValue("Invincible") then
		Render:DrawText(Vector2(0,Render.Size.y / 2.25), "You are invincible.", Color.Yellow, 25)
	end
	
end
Events:Subscribe("Render", ren)