class 'Exp'
function Exp:__init()
	linear = 45
	exponent = 2.3
	debugOn = false
	noob_island = Vector3(-14709, 202, 14957) --noob island
	Events:Subscribe("PlayerChat", self, self.Chat)
	Events:Subscribe("PlayerDeath", self, self.Death)
	Events:Subscribe("KickDeath", self, self.Death)
	Events:Subscribe("Exp_CompleteCraft", self, self.CompleteCraft)
	Events:Subscribe("Exp_OutsideModule", self, self.AddExpOutside)
	Events:Subscribe("LC_AddExpOnObjectDestroy", self, self.AddExpObjectDestroy)
	Events:Subscribe("Exp_AchievementGet", self, self.AddExpAchievement)
	--
	Network:Subscribe("GetRandomExp", self, self.GetRandomExp)
end
function Exp:AddExpAchievement(args)
	if not args.achname and args.player then return end
	local expAdd = exp_add[args.achname]
	if not expAdd then return end
	local curExp = tonumber(args.player:GetValue("Experience"))
	args.player:SetNetworkValue("Experience", curExp + expadd)
	self:CheckIfGainedLevel(args.player)
	if credits_add[args.achname] then
		args.player:SetMoney(args.player:GetMoney() + credits_add[args.achname])
	end
end
function Exp:AddExpObjectDestroy(args)
	if not IsValid(args.player) then return end
	local sender = args.player
	local level = tonumber(sender:GetValue("Level"))
	local curExp = tonumber(sender:GetValue("Experience"))
	if not level or not curExp then return end
	local rarity = (6 - rarity[args.name]) * (6 - rarity[args.name])
	local hpadd = args.maxhp / 100
	local explin = level * 10
	local expadd = (explin * hpadd * rarity)
	sender:SetNetworkValue("Experience", curExp + expadd)
	self:CheckIfGainedLevel(sender)
end
function Exp:AddExpOutside(args)
	if not args.sender or not args.tier then return end
	local sender = args.sender
	local level = tonumber(sender:GetValue("Level"))
	local curExp = tonumber(sender:GetValue("Experience"))
	if not level or not curExp then return end
	local explin = level * 7.5
	local expadd = (explin * args.tier) / 2
	sender:SetNetworkValue("Experience", curExp + expadd)
	self:CheckIfGainedLevel(sender)
end
function Exp:CompleteCraft(args)
	local sender = args.sender
	local item = args.item
	local bonus = args.bonus
	if not IsValid(sender) or not item then return end
	local level = tonumber(sender:GetValue("Level"))
	local curExp = tonumber(sender:GetValue("Experience"))
	local rarityL = rarity[item]
	if not level or not rarityL or not curExp then return end
	local mult = 6 - (rarityL)
	local explin = level * bonus
	local expadd = explin * mult
	sender:SetNetworkValue("Experience", curExp + expadd)
	self:CheckIfGainedLevel(sender)
end
function Exp:Chat(args)
	local text = args.text:split(" ")
	local target = args.player
	if #text == 3 and (args.player:GetValue("NT_TagName") == "[Admin]" or args.player:GetValue("NT_TagName") == "[Mod]") and (text[1] == "/exp" or text[1] == "/level") then
		target = Player.GetById(tonumber(text[3]))
		if not IsValid(target) then return end
	end
 
	local value = tonumber(text[2])
	if text[1] == "/level" and value and args.player:GetValue("NT_TagName") == "[Admin]" then
		target:SetNetworkValue("Level", value)
		local newMax = CalcMaxExp:Calculate(value)
		target:SetNetworkValue("ExperienceMax", newMax)
		target:SetNetworkValue("Experience", 0)
		return false
	elseif text[1] == "/exp" and value and (args.player:GetValue("NT_TagName") == "[Admin]" or args.player:GetValue("NT_TagName") == "[Mod]") then
		target:SetNetworkValue("Experience", value + target:GetValue("Experience"))
		self:CheckIfGainedLevel(target)
		return false
	end
end
function Exp:CheckIfGainedLevel(player)
	if not IsValid(player) then return end
	local CurExp = tonumber(player:GetValue("Experience"))
	local MaxExp = tonumber(player:GetValue("ExperienceMax"))
	local Level = tonumber(player:GetValue("Level"))
	if CurExp and MaxExp and CurExp >= MaxExp and Level < 200 then
		self:GainLevel(player)
	elseif Level >= 200 then
		player:SetNetworkValue("Level", 200)
		player:SetNetworkValue("Experience", 1)
	end
