class 'PortalGun'
function PortalGun:__init()
	portalsblue = {}
	portalsorange = {}
	Events:Subscribe("ModuleUnload", self, self.Unload)
	Network:Subscribe("PortalGun_Fire", self, self.CreateNewPortal)
	Network:Subscribe("PortalGun_EnterPlayer", self, self.EnterPortalPlayer)
	Network:Subscribe("PortalGun_EnterVehicle", self, self.EnterPortalVehicle)
end
function PortalGun:EnterPortalVehicle(args, sender)
	local wno = WorldNetworkObject.GetById(args.id)
	if not IsValid(wno) then return end
	local v = args.v
	if not IsValid(v) then return end
	local portalid = wno:GetValue("ID")
	if not (portalsorange[portalid] and portalsblue[portalid]) then return end
	local velocity = v:GetLinearVelocity()
	if wno:GetValue("Type") == 1 then
		local wnoTarget = WorldNetworkObject.GetById(portalsorange[portalid])
		local newvelo = wnoTarget:GetAngle() * (Vector3.Forward * v:GetLinearVelocity():Length())
		v:SetPosition(wnoTarget:GetPosition() + (wnoTarget:GetAngle() * (Vector3.Forward * 4)))
		v:SetAngle(Angle.Inverse(v:GetAngle()) * wnoTarget:GetAngle())
		v:SetLinearVelocity(newvelo * 1.5)
	else
		local wnoTarget = WorldNetworkObject.GetById(portalsblue[portalid])
		local newvelo = wnoTarget:GetAngle() * (Vector3.Forward * v:GetLinearVelocity():Length())
		v:SetPosition(wnoTarget:GetPosition() + (wnoTarget:GetAngle() * (Vector3.Forward * 4)))
		v:SetAngle(Angle.Inverse(v:GetAngle()) * wnoTarget:GetAngle())
		v:SetLinearVelocity(newvelo * 1.5)
	end
end
function PortalGun:EnterPortalPlayer(id, sender)
	local wno = WorldNetworkObject.GetById(id)
	if not IsValid(wno) then return end
	local portalid = tostring(wno:GetValue("ID"))
	if not (portalsorange[portalid] and portalsblue[portalid]) then return end
	local velocity = sender:GetLinearVelocity()
	if wno:GetValue("Type") == 1 then
		local wnoTarget = WorldNetworkObject.GetById(portalsorange[portalid])
		local newvelo = Angle.Inverse(sender:GetAngle()) * wnoTarget:GetAngle() * velocity
		sender:SetPosition(wnoTarget:GetPosition())
		sender:SetAngle(Angle.Inverse(sender:GetAngle()) * wnoTarget:GetAngle())
		--Network:Send(sender, "PortalGun_ReceiveAngle", {velo = newvelo, pos = wnoTarget:GetPosition()})
		--wnoTarget:SetValue("RecentlyUsed", tostring(wnoTarget:GetValue("RecentlyUsed")) .. sender:GetSteamId())
	else
		local wnoTarget = WorldNetworkObject.GetById(portalsblue[portalid])
		local newvelo = Angle.Inverse(sender:GetAngle()) * wnoTarget:GetAngle() * velocity
		sender:SetPosition(wnoTarget:GetPosition())
		sender:SetAngle(Angle.Inverse(sender:GetAngle()) * wnoTarget:GetAngle())
		--Network:Send(sender, "PortalGun_ReceiveAngle", {velo = newvelo, pos = wnoTarget:GetPosition()})
		--wnoTarget:SetValue("RecentlyUsed", tostring(wnoTarget:GetValue("RecentlyUsed")) .. sender:GetSteamId())
	end
end
function PortalGun:Unload()
	for steamid, id in pairs(portalsblue) do
		local wno2 = WorldNetworkObject.GetById(id)
		if IsValid(wno2) then wno2:Remove() end
	end
	for steamid, id in pairs(portalsorange) do
		local wno2 = WorldNetworkObject.GetById(id)
		if IsValid(wno2) then wno2:Remove() end
	end
end
function PortalGun:CreateNewPortal(args, sender)
	--if not (sender:GetValue("NT_TagName") == "[Admin]" or sender:GetValue("NT_TagName") == "[Mod]") then return end
	if args.type == 1 then
		for id1, id in pairs(portalsblue) do
			if id1 == tostring(sender:GetSteamId()) then
				local wno = WorldNetworkObject.GetById(id)
				if IsValid(wno) then wno:Remove() end
			end
		end
	else
		for id1, id in pairs(portalsorange) do
			if id1 == tostring(sender:GetSteamId()) then
				local wno = WorldNetworkObject.GetById(id)
				if IsValid(wno) then wno:Remove() end
			end
		end
	end
	local angle = Angle.FromVectors(Vector3.Forward, args.normal)
	if angle == Angle(0,1.570796,0) then angle = Angle(0,-math.pi/2,0) end
	local wno = WorldNetworkObject.Create({position = args.position, angle = angle})
	wno:SetNetworkValue("IsPortal", 1)
	wno:SetNetworkValue("Type", args.type)
	wno:SetNetworkValue("ID", tostring(sender:GetSteamId()))
	wno:SetNetworkValue("Normal", args.normal)
	if args.type == 1 then
		portalsblue[tostring(sender:GetSteamId())] = wno:GetId()
	else
		portalsorange[tostring(sender:GetSteamId())] = wno:GetId()
	end
end
PortalGun = PortalGun()