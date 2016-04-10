class 'FreeBuild'
function FreeBuild:__init()
	f_mortars = {}
	SQL:Execute("CREATE TABLE IF NOT EXISTS placedObjects (steamID VARCHAR UNIQUE, info BLOB)")
	SQL:Execute("CREATE TABLE IF NOT EXISTS doorAccessTypes (pos VARCHAR, access_type VARCHAR)")
	doorAccessTypes = {}
	self:GetDoorAccessTypes()
	--cannot claim within 500m of these areas
	objectSO = {} --static object id, static object
	healthUpdateQueue = {} --id, old hp
	Events:Subscribe("ModuleUnload", self, self.Unload)
	Events:Subscribe("ModuleLoad", self, self.Load)
	Events:Subscribe("ModulesLoad", self, self.ModulesLoad)
	Events:Subscribe("TimeChange", self, self.UpdateObjectHealthQueue)
	Network:Subscribe("LC_ClientObjectPlace", self, self.ClientPlaceObject)
	Network:Subscribe("LC_PickUpObject", self, self.ClientPickUpObject)
	Network:Subscribe("LC_HitClaimObject", self, self.ClientShootObject)
	Network:Subscribe("LC_SetSpawn", self, self.ClientSetSpawn)
	Network:Subscribe("LC_UseDoor", self, self.ClientUseDoor)
	Network:Subscribe("LC_UseGarageDoor", self, self.ClientUseGarageDoor)
	Network:Subscribe("LC_ChangeDoorAccessType", self, self.ClientChangeDoorAccessType)
	Network:Subscribe("SitInChair", self, self.ClientSitInChair)
	Network:Subscribe("GetUpFromChair", self, self.ClientGetUpFromChair)
	Network:Subscribe("LC_HealObject", self, self.SetObjectHealth)
	Console:Subscribe("getobjs", self, self.GetObjs)
end
function FreeBuild:GetObjs()
	local numobjs = 0
	for k,v in pairs(objectSO) do
		numobjs = numobjs + 1
	end
	print("Number of objects in server: "..tostring(numobjs))
end
function FreeBuild:GetDoorAccessTypes()
	local result = SQL:Query('SELECT * FROM doorAccessTypes'):Execute(), nil
    if #result > 0 then
        for i, v in ipairs(result) do
			doorAccessTypes[v.pos] = v.access_type
		end
	end
end
function FreeBuild:UpdateDoorAccessType(obj)
	local cmd = SQL:Command('UPDATE doorAccessTypes SET access_type = ? WHERE pos = ?')
	local pos = tostring(obj:GetPosition())
	local accesstype = obj:GetValue("AccessType")
	cmd:Bind(1, accesstype)
	cmd:Bind(2, pos)
	cmd:Execute()
	doorAccessTypes[pos] = accesstype
end
function FreeBuild:InsertDoorAccessType(obj)
	local cmd = SQL:Command('INSERT INTO doorAccessTypes (pos, access_type) VALUES (?,?)')
	local pos = tostring(obj:GetPosition())
	local accesstype = tostring(obj:GetValue("AccessType"))
	cmd:Bind(1, pos)
	cmd:Bind(2, accesstype)
	cmd:Execute()
	doorAccessTypes[pos] = accesstype
end
function FreeBuild:ClientGetUpFromChair(obj, sender)
	sender:SetPosition(sender:GetPosition() + Vector3(0,0.5,0))
	obj:SetNetworkValue("Occupied", nil)
end
function FreeBuild:ClientSitInChair(obj, sender)
	local angle = obj:GetAngle() * Angle(math.pi,0,0)
	sender:SetPosition(obj:GetPosition() + Vector3(0,0.75,0))
	sender:SetAngle(angle)
	obj:SetNetworkValue("Occupied", 1)
end
function FreeBuild:ClientChangeDoorAccessType(id, sender)
	local obj = objectSO[id]
	if not IsValid(obj) then Chat:Send(sender, "Error in changing door access type. (16)", Color.Red) return end
	if tostring(obj:GetValue("SteamID")) == tostring(sender:GetSteamId()) then
		ChangeAccessType(obj)
	else
		Chat:Send(sender, "Error in changing door access type. (37)", Color.Red)
	end