end
function Exp:GainLevel(player)
	local level = player:GetValue("Level")
	local level_new = tonumber(level) + 1
	local CurExp = player:GetValue("Experience")
	local MaxExp = player:GetValue("ExperienceMax")
	local newExp = CurExp - MaxExp
	local newMax = CalcMaxExp:Calculate(level_new)
	player:SetNetworkValue("Level", level_new)
	player:SetNetworkValue("ExperienceMax", newMax)
	Events:Fire("Exp_GainLevel", {player = player, level = level_new})
	player:SetNetworkValue("Experience", newExp)
	local iPoints = player:GetValue("IP")
	if iPoints == nil then
		iPoints = 0
	end
	local resets = player:GetValue("IP_Resets")
	if resets then
		if level_new == 25 
		or level_new == 50 
		or level_new == 75 
		or level_new == 100 
		or level_new == 125 
		or level_new == 150 
		or level_new == 175 
		or level_new == 200 then
			resets = resets + 1
			player:SetNetworkValue("IP_Resets", resets)
		end
		player:SetNetworkValue("IP", iPoints + level_new)
	end
	Network:SendNearby(player, "Exp_PlayerGainLevel", player)
	Network:Send(player, "Exp_PlayerGainLevel", player)
	--if debugOn then Chat:Broadcast(tostring(player).." is now level "..tostring(level_new), Color(255,255,255)) end
	print(tostring(player).." is now level "..tostring(level_new))
	self:CheckIfGainedLevel(player)
end
function Exp:Death(args)
	--print(args.killer,args.player)
	if args.killer and args.player and args.killer ~= args.player then
		--print("money")
		local ipK = args.killer:GetIP()
		local ipP = args.player:GetIP()
		local sameIp = 0
		if ipK == ipP then
			sameIp = 1
		end
		local killerLVL = args.killer:GetValue("Level")
		local playerLVL = args.player:GetValue("Level")
		local mult = args.player:GetValue("Multiplier")
		if not mult then
			mult = 1
		end
		local diff = tonumber(playerLVL) - tonumber(killerLVL)
		if diff < 0 then
			diff = 0
		end
		if diff > 50 then diff = 50 end
		local expGain1 = math.pow(2,playerLVL/20)
		local expGain2 = playerLVL * 12
		local expGain3 = playerLVL * diff
		local expGain = mult * ( expGain1 + expGain2 + expGain3 )
		if sameIp == 1 then
			expGain = expGain / mult / tonumber(killerLVL)
			print("[WARN] Same IP between killer ("..tostring(ipK)..") and player ("..tostring(ipP).."), multiplier deducted and experience lessened.")
		end
		local moneyAdd = 100
		if tonumber(args.player:GetValue("Experience")) == 0 then
			expGain = playerLVL
			moneyAdd = 1
		end
		local curExp = args.killer:GetValue("Experience")
		local newKexp = curExp + expGain
		args.killer:SetMoney(args.killer:GetMoney() + 100)
		args.killer:SetNetworkValue("Experience", newKexp)
		self:CheckIfGainedLevel(args.killer)
		if tonumber(playerLVL) > 10 then
			args.player:SetNetworkValue("Experience", 0)
		end
		local pExp = args.player:GetValue("Experience")
		--if debugOn then Chat:Broadcast("[INFO] "..tostring(args.killer).." [Level "..tostring(killerLVL).."] gained "..tostring(math.floor(expGain)).." exp by killing "..tostring(args.player).." [Level "..tostring(playerLVL).."]", Color(255,255,255)) end
		--if debugOn then Chat:Broadcast(""..tostring(args.player).." [Level "..tostring(playerLVL).."] died and lost "..tostring(math.floor(pExp)).." experience", Color(255,255,255)) end
		print("[INFO] "..tostring(args.killer).." [Level "..tostring(killerLVL).."] gained "..tostring(math.floor(expGain)).." exp by killing "..tostring(args.player).." [Level "..tostring(playerLVL).."]")
	elseif args.player then
		local exper = tonumber(args.player:GetValue("Experience"))
		local lvl = tonumber(args.player:GetValue("Level"))
		if not exper then
			exper = 0
		end
		if not lvl then
			lvl = 1
		end
		if lvl > 10 then
			args.player:SetNetworkValue("Experience", 0)
		end
		--if debugOn then Chat:Broadcast(""..tostring(args.player).." [Level "..tostring(lvl).."] died and lost "..tostring(math.floor(exper)).." experience", Color(255,255,255)) end
		--if debugOn then print(""..tostring(args.player).." [Level "..tostring(lvl).."] died and lost "..tostring(math.floor(exper)).." experience") end
	end
end

function Exp:GetRandomExp(args, player)
	player:SetNetworkValue("Experience", args.xp + player:GetValue("Experience"))
	self:CheckIfGainedLevel(player)
end
Exp = Exp()