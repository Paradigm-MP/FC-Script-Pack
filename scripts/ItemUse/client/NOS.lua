maxspeed = 1000
speedTimer = Timer()
function KeyDownBoost(args)
	if args.key == string.byte('Q') and LocalPlayer:InVehicle() and drugname == "NOS" then
		local v = LocalPlayer:GetVehicle()
		local forwardVelocity = math.abs((v:GetAngle() * v:GetLinearVelocity()).z)
		local add = v:GetLinearVelocity() * 1.05
		if forwardVelocity < maxspeed and speedTimer:GetSeconds() > 1 and v:GetHealth() > 0.1 then
			v:SetLinearVelocity(v:GetLinearVelocity() + add)
			speedTimer:Restart()
			fx = ClientEffect.Create(AssetLocation.Game, {
				position = LocalPlayer:GetPosition(),
				angle = v:GetAngle(),
				effect_id = 285})
		end
	end
end
Events:Subscribe("KeyUp", KeyDownBoost)