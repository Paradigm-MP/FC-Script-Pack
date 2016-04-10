function cVehicleRepair()
	local inveh = LocalPlayer:InVehicle()
	if inveh == false then
		local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, 100)
		if ray.entity and ray.entity.__type == "Vehicle" and IsValid(ray.entity) then
			if ray.entity:GetHealth() < 1 then
				Network:Send("RepairVehicle", {vehicle = ray.entity})
				Events:Fire("DeleteFromInventory", {sub_item = "Vehicle Repair", sub_amount = 1})
			end
		end
	elseif inveh == true then
		Events:Fire("DeleteFromInventory", {sub_item = "Vehicle Repair", sub_amount = 1})
		Network:Send("RepairVehicle", {vehicle = LocalPlayer:GetVehicle()})
	end
end
Events:Subscribe("AttemptVehicleRepair", cVehicleRepair)