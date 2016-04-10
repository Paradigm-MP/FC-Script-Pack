-------------------------------------------------
----|			  DevBot  v0.1.2			|----
----|		A JC-MP Community project		|----
-------------------------------------------------

class 'DevBot'


function DevBot:__init()
	
		SQL:Execute("CREATE TABLE IF NOT EXISTS DevBot (trigger VARCHAR, answer VARCHAR)")
	
		MessageQueue 					= 					{}
		TriggerTable					=					{}

		BotName							=					"devbot" 		-- must be lowercase!
		BotTag							=					"[DevBot]: "
		BotColor						=					Color( 255, 255, 255 )
		
		self.numtick					=					0
		self.enabled					=					true
		
		self.insert                     =                   "INSERT INTO DevBot (trigger, answer) VALUES (?, ?)"
		self.delete                     =					"DELETE FROM DevBot WHERE trigger = (?)"
		self.update                     =					"UPDATE DevBot SET answer = (?) WHERE trigger = (?)"

		local bot_data = SQL:Query("SELECT * FROM DevBot"):Execute()
		for _, itable in pairs(bot_data) do
			--print(itable.trigger, itable.answer)
			TriggerTable[itable.trigger] = itable.answer
		end
		for k, v in pairs(TriggerTable) do
			print(k, v)
		end
		
		Events:Subscribe( "PlayerChat", self, self.PlayerChat )
		Events:Subscribe( "PostTick", self, self.PostTick )
		
end


