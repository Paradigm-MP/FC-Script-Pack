class 'Model_GUI'
function Model_GUI:__init()
	window = Window.Create()
	window:SetSize(Vector2(Render.Size.x / 4, Render.Size.y / 4))
	window:SetTitle("Plastic Surgery Kit - Click the arrows to change your model!")
	window:SetPosition((Render.Size / 2) - (window:GetSize() / 2))
	backbtn = Button.Create(window)
	backbtn:SetText("<")
	backbtn:SetTextSize(Render.Size.x / 30)
	backbtn:SetSize(window:GetSize() / 5)
	backbtn:SetPositionRel(Vector2(0.1, 0.3))
	backbtn:Subscribe("Press", self, self.Back)
	nextbtn = Button.Create(window)
	nextbtn:SetText(">")
	nextbtn:SetTextSize(Render.Size.x / 30)
	nextbtn:SetSize(window:GetSize() / 5)
	nextbtn:SetPositionRel(Vector2(0.6, 0.3))
	nextbtn:Subscribe("Press", self, self.Next)
	label = Label.Create(window)
	model = LocalPlayer:GetModelId()
	label:SetText(tostring(model).."/103")
	label:SetSizeRel(Vector2(1,1))
	label:SetTextSize(Render.Size.x / 30)
	label:SetPositionRel(Vector2(0.25,0))
	window:Hide()
	Events:Subscribe("UsePlasticSurgeryKit", self, self.ShowWindow)
	timer = Timer()
end
function Model_GUI:Back()
	if timer:GetSeconds() < 1 then return end
	timer:Restart()
	Network:Send("Models_Back")
	model = model - 1
	if model < 1 then model = 103 end
	if model == 20 then model = 19 end
	label:SetText(tostring(model).."/103")
end
function Model_GUI:Next()
	if timer:GetSeconds() < 1 then return end
	timer:Restart()
	Network:Send("Models_Next")
	model = model + 1
	if model > 103 then model = 1 end
	if model == 20 then model = 21 end
	label:SetText(tostring(model).."/103")
end
function CheckDisguise(p)
	if p:GetValue("SOCIAL_Disguise") and string.len(tostring(p:GetValue("SOCIAL_Disguise"))) > 3 then
		return tostring(p:GetValue("SOCIAL_Disguise"))
	else
		return false
	end
end
function Model_GUI:ShowWindow()
	if CheckDisguise(LocalPlayer) then
		Chat:Print("You cannot use the Plastic Surgery Kit while in disguise!", Color.Red)
	else
		window:Show()
		Events:Fire("DeleteFromInventory", {sub_item = "Plastic Surgery Kit", sub_amount = 1})
	end
end
Model_GUI = Model_GUI()
