function Chat:dBroadcast(...)
	for ply in Server:GetPlayers() do
		if ply:GetValue("NT_TagName") == "[Admin]" then
			Chat:Send(ply, table.unpack(table.pack(...)))
		end
	end
end

function dostuff(...)
	local x = 0
	local variables = {}
	local idx = 1
	while true do
		local ln, lv = debug.getlocal(1, idx)
		if ln ~= nil then
			variables[ln] = lv
		else
			break
		end
		idx = 1 + idx
	end
	print(table.count(variables))
	for i, v in pairs(variables) do
		print(tostring(i) .. ": " .. tostring(v))
	end
end

function getlocals()
	local variables = {}
	local idx = 1
	while true do
		local ln, lv = debug.getlocal(2, idx)
		if ln ~= nil then
			variables[ln] = lv
		else
			break
		end
		idx = 1 + idx
	end
	return variables
end