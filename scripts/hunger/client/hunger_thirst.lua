class 'HungerThirst'
function HungerThirst:__init()
	syncTimer = Timer()
	messageTimer1 = Timer()
	messageTimer2 = Timer()
	hunger = Encrypt(LocalPlayer:GetValue("Hunger"))
	thirst = Encrypt(LocalPlayer:GetValue("Thirst"))
	food_Inner = Image.Create(AssetLocation.Resource, "Food_Inner_IMG")
	food_Outline = Image.Create(AssetLocation.Resource, "Food_Outline_IMG")
	thirst_Inner = Image.Create(AssetLocation.Resource, "Thirst_Inner_IMG")
	thirst_Outline = Image.Create(AssetLocation.Resource, "Thirst_Outline_IMG")
--	Events:Subscribe("Render", self, self.RenderStuff)
	Events:Subscribe("SecondTick", self, self.DisplayMessage)
	Events:Subscribe("SecondTick", self, self.Sync)
	Events:Subscribe("GameLoad", self, self.FirstSync)
	Events:Subscribe("LocalPlayerDeath", self, self.Death)
	Events:Subscribe("HT_Consume", self, self.Consume)
	--Events:Subscribe("LocalPlayerChat", self, self.Chat)
end
function AddHelp()
    Events:Fire( "HelpAddItem",
        {
            name = "Hunger",
            text = 
                "You can view your hunger and thirst amounts by opening your inventory with G. "..
                "The hunger is indicated by the apple and the thirst is indicated by the water " ..
                "bottle.  These will slowly decrease over time. If they reach zero, your health "..
				"will slowly begin to decrease until you die. You can stop this by consuming food "..
				"items by left-clicking them in your inventory."
        } )
		
end

function RemoveHelp()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Hunger"
        } )
end

Events:Subscribe("ModulesLoad", AddHelp)
Events:Subscribe("ModuleUnload", RemoveHelp)
function HungerThirst:DisplayMessage()
	if Decrypt(hunger) == 0 and not mTimer1 then
		mTimer1 = Timer()
		Chat:Print("Your body deteriorates due to lack of food.", Color(212,192,144))
	elseif Decrypt(hunger) == 0 and mTimer1 and mTimer1:GetMinutes() > 0.5 then
		mTimer1:Restart()
		Chat:Print("Your body deteriorates due to lack of food.", Color(212,192,144))
	end
	if Decrypt(thirst) == 0 and not mTimer2 then
		mTimer2 = Timer()
		Chat:Print("Your body deteriorates due to lack of water.", Color(144,176,212))
	elseif Decrypt(thirst) == 0 and mTimer2 and mTimer2:GetMinutes() > 0.5 then
		mTimer2:Restart()
		Chat:Print("Your body deteriorates due to lack of water.", Color(144,176,212))
	end
	if Decrypt(thirst) < 10 and Decrypt(thirst) > 0 and messageTimer2:GetMinutes() > 3 then
		messageTimer2:Restart()
		Chat:Print("Your throat is parched.", Color(144,176,212))
	end
	if Decrypt(hunger) < 10 and Decrypt(hunger) > 0 and messageTimer1:GetMinutes() > 3 then
		messageTimer1:Restart()
		Chat:Print("Your stomach growls.", Color(212,192,144))
	end
end
function HungerThirst:Death()
	hunger = Encrypt(75)
	thirst = Encrypt(75)
	local args = {}
	args.hunger = Decrypt(hunger)
	args.thirst = Decrypt(thirst)
	Network:Send("HT_Sync", args)
end
function HungerThirst:Chat(args)
	local words = args.text:split(" ")
	if words[1] == "/c" and words[2] then
		local words = args.text:split(" ")
		Events:Fire("HT_Consume", tostring(words[2]))
		return false
	elseif args.text == "/decrease" then
		DecreaseHT(60)
		return false
	end
