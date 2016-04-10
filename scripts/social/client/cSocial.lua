class 'Social'
function Social:__init()
	self.players = {}
	self.disCSOs = {}
	self.hatCSOs = {}
	self.faceCSOs = {}
	self.backCSOs = {}
	self.handCSOs = {}
	self.handCSOs2 = {}
	self.refDIS = {}
	self.mismatchTimer1 = Timer()
	self.mismatchTimer2 = Timer()
	self.mismatchTimer3 = Timer()
	self.mismatchTimer4 = Timer()
	self.mismatchTimer5 = Timer()
	self.mismatchTimer6 = Timer()
	self.refDIS["(Disguise) Palm Tree"] = "vegetation_0.blz/jungle_T11_palmS-Whole.lod"
	self.refDIS["(Disguise) Needlebush"] = "vegetation_2.blz/Desert_T01_NeedleBushM-whole.lod"
	self.refDIS["(Disguise) Bush"] = "City_B10_roofbush-Whole.lod"
	self.refDIS["(Disguise) Kelp"] = "Jungle_B32_KelpL-Whole.lod"
	Events:Subscribe("SecondTick", self, self.GetPlayers)
	Events:Subscribe("ModuleUnload", self, self.Unload)
	Events:Subscribe("LocalPlayerBulletHit", self, self.Hit)
	Events:Subscribe("SOCIAL_MISMATCH_NO_ITEM", self, self.Mismatch)
	Events:Subscribe("SOCIAL_CheckItemUse", self, self.ItemEquip)
end
function Social:FindTimer(str)
	for name, model in pairs(hats) do
		if name == str then return self.mismatchTimer1 end
	end
	for name, model in pairs(glasses) do
		if name == str then return self.mismatchTimer2 end
	end
	for name, model in pairs(backpacks) do
		if name == str then return self.mismatchTimer3 end
	end
	for name, model in pairs(hand) do
		if name == str then return self.mismatchTimer4 end
	end
	for name, model in pairs(DIS) do
		if name == str then return self.mismatchTimer5 end
	end
	if str == "Wingsuit" then return self.mismatchTimer6 end
	return " "
end
function Social:ItemEquip(item)
	Network:Send("SOCIAL_ItemEquipUnequip", item)
end
function Social:Mismatch(str)
	local newStr = string.split(str, "|")
	for _, str2 in pairs(newStr) do
		local timer = self:FindTimer(str2)
		if timer ~= " " and timer:GetSeconds() > 0.25 then
			if string.len(str2) > 1 then
				Network:Send("SOCIAL_Mismatch_NoItem", str2)
			end
			timer:Restart()
		end
	end
end
function Social:Hit()
	if CheckSocial(p, "SOCIAL_Disguise") then
		Events:Fire("DeleteFromInventory", {sub_item = tostring(p:GetValue("SOCIAL_Disguise")), sub_amount = 1})
		LocalPlayer:SetValue("SOCIAL_Disguise", " ")
		Network:Send("SOCIAL_DisguiseHit")
	end
end
function CheckSocial(p, str)
	if p:GetValue(str) and string.len(tostring(p:GetValue(str))) > 3 then
		return tostring(p:GetValue(str))
	else
		return false
	end
end
function Social:CheckDisguise(p)
	if CheckSocial(p, "SOCIAL_Disguise") and not self.disCSOs[p:GetId()] then
		self.disCSOs[p:GetId()] = ClientStaticObject.Create({
		position = p:GetBonePosition("ragdoll_Spine"),
		angle = Angle(),
		model = self.refDIS[CheckSocial(p, "SOCIAL_Disguise")]})
	elseif not CheckSocial(p, "SOCIAL_Disguise") and IsValid(self.disCSOs[p:GetId()]) then
		self.disCSOs[p:GetId()]:Remove()
		self.disCSOs[p:GetId()] = nil
	elseif CheckSocial(p, "SOCIAL_Disguise")
	and self.disCSOs[p:GetId()]:GetModel() ~= self.refDIS[CheckSocial(p, "SOCIAL_Disguise")] then
		self.disCSOs[p:GetId()]:Remove()
		self.disCSOs[p:GetId()] = nil
		self.disCSOs[p:GetId()] = ClientStaticObject.Create({
		position = p:GetBonePosition("ragdoll_Spine"),
		angle = Angle(),
		model = self.refDIS[CheckSocial(p, "SOCIAL_Disguise")]})
	end
