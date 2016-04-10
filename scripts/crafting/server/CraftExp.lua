function FireExp(item, sender)
	local args = {item = item, sender = sender, bonus = cRecipes[item].craftReq}
	Events:Fire("Exp_CompleteCraft", args)
end
Network:Subscribe("CompleteCraft_Exp", FireExp)