class 'Social'
function Social:__init()
	SQL:Execute("CREATE TABLE IF NOT EXISTS social (steamID INTEGER UNIQUE, hat VARCHAR, face VARCHAR, back VARCHAR, hand VARCHAR, wingsuit VARCHAR, disguise VARCHAR, modelid INTEGER)")
	
	Events:Subscribe("PlayerJoin", self, self.Load)
	Events:Subscribe("PlayerQuit", self, self.Save)
	Network:Subscribe("Models_Next", self, self.PlasticSurgery)
	Network:Subscribe("Models_Back", self, self.PlasticSurgery2)
	Network:Subscribe("SOCIAL_Mismatch_NoItem", self, self.Mismatch)
	Network:Subscribe("SOCIAL_ItemEquipUnequip", self, self.ItemEquip)
end
function CheckSocial(p, str)
	if p:GetValue(str) and string.len(tostring(p:GetValue(str))) > 3 then
		return tostring(p:GetValue(str))
	else
		return false
	end
end
function Social:ItemEquip(item, sender)
	local section = FindSection(item)
	if section ~= " " then
		local oldValue = CheckSocial(sender, section)
		if oldValue == item then
			sender:SetNetworkValue(section, " ")
			if FindSection(oldValue) == "SOCIAL_Disguise" then
				sender:SetModelId(disModels[sender:GetId()])
				disModels[sender:GetId()] = nil
			end
			return
		end
		sender:SetNetworkValue(section, item)
		if section == "SOCIAL_Disguise" and not disModels[sender:GetId()] then
			disModels[sender:GetId()] = sender:GetModelId()
			sender:SetModelId(20)
		end
	end
end
function Social:Mismatch(str, sender)
	local section = FindSection(str)
	if section ~= " " then
		sender:SetNetworkValue(section, " ")
		if section == "SOCIAL_Disguise" then
			sender:SetModelId(disModels[sender:GetId()])
		end
	end
end
function FindSection(str)
	for name, model in pairs(hats) do
		if name == str then return "SOCIAL_Hat" end
	end
	for name, model in pairs(glasses) do
		if name == str then return "SOCIAL_Face" end
	end
	for name, model in pairs(backpacks) do
		if name == str then return "SOCIAL_Back" end
	end
	for name, model in pairs(hand) do
		if name == str then return "SOCIAL_Hand" end
	end
	for name, model in pairs(DIS) do
		if name == str then return "SOCIAL_Disguise" end
	end
	if str == "Wingsuit" then return "SOCIAL_Wingsuit" end
	return " "
end
function GetRandomModel()
	nakedmodels = {4,15,17,43,53,81,86,88}
	return table.randomvalue(nakedmodels)
end
function Social:Load(args)
	local cmd = SQL:Query('SELECT steamID FROM social WHERE steamID = ?')
	cmd:Bind(1, args.player:GetSteamId().id)
	local result = cmd:Execute(), nil
	if result[1] == nil then
		local model = GetRandomModel()
		local cmd2 = SQL:Command('INSERT INTO social (steamID, hat, face, back, hand, disguise, wingsuit, modelid) VALUES (?,?,?,?,?,?,?,?)')
		cmd2:Bind(1, args.player:GetSteamId().id)
		cmd2:Bind(2, " ")
		cmd2:Bind(3, " ")
		cmd2:Bind(4, " ")
		cmd2:Bind(5, " ")
		cmd2:Bind(6, " ")
		cmd2:Bind(7, " ")
		cmd2:Bind(8, model)
		cmd2:Execute()
		--print("New player, default social values for social loaded.")
	end
	local query = SQL:Query('SELECT hat, face, back, hand, disguise, wingsuit, modelid FROM social WHERE steamID = ? LIMIT 1')
	query:Bind(1, args.player:GetSteamId().id)
	local result2 = query:Execute()
	args.player:SetNetworkValue("SOCIAL_Hat", result2[1].hat)
	args.player:SetNetworkValue("SOCIAL_Face", result2[1].face)
	args.player:SetNetworkValue("SOCIAL_Back", result2[1].back)
	args.player:SetNetworkValue("SOCIAL_Hand", result2[1].hand)
	args.player:SetNetworkValue("SOCIAL_Disguise", result2[1].disguise)
	args.player:SetNetworkValue("SOCIAL_Wingsuit", result2[1].wingsuit)
	if tonumber(result2[1].modelid) == 20 then
		args.player:SetModelId(GetRandomModel())
	elseif tonumber(result2[1].modelid) == 51 then
		args.player:SetModelId(GetRandomModel())
	elseif CheckDisguise(args.player) then
		disModels[args.player:GetId()] = tonumber(result2[1].modelid)
		args.player:SetModelId(20)
	else
		args.player:SetModelId(tonumber(result2[1].modelid))
	end
	--print("Model Id "..tostring(result2[1].modelid))
end
function CheckDisguise(p)
	if p:GetValue("SOCIAL_Disguise") and string.len(tostring(p:GetValue("SOCIAL_Disguise"))) > 3 then
		return tostring(p:GetValue("SOCIAL_Disguise"))
	else
		return false
	end
end
function Social:Save(args)
	local cmd = SQL:Command('UPDATE social set hat=?,face=?,back=?,hand=?,disguise=?,wingsuit=?,modelid=? WHERE steamID = ?')
	cmd:Bind(1, args.player:GetValue("SOCIAL_Hat"))
	cmd:Bind(2, args.player:GetValue("SOCIAL_Face"))
	cmd:Bind(3, args.player:GetValue("SOCIAL_Back"))
	cmd:Bind(4, args.player:GetValue("SOCIAL_Hand"))
	cmd:Bind(5, args.player:GetValue("SOCIAL_Disguise"))
	cmd:Bind(6, args.player:GetValue("SOCIAL_Wingsuit"))
	if CheckDisguise(args.player) then
		cmd:Bind(7, disModels[args.player:GetId()])
	else
		cmd:Bind(7, args.player:GetModelId())
	end
	cmd:Bind(8, args.player:GetSteamId().id)
	cmd:Execute()
end
function Social:PlasticSurgery(args, sender)
	local modelid = sender:GetModelId()
	modelid = modelid + 1
	if modelid > 103 then modelid = 1 end
	if modelid == 20 then modelid = 21 end
	sender:SetModelId(modelid)
end
function Social:PlasticSurgery2(args, sender)
	local modelid = sender:GetModelId()
	modelid = modelid - 1
	if modelid < 1 then modelid = 103 end
	if modelid == 20 then modelid = 19 end
	sender:SetModelId(modelid)
end
Social = Social()