end
function Social:CheckHat(p)
	if CheckSocial(p, "SOCIAL_Hat") and not self.hatCSOs[p:GetId()] then
		if not hats[CheckSocial(p, "SOCIAL_Hat")] then return end
		self.hatCSOs[p:GetId()] = ClientStaticObject.Create({
		position = p:GetBonePosition("ragdoll_Head"),
		angle = Angle(),
		model = hats[CheckSocial(p, "SOCIAL_Hat")]})
	elseif not CheckSocial(p, "SOCIAL_Hat") and IsValid(self.hatCSOs[p:GetId()]) then
		self.hatCSOs[p:GetId()]:Remove()
		self.hatCSOs[p:GetId()] = nil
	elseif CheckSocial(p, "SOCIAL_Hat")
	and self.hatCSOs[p:GetId()]:GetModel() ~= hats[CheckSocial(p, "SOCIAL_Hat")] then
		self.hatCSOs[p:GetId()]:Remove()
		self.hatCSOs[p:GetId()] = nil
		self.hatCSOs[p:GetId()] = ClientStaticObject.Create({
		position = p:GetBonePosition("ragdoll_Spine"),
		angle = Angle(),
		model = hats[CheckSocial(p, "SOCIAL_Hat")]})
	end
end
function Social:CheckFace(p)
	if CheckSocial(p, "SOCIAL_Face") and not self.faceCSOs[p:GetId()] then
		if not glasses[CheckSocial(p, "SOCIAL_Face")] then return end
		self.faceCSOs[p:GetId()] = ClientStaticObject.Create({
		position = p:GetBonePosition("ragdoll_Head"),
		angle = Angle(),
		model = glasses[CheckSocial(p, "SOCIAL_Face")]})
	elseif not CheckSocial(p, "SOCIAL_Face") and IsValid(self.faceCSOs[p:GetId()]) then
		self.faceCSOs[p:GetId()]:Remove()
		self.faceCSOs[p:GetId()] = nil
	elseif CheckSocial(p, "SOCIAL_Face")
	and self.faceCSOs[p:GetId()]:GetModel() ~= hats[CheckSocial(p, "SOCIAL_Face")] then
		self.faceCSOs[p:GetId()]:Remove()
		self.faceCSOs[p:GetId()] = nil
		self.faceCSOs[p:GetId()] = ClientStaticObject.Create({
		position = p:GetBonePosition("ragdoll_Spine"),
		angle = Angle(),
		model = glasses[CheckSocial(p, "SOCIAL_Face")]})
	end
end
function Social:CheckBack(p)
	if CheckSocial(p, "SOCIAL_Back") and not self.backCSOs[p:GetId()] then
		if not backpacks[CheckSocial(p, "SOCIAL_Back")] then return end
		self.backCSOs[p:GetId()] = ClientStaticObject.Create({
		position = p:GetBonePosition("ragdoll_Head"),
		angle = Angle(),
		model = backpacks[CheckSocial(p, "SOCIAL_Back")]})
	elseif not CheckSocial(p, "SOCIAL_Back") and IsValid(self.backCSOs[p:GetId()]) then
		self.backCSOs[p:GetId()]:Remove()
		self.backCSOs[p:GetId()] = nil
	elseif CheckSocial(p, "SOCIAL_Back")
	and self.backCSOs[p:GetId()]:GetModel() ~= backpacks[CheckSocial(p, "SOCIAL_Back")] then
		self.backCSOs[p:GetId()]:Remove()
		self.backCSOs[p:GetId()] = nil
		self.backCSOs[p:GetId()] = ClientStaticObject.Create({
		position = p:GetBonePosition("ragdoll_Spine"),
		angle = Angle(),
		model = backpacks[CheckSocial(p, "SOCIAL_Back")]})
	end