end
function ChangeAccessType(obj)
	local oldAccess = tostring(obj:GetValue("AccessType"))
	if oldAccess == "Only Me" then
		obj:SetNetworkValue("AccessType", "Friends")
		FreeBuild:UpdateDoorAccessType(obj)
	elseif oldAccess == "Friends" then
		obj:SetNetworkValue("AccessType", "Anyone")
		FreeBuild:UpdateDoorAccessType(obj)
	elseif oldAccess == "Anyone" then
		obj:SetNetworkValue("AccessType", "Only Me")
		FreeBuild:UpdateDoorAccessType(obj)
	end
end
function FreeBuild:ClientUseDoor(id, sender)
	local obj = objectSO[id]
	if not IsValid(obj) then Chat:Send(sender, "Error in using door. (13)", Color.Red) return end
	local ownerid = tostring(obj:GetValue("SteamIDid"))
	local owner = tostring(obj:GetValue("SteamID"))
	local AccessType = tostring(obj:GetValue("AccessType"))
	if AccessType == "Anyone" 
	or (AccessType == "Friends" and sender:GetValue("Friends"):find(tostring(ownerid)))
	or owner == tostring(sender:GetSteamId()) 
	or tostring(sender:GetValue("NT_TagName")) == "[Admin]" then
		if obj:GetValue("DoorOpen") then
			local angle = obj:GetAngle() * Angle(-math.pi/2,0,0)
			obj:SetAngle(angle)
			obj:SetNetworkValue("DoorOpen", nil)
		else
			local angle = obj:GetAngle() * Angle(math.pi/2,0,0)
			obj:SetAngle(angle)
			obj:SetNetworkValue("DoorOpen", 1)
		end
	end
end
function FreeBuild:ClientUseGarageDoor(id, sender)
	local obj = objectSO[id]
	if not IsValid(obj) then Chat:Send(sender, "Error in using door. (13)", Color.Red) return end
	local ownerid = tostring(obj:GetValue("SteamIDid"))
	local owner = tostring(obj:GetValue("SteamID"))
	local AccessType = tostring(obj:GetValue("AccessType"))
	if AccessType == "Anyone" 
	or (AccessType == "Friends" and sender:GetValue("Friends"):find(tostring(ownerid)))
	or owner == tostring(sender:GetSteamId()) 
	or tostring(sender:GetValue("NT_TagName")) == "[Admin]" then
		if obj:GetValue("DoorOpen") then
			local angle = obj:GetAngle() * Angle(0,0,-math.pi/2)
			obj:SetAngle(angle)
			obj:SetNetworkValue("DoorOpen", nil)
		else
			local angle = obj:GetAngle() * Angle(0,0,math.pi/2)
			obj:SetAngle(angle)
			obj:SetNetworkValue("DoorOpen", 1)
		end
	end
end
function FreeBuild:ClientSetSpawn(id, sender)
	local obj = objectSO[id]
	if not IsValid(obj) then Chat:Send(sender, "Error in setting home. (33)", Color.Red) return end
	if tostring(obj:GetValue("SteamID")) == tostring(sender:GetSteamId()) then
		if Vector3.Distance(obj:GetPosition(), sender:GetPosition()) < 10 then
			Events:Fire("LC_SetSpawnPosition", {pos = obj:GetPosition(), player = sender})
		else
			Chat:Send(sender, "Error in setting home. (25)", Color.Red)
		end
	else
		Chat:Send(sender, "Error in setting home. (27)", Color.Red)
	end
