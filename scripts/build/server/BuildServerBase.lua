class 'Building'

function Building:__init()

end

function Building:NewStatic(args, player) -- receives b_args and info and name - Storages come here
	if args.name == "gbin" then
		local qry = SQL:Query("SELECT storageID FROM PlayerStorages WHERE steamID = (?)")
		qry:Bind(1, tostring(player:GetSteamId().id))
		local result = qry:Execute()
		if #result >= GetStorageMax(player) then
			return
		end
	end
	local static = StaticObject.Create({position = args.b_args.position, angle = args.b_args.angle, model = "f1t16.garbage_can.eez/go225-a.lod", collision = "f1t16.garbage_can.eez/go225_lod1-a_col.pfx"})
	static:SetStreamDistance(300)
	for identifier, value in pairs(args.info) do
		static:SetNetworkValue(identifier, value)
	end
	Events:Fire("RegisterStatic", {obj = static, steam_id = player:GetSteamId().id, ply = player})
	--Chat:dBroadcast("New WNO Created", Color(0, 255, 0))
end


function Building:PlaceFactionGuard(args, player)
	Events:Fire("PlaceFactionGuardServer", {pos = args.pos, ply = player})
end

function Building:PlaceFactionTurret(args, player)
	Events:Fire("PlaceFactionTurretServer", {pos = args.pos, ply = player})
end

building = Building()

-- Start Network Events
Network:Subscribe("CreateNewNetworkedObject", building, building.NewStatic)
--
Network:Subscribe("PlaceFactionGuard", building, building.PlaceFactionGuard)
Network:Subscribe("PlaceFactionTurret", building, building.PlaceFactionTurret)
-- End Network Events


function GetStorageMax(p)
	local level = tonumber(p:GetValue("Level"))
	if not level then return 0 end
	
	if level < 10 then
		return 5
	elseif level < 20 then
		return 5
	elseif level < 40 then
		return 5
	elseif level < 50 then
		return 6
	elseif level < 65 then
		return 7
	elseif level < 75 then
		return 8
	elseif level < 85 then
		return 9
	elseif level < 95 then
		return 10
	elseif level < 100 then
		return 11
	elseif level < 125 then
		return 12
	elseif level < 150 then
		return 13
	elseif level < 175 then
		return 14
	elseif level <= 200 then
		return 15
	else
		return 15
	end
end