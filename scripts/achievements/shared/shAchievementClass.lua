GlobalAchievementTable = {}
GlobalAchievementTableIndexed = {}

class "Achievement"

function Achievement:__init(dispname, codename, achtype, maxprogress, image, description)
	self.dispname = dispname
	if string.match(codename, "~") or string.match(codename, "|") then
		error("NO. DON'T TRY TO BREAK ME. I AM UNBREAKABLE.")
	end
	self.codename = codename
	self.achtype = achtype
	self.maxprogress = maxprogress
	self.b64img = image
	self.description = description
	GlobalAchievementTableIndexed[self.codename] = self
	table.insert(GlobalAchievementTable, self)
end

function Achievement:ToTable()
	local rettable = {}
	rettable.dispname = self.dispname
	rettable.codename = self.codename
	rettable.achtype = self.achtype
	rettable.maxprogress = self.maxprogress
	return rettable
end

function Achievement.GetByCodename(name)
	for _, ach in pairs(GlobalAchievementTable) do
		if ach.codename == name then
			return ach
		end
	end
	return nil
end

class "AchievementInstance"

function AchievementInstance:__init(baseach, progress)
	self.parent = baseach
	self.progress = progress
end

function AchievementInstance:IsComplete()
	if self.parent.achtype == AchievementType.Boolean then
		return self.progress == true
	elseif self.parent.achtype == AchievementType.Progressive then
		return self.progress >= self.parent.maxprogress
	else
		error("[CRITICAL] An achievement was of a type that is not implemented!")
	end
end

function AchievementInstance:GetProgress()
	if self.parent.achtype == AchievementType.Boolean then
		return self.progress
	elseif self.parent.achtype == AchievementType.Progressive then
		return self.progress
	else
		error("[CRITICAL] An achievement was of a type that is not implemented!")
	end
end

function AchievementInstance:SetProgress(newprog)
	if self.parent.achtype == AchievementType.Boolean then
		if type(newprog) == "boolean" then
			self.progress = newprog
		else
			error("[CRITICAL] Attempted to set an achievement to an invalid type!")
		end
	elseif self.parent.achtype == AchievementType.Progressive then
		if type(newprog) == "number" then
			self.progress = newprog
		else
			error("[CRITICAL] Attempted to set an achievement to an invalid type!")
		end
	else
		error("[CRITICAL] An achievement was of a type that is not implemented!")
	end
end

function AchievementInstance:Pickle()
	local progstr = tostring(self.progress)
	
	if self.progress == true then
		progstr = "COMPLETE"
	end
	
	return self.parent.codename .. "~" .. progstr
end

function AchievementInstance:ToTable()
	local rettable = self.parent:ToTable()
	rettable.progress = self.progress
	return rettable
end

function AchievementInstance:__tostring()
	local retstring = self.parent.dispname .. " (" .. self.parent.codename .. "): "
	if self.parent.achtype == AchievementType.Boolean then
		retstring = retstring .. tostring(self.progress)
	elseif self.parent.achtype == AchievementType.Progressive then
		retstring = retstring .. tostring(self.progress) .. " / " .. tostring(self.parent.maxprogress)
	else
		error("[CRITICAL] An achievement was of a type that is not implemented!")
	end
	
	if self:IsComplete() then
		retstring = retstring .. " (Complete)"
	else
		retstring = retstring .. " (Incomplete)"
	end
	
	return retstring
end

function AchievementInstance.FromPickle(str)
	if str == "" then return nil end
	
	local parts = string.split(str, "~")
	
	local baseach = Achievement.GetByCodename(parts[1])
	assert(baseach != nil, "[CRITICAL] Attempted to create an achievement that hadn't been registered!")
	
	local prog = parts[2]
	if baseach.achtype == AchievementType.Boolean then
		if parts[2] == "COMPLETE" then
			prog = true
		else
			prog = false
		end
	end
	
	if baseach.achtype == AchievementType.Progressive then
		prog = tonumber(prog)
	end
	
	return AchievementInstance(baseach, prog)
end


AchievementType = {Boolean = 1, Progressive = 2}

--params: dispname, codename, achtype, maxprogress, image, description (if achtype is bool, you can leave maxprogress as a nil)
Achievement("Open Your Inventory",
			"ach_openinv",
			AchievementType.Boolean,
			nil, --maxprogress
			nil, --IMG
			"Complete by opening your inventory!  Easy, right?")
Achievement("Loot 100 items",
			"ach_loot100",
			AchievementType.Progressive,
			100,
			nil,
			"You found some lootboxes")
Achievement("Loot 1,000 items",
			"ach_loot1000",
			AchievementType.Progressive,
			1000,
			nil,
			"You're starting to memorize where to look")
Achievement("Loot 10,000 items",
			"ach_loot10000",
			AchievementType.Progressive,
			10000,
			nil,
			"You know all the best spots")
Achievement("Kill 50 players",
			"ach_kill50",
			AchievementType.Progressive,
			50,
			nil,
			"Sometimes it just happens")
Achievement("Kill 250 players",
			"ach_kill200",
			AchievementType.Progressive,
			200,
			nil,
			"For the casual survivalist")
Achievement("Kill 1,000 players",
			"ach_kill1000",
			AchievementType.Progressive,
			1000,
			nil,
			"Are you a killing machine?")
Achievement("Kill a member of the server staff",
			"ach_killstaff",
			AchievementType.Boolean,
			nil,
			nil,
			"Bite the hand that feeds you")

-- add level achievements
exp_add = {}
exp_add["ach_openinv"] = 250
exp_add["ach_loot100"] = 7000
exp_add["ach_loot1000"] = 20000
exp_add["ach_loot10000"] = 125000
exp_add["ach_kill50"] = 20000
exp_add["ach_kill200"] = 80000
exp_add["ach_kill1000"] = 350000
exp_add["ach_killstaff"] = 10000 
--
credits_add = {}
credits_add["ach_openinv"] = 75
credits_add["ach_loot100"] = 500
credits_add["ach_loot1000"] = 4500
credits_add["ach_loot10000"] = 15000
credits_add["ach_kill50"] = 2500
credits_add["ach_kill200"] = 12500
credits_add["ach_kill1000"] = 35000
credits_add["ach_killstaff"] = 500




