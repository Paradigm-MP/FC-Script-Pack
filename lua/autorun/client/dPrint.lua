function Chat:dPrint(...)
	if LocalPlayer:GetValue("NT_TagName") == "[Admin]" and LocalPlayer:GetValue("dDebugOn") then
		Chat:Print(table.unpack(table.pack(...)))
	end
end

function dprint(...)
	if LocalPlayer:GetValue("NT_TagName") == "[Admin]" and LocalPlayer:GetValue("dDebugOn") then
		print(table.unpack(table.pack(...)))
	end
end