function DevBot:PlayerChat( args )
		
		local lowertext					=					string.lower(args.text)
		
		if self.enabled then
		
		
			if lowertext == BotName or lowertext == "hey " .. BotName then
				if args.player:GetValue("BotActive")	== false or args.player:GetValue("BotActive") == nil then
					
					table.insert( MessageQueue, "Yes my lord?" )
					args.player:SetValue("BotActive", true)
					
				else
					
					table.insert( MessageQueue, "I'm already active, ask me anything!" )
					
				end
			end

			
			if lowertext == BotName .. " learn this" or lowertext == BotName .. ", learn this" or lowertext == BotName .. " learn this:" or lowertext == BotName .. ", learn this:" then
				if args.player:GetValue("BotLearningStage0") == false or args.player:GetValue("BotLearningStage0") == nil then
					
					args.player:SetValue("BotLearningStage0", true)
					
				end
			end
			
			
			if args.player:GetValue("BotLearningStage0") == true then
				if string.sub(lowertext, 1, 9) == [[trigger: ]] then
					
					local trigger = string.sub(lowertext, 10, string.len(lowertext)) -- shouldn't this start at 10?
					trigger = trigger:gsub("?", "")
					args.player:SetValue("TriggerValue", trigger)
					args.player:SetValue("BotLearningStage1", true)
					
				end
			end

			
			if args.player:GetValue("BotLearningStage1") == true then
				if string.sub(lowertext, 1, 8) == [[answer: ]] then
					
					local answer = string.sub(args.text, 9, string.len(args.text))
					args.player:SetValue("AnswerValue", answer)
					
					local triggervalue		=		args.player:GetValue("TriggerValue")
					local answervalue		=		args.player:GetValue("AnswerValue")
					
					if not TriggerTable[answervalue] then
						local insert = SQL:Command(self.insert)
						insert:Bind(1, triggervalue)
						insert:Bind(2, answervalue)
						insert:Execute()
					else
						local update = SQL:Command(self.update)
						update:Bind(1, answervalue)
						update:Bind(2, triggervalue)
						update:Execute()
					end
					TriggerTable[triggervalue] = answervalue

					--Chat:Broadcast("trigger: " .. tostring(triggervalue) .. " || answer: " .. tostring(answervalue), Color(255, 255, 0))
					table.insert( MessageQueue, "Noted. I'll remember that." )
					
					args.player:SetValue("TriggerValue", nil)
					args.player:SetValue("AnswerValue", nil)
					
					args.player:SetValue("BotLearningStage0", false)
					args.player:SetValue("BotLearningStage1", false)
					args.player:SetValue("BotActive", false)

				end
			end
			
			
			if lowertext == BotName .. " remove this" or lowertext == BotName .. ", remove this" or lowertext == BotName .. " remove this:" or lowertext == BotName .. ", remove this:" then
				if args.player:GetValue("BotRemoval") == false or args.player:GetValue("BotRemoval") == nil then
					
					args.player:SetValue("BotRemoval", true)
					
				end
			end
			
			
			if args.player:GetValue("BotRemoval") == true then
				if string.sub(lowertext, 1, 9) == [[trigger: ]] then
					
					local trigger = string.sub(lowertext, 10, string.len(lowertext))
					args.player:SetValue("TriggerValue", trigger)
					
					local triggervalue		=		args.player:GetValue("TriggerValue")
					if TriggerTable[triggervalue] then
						TriggerTable[triggervalue] = nil
						
						local delete = SQL:Command(self.delete)
						delete:Bind(1, triggervalue)
						delete:Execute()
						
						table.insert( MessageQueue, "Got it. I removed that one for you." )
					
						args.player:SetValue("TriggerValue", nil)
						args.player:SetValue("BotRemoval", false)
					end
					
				end
			end
			
			
			if lowertext:find("thanks") and lowertext:find(BotName) then
			
				table.insert( MessageQueue, "You're welcome." )
				args.player:SetValue("BotActive", false)
				
			end

			
			if lowertext:find("never mind") and lowertext:find(BotName) then
			
				table.insert( MessageQueue, "Okay, let me know when you need me." )
				args.player:SetValue("BotActive", false)
				
			end
			
			
			if lowertext == BotName .. " go away" or lowertext == BotName .. ", go away" then
				
				table.insert( MessageQueue, "Okay, I'll disable myself for a bit" )
				self.enabled = false
				args.player:SetValue("BotActive", false)
				
			end																			  

			----------------------------------------------------------------------------------------------------
			if args.player:GetValue("BotActive") == true or string.sub(lowertext, 1, 6) == [[devbot]] then -- this gives the trigger 2 distinct forms
				DevBotMessage = nil
				--Chat:Broadcast("Trigger Identification Entered", Color(255, 255, 0))
				if string.sub(lowertext, 1, 6) == [[devbot]] then
					lowertext = string.sub(lowertext, 7) -- cut out "devbot"
				end
				--Chat:Broadcast("lowertext = " .. tostring(lowertext), Color(255, 255, 0))
				local trimmed = lowertext:gsub("?", "")
				trimmed = trimmed:gsub("^%s*(.-)%s*$", "%1")
				if not TriggerTable[trimmed] then
					local text_table = string.split(trimmed, " ")
					for _, word in pairs(text_table) do
						if TriggerTable[word] then
							if not Remove[word] then
								DevBotMessage = TriggerTable[word]
								break
							end
						end
					end
				else
					DevBotMessage = TriggerTable[trimmed]
				end
				
				if DevBotMessage then
					table.insert( MessageQueue, DevBotMessage )
					args.player:SetValue("BotActive", false)
				end
				
			end
			----------------------------------------------------------------------------------------------------
		end

		
		if lowertext == BotName .. " activate yourself" or lowertext == BotName .. ", activate yourself" or lowertext == BotName .. " activate" then
			if args.player:GetValue("BotActive") == false then
				
				table.insert( MessageQueue, "Hi! Did you miss me?" )
				self.enabled = true
			
			end
		end

end


function DevBot:PostTick()
	
		self.numtick	=	self.numtick + 1
	
		if self.numtick >= 200 then
	
			self.ProcessQueue()
			self.numtick 	=	0
		
		end
	
end


function DevBot:ProcessQueue()

		for k, message in ipairs(MessageQueue) do 
			local i = SharedObject.GetByName("DevBot")
			if i then
				Chat:Broadcast( "[DankBot]: " .. message, BotColor) 
			else
				Chat:Broadcast( BotTag .. message, BotColor) 
			end
			table.remove(MessageQueue, k) 
			
		end

end


devbot = DevBot()