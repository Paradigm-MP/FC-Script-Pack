trade_zones = {}
trade_zones[1] = Vector3(-9098.20, 585.9965, 4187.05)
trade_zones[2] = Vector3(-7502.546, 206.96, -4128.777)
trade_zones[3] = Vector3(1087.676, 202.54, 1125.976)
trade_zones[4] = Vector3(10813.279, 202.77, -8506.759)
trade_zones[5] = Vector3(7247.078, 822.935, -1166.325)
trade_zones[6] = Vector3(-4927.674, 214.876, 3050.660)
trade_zones[7] = Vector3(-14709.128906, 188.288757, 14957.080078)--noob island
function ChatHandl(args)
	if args.text:find("/tradezone") then
		if args.player:GetValue("NT_TagName") == "[Admin]" then
			args.player:SetPosition(trade_zones[tonumber(string.match(args.text, '%d+'))])
			return false
		end
	end
end
Events:Subscribe("PlayerChat", ChatHandl)

class 'TradeZone'

function TradeZone:__init()
	
end

function TradeZone:ChangeCanHit(args, player)
	player:SetNetworkValue("CanHit", args.can_hit)
	player:SetNetworkValue("TZ", args.tz)
	--Chat:Broadcast("Can Hit is now: " .. tostring(args.can_hit), Color(0, 255, 0))
end

function TradeZone:OnClientModuleLoad(args)
	args.player:SetNetworkValue("CanHit", true)
end

tradezone = TradeZone()

Network:Subscribe("ChangeCanHit", tradezone, tradezone.ChangeCanHit)
Events:Subscribe("ClientModuleLoad", tradezone, tradezone.OnClientModuleLoad)