end
function FreeBuild:ClientShootObject(args, sender)
	local obj = objectSO[args.id]
	if not IsValid(obj) then return end
	local hp = obj:GetValue("Health")
	
	local newhp
	
	args.damage = args.damage / 2.5
	
	if not args.absolute_damage then
		newhp = hp - (args.damage * 10)
	else
		newhp = hp - (args.damage)
	end
	
	if newhp < 0 then
		newhp = 0
	end
	
	if not healthUpdateQueue[obj:GetId()] then
		healthUpdateQueue[obj:GetId()] = hp
	end
	obj:SetNetworkValue("Health", newhp)
	print(tostring(sender).." damaged "..tostring(obj:GetValue("model")).." with "..tostring(args.damage).." at "..tostring(obj:GetPosition()))

	if newhp <= 0 then
		Network:SendNearby(sender, "LC_ClaimObjectDestroy", {pos = obj:GetPosition(), angle = obj:GetAngle(), name = obj:GetValue("model")})
		Network:Send(sender, "LC_ClaimObjectDestroy", {pos = obj:GetPosition(), angle = obj:GetAngle(), name = obj:GetValue("model")})
		if tostring(sender:GetSteamId()) ~= tostring(obj:GetValue("SteamID")) and not sender:GetValue("Friends"):find(tostring(obj:GetValue("SteamID"))) then
			Events:Fire("LC_AddExpOnObjectDestroy", {player = sender, name = obj:GetValue("model"), maxhp = HPamts[obj:GetValue("model")]})
		end
		self:RemoveObjectOnDeath(obj)
		if tostring(sender:GetValue("NT_TagName")) == "[Admin]" then
			sender:SendChatMessage("REMOVING YOUR OBJECT CODE 2", Color.Red)
		end
	end
	end
function FreeBuild:RemoveObjectOnDeath(obj, A, B)
	--Chat:Broadcast("RemoveOnDeath", Color.Red)
	if not IsValid(obj) then return end
	local hp = tostring(healthUpdateQueue[obj:GetId()])
	if A or not hp then hp = tostring(obj:GetValue("Health")) end
	local steamid = tostring(obj:GetValue("SteamID"))
	local str = "|"..tostring(obj:GetPosition())..","..tostring(obj:GetValue("angle"))..","..tostring(hp)..","..tostring(obj:GetValue("model"))..","..tostring(obj:GetValue("SteamIDid"))
	local query = SQL:Query( "SELECT info FROM placedObjects WHERE steamID = ? LIMIT 1" )
	query:Bind(1, steamid)
	local result = query:Execute(), nil
	local totalStr = ""
	if result[1] ~= nil and result[1].info ~= nil then
		if tostring(obj:GetValue("model")) == "Bed" then
			Events:Fire("LC_DestroyBedSpawn", {pos = obj:GetPosition(), steamID = steamid})
		end
		totalStr = tostring(result[1].info)
		local a, b = string.find(totalStr, str, 0, true)
		if a and b then
			totalStr = string.sub(totalStr, 0, a-1)..string.sub(totalStr, b+1, string.len(totalStr))
			local cmd = SQL:Command("UPDATE placedObjects SET info=? WHERE steamID = ?")	
			cmd:Bind(1, totalStr)
			cmd:Bind(2, steamid)
			cmd:Execute()
		end
		healthUpdateQueue[obj:GetId()] = nil
		if not B then
			objectSO[obj:GetId()] = nil
			obj:Remove()
		end
	end
end
function FreeBuild:UpdateObjectHealthQueue()
	for id, hp in pairs(healthUpdateQueue) do
		local obj = objectSO[id]
		if not IsValid(obj) then return end
		local steamID = tostring(obj:GetValue("SteamID"))
		local str = "|"..tostring(obj:GetPosition())..","..tostring(obj:GetValue("angle"))..","..tostring(hp)..","..tostring(obj:GetValue("model"))..","..tostring(obj:GetValue("SteamIDid"))
		local strNew = "|"..tostring(obj:GetPosition())..","..tostring(obj:GetValue("angle"))..","..tostring(obj:GetValue("Health"))..","..tostring(obj:GetValue("model"))..","..tostring(obj:GetValue("SteamIDid"))
		local query = SQL:Query( "SELECT info FROM placedObjects WHERE steamID = ? LIMIT 1" )
		query:Bind(1, steamID)
		local result = query:Execute(), nil
		local totalStr = ""
		if result[1] ~= nil and result[1].info ~= nil then
			totalStr = tostring(result[1].info)
			local a, b = string.find(totalStr, str, 0, true)
			if a and b then
				totalStr = string.sub(totalStr, 0, a-1)..string.sub(totalStr, b+1, string.len(totalStr))
				totalStr = totalStr..strNew
				local cmd = SQL:Command("UPDATE placedObjects SET info=? WHERE steamID = ?")	
				cmd:Bind(1, totalStr)
				cmd:Bind(2, steamID)
				cmd:Execute()
			end
		end
		healthUpdateQueue[id] = nil
	end