end
function Decrypt(value)
	if value then
		value = tonumber(Crypt34(tostring(value)))
		return value
	end
end
function Encrypt(value)
	if value then
		value = Crypt34(tostring(value))
		return value
	end
end
function HungerThirst:Consume(item)
	if item then
		hunger = Encrypt(Decrypt(hunger) + htamt[item].food)
		thirst = Encrypt(Decrypt(thirst) + htamt[item].drink)
	end
	if Decrypt(hunger) > 100 then hunger = Encrypt(100) end
	if Decrypt(thirst) > 100 then thirst = Encrypt(100) end
	local args = {}
	args.hunger = Decrypt(hunger)
	args.thirst = Decrypt(thirst)
	Events:Fire("DeleteFromInventory", {sub_item = item, sub_amount = 1})
	Network:Send("HT_Sync", args)
	LocalPlayer:SetValue("RenderHunger", args.hunger)
	LocalPlayer:SetValue("RenderThirst", args.thirst)
end
function DecreaseHunger(amt)
	hunger = Encrypt(Decrypt(hunger) - amt)
	if Decrypt(hunger) < 0 then hunger = Encrypt(0) end
end
function DecreaseThirst(amt)
	thirst = Encrypt(Decrypt(thirst) - amt)
	if Decrypt(thirst) < 0 then thirst = Encrypt(0) end
end
function DecreaseHT(amt)
	if LocalPlayer:InVehicle() then amt = amt / 2 end
	DecreaseHunger(amt/3)
	DecreaseThirst(amt)
end
function HungerThirst:Sync()
	DecreaseHT(0.02)
	if syncTimer:GetSeconds() >= 30 then
		syncTimer:Restart()
		local args = {}
		args.hunger = Decrypt(hunger)
		args.thirst = Decrypt(thirst)
		Network:Send("HT_Sync", args)
		
		LocalPlayer:SetValue("RenderHunger", args.hunger)
		LocalPlayer:SetValue("RenderThirst", args.thirst)
	end
end

function HungerThirst:FirstSync()
		local args = {}
		args.hunger = Decrypt(hunger)
		args.thirst = Decrypt(thirst)
		Network:Send("HT_Sync", args)
		
		LocalPlayer:SetValue("RenderHunger", args.hunger)
		LocalPlayer:SetValue("RenderThirst", args.thirst)
end

-- function HungerThirst:RenderStuff()
	-- if not hunger or not thirst then return end
	
	-- if Game:GetState() == GUIState.Game and LocalPlayer:GetValue("Inv_Open") then
		-- local basepos = Vector2(Render.Size.x / 1.5, Render.Size.y / 100)
		-- local size = Vector2(Render.Size.x / 6.4, Render.Size.y / 3.6)/2
		-- local percent1 = Decrypt(hunger) / 100
		-- local pos = size.y - (size.y*percent1)
		-- Render:SetClip(true, basepos + Vector2(0,pos), size)
		-- food_Inner:Draw(basepos, size, Vector2(0,0), Vector2(1,1))
		-- Render:SetClip(false)
		-- food_Outline:Draw(basepos, size, Vector2(0,0), Vector2(1,1))
		-- local percent2 = Decrypt(thirst) / 100
		-- local pos = size.y - (size.y*percent2)
		-- Render:SetClip(true, basepos + Vector2(0,pos)+ Vector2(size.x,0), size)
		-- thirst_Inner:Draw(basepos + Vector2(size.x,0), size, Vector2(0,0), Vector2(1,1))
		-- Render:SetClip(false)
		-- thirst_Outline:Draw(basepos + Vector2(size.x,0), size, Vector2(0,0), Vector2(1,1))
	-- end
-- end

function ModuleLoad(args)
	if subber and LocalPlayer:GetValue("Thirst") then
		HungerThirst = HungerThirst()
		Events:Unsubscribe(subber)
		subber = nil
	end
end
subber = Events:Subscribe("SecondTick", ModuleLoad)