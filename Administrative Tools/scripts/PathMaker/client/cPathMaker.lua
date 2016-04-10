class 'PathMaker'

function PathMaker:__init()
	existing_paths = {}
	path = {}
end

function PathMaker:KeyUp(args)
	if LocalPlayer:GetValue("PathMaking") == true then
		if args.key == 96 then
			Network:Send("AddCoord", {pos = LocalPlayer:GetPosition()})
		elseif args.key == string.byte("6") and closest then
			Network:Send("RemoveCoord", {index = closest})
		end
	end
end

function PathMaker:Render()
	plypos = LocalPlayer:GetPosition()
	local smallest_dist = math.huge
	for name, data in pairs(existing_paths) do
		local prev = data.coords[1]
		for index, point in pairs(data.coords) do
			Render:DrawLine(prev, point, data.color)
			if Vector3.Distance(plypos, point) < 50 then
				if closest and closest_pos == point then
					Render:FillCircle(Render:WorldToScreen(point), 10, data.color)
				else
					Render:FillCircle(Render:WorldToScreen(point), 10, data.color)
				end
			end
			prev = point
		end
	end
	--
	local prev
	if #path > 0 then prev = path[1] end
	for index, point in pairs(path) do
		Render:DrawLine(prev, point, Color(0, 255, 0))
		if Vector3.Distance(plypos, point) < 50 then
			if closest and closest_pos == point then
				Render:FillCircle(Render:WorldToScreen(point), 10, Color(255, 0, 0))
			else
				Render:FillCircle(Render:WorldToScreen(point), 10, Color(25, 255, 25))
			end
		end
		prev = point
	end
	
	local size = Render.Size
	if closest then
		local screen_size = Render.Size
		local w = Render:GetTextWidth("Press ' 6 ' to delete coordinate", TextSize.Default * 1.25)
		Render:DrawText(Vector2(screen_size.x - w, screen_size.y * .05), "Press ' 6 ' to delete coordinate", Color(255, 255, 0, 200), TextSize.Default * 1.25)
	end
end

function PathMaker:GetUpdatedPath(args)
	path = nil
	path = args.path
end

function PathMaker:GetExistingPaths(args)
	existing_paths = args.paths
end

function PathMaker:GetClosestPoint()
	--closest_index = nil
	--closest_name = nil
	closest_pos = nil
	closest = nil
	local pos = LocalPlayer:GetPosition()
	local smallest_dist = math.huge
	--for name, coord_table in pairs(existing_paths) do
		--for index, point in pairs(coord_table) do
		--	local dist = Vector3.Distance(pos, point)
		--	if dist < smallest_dist and dist < 50 then
		--		smallest_dist = dist
		--		closest_name = name
		--		closest_index = index
		--		closest = point
		--	end
		--end
	--end
	
	for index, point in pairs(path) do
		local dist = Vector3.Distance(pos, point)
		if dist < smallest_dist and dist < 50 then
			smallest_dist = dist
			--closest_name = name
			--closest_index = index
			closest = index
			closest_pos = point
		end
	end
end

function PathMaker:LocalPlayerChat(args)
	if args.text == "/end" and LocalPlayer:GetValue("PathMaking") == true then
		Chat:Print("You must specify a file name after /end", Color(255, 255, 0))
		Chat:Print("for example: /end PiaZombies", Color(255, 255, 0))
		return false
	end
end


paths = PathMaker()

Events:Subscribe("KeyUp", paths, paths.KeyUp)
Events:Subscribe("Render", paths, paths.Render)
Events:Subscribe("LocalPlayerChat", paths, paths.LocalPlayerChat)
Events:Subscribe("SecondTick", paths, paths.GetClosestPoint)
--
Network:Subscribe("ExistingPaths", paths, paths.GetExistingPaths)
Network:Subscribe("UpdatePath", paths, paths.GetUpdatedPath)