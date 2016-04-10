function sVehicleRepair(args)
	if args.vehicle and IsValid(args.vehicle) then
		args.vehicle:SetHealth(1)
	end
end
Network:Subscribe("RepairVehicle", sVehicleRepair)