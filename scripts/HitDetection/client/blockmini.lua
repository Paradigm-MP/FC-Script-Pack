function second()
	if LocalPlayer:GetEquippedWeapon().id == 26 and not LocalPlayer:InVehicle() then
		Network:Send("KickMe")
	end
end
Events:Subscribe("SecondTick", second)