end
function Social:CheckHand(p)
	if CheckSocial(p, "SOCIAL_Hand") and not self.handCSOs[p:GetId()] then
		if not hand[CheckSocial(p, "SOCIAL_Hand")] then return end
		self.handCSOs[p:GetId()] = ClientStaticObject.Create({
		position = p:GetBonePosition("ragdoll_Head"),
		angle = Angle(),
		model = hand[CheckSocial(p, "SOCIAL_Hand")]})
		if CheckSocial(p, "SOCIAL_Hand") == "Mirror" and not self.handCSOs2[p:GetId()] then
			self.handCSOs2[p:GetId()] = ClientStaticObject.Create({
			position = p:GetBonePosition("ragdoll_Head"),
			angle = Angle(),
			model = hand[CheckSocial(p, "SOCIAL_Hand")]})
		end
	elseif not CheckSocial(p, "SOCIAL_Hand") and IsValid(self.handCSOs[p:GetId()]) then
		self.handCSOs[p:GetId()]:Remove()
		self.handCSOs[p:GetId()] = nil
		if IsValid(self.handCSOs2[p:GetId()]) then
			self.handCSOs2[p:GetId()]:Remove()
			self.handCSOs2[p:GetId()] = nil
		end
	elseif CheckSocial(p, "SOCIAL_Hand")
	and self.handCSOs[p:GetId()]:GetModel() ~= hand[CheckSocial(p, "SOCIAL_Hand")] then
		self.handCSOs[p:GetId()]:Remove()
		self.handCSOs[p:GetId()] = nil
		if IsValid(self.handCSOs2[p:GetId()]) then
			self.handCSOs2[p:GetId()]:Remove()
			self.handCSOs2[p:GetId()] = nil
		end
		self.handCSOs[p:GetId()] = ClientStaticObject.Create({
		position = p:GetBonePosition("ragdoll_Spine"),
		angle = Angle(),
		model = hand[CheckSocial(p, "SOCIAL_Hand")]})
		if CheckSocial(p, "SOCIAL_Hand") == "Mirror" and not self.handCSOs2[p:GetId()] then
			self.handCSOs2[p:GetId()] = ClientStaticObject.Create({
			position = p:GetBonePosition("ragdoll_Head"),
			angle = Angle(),
			model = tostring(hand[CheckSocial(p, "SOCIAL_Hand")])})
		end
	end
end
function Social:GetPlayers()
	for id, p in pairs(self.players) do
		if not IsValid(p) then
			self.players[id] = nil
			if IsValid(self.handCSOs[id]) then self.handCSOs[id]:Remove() self.handCSOs[id] = nil end
			if IsValid(self.hatCSOs[id]) then self.hatCSOs[id]:Remove() self.hatCSOs[id] = nil end
			if IsValid(self.faceCSOs[id]) then self.faceCSOs[id]:Remove() self.faceCSOs[id] = nil end
			if IsValid(self.backCSOs[id]) then self.backCSOs[id]:Remove() self.backCSOs[id] = nil end
			if IsValid(self.disCSOs[id]) then self.disCSOs[id]:Remove() self.disCSOs[id] = nil end
			if IsValid(self.handCSOs2[id]) then self.handCSOs2[id]:Remove() self.handCSOs2[id] = nil end
		end
	end
	for p in Client:GetStreamedPlayers() do
		if not self.players[p:GetId()] then self.players[p:GetId()] = p end
		self:CheckDisguise(p)
		self:CheckHat(p)
		self:CheckFace(p)
		self:CheckBack(p)
		self:CheckHand(p)
	end
	if not self.players[LocalPlayer:GetId()] then self.players[LocalPlayer:GetId()] = LocalPlayer end
	self:CheckDisguise(LocalPlayer)
	self:CheckHat(LocalPlayer)
	self:CheckFace(LocalPlayer)
	self:CheckBack(LocalPlayer)
	self:CheckHand(LocalPlayer)
	if table.count(self.players) > 0 and not self.renderSub then
		self.renderSub = Events:Subscribe("PostTick", self, self.PostTick)
	elseif table.count(self.players) == 0 and self.renderSub then
		Events:Unsubscribe(self.renderSub)
		self.renderSub = nil
	end
end
function Social:PostTick()
	for id, p in pairs(self.players) do
		self:MoveSocial(id)
	end
end
function Social:Unload()
	for id, obj in pairs(self.disCSOs) do
		if IsValid(obj) then obj:Remove() end
	end
	for id, obj in pairs(self.hatCSOs) do
		if IsValid(obj) then obj:Remove() end
	end
	for id, obj in pairs(self.faceCSOs) do
		if IsValid(obj) then obj:Remove() end
	end
	for id, obj in pairs(self.backCSOs) do
		if IsValid(obj) then obj:Remove() end
	end
	for id, obj in pairs(self.handCSOs) do
		if IsValid(obj) then obj:Remove() end
	end
	for id, obj in pairs(self.handCSOs2) do
		if IsValid(obj) then obj:Remove() end
	end
