class 'Exchange'

function Exchange:__init()
	trades = {}
end

function Exchange:ClientModuloLoad(args)
	args.player:SetNetworkValue("WillTrade", true)
	args.player:SetNetworkValue("TradeBusy", false)
end

function Exchange:BoolFlipWillTrade(args, player)
	player:SetNetworkValue("WillTrade", not player:GetValue("WillTrade"))
	--Chat:Broadcast("Will Trade: " .. tostring(player:GetValue("WillTrade")), Color(0, 255, 0))
end

function Exchange:RequestTrade(args, player) -- receives ply_id
	local other_ply = Player.GetById(args.ply_id)
	if not other_ply or other_ply:GetValue("TradeBusy") == true then
		player:SendChatMessage("Other player is busy", Color(255, 255, 0))
		return
	end
	--
	player:SetValue("TradeBusy", true) -- serverside ply val
	Network:Send(other_ply, "ConfirmRequestTrade", {requester = player:GetId()})
end

function Exchange:RespondToRequest(args, player) -- receives ply_id(of requester), accept(true/false/"afk")
	local ply = Player.GetById(args.ply_id)
	if not ply then return end
	if args.accept == true then
		Network:Send(ply, "StartTrade", {ply_id = player:GetId()})
	elseif args.accept == false then
		ply:SetValue("TradeBusy", false)
		player:SetValue("TradeBusy", false)
		ply:SendChatMessage("Other player denied trade request", Color(255, 255, 0))
	elseif args.accept == "afk" then 
		ply:SetValue("TradeBusy", false)
		player:SetValue("TradeBusy", false)
		ply:SendChatMessage("Other player did not respond to trade request", Color(255, 255, 0))
	end
end

function Exchange:CancelTrade(args, player)
	player:SetValue("TradeBusy", false)
	local other_ply = Player.GetById(args.ply_id)
	if other_ply then
		other_ply:SetValue("TradeBusy", false)
		Network:Send(other_ply, "ServerCancelledTrade")
	end
end

function Exchange:TradeConfirm(args, player) -- receives ply_id, items
	local ply = Player.GetById(args.ply_id)
	if ply then
		Network:Send(ply, "OtherPlyConfirm", {items = args.items})
	end
end

function Exchange:TradeAccept(args, player) -- receives ply_id
	local ply = Player.GetById(args.ply_id)
	if ply then
		Network:Send(ply, "OtherPlyAccept")
	end
end

function Exchange:ExecuteTrade(args, player) -- receives ply_id
	local ply = Player.GetById(args.ply_id)
	if ply then
		ply:SetValue("TradeBusy", false)
		Network:Send(ply, "OtherPlyAcceptExecuteTrade")
	end
	player:SetValue("TradeBusy", false)
	
end

exchange = Exchange()

Events:Subscribe("ClientModuleLoad", exchange, exchange.ClientModuloLoad)
--
Network:Subscribe("ChangeWillTrade", exchange, exchange.BoolFlipWillTrade)
Network:Subscribe("RequestTrade", exchange, exchange.RequestTrade)
Network:Subscribe("RespondToRequest", exchange, exchange.RespondToRequest)
Network:Subscribe("CancelTrade", exchange, exchange.CancelTrade)
Network:Subscribe("TradeConfirm", exchange, exchange.TradeConfirm)
Network:Subscribe("TradeAccept", exchange, exchange.TradeAccept)
Network:Subscribe("ExecuteTrade", exchange, exchange.ExecuteTrade)