class 'Scanner'

function Scanner:__init()
	check_view_ticks = 0
	can_open = false
	crafting_open = false
	current_table = -1
	screen_size = Render.Size
	img = Image.Create(AssetLocation.Resource, "LookAtTable")
end

function Scanner:Scan()
	check_view_ticks = check_view_ticks + 1
	if check_view_ticks < 5 then return end
	check_view_ticks = 0
	crafting_open = Crafting:GetOpen()
	if Crafting:GetOpen() == true then return end
	
	local aimtarget = LocalPlayer:GetAimTarget()
	if aimtarget.entity then
		if aimtarget.entity.__type == "StaticObject" then
			if aimtarget.entity:GetModel() == "33x08.flz/go113-a.lod" then
				if Vector3.Distance(LocalPlayer:GetPosition(), aimtarget.entity:GetPosition()) <= 3.75 then
					if aimtarget.entity:GetId() ~= current_table then
						can_open = true
						craftobject = aimtarget.entity
					end
				else
					CloseCrafting()
				end
			else
				CloseCrafting()
			end
		else
			CloseCrafting()
		end
	else
		CloseCrafting()
	end
end

function Scanner:KeyPressScan(args)
	if args.key == string.byte("E") then
		if can_open == true then
			if current_object then
				--Chat:Print("current_object exists", Color(255, 255, 0))
				--if craftobject ~= current_object then
					--Crafting:Open()
					--crafting_open = true
				--else
					if Crafting:GetOpen() == true then
						CloseCrafting()
					elseif Crafting:GetOpen() == false then
						--Chat:Print("Opening", Color(0, 255, 0))
						current_object = craftobject
						Crafting:Open()
						crafting_open = true
					end
				--end
			else
				--Chat:Print("Opening", Color(0, 255, 0))
				current_object = craftobject
				Crafting:Open()
				crafting_open = true
			end
		elseif crafting_open == true then
			CloseCrafting()
		end
	end
end

function Scanner:RenderScan()
	if can_open == true and crafting_open == false and craftobject then
		local pos,t = Render:WorldToScreen(craftobject:GetPosition() + Vector3(0,1.5,0))
		local size = Vector3.Distance(craftobject:GetPosition(),Camera:GetPosition())
		if t then
			img:Draw(pos - (img:GetPixelSize() / 2), img:GetPixelSize(), Vector2(0,0), Vector2(1,1))
		end
		--Render:FillCircle(Vector2(screen_size.x * .5, screen_size.y * .5), 25, Color(0, 255, 0, 200))
	end
end
function setClosed()
	Scanner.crafting_open = false
end
function CloseCrafting()
	Crafting:Close()
	crafting_open = false
	current_table = -1
	can_open = false
	current_object = nil
end
function Loader()
	if LocalPlayer:GetValue("Crafting_Initialized") then
		scanner = Scanner()
		Events:Subscribe("PostTick", scanner, scanner.Scan)
		Events:Subscribe("Render", scanner, scanner.RenderScan)
		Events:Subscribe("KeyDown", scanner, scanner.KeyPressScan)
		Events:Subscribe("Crafting_Closed", setClosed)
		Events:Unsubscribe(sube)
		sube = nil
	end
end
sube = Events:Subscribe("SecondTick", Loader)