end

function FreeBuild:SetObjectHealth(args, player)
	local name = player:GetName()
	for id, new_health in pairs(args.objects) do
		local obj = StaticObject.GetById(id)
		if IsValid(obj) and obj:GetValue("Health") then
			local oldHp = obj:GetValue("Health")
			obj:SetNetworkValue("Health", new_health)
			local steamID = tostring(obj:GetValue("SteamID"))
			local str = "|"..tostring(obj:GetPosition())..","..tostring(obj:GetValue("angle"))..","..tostring(oldHp)..","..tostring(obj:GetValue("model"))..","..tostring(obj:GetValue("SteamIDid"))
			local strNew = "|"..tostring(obj:GetPosition())..","..tostring(obj:GetValue("angle"))..","..tostring(new_health)..","..tostring(obj:GetValue("model"))..","..tostring(obj:GetValue("SteamIDid"))
			local query = SQL:Query( "SELECT info FROM placedObjects WHERE steamID = ? LIMIT 1" )
			query:Bind(1, steamID)
			local result = query:Execute(), nil
			local totalStr = ""
			if result[1] ~= nil and result[1].info ~= nil then
				totalStr = tostring(result[1].info)
				local a, b = string.find(totalStr, str, 0, true)
				if a and b then
					totalStr = string.sub(totalStr, 0, a-1)..string.sub(totalStr, b+1, string.len(totalStr))
					totalStr = totalStr..strNew
					local cmd = SQL:Command("UPDATE placedObjects SET info=? WHERE steamID = ?")	
					cmd:Bind(1, totalStr)
					cmd:Bind(2, steamID)
					cmd:Execute()
				end
			end
			print(tostring(name) .. " healed object at " .. tostring(obj:GetPosition()))
		end
	end
end

function FreeBuild:ClientPickUpObject(id, sender)
	local obj = objectSO[id]
	if not IsValid(obj) then Chat:Send(sender, "Error in picking up object. (82)", Color.Red) return end
	if tostring(obj:GetValue("SteamID")) == tostring(sender:GetSteamId()) or tostring(sender:GetValue("NT_TagName")) == "[Admin]" then
		self:RemoveObject(obj, sender)
		if tostring(sender:GetValue("NT_TagName")) == "[Admin]" then
			sender:SendChatMessage("REMOVING YOUR OBJECT CODE 1", Color.Red)
		end
	else
		Chat:Send(sender, "Error in picking up object. (93)", Color.Red)
	end
end
function FreeBuild:RemoveObject(obj, p)
	if p:GetValue("NT_TagName") == "[Admin]" then
		p:SendChatMessage("Passed Through FreeBuild:RemoveObject()", Color(0, 255, 0))
	end
	local steamid = tostring(obj:GetValue("SteamID"))
	local str = "|"..tostring(obj:GetPosition())..","..tostring(obj:GetValue("angle"))..","..tostring(obj:GetValue("Health"))..","..tostring(obj:GetValue("model"))
	if tostring(obj:GetValue("model")) == "Door" or tostring(obj:GetValue("model")) == "Reinforced Door" or tostring(obj:GetValue("model")) == "Garage Door" then
		str = str..","..tostring(obj:GetValue("SteamIDid"))
	end
	local query = SQL:Query( "SELECT info FROM placedObjects WHERE steamID = ? LIMIT 1" )
	query:Bind(1, steamid)
	local result = query:Execute(), nil
	local totalStr = ""
	if result[1] ~= nil and result[1].info ~= nil then
		if tostring(obj:GetValue("model")) == "Bed" then
			Events:Fire("LC_DestroyBedSpawn", {pos = obj:GetPosition(), steamID = steamid})
		end
		totalStr = tostring(result[1].info)
		local a, b = string.find(totalStr, str, 0, true)
		totalStr = string.sub(totalStr, 0, a-1)..string.sub(totalStr, b+1, string.len(totalStr))
		local cmd = SQL:Command("UPDATE placedObjects SET info=? WHERE steamID = ?")	
		cmd:Bind(1, totalStr)
		cmd:Bind(2, steamid)
		cmd:Execute()
		objectSO[obj:GetId()] = nil
		Network:Send(p, "LC_RefundBuildingItem", tostring(obj:GetValue("model")))
		obj:Remove()
	else
		Chat:Send(p, "Error in picking up object. (45)", Color.Red)
	end
