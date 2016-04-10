class 'Notifications'

function Notifications:__init()
	Events:Subscribe("PlayerChat", self, self.PlayerChat)
	WaitforOpt 	= false
	HasSub 		= false
end

function Notifications:PlayerChat(args)
	
	if args.player:GetValue("NT_TagName") == "[Admin]" then
	
		local cmd_args = args.text:split( " " )
	
		if cmd_args[1] == "/information" then
			local text_index = string.find(args.text, "text: ", 1)
			local subtext_index = string.find(args.text, "subtext: ", 1)
        
			if text_index ~=nil then
				if subtext_index ~= nil then
					text 		= 	string.sub(args.text, text_index + 6, subtext_index - 2)
					subtext 	= 	string.sub(args.text, subtext_index + 9)
					WaitforOpt	= 	true
					HasSub		=	true
					Type		=	"Information"
					Chat:Send(args.player, "------------------------------------------------------", Color(200,200,200))
					Chat:Send(args.player, "Please verify you that want to send this notification:", Color(200,200,200))
					Chat:Send(args.player, " ", Color(200,200,200))
					Chat:Send(args.player, "Type: Information", Color(200,200,200))
					Chat:Send(args.player, "Text: " .. text, Color(200,200,200))
					Chat:Send(args.player, "Subtext: " .. subtext, Color(200,200,200))
					Chat:Send(args.player, " ", Color(200,200,200))
					Chat:Send(args.player, "Type /yes to verify", Color(200,200,200))
					Chat:Send(args.player, "------------------------------------------------------", Color(200,200,200))
				else
					WaitforOpt 	= 	true
					HasSub		=	false
					Type		=	"Information"
					text = string.sub(args.text, text_index + 6)
					Chat:Send(args.player, "------------------------------------------------------", Color(200,200,200))
					Chat:Send(args.player, "Please verify that you want to send this notification:", Color(200,200,200))
					Chat:Send(args.player, " ", Color(200,200,200))
					Chat:Send(args.player, "Type: Information", Color(200,200,200))
					Chat:Send(args.player, "Text: " .. text, Color(200,200,200))
					Chat:Send(args.player, " ", Color(200,200,200))
					Chat:Send(args.player, "Type /yes to verify", Color(200,200,200))
					Chat:Send(args.player, "------------------------------------------------------", Color(200,200,200))
				end
        
			return false
			end
	
		end
	
		if cmd_args[1] == "/warning" then
			local text_index = string.find(args.text, "text: ", 1)
			local subtext_index = string.find(args.text, "subtext: ", 1)
        
			if text_index ~=nil then
				if subtext_index ~= nil then
					text 		= 	string.sub(args.text, text_index + 6, subtext_index - 2)
					subtext 	= 	string.sub(args.text, subtext_index + 9)
					WaitforOpt	= 	true
					HasSub		=	true
					Type		=	"Warning"
					Chat:Send(args.player, "------------------------------------------------------", Color(200,200,200))
					Chat:Send(args.player, "Please verify you that want to send this notification:", Color(200,200,200))
					Chat:Send(args.player, " ", Color(200,200,200))
					Chat:Send(args.player, "Type: Warning", Color(200,200,200))
					Chat:Send(args.player, "Text: " .. text, Color(200,200,200))
					Chat:Send(args.player, "Subtext: " .. subtext, Color(200,200,200))
					Chat:Send(args.player, " ", Color(200,200,200))
					Chat:Send(args.player, "Type /yes to verify", Color(200,200,200))
					Chat:Send(args.player, "------------------------------------------------------", Color(200,200,200))
				else
					WaitforOpt 	= 	true
					HasSub		=	false
					Type		=	"Warning"
					text = string.sub(args.text, text_index + 6)
					Chat:Send(args.player, "------------------------------------------------------", Color(200,200,200))
					Chat:Send(args.player, "Please verify that you want to send this notification:", Color(200,200,200))
					Chat:Send(args.player, " ", Color(200,200,200))
					Chat:Send(args.player, "Type: Warning", Color(200,200,200))
					Chat:Send(args.player, "Text: " .. text, Color(200,200,200))
					Chat:Send(args.player, " ", Color(200,200,200))
					Chat:Send(args.player, "Type /yes to verify", Color(200,200,200))
					Chat:Send(args.player, "------------------------------------------------------", Color(200,200,200))
				end
        
			return false
			end
		
		end
	
		if cmd_args[1] == "/upgrade" then
			local text_index = string.find(args.text, "text: ", 1)
			local subtext_index = string.find(args.text, "subtext: ", 1)
			
			if text_index ~=nil then
				if subtext_index ~= nil then
					text 		= 	string.sub(args.text, text_index + 6, subtext_index - 2)
					subtext 	= 	string.sub(args.text, subtext_index + 9)
					WaitforOpt	= 	true
					HasSub		=	true
					Type		=	"Upgrade"
					Chat:Send(args.player, "------------------------------------------------------", Color(200,200,200))
					Chat:Send(args.player, "Please verify you that want to send this notification:", Color(200,200,200))
					Chat:Send(args.player, " ", Color(200,200,200))
					Chat:Send(args.player, "Type: Upgrade", Color(200,200,200))
					Chat:Send(args.player, "Text: " .. text, Color(200,200,200))
					Chat:Send(args.player, "Subtext: " .. subtext, Color(200,200,200))
					Chat:Send(args.player, " ", Color(200,200,200))
					Chat:Send(args.player, "Type /yes to verify", Color(200,200,200))
					Chat:Send(args.player, "------------------------------------------------------", Color(200,200,200))
				else
					WaitforOpt 	= 	true
					HasSub		=	false
					Type		=	"Upgrade"
					text = string.sub(args.text, text_index + 6)
					Chat:Send(args.player, "------------------------------------------------------", Color(200,200,200))
					Chat:Send(args.player, "Please verify that you want to send this notification:", Color(200,200,200))
					Chat:Send(args.player, " ", Color(200,200,200))
					Chat:Send(args.player, "Type: Upgrade", Color(200,200,200))
					Chat:Send(args.player, "Text: " .. text, Color(200,200,200))
					Chat:Send(args.player, " ", Color(200,200,200))
					Chat:Send(args.player, "Type /yes to verify", Color(200,200,200))
					Chat:Send(args.player, "------------------------------------------------------", Color(200,200,200))
				end
        
			return false
			end
	
		end
	
		if cmd_args[1] == "/yes" then
			if WaitforOpt == true then
				if HasSub == true then
					WaitforOpt = false
					HasSub = false
					if Type	== "Information" then
						Network:Broadcast("SendNotification", {txt = text, image = "Information", subtxt = subtext})
					elseif Type	== "Warning" then
						Network:Broadcast("SendNotification", {txt = text, image = "Warning", subtxt = subtext})
					elseif Type	== "Upgrade" then
						Network:Broadcast("SendNotification", {txt = text, image = "Upgrade", subtxt = subtext})
					end
					Type = nil
					Chat:Send(args.player, "Notification has been sent!", Color(0,200,0))
				else
					WaitforOpt = false
					HasSub = false
					if Type	== "Information" then
						Network:Broadcast("SendNotification", {txt = text, image = "Information"})
					elseif Type	== "Warning" then
						Network:Broadcast("SendNotification", {txt = text, image = "Warning"})
					elseif Type	== "Upgrade" then
						Network:Broadcast("SendNotification", {txt = text, image = "Upgrade"})
					end
					Type = nil
					Chat:Send(args.player, "Notification has been sent!", Color(0,200,0))
				end
			end
			return false
		end
	end
end

Notifications = Notifications()