end
function Social:MoveSocial(id)
	local p = self.players[id]
	local disCSO = self.disCSOs[id]
	local hatCSO = self.hatCSOs[id]
	local faceCSO = self.faceCSOs[id]
	local backCSO = self.backCSOs[id]
	local handCSO = self.handCSOs[id]
	if not IsValid(p) then return end
	if IsValid(disCSO) then
		local angle = p:GetBoneAngle("ragdoll_Spine1")
		disCSO:SetPosition(p:GetBonePosition("ragdoll_Spine1") - Vector3(0,1.25,0))
		disCSO:SetAngle(angle)
		if IsValid(hatCSO) then
			hatCSO:SetPosition(p:GetPosition() - Vector3(0,1000,0))
		end
		if IsValid(faceCSO) then
			faceCSO:SetPosition(p:GetPosition() - Vector3(0,1000,0))
		end
		if IsValid(backCSO) then
			backCSO:SetPosition(p:GetPosition() - Vector3(0,1000,0))
		end
		if IsValid(handCSO) then
			handCSO:SetPosition(p:GetPosition() - Vector3(0,1000,0))
		end
		if IsValid(self.handCSOs2[id]) then
			self.handCSOs2[id]:SetPosition(p:GetPosition() - Vector3(0,1000,0))
		end
	else
		if IsValid(hatCSO) then
			hatCSO:SetAngle(p:GetBoneAngle("ragdoll_Head"))
			local hatoffset = hatCSO:GetAngle() * Vector3(0,1.62,.03)
			hatCSO:SetPosition(p:GetBonePosition("ragdoll_Head") - hatoffset) 
		end
		if IsValid(faceCSO) then
			faceCSO:SetAngle(p:GetBoneAngle("ragdoll_Head"))
			local hatoffset = faceCSO:GetAngle() * Vector3(0,1.64,.0325)
			faceCSO:SetPosition(p:GetBonePosition("ragdoll_Head") - hatoffset) 
		end
		if IsValid(backCSO) then
			backCSO:SetAngle(p:GetBoneAngle("ragdoll_Spine1"))
			local f = 0
			if backCSO:GetModel() == backpacks["Backpack"] then
				f = 0.03
			end
			local hatoffset = backCSO:GetAngle() * Vector3(0,1.25,f)
			backCSO:SetPosition(p:GetBonePosition("ragdoll_Spine1") - hatoffset) 
		end
		if IsValid(handCSO) then
			if handCSO:GetModel() == hand["Small Pillow"] then
				handCSO:SetAngle(p:GetBoneAngle("ragdoll_AttachHandLeft") * Angle(0,math.pi/2,0))
				handCSO:SetPosition(p:GetBonePosition("ragdoll_AttachHandLeft") + p:GetBoneAngle("ragdoll_AttachHandLeft") * Vector3(-0.2,-0.025,0.03))
			elseif handCSO:GetModel() == hand["Yellow Pillow"] or handCSO:GetModel() == hand["Pink Pillow"] then
				handCSO:SetAngle(p:GetBoneAngle("ragdoll_AttachHandLeft") * Angle(0,math.pi/2,0))
				handCSO:SetPosition(p:GetBonePosition("ragdoll_AttachHandLeft") + p:GetBoneAngle("ragdoll_AttachHandLeft") * Vector3(-0.25,-0.075,0.03))
			elseif handCSO:GetModel() == hand["Mirror"] then
				handCSO:SetAngle(p:GetBoneAngle("ragdoll_AttachHandLeft") * Angle(0, 1.57, 0) * Angle(0,math.pi/2,0))
				handCSO:SetPosition(p:GetBonePosition("ragdoll_AttachHandLeft") + p:GetBoneAngle("ragdoll_AttachHandLeft") * Vector3(-0.3,-0.025,0.03))
				local handCSO2 = self.handCSOs2[id]
				if IsValid(handCSO2) then
					handCSO2:SetPosition(p:GetBonePosition("ragdoll_AttachHandLeft") + p:GetBoneAngle("ragdoll_AttachHandLeft") * Vector3(-0.3,-0.025,0.03))
					handCSO2:SetAngle(p:GetBoneAngle("ragdoll_AttachHandLeft") * Angle(0, 1.57, 0) * Angle(0,3 * math.pi/2,0))
				end
			end
		end
	end
end
Social = Social()