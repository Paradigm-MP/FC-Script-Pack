class 'Hellfire'

function Hellfire:__init()

end

function Hellfire:MissileExplode(args, player) -- receives pos
	if player:InVehicle() == true then
		plyveh = player:GetVehicle()
	end
	local send_explosion = {}
	for ply in Server:GetPlayers() do
		if Vector3.Distance(args.pos, ply:GetPosition()) < 750 
		and ply:GetValue("CanHit") == true then -- config explosion streaming range
			table.insert(send_explosion, ply)
		end
	end
	Network:SendToPlayers(send_explosion, "CreateExplosion", {pos = args.pos})
	for index, ply in pairs(send_explosion) do
		if ply ~= player and not ply:GetValue("Invincible") then
			local dist = Vector3.Distance(args.pos, ply:GetPosition())
			if dist <= 20 then -- killzone
				ply:SetHealth(0)
			elseif dist <= 35 then
				ply:SetHealth(ply:GetHealth() - .65)
			elseif dist <= 45 then
				ply:SetHealth(ply:GetHealth() - .35)
			end
			--Chat:Broadcast("DIST: " .. tostring(dist), Color(0, 255, 0))
		end
	end
	if plyveh then
		for veh in Server:GetVehicles() do
			if plyveh ~= veh then
				if Vector3.Distance(args.pos, veh:GetPosition()) <= 45 then
					local dist = Vector3.Distance(args.pos, veh:GetPosition())
					if dist <= 20 then -- killzone
						veh:SetHealth(0)
					elseif dist <= 35 then
						veh:SetHealth(veh:GetHealth() - .65)
					elseif dist <= 45 then
						veh:SetHealth(veh:GetHealth() - .35)
					end
				end
			end
		end
	else
		for veh in Server:GetVehicles() do
			if plyveh ~= veh then
				if Vector3.Distance(args.pos, veh:GetPosition()) <= 45 then
					local dist = Vector3.Distance(args.pos, veh:GetPosition())
					if dist <= 20 then -- killzone
						veh:SetHealth(0)
					elseif dist <= 35 then
						veh:SetHealth(veh:GetHealth() - .65)
					elseif dist <= 45 then
						veh:SetHealth(veh:GetHealth() - .35)
					end
				end
			end
		end
	end
	plyveh = nil
end

function Hellfire:HandleData(args, player) -- receives players, pos, ang, speed
	Network:SendToPlayers(args.players, "OtherMissileData", {pos = args.pos, ang = args.ang, id = player:GetId(), speed = args.speed})
end

hellfire = Hellfire()

Network:Subscribe("MissileExplode", hellfire, hellfire.MissileExplode)
Network:Subscribe("SendUpdate", hellfire, hellfire.HandleData)
