class 'Msgs'
function Msgs:__init()
	self.data = {}
	self.window = Window.Create()
	self.window:Hide()
	self.window:SetTitle("Moderator Answers to Frequently Asked Questions")
	self.window:SetSize(Render.Size / 1.5)
	self.window:Subscribe("WindowClosed", self, self.Exit)
	self.window:SetPosition((Render.Size / 2) - (self.window:GetSize() / 2))
	self.list = SortedList.Create(self.window)
	self.list:SetSizeRel(Vector2(0.99,0.8))
	self.list:AddColumn("Messages")
	self:UpdateWindowData()
	self.textbox = TextBox.Create(self.window)
	self.textbox:SetSizeRel(Vector2(0.6,0.1))
	self.textbox:SetPositionRel(Vector2(0,0.825))
	self.bsave = Button.Create(self.window)
	self.bsave:SetSizeRel(Vector2(0.1,0.1))
	self.bsave:SetPositionRel(Vector2(0.625,0.825))
	self.bsave:SetText("Send")
	self.bsave:Subscribe("Press", self, self.Press)
	self.badd = Button.Create(self.window)
	self.badd:SetSizeRel(Vector2(0.1,0.1))
	self.badd:SetPositionRel(Vector2(0.725,0.825))
	self.badd:SetText("Add")
	self.badd:Subscribe("Press", self, self.Press)
	self.bsave = Button.Create(self.window)
	self.bsave:SetSizeRel(Vector2(0.1,0.1))
	self.bsave:SetPositionRel(Vector2(0.825,0.825))
	self.bsave:SetText("Save")
	self.bsave:Subscribe("Press", self, self.Press)
	self.list:Subscribe("RowSelected", self, self.SelectRow)
	Events:Subscribe("LocalPlayerChat", self, self.Open)
	Network:Subscribe("MSGS_AllMsgsData", self, self.ReceiveData)
end
function Msgs:Exit()
	Mouse:SetVisible(false)
	Events:Unsubscribe(self.RestrictEvent)
end
function Msgs:Open(args)
	if args.text == "/msgs" then
		if tostring(LocalPlayer:GetValue("NT_TagName")) == "[Admin]" or 
		tostring(LocalPlayer:GetValue("NT_TagName")) == "[Mod]" then
			self.window:Show()
			self.RestrictEvent = Events:Subscribe("LocalPlayerInput", self, self.RestrictMovement)
			Mouse:SetVisible(true)
		end
	end
end
function Msgs:RestrictMovement(args)
	if self.window:GetVisible() then
		return false
	end
end
function Msgs:ReceiveData(args)
	self.data = args
	self:UpdateWindowData()
end
function Msgs:UpdateWindowData()	
	self.list:Clear()
	for index,str in pairs(self.data) do 
		self:AddToSection(str)
	end
end
function Msgs:AddToSection(name)
	local add = self.list:AddItem(name)
	add:SetCellText(0, name)
end
function Msgs:SelectRow(list)
	self.textbox:SetText(list:GetSelectedRow():GetCellText(0))
end
function Msgs:Press(btn)
	if btn:GetText() == "Send" then
		if string.len(self.textbox:GetText()) > 1 then
			Network:Send("Msgs_SayText", self.textbox:GetText())
		end
	elseif btn:GetText() == "Add" then
		Network:Send("MSGS_Add", self.textbox:GetText())
	elseif btn:GetText() == "Save" then
		if not self.list:GetSelectedRow() then return end
		local text = self.list:GetSelectedRow():GetCellText(0)
		local index = -1
		for indo, msg in pairs(self.data) do
			if text == msg then
				index = indo
			end
		end
		if index ~= -1 then
			Network:Send("MSGS_Save", {index = index, new = self.textbox:GetText()})
		end
	end
end
Msgs = Msgs()