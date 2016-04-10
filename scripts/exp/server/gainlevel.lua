class 'GainLevel'
function GainLevel(player)
	LevelGain(player)
end
function LevelGain(player)
linear = 45
exponent = 2.3
	local CurExp = tonumber(player:GetValue("Experience"))
	local MaxExp = tonumber(player:GetValue("ExperienceMax"))
		if CurExp and MaxExp then
			if CurExp >= MaxExp then
				local level = player:GetValue("Level")
				local level_new = tonumber(level) + 1
				local newExp = CurExp - MaxExp
				local newMax = (level_new * linear) + math.pow(level_new, exponent)
				player:SetValue("Level", level_new)
				player:SetValue("ExperienceMax", newMax)
				player:SetValue("Experience", newExp)
				local iPoints = player:GetValue("IP")
				if iPoints == nil then
					iPoints = 0
				end
				local resets = player:GetValue("IP_Resets")
				if level_new == 25 
				or level_new == 50 
				or level_new == 75 
				or level_new == 100 
				or level_new == 125 
				or level_new == 150 
				or level_new == 175 
				or level_new == 200 then
					resets = resets + 1
					player:SetValue("IP_Resets", resets)
				end
				player:SetNetworkValue("IP", iPoints + level_new)
				local args = {}
				args.IP_Resets = resets
				args.IP = iPoints + level_new
				args.level = level_new
				args.expmax = newMax
				args.newexp = newExp
				Chat:Broadcast(tostring(player).." is now level "..tostring(level_new), Color(255,255,255))
				Network:Send(player, "LevelUp", args)
				if newExp >= newMax then
					LevelGain(player)
				end
			end
		end
end