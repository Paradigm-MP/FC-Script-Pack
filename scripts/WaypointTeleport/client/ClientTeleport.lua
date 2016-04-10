function SendWaypoint(args)
	if args.key == string.byte("0") and (LocalPlayer:GetValue("NT_TagName") == "[Admin]" or LocalPlayer:GetValue("NT_TagName") == "[Mod]") then
		if Waypoint:GetPosition() ~= nil then
			local wp = Waypoint:GetPosition()
			wp.y = wp.y + 50
			Network:Send("ToWaypoint", {pos = wp})
			Waypoint:Remove()
		else
			--Chat:Print("Waypoint:GetPosition() = " .. tostring(Waypoint:GetPosition()), Color(0, 255, 0))
		end
	end
end
Events:Subscribe("KeyDown", SendWaypoint)