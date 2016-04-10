class 'PosManager'

function PosManager:__init()
	timer = Timer()
	ShowAxes = false
	ShowTrespass = false
	counter = 0
end

function PosManager:RenderLine()

if ShowAxes == true then
	local pos = Camera:GetPosition()
	Render:DrawLine(Vector3(pos.x + 100, pos.y - .5, pos.z), Vector3(pos.x - 100, pos.y - .5, pos.z), Color(255, 255, 0))
	Render:DrawLine(Vector3(pos.x, pos.y - .5, pos.z + 100), Vector3(pos.x, pos.y - .5, pos.z - 100), Color(255, 0, 0))
end

end

function PosManager:ChatHandle(args)

	if args.text == "/axes" then
		ShowAxes = not ShowAxes
	end
	
end

check = PosManager()

Events:Subscribe("Render", check, check.RenderLine)
Events:Subscribe("LocalPlayerChat", check, check.ChatHandle)