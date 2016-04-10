class 'GMI'

function GMI:__init()
	
end

function GMI:PlyAttemptBuy(args, player) -- receives item
	if not reference[args.item] or not item_price[args.item] then
		player:Kick("Client Shared data is corrupt - Error Code #1")
	end
	local ply_money = player:GetMoney() or 0
	if ply_money >= item_price[args.item] then
		player:SetMoney(ply_money - item_price[args.item])
		Network:Send(player, "GiveGMIItem", {item = args.item})
	else
		player:SendChatMessage("Not enough credits to buy item")
	end
end

gmi = GMI()

Network:Subscribe("GMIBuy", gmi, gmi.PlyAttemptBuy)