end
function GetCollision(model)
	model = tostring(objects[model])
	local i, j = string.find(model, "-")
	local str1 = string.sub(model, 1, i-1)
	str1 = str1.."_lod1"
	local k, m = string.find(model, ".lod")
	str1 = str1..string.sub(model, j, k-1)
	str1 = str1.."_col.pfx"
	return str1
end
function FreeBuild:ClientPlaceObject(args, sender)
	if self:CheckIfCanPlaceObject(args, sender) then
		local hp = HPamts[args.iname]
		if not hp then Chat:Send(sender, "Error in placing object. (86)", Color.Red) return end
		local tbl = {}
		--print(args.angle)
		if args.pos.y < 200 and args.iname == "Mortar" then
			Chat:Send(sender, "You cannot place a mortar underwater!", Color.Red)
			Network:Send(sender, "LC_RefundBuildingItem", args.iname)
			return
		elseif args.pos.y < 200 and args.iname == "Bed" then
			Chat:Send(sender, "You cannot place a bed underwater!", Color.Red)
			Network:Send(sender, "LC_RefundBuildingItem", args.iname)
			return
		end
		tbl.position = args.pos
		tbl.angle = args.angle
		tbl.model = objects[tostring(args.iname)]
		tbl.collision = GetCollision(args.iname)
		if tostring(args.iname) == "Door" then
			--tbl.fixed = false
		end
		local obj = StaticObject.Create(tbl)
		obj:SetNetworkValue("Health", hp)
		obj:SetNetworkValue("IsClaimOBJ", 1)
		obj:SetNetworkValue("SteamID", sender:GetSteamId())
		obj:SetNetworkValue("model", args.iname)
		obj:SetNetworkValue("angle", tostring(args.angle))
		--pos.x,pos.y,pos.z,angle.yaw,angle.pitch,angle.roll,hp,model
		local str = "|"..tostring(args.pos)..","..tostring(args.angle)..","..tostring(hp)..","..tostring(args.iname)..","..tostring(sender:GetSteamId().id)
		objectSO[obj:GetId()] = obj
		self:AddObjectToSQL(str, tostring(sender:GetSteamId()))
		if args.iname == "Door" or args.iname == "Reinforced Door" or args.iname == "Garage Door" then
			obj:SetNetworkValue("AccessType", "Only Me")
			self:InsertDoorAccessType(obj)
		end
		obj:SetNetworkValue("SteamIDid", tostring(sender:GetSteamId().id))
		if tostring(args.iname) == "Mortar" then
			local mortars = {}
			if not f_mortars[obj:GetId()] then f_mortars[obj:GetId()] = obj end
			table.insert(mortars, obj)
			Events:Fire("SendFreebuildTurrets", {statics = mortars})
		end
	else
		Network:Send(sender, "LC_RefundBuildingItem", args.iname)
	end
end
function FreeBuild:CheckIfCanPlaceObject(args, sender)
	for _, pos in pairs(restrictedAreas) do
		local radius = 500
		if _ == 7 then radius = 1450 end
		if _ == 8 then radius = 1000 end
		if Vector3.Distance(args.pos, pos) < radius then
			if _ ~= 8 then
				Chat:Send(sender, "You are too close to a safezone to place this!", Color.Red)
			else
				Chat:Send(sender, "You are too close to Wajah Ramah Fortress to place this!", Color.Red)
			end
			return false
		end
	end
	for _, tbl in pairs(Airport) do
		if Vector3.Distance(args.pos, tbl.position) < 500 then
			local str = "You are too close to "..tbl.name.." to place this!"
			Chat:Send(sender, str, Color.Red)
			return false
		end
	end
	for index, tbl in pairs(cursed_locations) do
		if Vector3.Distance(tbl.position, args.pos) < tbl.radius then
			return false
		end
	end
	return true
