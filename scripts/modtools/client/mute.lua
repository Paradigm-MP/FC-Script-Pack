function chat(args)
	if LocalPlayer:GetValue("Muted")
	and not (LocalPlayer:GetValue("NT_TagName") == "[Mod]" or 
	LocalPlayer:GetValue("NT_TagName") == "[Admin]") then return false end
end
Events:Subscribe("LocalPlayerChat", chat)