ShiftTimer = Timer()
function ShiftTimerFunc(args)
	if Key:IsDown(16) then
		LocalPlayer:SetValue("SHIFTING", 1)
	elseif tonumber(LocalPlayer:GetValue("SHIFTING")) == 1 then
		LocalPlayer:SetValue("SHIFTING", 0)
	end
end
function AddHelp()
    Events:Fire( "HelpAddItem",
        {
            name = "Melee",
            text = 
                "There are two types of melee attacks that you can use, and both of them require "..
                "stamina to perform.  The first type is the spin kick, which is used by pressing 'Q' " ..
                "while standing still.  The second type is much more powerful and requires more stamina. "..
				"You can use the second type (the slide kick) by running and then pressing 'Q'."
       } )
end

function RemoveHelp()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Melee"
        } )
end

Events:Subscribe("ModulesLoad", AddHelp)
Events:Subscribe("ModuleUnload", RemoveHelp)
Events:Subscribe("KeyDown", ShiftTimerFunc)
QTimer = Timer()
function HitQ(args)
	if LocalPlayer:GetValue("StaminaReady") then
		local engv = tonumber(Crypt34(tostring(LocalPlayer:GetValue("Melee_Sta_1")))) / 50
		local engv2 = tonumber(Crypt34(tostring(LocalPlayer:GetValue("Melee_Sta_2")))) / 50
		local energyNeeded = 7.5 - engv
		if energyNeeded < 0 then
			energyNeeded = 0
		end
		local energyNeeded2 = 20 - engv2
		if energyNeeded2 < 0 then
			energyNeeded2 = 0
		end
		local velocity2 = -LocalPlayer:GetAngle() * LocalPlayer:GetLinearVelocity()
		local velocityY = -velocity2.y
		local velocity = -velocity2.z
		local pos = LocalPlayer:GetPosition()
		if args.key == string.byte("Q") 
		and QTimer:GetSeconds () > 1.25 
		and not LocalPlayer:InVehicle() 
		and velocityY < 5 
		and pos.y > 200.15 
		and LocalPlayer:GetHealth() > 0 
		and LocalPlayer:GetState() ~= 5 
		and velocity < 15 
		and LocalPlayer:GetValue("CanHit") ~= false
		and LocalPlayer:GetBaseState() ~= 45 
		and LocalPlayer:GetBaseState() ~= 253 
		and LocalPlayer:GetBaseState() ~= 425 
		and LocalPlayer:GetBaseState() ~= 423 
		and LocalPlayer:GetBaseState() ~= 135 
		and LocalPlayer:GetBaseState() ~= 15 
		and LocalPlayer:GetBaseState() ~= 18 
		and LocalPlayer:GetBaseState() ~= 338 
		and LocalPlayer:GetBaseState() ~= 56 
		and LocalPlayer:GetBaseState() ~= 88 
		and LocalPlayer:GetBaseState() ~= 341 
		and LocalPlayer:GetBaseState() ~= 333 
		and LocalPlayer:GetBaseState() ~= 334 
		and LocalPlayer:GetBaseState() ~= 64 
		and LocalPlayer:GetBaseState() ~= 21 
		and LocalPlayer:GetBaseState() ~= 22 
		and LocalPlayer:GetBaseState() ~= 34 
		and LocalPlayer:GetBaseState() ~= 440 
		and LocalPlayer:GetBaseState() ~= 323 
		and LocalPlayer:GetBaseState() ~= 190 
		and LocalPlayer:GetBaseState() ~= 291 
		and LocalPlayer:GetBaseState() ~= 223 
		and LocalPlayer:GetBaseState() ~= 215 
		and LocalPlayer:GetBaseState() ~= 110 
		and LocalPlayer:GetBaseState() ~= 257 
		and LocalPlayer:GetBaseState() ~= 256 
		and LocalPlayer:GetBaseState() ~= 167 
		and LocalPlayer:GetBaseState() ~= 30 
		and LocalPlayer:GetBaseState() ~= 29 
		and LocalPlayer:GetBaseState() ~= 166 
		and LocalPlayer:GetBaseState() ~= 148 
		and LocalPlayer:GetBaseState() ~= 28 
		and LocalPlayer:GetBaseState() ~= 188 
		and LocalPlayer:GetBaseState() ~= 147 
		and LocalPlayer:GetBaseState() ~= 36 
		and LocalPlayer:GetBaseState() ~= 422 
		and LocalPlayer:GetBaseState() ~= 428 
		and LocalPlayer:GetBaseState() ~= 255 
		and LocalPlayer:GetBaseState() ~= 45 
		and LocalPlayer:GetBaseState() ~= 47 
		and LocalPlayer:GetBaseState() ~= 46 
		and LocalPlayer:GetBaseState() ~= 50 
		and LocalPlayer:GetBaseState() ~= 468 
		and LocalPlayer:GetBaseState() ~= 40 
		and LocalPlayer:GetBaseState() ~= 438 
		and LocalPlayer:GetBaseState() ~= 158 
		and LocalPlayer:GetBaseState() ~= 187 
		and LocalPlayer:GetBaseState() ~= 25 
		and LocalPlayer:GetBaseState() ~= 455 
		and LocalPlayer:GetBaseState() ~= 43 
		and LocalPlayer:GetBaseState() ~= 216 
		and LocalPlayer:GetBaseState() ~= 208 
		and LocalPlayer:GetBaseState() ~= 415 
		and LocalPlayer:GetBaseState() ~= 211 
		and LocalPlayer:GetBaseState() ~= 474 
		and LocalPlayer:GetBaseState() ~= 209 
		and LocalPlayer:GetBaseState() ~= 210 
		and LocalPlayer:GetBaseState() ~= 427 
		and LocalPlayer:GetBaseState() ~= 207 
		and LocalPlayer:GetBaseState() ~= 324 
		and LocalPlayer:GetBaseState() ~= 221 
		and LocalPlayer:GetBaseState() ~= 325 
		and LocalPlayer:GetBaseState() ~= 219 
		and LocalPlayer:GetBaseState() ~= 212 
		and LocalPlayer:GetBaseState() ~= 414 
		and LocalPlayer:GetBaseState() ~= 213 
		and LocalPlayer:GetBaseState() ~= 217 
		and LocalPlayer:GetBaseState() ~= 214 
		and LocalPlayer:GetBaseState() ~= 326 
		and LocalPlayer:GetBaseState() ~= 429 
		and LocalPlayer:GetBaseState() ~= 222 
		and LocalPlayer:GetBaseState() ~= 218 
		and LocalPlayer:GetBaseState() ~= 418 
		and LocalPlayer:GetBaseState() ~= 220 
		and LocalPlayer:GetBaseState() ~= 294 
		and LocalPlayer:GetBaseState() ~= 23 
		and LocalPlayer:GetBaseState() ~= 153 
		and LocalPlayer:GetBaseState() ~= 24 
		and LocalPlayer:GetBaseState() ~= 38 
		and LocalPlayer:GetBaseState() ~= 191 
		and LocalPlayer:GetBaseState() ~= 39 
		and LocalPlayer:GetBaseState() ~= 159 
		and LocalPlayer:GetBaseState() ~= 275 
		and LocalPlayer:GetBaseState() ~= 254 then
			if tonumber(LocalPlayer:GetValue("SHIFTING")) == 1 and tonumber(Crypt34(tostring(LocalPlayer:GetValue("Stamina")))) >= energyNeeded2 then
				local seconds = QTimer:GetSeconds ()
				local args = {}
				args.ent = LocalPlayer:GetAimTarget().entity
				args.seconds = seconds
				args.stamina = tonumber(Crypt34(tostring(LocalPlayer:GetValue("Stamina"))))
				args.state = LocalPlayer:GetBaseState()
				for p in Client:GetStreamedPlayers() do
					local dist = Vector3.Distance(p:GetPosition(), LocalPlayer:GetPosition())
					if dist < 6 then
						args.ent = p
						Network:Send("MeleeBigToServer", args)
					end
				end
				LocalPlayer:SetBaseState(312)
				QTimer:Restart()
				Events:Fire("Stamina_DecreaseKick", energyNeeded2)
			elseif tonumber(Crypt34(tostring(LocalPlayer:GetValue("Stamina")))) >= energyNeeded and tonumber(LocalPlayer:GetValue("SHIFTING")) ~= 1 then 
				local seconds = QTimer:GetSeconds ()
				local args = {}
				args.ent = Physics:Raycast(LocalPlayer:GetPosition() + Vector3(0,1.8,0), Camera:GetAngle() * Vector3.Forward, 0, 5).entity
				args.seconds = seconds
				args.stamina = tonumber(Crypt34(tostring(LocalPlayer:GetValue("Stamina"))))
				args.state = LocalPlayer:GetBaseState()
				for p in Client:GetStreamedPlayers() do
					local dist = Vector3.Distance(p:GetPosition(), LocalPlayer:GetPosition())
					if dist < 3 then
						args.ent = p
						Network:Send("MeleeToServer", args)
					end
				end
				LocalPlayer:SetBaseState(311)
				QTimer:Restart()
				Events:Fire("Stamina_DecreaseKick", energyNeeded)
			end
		end
	end
end
Events:Subscribe("KeyDown", HitQ)
function CreateEff(argz)
	if argz then
		local args = {}
		args.effect_id = argz.id
		args.position = argz.pos
		args.angle = LocalPlayer:GetAngle()
		local effect = ClientEffect.Create(AssetLocation.Game, args)
	end
end
Network:Subscribe("QEffect", CreateEff)
function CreateEff2(argz)
	if argz then
		local args = {}
		args.path = "fx_bulhit_flesh_02.psmb"
		args.position = argz.pos
		args.angle = argz.angle
		local effect = ClientParticleSystem.Create(AssetLocation.Game, args)
		args.path = "fx_bulhit_flesh_01.psmb"
		effect = ClientParticleSystem.Create(AssetLocation.Game, args)
		args.path = "fx_bulhit_flesh_03.psmb"
		effect = ClientParticleSystem.Create(AssetLocation.Game, args)
	end
end
Network:Subscribe("QEffect2", CreateEff2)