end
function FreeBuild:Load()
	local numobjs = 0
	local result = SQL:Query('SELECT * FROM placedObjects'):Execute(), nil
    if #result > 0 then
        for i, v in ipairs(result) do
			local owner = v.steamID
			local split1 = string.split(v.info, "|")
			for i=1, #split1 do
				local str = split1[i]
				str = string.trim(str)
				--print(str)
				if string.len(str) > 5 then
					local s2 = string.split(str, ",")
					if string.len(tostring(s2[1])) > 4 then
						if tostring(s2[8]) ~= "Silver Fence (Double)" and tostring(s2[8]) ~= "Silver Fence (Single)" then
							local pos = Vector3(tonumber(s2[1]),tonumber(s2[2]),tonumber(s2[3]))
							local angle = Angle(tonumber(s2[4]),tonumber(s2[5]),tonumber(s2[6]))
							local spawn = true
							for index, tbl in pairs(cursed_locations) do
								if Vector3.Distance(tbl.position, pos) < tbl.radius then
									spawn = false
								end
							end
							if spawn == true then
								--print(angle)
								local tbl = {}
								tbl.position = pos
								tbl.angle = angle
								tbl.model = objects[tostring(s2[8])]
								tbl.collision = GetCollision(tostring(s2[8]))
								local obj = StaticObject.Create(tbl)
								obj:SetNetworkValue("Health", tonumber(s2[7]))
								obj:SetNetworkValue("IsClaimOBJ", 1)
								obj:SetNetworkValue("SteamID", owner)
								obj:SetNetworkValue("model", tostring(s2[8]))
								obj:SetNetworkValue("angle", tostring(angle))
								if tostring(s2[8]) == "Door" or tostring(s2[8]) == "Garage Door" or tostring(s2[8]) == "Reinforced Door" then
									if not doorAccessTypes[tostring(pos)] then
										obj:SetNetworkValue("AccessType", "Only Me")
										self:InsertDoorAccessType(obj)
									else
										obj:SetNetworkValue("AccessType", doorAccessTypes[tostring(pos)])
									end
								end
								obj:SetNetworkValue("SteamIDid", tostring(s2[9]))
								objectSO[obj:GetId()] = obj
								if tostring(s2[8]) == "Mortar" then
									if not f_mortars[obj:GetId()] then f_mortars[obj:GetId()] = obj end
								end
								numobjs = numobjs + 1
								--pos.x,pos.y,pos.z,angle.yaw,angle.pitch,angle.roll,hp,model
							end
						end
					end
				end
			end
		--[[local cmd = SQL:Command("UPDATE placedObjects SET info=? WHERE steamID = ?")	
		cmd:Bind(1, updateStr)
		cmd:Bind(2, owner)
		cmd:Execute()--]]
		end
	end
	print("Number of objects in server: "..tostring(numobjs))
end
function FreeBuild:ModulesLoad()
	Events:Fire("SendFreebuildTurrets", {statics = f_mortars})
end
function FreeBuild:Unload()
	for id, obj in pairs(objectSO) do
		if IsValid(obj) then
			obj:Remove()
		end
	end
end
function FreeBuild:AddObjectToSQL(str, steamID)
	local query = SQL:Query( "SELECT info FROM placedObjects WHERE steamID = ? LIMIT 1" )
	query:Bind(1, steamID)
	local result = query:Execute(), nil
	local totalStr = ""
	if result[1] ~= nil and result[1].info ~= nil then
		totalStr = tostring(result[1].info)
	end
	totalStr = totalStr..str
	if result[1] == nil then
		local cmd = SQL:Command("INSERT INTO placedObjects (steamID, info) VALUES (?,?)")	
		cmd:Bind(1, steamID)
		cmd:Bind(2, totalStr)
		cmd:Execute()
	else
		local cmd = SQL:Command("UPDATE placedObjects SET info=? WHERE steamID = ?")	
		cmd:Bind(1, totalStr)
		cmd:Bind(2, steamID)
		cmd:Execute()
	end
end
FreeBuild = FreeBuild()