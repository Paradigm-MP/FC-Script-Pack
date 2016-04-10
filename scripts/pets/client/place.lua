class 'PetDiscover'
function PetDiscover:__init()
	center = Vector3(12264.432617, 264.835358, -3464.809570)
	bottomcenter = Vector3(12264.404297, 212.747620, -3465.803223)
	color = Color(0,191,255)
	Events:Subscribe("Pets_UseCompanionKey", self, self.UseKey)
	Events:Subscribe("ModuleUnload", self, self.Unload)
	timer = Timer()
end
function PetDiscover:UseKey()
	if not LocalPlayer:GetValue("Level") or not LocalPlayer:GetValue("Personality") then return end
	if tonumber(LocalPlayer:GetValue("Personality")) < 0 then
		color = Color(255,85,0)
	end
	if LocalPlayer:GetValue("Pet_Enabled") then
		Events:Fire("DeleteFromInventory", {sub_item = "Companion Key", sub_amount = 1})
		Chat:Print("The wind howls at you, causing you to drop your key.", color)
		return
	end
	local level = tonumber(LocalPlayer:GetValue("Level"))
	if level < 25 then
		Chat:Print("You shiver in the wind. It is not time yet.", color)
		return
	end
	local dist = Vector3.Distance(LocalPlayer:GetPosition(), center)
	if dist > 20000 then
		Chat:Print("The wind howls, but you hear nothing.", color)
	elseif dist > 10000 then
		Chat:Print("The wind howls your name, but you feel nothing.", color)
	elseif dist > 2500 then
		Chat:Print("The wind howls at you, and you feel something.", color)
	elseif dist > 25 then
		Chat:Print("The wind howls for you, and you feel a presence near you.", color)
	else
		Chat:Print("The wind howls with you as the gates of a mysterious place unfold. It is time.", color)
		Game:FireEvent("msy.f3m04Obj03.activated")
		Events:Fire("DeleteFromInventory", {sub_item = "Companion Key", sub_amount = 1})
		secondersub = Events:Subscribe("SecondTick", self, self.CheckTimer)
		timer:Restart()
		if tonumber(LocalPlayer:GetValue("Personality")) > 0 then
			self:CreateBlueFX()
		else
			self:CreateRedFX()
		end
	end
end
function PetDiscover:CheckTimer()
	local dist = Vector3.Distance(LocalPlayer:GetPosition(), bottomcenter)
	local haspet = Pets:Pets_HasPet()
	if dist > 25 and not haspet then timer:Restart() return end
	if timer:GetSeconds() > 10 and not haspet then
		Network:Send("PetSummon")
	elseif timer:GetSeconds() > 15 and haspet and not fire then
		Events:Fire("LoadingScreen_Fire")
		fire = true
	elseif timer:GetSeconds() > 17 and haspet and not camsub then
		Network:Send("Pets_PetRitualComplete")
		Events:Fire("Pets_ShowPetPanel")
		camsub = Events:Subscribe("CalcView", self, self.Cam)
		self:Unload()
		Events:Unsubscribe(secondersub)
		secondersub = nil
	end
end
function PetDiscover:Cam()
	Camera:SetPosition(Vector3(0,500,0))
	if timer:GetSeconds() > 19 then
		Events:Unsubscribe(camsub)
		camsub = nil
	end
	return true
end
function PetDiscover:CreateRedFX()
	effect1 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter,
		path = "cs_helicopter_dust_01.psmb"
		})
	effect2 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter+Vector3(0,0.1,0),
		path = "fx_key02_waterfall_bottom_01.psmb"
		})
	effect3 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter,
		path = "fx_km07_cylinder_l2_fire_08.psmb"
		})
	effect4 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter+Vector3(0,5,0),
		path = "cs_helicopter_dust_01.psmb"
		})
	effect5 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter+Vector3(0,2.5,0),
		path = "cs_helicopter_dust_01.psmb"
		})
	effect6 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter,
		--path = "fx_km07_cylinder_e_01.psmb"
		path = "fx_km07_cylinder_l2_fire_09.psmb"
		})
	effect7 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter+Vector3(0,2,0),
		path = "fx_f2m06_emptoweractive_05.psmb"
		})
	light1 = ClientLight.Create({
		position = bottomcenter + Vector3(0,15,0),
		radius = 25,
		multiplier = 10,
		fade_in_duration = 3,
		fade_out_duration = 3,
		color = Color(255,100,0)
		})
end
function PetDiscover:CreateBlueFX()
	effect1 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter,
		path = "fx_f2m07_sinkinglab_01.psmb"
		})
	effect2 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter+Vector3(0,0.1,0),
		path = "fx_key02_waterfall_bottom_01.psmb"
		})
	effect3 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter,
		path = "fx_km07_cylinder_l2_fire_08.psmb"
		})
	effect4 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter+Vector3(0,5,0),
		path = "cs_helicopter_snow_01.psmb"
		})
	effect5 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter+Vector3(0,2.5,0),
		path = "cs_helicopter_snow_01.psmb"
		})
	effect6 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter+Vector3(0,2,0),
		path = "fx_f2m06_emptoweractive_05.psmb"
		})
	effect7 = ClientParticleSystem.Create(AssetLocation.Game, {
		angle = Angle(0,0,0),
		position = bottomcenter,
		path = "fx_ballonengine_01.psmb"
		})
	light1 = ClientLight.Create({
		position = bottomcenter + Vector3(0,15,0),
		radius = 25,
		multiplier = 10,
		fade_in_duration = 3,
		fade_out_duration = 3,
		color = Color(0,191,255)
		})
end
function PetDiscover:Unload()
	if IsValid(effect1) then effect1:Remove() end
	if IsValid(effect2) then effect2:Remove() end
	if IsValid(effect3) then effect3:Remove() end
	if IsValid(effect4) then effect4:Remove() end
	if IsValid(effect5) then effect5:Remove() end
	if IsValid(effect6) then effect6:Remove() end
	if IsValid(effect7) then effect7:Remove() end
	if IsValid(light1) then light1:Remove() end
end
PetDiscover = PetDiscover()