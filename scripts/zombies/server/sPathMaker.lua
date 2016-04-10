class 'PathMaker'

function PathMaker:__init()
	coords = {}
end

function PathMaker:PlayerChat(args)
	if args.text == "/start" then
		coords[args.player:GetId()] = nil
		coords[args.player:GetId()] = {}
		args.player:SendChatMessage("Started New Path", Color.Green)
		return false
	elseif args.text == "/c" then
		if not coords[args.player:GetId()] then
			args.player:SendChatMessage("You havent started a path yet, type /start", Color.Yellow)
		else
			table.insert(coords[args.player:GetId()], args.player:GetPosition())
			args.player:SendChatMessage("Placed Point #" .. tostring(#coords[args.player:GetId()]), Color.Green)
		end
		return false
	elseif args.text == "/end" then
		if coords[args.player:GetId()] then
			local file = io.open("path" .. tostring(math.random(0, 99999)), "w")
			for _, pos in pairs(coords[args.player:GetId()]) do
				file:write("\n", tostring(pos))
			end
			file:close()
			args.player:SendChatMessage("Path Written to File", Color.Green)
		else
			args.player:SendChatMessage("No path to save", Color.Yellow)
		end
		return false
	end
end

paths = PathMaker()

Events:Subscribe("PlayerChat", paths, paths.PlayerChat)