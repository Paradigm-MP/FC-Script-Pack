class "AchievementViewer"

function AchievementViewer:__init()
	self.drawing = false
	self.scrolloffset = 0
	self.panelsize = Vector2(8 * Render.Width / 20, 4 * Render.Height / 20)
	self.numpanels = 0
	self.currentcopy = nil
	self.screentext = nil
	self.screentexttimer = nil
	self.screentexttime = 5
	self.solidtime = 3
	
	Events:Subscribe("KeyUp", self, self.KeyUp)
	Events:Subscribe("LocalPlayerInput", self, self.BlockInput)
	Events:Subscribe("Render", self, self.Render)
	Events:Subscribe("MouseScroll", self, self.Scroll)
	Events:Subscribe("NetworkObjectValueChange", self, self.NOValueChange)
	Events:Subscribe("ModulesLoad", self, self.AddHelp)
	Events:Subscribe("ModuleUnload", self, self.RemoveHelp)

end

function AchievementViewer:AddHelp()
    Events:Fire( "HelpAddItem",
        {
            name = "Achievements",
            text = 
                "You can access the achievements menu by pressing '. "..
                "Here, you will see all available achievements and your progress " ..
                "towards them.  Once you accomplish an achievement, you will receive "..
				"credits and experience based on how difficult it was to accomplish."
        } )
end

function AchievementViewer:RemoveHelp()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Achievements"
        } )
end


function AchievementViewer:NOValueChange(args)
	if args.key == "Achievements" and args.object == LocalPlayer then
		if self.drawing then
			for achname, value in pairs(args.value) do
				if self.panels[achname] then
					self.panels[achname].achobj:SetProgress(value.progress)
				end
			end
		end
		if self.currentcopy then
			for codename, value in pairs(args.value) do
				achobj = AchievementInstance(GlobalAchievementTableIndexed[codename], value.progress)
				if achobj:IsComplete() and not self.currentcopy[codename] then
					if self.achcompobj then
						self.achcompobj:Remove()
						self.achcompobj = nil
					end
					self.achcompobj = SoundDB.Create("Adaptive Music", "MissionComplete", {position = Camera:GetPosition(), angle = Angle()})
					Chat:Print("Achievement unlocked: ", Color(100, 100, 255), value.dispname, Color(255, 255, 0), " !", Color(100, 100, 255))
					self.screentext = value.dispname
					self.screentexttimer = Timer()
					ClientEffect.Play(AssetLocation.Game, {position = LocalPlayer:GetPosition(), angle = Angle(), effect_id = 348})
				elseif self.currentcopy[codename] and not achobj:IsComplete() then
					self.currentcopy[codename] = false
					print("Achievement \"" .. codename .. "\" was revoked, wat?")
				end
			end
		end
		self.currentcopy = {}
		for codename, value in pairs(args.value) do
			achobj = AchievementInstance(GlobalAchievementTableIndexed[codename], value.progress)
			self.currentcopy[codename] = achobj:IsComplete()
		end
	end
end

function AchievementViewer:Scroll(args)
	local delta = args.delta * Render.Height / 20
	if self.drawing then
		self.scrolloffset = math.clamp(self.scrolloffset - delta, 0, math.clamp((self.numpanels * self.panelsize.y) - (4 * self.panelsize.y), 0, math.huge))
	end
end

function AchievementViewer:Render()
	Render:SetFont(AssetLocation.Disk, "LeagueGothic.ttf")

	if self.drawing then
		Mouse:SetVisible(true)
		
		local outeranchor = Vector2(5.75 * Render.Width / 20, Render.Height / 20)
		Render:FillArea(outeranchor, Vector2(8.5 * Render.Width / 20, 18 * Render.Height / 20), Color(50, 50, 50, 220))
		local achtextpos = Vector2(Render.Width / 2, 1.625 * Render.Height / 20) - (Render:GetTextSize("Achievements", Render.Height * (40 / 1080)) / 2)
		Render:DrawText(achtextpos, "Achievements", Color.White, Render.Height * (40 / 1080))
		
		Render:SetClip(true, Vector2(6 * Render.Width / 20, 2 * Render.Height / 20), Vector2(self.panelsize.x, 4 * self.panelsize.y))
		
		for _, panel in pairs(self.panels) do
			panel:Render(Vector2(6 * Render.Width / 20, 2 * Render.Height / 20), self.scrolloffset)
		end
		
		Render:SetClip(false)
	end
	if self.achcompobj then
		self.achcompobj:SetPosition(Camera:GetPosition())
		if not self.achcompobj:IsPlaying() then
			self.achcompobj:Remove()
			self.achcompobj = nil
		end
	end
	if self.screentext then
		local screentextsize = Render.Height * (80 / 1080)
		local achunlockstr = "Achievement Unlocked:"
		local basepos = Vector2(Render.Width / 2, Render.Height / 3)
		local alphascale = math.clamp((self.screentexttime - self.screentexttimer:GetSeconds()) / (self.screentexttime - self.solidtime), 0, 1)
		
		Render:DrawText(basepos - (Render:GetTextSize(achunlockstr, screentextsize) / 2) + Vector2(5, 5), achunlockstr, Color(50, 50, 50, 200 * alphascale), screentextsize)
		Render:DrawText(basepos - (Render:GetTextSize(achunlockstr, screentextsize) / 2), achunlockstr, Color(255, 0, 0, 255 * alphascale), screentextsize)
		
		local screentextpos = basepos - (Render:GetTextSize(self.screentext, screentextsize) / 2) + Vector2(0, Render:GetTextHeight(achunlockstr, screentextsize))
		
		Render:DrawText(screentextpos + Vector2(5, 5), self.screentext, Color(50, 50, 50, 200 * alphascale), screentextsize)
		Render:DrawText(screentextpos, self.screentext, Color(255, 255, 0, 255 * alphascale), screentextsize)
		
		if self.screentexttimer:GetSeconds() > self.screentexttime then
			self.screentext = nil
			self.screentexttimer = nil
		end
	end
	Render:ResetFont()
end

function AchievementViewer:BlockInput(args)
	if self.drawing then
		return false
	end
end

function AchievementViewer:KeyUp(args)
	if args.key == 222 then --single quote: '
		self.drawing = not self.drawing
		if self.drawing then
			self.panels = {}
			local currentach = LocalPlayer:GetValue("Achievements")
			local currentoffset = 0
			
			for _, v in pairs(GlobalAchievementTable) do
				local panel = AchievementPanel(AchievementInstance(v, nil), currentoffset, self.panelsize)
				
				if not currentach[panel.achobj.parent.codename] then
					if panel.achobj.parent.achtype == AchievementType.Boolean then
						panel.achobj:SetProgress(false)
					elseif panel.achobj.parent.achtype == AchievementType.Progressive then
						panel.achobj:SetProgress(0)
					else
						error("[CRITICAL] An achievement was of a type that is not implemented!")
					end
				else
					panel.achobj:SetProgress(currentach[panel.achobj.parent.codename].progress)
				end
				self.panels[panel.achobj.parent.codename] = panel
				self.numpanels = self.numpanels + 1
				currentoffset = currentoffset + self.panelsize.y
			end
			
		else
			self.numpanels = 0
			self.panels = nil
		end
		Mouse:SetVisible(self.drawing)
	end
end

SoundDB = {
    Sounds = {
        ['Auto'] = {
            BankID = 0,
            ['AR_LowRate'] = {
                SoundId = 0,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['AR_MidRate'] = {
                SoundId = 1,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 1000.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['AR_HighRate'] = {
                SoundId = 2,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 1000.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['MG_LowRate'] = {
                SoundId = 3,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['MG_MidRate'] = {
                SoundId = 4,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 1000.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['MG_HighRate'] = {
                SoundId = 5,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 1000.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['SMG_LowRate'] = {
                SoundId = 6,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['MiniGun_Fire'] = {
                SoundId = 7,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['velocity'] = { Index = 3, Min = 0.0, Max = 10.0 },
                }
            },
            ['SMG_MidRate'] = {
                SoundId = 11,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 1000.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['FLAK'] = {
                SoundId = 12,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 500.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Sentry_Loop'] = {
                SoundId = 13,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Vulcan_Fire'] = {
                SoundId = 17,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['velocity'] = { Index = 3, Min = 0.0, Max = 5.0 },
                }
            },
            ['SMG_HighRate'] = {
                SoundId = 18,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 1000.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['DLC_Airzooka'] = {
                SoundId = 19,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 1000.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 45.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation2'] = { Index = 3, Min = 0.0, Max = 0.5 },
                }
            },
            ['MiniGun_Motor'] = {
                SoundId = 8,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['velocity'] = { Index = 3, Min = 0.0, Max = 10.0 },
                }
            },
            ['MiniGun_Motor_Start'] = {
                SoundId = 9,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['MiniGun_Motor_Stop'] = {
                SoundId = 10,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Vulcan_Motor_Start'] = {
                SoundId = 14,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Vulcan_Motor_Stop'] = {
                SoundId = 15,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Vulcan_Motor'] = {
                SoundId = 16,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['velocity'] = { Index = 3, Min = 0.0, Max = 5.0 },
                }
            },
        },
        ['Single'] = {
            BankID = 1,
            ['1'] = {
                SoundId = 1,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 100.0 },
                }
            },
            ['2'] = {
                SoundId = 2,
            },
            ['3'] = {
                SoundId = 3,
            },
            ['4'] = {
                SoundId = 4,
            },
            ['SignatureGun_Shot'] = {
                SoundId = 0,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Pistol_Shot'] = {
                SoundId = 5,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Shotgun_Shot'] = {
                SoundId = 6,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Rocket Launcher Shot'] = {
                SoundId = 8,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Rocket Launcher Loop'] = {
                SoundId = 9,
                Parameters = {
                    ['load'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 1000.0 },
                }
            },
            ['Mounted Cannon_Shot'] = {
                SoundId = 10,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 2000.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Sniper'] = {
                SoundId = 11,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 1000.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['SAM_Shot'] = {
                SoundId = 12,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 500.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['SawedOff Shotgun'] = {
                SoundId = 13,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Grenade Launcher'] = {
                SoundId = 14,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['15 - Missile AI Loop'] = {
                SoundId = 15,
                Parameters = {
                    ['load'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 500.0 },
                }
            },
            ['Single_Click'] = {
                SoundId = 7,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 100.0 },
                }
            },
        },
        ['Zones'] = {
            BankID = 10,
            ['Arctic_Det'] = {
                SoundId = 1,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Desert_3_Detail_1'] = {
                SoundId = 4,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jungle_3_Detail_1'] = {
                SoundId = 7,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['City_3_Detail_1'] = {
                SoundId = 10,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Field_3_Detail_1'] = {
                SoundId = 13,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Fisher_Jungle_3_Detail_1'] = {
                SoundId = 20,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Fisher_Arctic_Det'] = {
                SoundId = 23,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Fisher_Desert_3_Detail_1'] = {
                SoundId = 26,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Tourist_Jungle_3_Detail_1'] = {
                SoundId = 29,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Tourist_Arctic_Det'] = {
                SoundId = 32,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Tourist_Desert_3_Detail_1'] = {
                SoundId = 35,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Religous_Jungle_3_Detail_1'] = {
                SoundId = 38,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Religous_Arctic_Det'] = {
                SoundId = 41,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Religous_Desert_3_Detail_1'] = {
                SoundId = 44,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Military_Jungle_3_Detail_1'] = {
                SoundId = 47,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Military_Arctic_Det'] = {
                SoundId = 50,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Military_Desert_3_Detail_1'] = {
                SoundId = 53,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Industrial_Jungle_3_Detail_1'] = {
                SoundId = 56,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Industrial_Arctic_Det'] = {
                SoundId = 59,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Industrial_Desert_3_Detail_1'] = {
                SoundId = 62,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 14.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Arctic_Amb'] = {
                SoundId = 0,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Desert_Amb'] = {
                SoundId = 3,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jungle_Amb'] = {
                SoundId = 6,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['City_Amb'] = {
                SoundId = 9,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Field_Amb'] = {
                SoundId = 12,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Sea_Amb'] = {
                SoundId = 15,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['inversed_height'] = { Index = 2, Min = -50.0, Max = 30.0 },
                    ['temperature'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                }
            },
            ['Ice_Amb'] = {
                SoundId = 17,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Fisher_Jungle_Amb'] = {
                SoundId = 19,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Fisher_Arctic_Amb'] = {
                SoundId = 22,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Fisher_Desert_Amb'] = {
                SoundId = 25,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Tourist_Jungle_Amb'] = {
                SoundId = 28,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Tourist_Arctic_Amb'] = {
                SoundId = 31,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Tourist_Desert_Amb'] = {
                SoundId = 34,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Religous_Jungle_Amb'] = {
                SoundId = 37,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Religous_Arctic_Amb'] = {
                SoundId = 40,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Religous_Desert_Amb'] = {
                SoundId = 43,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Military_Jungle_Amb'] = {
                SoundId = 46,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Military_Arctic_Amb'] = {
                SoundId = 49,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Military_Desert_Amb'] = {
                SoundId = 52,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Industrial_Jungle_Amb'] = {
                SoundId = 55,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Industrial_Arctic_Amb'] = {
                SoundId = 58,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Industrial_Desert_Amb'] = {
                SoundId = 61,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['City_Park_1'] = {
                SoundId = 64,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['timeofday'] = { Index = 1, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 60.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                }
            },
            ['Arctic_Sprinkle'] = {
                SoundId = 2,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Desert_Sprinkle'] = {
                SoundId = 5,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 60.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jungle_Sprinkle'] = {
                SoundId = 8,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['City_Sprinkle'] = {
                SoundId = 11,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Field_Sprinkle'] = {
                SoundId = 14,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Sea_Sprinkle'] = {
                SoundId = 16,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 18.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Ice_Sprinkle'] = {
                SoundId = 18,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Fisher_Jungle_Sprinkle'] = {
                SoundId = 21,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Fisher_Arctic_Sprinkle'] = {
                SoundId = 24,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Fisher_Desert_Sprinkle'] = {
                SoundId = 27,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Tourist_Jungle_Sprinkle'] = {
                SoundId = 30,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Tourist_Arctic_Sprinkle'] = {
                SoundId = 33,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Tourist_Desert_Sprinkle'] = {
                SoundId = 36,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Religous_Jungle_Sprinkle'] = {
                SoundId = 39,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Religous_Arctic_Sprinkle'] = {
                SoundId = 42,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Religous_Desert_Sprinkle'] = {
                SoundId = 45,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Military_Jungle_Sprinkle'] = {
                SoundId = 48,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Military_Arctic_Sprinkle'] = {
                SoundId = 51,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Military_Desert_Sprinkle'] = {
                SoundId = 54,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Industrial_Jungle_Sprinkle'] = {
                SoundId = 57,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Industrial_Arctic_Sprinkle'] = {
                SoundId = 60,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Industrial_Desert_Sprinkle'] = {
                SoundId = 63,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                    ['precipitation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Explosions'] = {
            BankID = 11,
            ['16 - destruction_antenna_small'] = {
                SoundId = 16,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 13.0 },
                }
            },
            ['17 - Statue Explo (+km06 domedebris impact)'] = {
                SoundId = 17,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['7 - Water_Tower'] = {
                SoundId = 7,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 13.0 },
                }
            },
            ['8 - Explosion default'] = {
                SoundId = 8,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['9 - Missile Explo'] = {
                SoundId = 9,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1200.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['10 - Mortar Explosion'] = {
                SoundId = 10,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['11 - Explosion Medium'] = {
                SoundId = 11,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 750.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['12 - Cl.Mine_Fragm.Bomb'] = {
                SoundId = 12,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['13 - Grenade Explo'] = {
                SoundId = 13,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 550.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['14 - Trig. Mine C4'] = {
                SoundId = 14,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 8.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 750.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['15 - Explo_c4_fireworks'] = {
                SoundId = 15,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 8.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 300.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['18 - Wood Obelisk Explosion'] = {
                SoundId = 18,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 500.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['20 - km01_explosion_in_air'] = {
                SoundId = 20,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 2000.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cluster Grenade'] = {
                SoundId = 21,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 750.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['22 cannon explosion'] = {
                SoundId = 22,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 8.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 750.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['laser explosions km05'] = {
                SoundId = 23,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 750.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['0 - Extraction'] = {
                SoundId = 0,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 2.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['1 - Demolition_Man_killed(warning)'] = {
                SoundId = 1,
                Parameters = {
                    ['timer'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                }
            },
            ['Triggered Explosive_Armed'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cloaked Mine_Armed'] = {
                SoundId = 4,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cloaked Mine_Proximity'] = {
                SoundId = 5,
                Parameters = {
                    ['timer'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Handgrenade_Proximity'] = {
                SoundId = 6,
                Parameters = {
                    ['timer'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 60.0 },
                }
            },
            ['19 - Handgrenade_Proximity_AI'] = {
                SoundId = 19,
                Parameters = {
                    ['timer'] = { Index = 0, Min = 0.0, Max = 6.1 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 60.0 },
                }
            },
            ['3 - Blast_Alarm'] = {
                SoundId = 3,
                Parameters = {
                    ['time'] = { Index = 0, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Foley'] = {
            BankID = 12,
            ['Water_Horisontal'] = {
                SoundId = 0,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Water_Vertical_Down'] = {
                SoundId = 1,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Water_Vertical_Up'] = {
                SoundId = 2,
                Parameters = {
                    ['depth'] = { Index = 0, Min = 0.0, Max = 1.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 10.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Footsteps_Snow'] = {
                SoundId = 3,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Footsteps_Stone'] = {
                SoundId = 4,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Land_Snow'] = {
                SoundId = 5,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Land_Stone'] = {
                SoundId = 6,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Up_Snow'] = {
                SoundId = 7,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Up_Stone'] = {
                SoundId = 8,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Footsteps_Metal'] = {
                SoundId = 17,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Land_Metal'] = {
                SoundId = 18,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Hands'] = {
                SoundId = 19,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Slide'] = {
                SoundId = 20,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Up_Metal_Solid'] = {
                SoundId = 21,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Footsteps_Dirt'] = {
                SoundId = 23,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Land_Dirt'] = {
                SoundId = 24,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Footsteps_Gravel'] = {
                SoundId = 25,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Land_Gravel'] = {
                SoundId = 26,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Up_Gravel'] = {
                SoundId = 27,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['_Footsteps_Mud'] = {
                SoundId = 28,
            },
            ['_Jump_Land_Mud'] = {
                SoundId = 29,
            },
            ['Ragdoll_Tumble'] = {
                SoundId = 30,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 30.0 },
                    ['speed'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Footsteps_Sand_Dry'] = {
                SoundId = 31,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Land_Sand_Dry'] = {
                SoundId = 32,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Up_Sand_Dry'] = {
                SoundId = 33,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Footsteps_Metal_Catwalk'] = {
                SoundId = 34,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Up_Metal_Catwalk'] = {
                SoundId = 35,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Land_Metal_Catwalk'] = {
                SoundId = 36,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Footsteps_Metal_Car'] = {
                SoundId = 37,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Land_Metal_Car'] = {
                SoundId = 38,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Up_Metal_Car'] = {
                SoundId = 39,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Footsteps_Glass_Broken'] = {
                SoundId = 40,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Land_Glass_Broken'] = {
                SoundId = 41,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Up_Glass_Broken'] = {
                SoundId = 42,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Footsteps_Wood_Solid'] = {
                SoundId = 43,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Land_Wood_Solid'] = {
                SoundId = 44,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Up_Wood_Solid'] = {
                SoundId = 45,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Footsteps_Ice_Solid'] = {
                SoundId = 46,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Land_Ice_Solid'] = {
                SoundId = 47,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Up_Ice_Solid'] = {
                SoundId = 48,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['In Water'] = {
                SoundId = 50,
                Parameters = {
                    ['waterdepth'] = { Index = 0, Min = -1.0, Max = 50.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Jump_Up_Dirt'] = {
                SoundId = 51,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 1, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Ladder'] = {
                SoundId = 53,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                    ['param04'] = { Index = 4, Min = 0.0, Max = 1.0 },
                }
            },
            ['Clothing_Jump'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 10.0 },
                }
            },
            ['Clothing_Walk_Run'] = {
                SoundId = 10,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 8.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 10.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Evade_Groundcontact'] = {
                SoundId = 11,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Throw_Over'] = {
                SoundId = 12,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Throw_Under'] = {
                SoundId = 13,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Wield_Down'] = {
                SoundId = 14,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Wield_Up'] = {
                SoundId = 15,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Wield_Up_Grenade'] = {
                SoundId = 16,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Foliage'] = {
                SoundId = 22,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 15.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['vegetation'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Ice_Cracks'] = {
                SoundId = 49,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 10.0 },
                    ['waterdepth'] = { Index = 2, Min = 0.0, Max = 0.5 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Turn'] = {
                SoundId = 52,
                Parameters = {
                    ['Speed'] = { Index = 0, Min = 0.0, Max = 9.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Close Combat'] = {
            BankID = 13,
            ['Punch'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Swisch'] = {
                SoundId = 1,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Hijack-Punch'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Hijack-Swisch'] = {
                SoundId = 3,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Melee_Strike'] = {
                SoundId = 4,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 1, Min = 0.0, Max = 2.0 },
                }
            },
            ['Struggle_Punch'] = {
                SoundId = 5,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 1, Min = 0.0, Max = 2.0 },
                }
            },
            ['Struggle_Counter_Foley'] = {
                SoundId = 6,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 1, Min = 0.0, Max = 2.0 },
                }
            },
            ['Struggle_Headbutt_Foley'] = {
                SoundId = 7,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 1, Min = 0.0, Max = 2.0 },
                }
            },
            ['Struggle_Headbutt_Block_Foley'] = {
                SoundId = 8,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 1, Min = 0.0, Max = 2.0 },
                }
            },
            ['Struggle_Idle_Foley'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 1, Min = 0.0, Max = 2.0 },
                }
            },
            ['Struggle_Knee_Foley'] = {
                SoundId = 10,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 1, Min = 0.0, Max = 2.0 },
                }
            },
            ['Struggle_Knee_Block_Foley'] = {
                SoundId = 11,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 1, Min = 0.0, Max = 2.0 },
                }
            },
            ['Struggle_Lft_Punch_Foley'] = {
                SoundId = 12,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 1, Min = 0.0, Max = 2.0 },
                }
            },
            ['Struggle_Lft_Punch_Block_Foley'] = {
                SoundId = 13,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 1, Min = 0.0, Max = 2.0 },
                }
            },
            ['Neutral_To_Struggle_Foley'] = {
                SoundId = 14,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 1, Min = 0.0, Max = 2.0 },
                }
            },
        },
        ['Parachute'] = {
            BankID = 14,
            ['Parachute_Horiz'] = {
                SoundId = 0,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Parachute_InFlight'] = {
                SoundId = 1,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['param04'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Wind_skydive'] = {
                SoundId = 2,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 65.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['height'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['speed vertical'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Parachute_steer'] = {
                SoundId = 3,
                Parameters = {
                    ['steer'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                    ['var'] = { Index = 3, Min = 0.0, Max = 10.0 },
                }
            },
            ['Wind_height'] = {
                SoundId = 4,
                Parameters = {
                    ['variation'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['height'] = { Index = 2, Min = 0.0, Max = 100.0 },
                }
            },
            ['Parachute_Vert'] = {
                SoundId = 5,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Physics'] = {
            BankID = 15,
            ['Antenna Huge Fall'] = {
                SoundId = 2,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 50000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 400.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Lave_Slide'] = {
                SoundId = 5,
                Parameters = {
                    ['deltavelocity'] = { Index = 0, Min = 0.0, Max = 50.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['26 - Crane Fall'] = {
                SoundId = 26,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 50000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 400.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['27 - Lave_Aggroll'] = {
                SoundId = 27,
                Parameters = {
                    ['angular velocity'] = { Index = 0, Min = 0.0, Max = 20.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Constraint Brake'] = {
                SoundId = 4,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Statue Crumble'] = {
                SoundId = 6,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['15_Pipeline_ventpop'] = {
                SoundId = 15,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 2.0 },
                }
            },
            ['18_Explosion_antenna_break'] = {
                SoundId = 18,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 240.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['22 - Tree Small'] = {
                SoundId = 22,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 75.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['23 - Tree Medium'] = {
                SoundId = 23,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 75.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['24 - Tree Large'] = {
                SoundId = 24,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 75.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['25 - Water_Splash'] = {
                SoundId = 25,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Statue Generic Debris'] = {
                SoundId = 28,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 15.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Wiggle Mast'] = {
                SoundId = 3,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['14_Wiresnap'] = {
                SoundId = 14,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['16_Pipeline_pressure'] = {
                SoundId = 16,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['17_Pipeline_Steam360'] = {
                SoundId = 17,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 5.0 },
                }
            },
            ['19 - Floodgate waterloop'] = {
                SoundId = 19,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Crash'] = {
                SoundId = 0,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 25000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Deformation'] = {
                SoundId = 1,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Crash_Metal'] = {
                SoundId = 7,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 25000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Crash_Sand_Dirt'] = {
                SoundId = 8,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 25000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Crash_Stone'] = {
                SoundId = 9,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 25000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Crash_Wood'] = {
                SoundId = 10,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 25000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Crash_Glass'] = {
                SoundId = 11,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 25000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Crash_Snow'] = {
                SoundId = 12,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 25000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Crash_Water'] = {
                SoundId = 13,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 25000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 2.5 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['20 - Seve_Slide_Vehicle'] = {
                SoundId = 20,
                Parameters = {
                    ['deltavelocity'] = { Index = 0, Min = 0.0, Max = 30.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['21 - Seve_Slide_Land'] = {
                SoundId = 21,
                Parameters = {
                    ['deltavelocity'] = { Index = 0, Min = 0.0, Max = 50.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Character'] = {
            BankID = 16,
            ['1'] = {
                SoundId = 1,
            },
            ['Health'] = {
                SoundId = 0,
                Parameters = {
                    ['intensity'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Personal Thruster'] = {
                SoundId = 2,
                Parameters = {
                    ['load'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['timeline'] = { Index = 3, Min = 0.0, Max = 3.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 30.0 },
                }
            },
        },
        ['Impacts'] = {
            BankID = 17,
            ['Bullet_Hit_Gong'] = {
                SoundId = 34,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                }
            },
            ['35 Melee_Hit_Gong'] = {
                SoundId = 35,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                }
            },
            ['Bullet_Hit_Shielder'] = {
                SoundId = 37,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Metal_Impact_Large'] = {
                SoundId = 18,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 50000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 400.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Metal_Impact_Medium'] = {
                SoundId = 39,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 30000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 400.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Metal_Impact_Medium_nodebris'] = {
                SoundId = 41,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 30000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 400.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['flak impact'] = {
                SoundId = 40,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['10 - Melee_Punch'] = {
                SoundId = 10,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Statue Impact'] = {
                SoundId = 11,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 7000.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['timeline'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Mast_Impact'] = {
                SoundId = 12,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 50000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cable Car Impact'] = {
                SoundId = 13,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 60.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['impulse'] = { Index = 3, Min = 0.0, Max = 2000.0 },
                }
            },
            ['Pillar_Impact'] = {
                SoundId = 21,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 30000.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Stone_Impact(melee_etc)'] = {
                SoundId = 28,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 50000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Metal Shed Impacts'] = {
                SoundId = 36,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 50000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Metal_Impact_Small'] = {
                SoundId = 16,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 50000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Glassobject_small'] = {
                SoundId = 17,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['20 - Metal_bin_Impact_Coll'] = {
                SoundId = 20,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 500.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Plastic_Impact_Coll'] = {
                SoundId = 22,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 500.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Sheetmetal_Impact_Coll'] = {
                SoundId = 23,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 500.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Body_Impact_Coll'] = {
                SoundId = 24,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 50000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['25 - Props_Impact_Coll'] = {
                SoundId = 25,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 50000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Car_Chassis_Impact_Coll'] = {
                SoundId = 26,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 50000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Wood_Impact_Coll'] = {
                SoundId = 27,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 500.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Body_Impact_Slide'] = {
                SoundId = 32,
                Parameters = {
                    ['deltavelocity'] = { Index = 0, Min = 0.0, Max = 20.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Metal_bin_Impact_Roll'] = {
                SoundId = 33,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Plastic_bin_Impact_Roll'] = {
                SoundId = 38,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Bullet_Hit_Dirt'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                }
            },
            ['Bullet_Hit_Flesh'] = {
                SoundId = 3,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['Bullet_Hit_Glass'] = {
                SoundId = 4,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['Bullet_Hit_Metal'] = {
                SoundId = 5,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['Bullet_Hit_Misc_Plastic'] = {
                SoundId = 6,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                }
            },
            ['Bullet_Hit_Water'] = {
                SoundId = 7,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['Bullet_Hit_Wood'] = {
                SoundId = 8,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                }
            },
            ['Bullet_Hit_SheetMetal'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['Bullet_Whizzes'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 40.0 },
                }
            },
            ['Bullet_Riccos'] = {
                SoundId = 1,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 40.0 },
                }
            },
            ['Bullet_Whizzes_HighSpeed'] = {
                SoundId = 14,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 40.0 },
                }
            },
            ['Bullet_Whizzes_Burst'] = {
                SoundId = 15,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 40.0 },
                }
            },
            ['Seve_Impact'] = {
                SoundId = 19,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 25000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Plastic_Impact_Slide'] = {
                SoundId = 29,
                Parameters = {
                    ['deltavelocity'] = { Index = 0, Min = 0.0, Max = 20.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['30 - Metal_Impact_Slide'] = {
                SoundId = 30,
                Parameters = {
                    ['deltavelocity'] = { Index = 0, Min = 0.0, Max = 20.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Wood_Impact_Slide'] = {
                SoundId = 31,
                Parameters = {
                    ['deltavelocity'] = { Index = 0, Min = 0.0, Max = 20.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['42 Seve_Impact_water'] = {
                SoundId = 42,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 25000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['43 Seve_Impact_sand'] = {
                SoundId = 43,
                Parameters = {
                    ['impulse'] = { Index = 0, Min = 0.0, Max = 25000.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Front End'] = {
            BankID = 18,
            ['Cancel'] = {
                SoundId = 0,
                Parameters = {
                    [''] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Select'] = {
                SoundId = 1,
                Parameters = {
                    [''] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Scroll'] = {
                SoundId = 2,
                Parameters = {
                    [''] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['start_game'] = {
                SoundId = 3,
                Parameters = {
                    [''] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['4'] = {
                SoundId = 4,
                Parameters = {
                    [''] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['5'] = {
                SoundId = 5,
                Parameters = {
                    [''] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Spinner_Radio'] = {
                SoundId = 6,
                Parameters = {
                    [''] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['selection_change_fail'] = {
                SoundId = 7,
                Parameters = {
                    [''] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['volume_test_music'] = {
                SoundId = 8,
                Parameters = {
                    ['param00'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['selection_change_complete'] = {
                SoundId = 11,
                Parameters = {
                    [''] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['attention_working'] = {
                SoundId = 12,
                Parameters = {
                    [''] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['cutscene text'] = {
                SoundId = 14,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['End Credits Text In'] = {
                SoundId = 13,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Hud'] = {
            BankID = 19,
            ['Objective_Show N'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Heat'] = {
                SoundId = 1,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Weapon_Switch_Walk_Over N'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Pick_Up N'] = {
                SoundId = 3,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Pick_Up_Ammo N'] = {
                SoundId = 4,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Equip Shoulder N'] = {
                SoundId = 5,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Equip N'] = {
                SoundId = 6,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Equip Switch N'] = {
                SoundId = 7,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Reject N'] = {
                SoundId = 8,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Sniper_Left_Right'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['10 - Sniper_Up_Down'] = {
                SoundId = 10,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Sniper_Zoom_In'] = {
                SoundId = 11,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Sniper_Zoom_Out'] = {
                SoundId = 12,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Disarm_Positive N'] = {
                SoundId = 13,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Disarm_Negative N'] = {
                SoundId = 14,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Disarm_Success N'] = {
                SoundId = 15,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Disarm_Failed N'] = {
                SoundId = 16,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Tutorial Small In N'] = {
                SoundId = 17,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Tutorial Largel In N'] = {
                SoundId = 18,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Tutorial Out N'] = {
                SoundId = 19,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['20 - Tutorial Incoming File N'] = {
                SoundId = 20,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Tutorial Incoming File Loop N'] = {
                SoundId = 21,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Tutorial Small Heading Flash N'] = {
                SoundId = 22,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Attention N'] = {
                SoundId = 23,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Rewards N'] = {
                SoundId = 24,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Mission Start N'] = {
                SoundId = 25,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Mission Complete N'] = {
                SoundId = 26,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Mission Fade N'] = {
                SoundId = 27,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Progression N'] = {
                SoundId = 28,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Mission Complete Split Pt 2 N'] = {
                SoundId = 29,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Pick Up Healthbox N'] = {
                SoundId = 30,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['31 - Flare Yes'] = {
                SoundId = 31,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['32 - Flare No'] = {
                SoundId = 32,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Objective_Complete'] = {
                SoundId = 39,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Download'] = {
                SoundId = 40,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['chaos_lvl_2-3'] = {
                SoundId = 41,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Mission_Complete_Parts_logo'] = {
                SoundId = 42,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Mission_Complete_Meter_progress'] = {
                SoundId = 43,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Mission_complete_Meter_topped'] = {
                SoundId = 44,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Mission_complete_Chaos_logo'] = {
                SoundId = 45,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Challenge start'] = {
                SoundId = 46,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Mercenary Mode screen'] = {
                SoundId = 47,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Mercenary Mode Percentage'] = {
                SoundId = 48,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Shells'] = {
            BankID = 2,
            ['Shell'] = {
                SoundId = 0,
                Parameters = {
                    ['hardness'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 10.0 },
                }
            },
        },
        ['Pda'] = {
            BankID = 20,
            ['Scroll Int File Loop N'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Lock Int File N'] = {
                SoundId = 1,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Open Int File N'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Close Int File N'] = {
                SoundId = 3,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Enter N'] = {
                SoundId = 4,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Exit N'] = {
                SoundId = 5,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Zoom Loop N'] = {
                SoundId = 6,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Counter Money Loop N'] = {
                SoundId = 7,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Open Close Sub Menu N'] = {
                SoundId = 8,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Confirm Selection N'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['10 - Scroll In Sub Menu N'] = {
                SoundId = 10,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Select In Sub Menu  N'] = {
                SoundId = 11,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Waypoint Set N'] = {
                SoundId = 12,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Waypoint Remove N'] = {
                SoundId = 13,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Selection Rejected N'] = {
                SoundId = 14,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Black Market Buy'] = {
                SoundId = 15,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Black Market Unlock'] = {
                SoundId = 16,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Black Market Upgrade'] = {
                SoundId = 17,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Black Market Enter'] = {
                SoundId = 18,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['AOI New Icon'] = {
                SoundId = 19,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['20 AOI Expanded'] = {
                SoundId = 20,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['21 Black MArket Top Menu Scroll'] = {
                SoundId = 21,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['22 Black MArket Top Menu Selcet'] = {
                SoundId = 22,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['23 Black Market Top Menu Exit'] = {
                SoundId = 23,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Show Chaos Info'] = {
                SoundId = 24,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Exclaimation'] = {
            BankID = 21,
            ['combat_'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 1, Min = -180.0, Max = 180.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 160.0 },
                }
            },
            ['wsim_'] = {
                SoundId = 1,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 75.0 },
                }
            },
            ['rico'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Buildings'] = {
            BankID = 23,
            ['Siren'] = {
                SoundId = 0,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['velocity'] = { Index = 2, Min = 0.0, Max = 15.0 },
                }
            },
            ['Alarm'] = {
                SoundId = 1,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['velocity'] = { Index = 2, Min = 0.0, Max = 30.0 },
                }
            },
        },
        ['Special'] = {
            BankID = 24,
            ['Gong'] = {
                SoundId = 0,
                Parameters = {
                    ['Focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['empty_15'] = {
                SoundId = 1,
            },
            ['empty_14'] = {
                SoundId = 2,
            },
            ['empty_17'] = {
                SoundId = 3,
            },
            ['empty_13'] = {
                SoundId = 4,
            },
            ['empty_19'] = {
                SoundId = 5,
            },
            ['Window Crash (Empty)'] = {
                SoundId = 9,
            },
            ['Resource_Item_DrugDrop(empty)'] = {
                SoundId = 6,
            },
            ['Resource_Item_BlackBox(empty)'] = {
                SoundId = 7,
            },
            ['Resource_Item_Skulls(empty)'] = {
                SoundId = 8,
            },
            ['Siren old'] = {
                SoundId = 11,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Bang From Car (empty)'] = {
                SoundId = 10,
            },
        },
        ['Adaptive Music'] = {
            BankID = 25,
            ['Def_Weird_Undetected'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Weird_Combat'] = {
                SoundId = 1,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Weird_Evasion'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Nig_Scary_Undetected'] = {
                SoundId = 3,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Nig_Scary_Combat'] = {
                SoundId = 4,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Nig_Scary_Evasion'] = {
                SoundId = 5,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Techy_Undetected'] = {
                SoundId = 6,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Techy_Combat'] = {
                SoundId = 7,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Techy_Evasion'] = {
                SoundId = 8,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Agentish_Undetected'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Agentish_Combat'] = {
                SoundId = 10,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Agentish_Evasion'] = {
                SoundId = 11,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Stressful_Undetected'] = {
                SoundId = 12,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Stressful_Combat'] = {
                SoundId = 13,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Stressful_Evasion'] = {
                SoundId = 14,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Nervous_Undetected'] = {
                SoundId = 15,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Nervous_Combat'] = {
                SoundId = 16,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Nervous_Evasion'] = {
                SoundId = 17,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Bondish_Undetected'] = {
                SoundId = 18,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Bondish_Combat'] = {
                SoundId = 19,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Bondish_Evasion'] = {
                SoundId = 20,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Military_Undetected'] = {
                SoundId = 21,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Military_Combat'] = {
                SoundId = 22,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Military_Evasion'] = {
                SoundId = 23,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Tribal_Undetected'] = {
                SoundId = 24,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Tribal_Combat'] = {
                SoundId = 25,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Tribal_Evasion'] = {
                SoundId = 26,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_TheBrass_Undetected'] = {
                SoundId = 27,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_TheBrass_Combat'] = {
                SoundId = 28,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_TheBrass_Evasion'] = {
                SoundId = 29,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Prime_Undetected'] = {
                SoundId = 30,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Prime_Combat'] = {
                SoundId = 31,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Prime_Evasion'] = {
                SoundId = 32,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Peak_Undetected'] = {
                SoundId = 33,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Peak_Combat'] = {
                SoundId = 34,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Peak_Evasion'] = {
                SoundId = 35,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Heat_Undetected'] = {
                SoundId = 36,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Heat_Combat'] = {
                SoundId = 37,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Heat_Evasion'] = {
                SoundId = 38,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Finale_Undetected'] = {
                SoundId = 39,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Finale_Combat'] = {
                SoundId = 40,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Finale_Evasion'] = {
                SoundId = 41,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['heat'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Carchase'] = {
                SoundId = 42,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Frontend'] = {
                SoundId = 43,
            },
            ['GameOver'] = {
                SoundId = 44,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['MissionComplete'] = {
                SoundId = 45,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['MissionFail'] = {
                SoundId = 46,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['MissionStart'] = {
                SoundId = 47,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['01 Panau_National_theme'] = {
                SoundId = 48,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['02 Baby_Panay_atmospheric'] = {
                SoundId = 49,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Km07 Rocket Combat'] = {
                SoundId = 50,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['04 Baby_Panay_Synt_2'] = {
                SoundId = 51,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['05 Panau_National_Theme_alt'] = {
                SoundId = 52,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['06 Baby_Panay_March'] = {
                SoundId = 53,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['07 Baby_Panay_Harp'] = {
                SoundId = 54,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['08 Baby_Panay_Flute'] = {
                SoundId = 55,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['01 OpeningScene_main'] = {
                SoundId = 56,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['02 OpeningScene_no_guittrump'] = {
                SoundId = 57,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['03 Cresc_all_OpeningScene'] = {
                SoundId = 58,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['04 GitarrMel_OpeningScene'] = {
                SoundId = 59,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['05 Opening_scene_short'] = {
                SoundId = 60,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['06 Opening_scene_short_quickstart'] = {
                SoundId = 61,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['07 Cresc_1_OpeningScene'] = {
                SoundId = 62,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['08 Cresc_2_OpeningScene'] = {
                SoundId = 63,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['09 Cresc_3_OpeningScene'] = {
                SoundId = 64,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['10 Cresc_4_OpeningScene'] = {
                SoundId = 65,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['11 Cresc_5_OpeningScene'] = {
                SoundId = 66,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['12 Cresc_6_OpeningScene'] = {
                SoundId = 67,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['01 Rico_Main'] = {
                SoundId = 68,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['02 RICO_nylon_theme'] = {
                SoundId = 69,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['03 RICO_harmon_theme'] = {
                SoundId = 70,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['04 RICO_nylon_kort'] = {
                SoundId = 71,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['05 RICO_harmon_kort'] = {
                SoundId = 72,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['01 theCrook_MainTheme'] = {
                SoundId = 73,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['02 theCrook_Theme_2'] = {
                SoundId = 74,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['03 theCrook_Theme_2_nomel'] = {
                SoundId = 75,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['04 theCrook_Theme_2_mel'] = {
                SoundId = 76,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['05 theCrook_Theme_1'] = {
                SoundId = 77,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['06 theCrook_Theme_1_SOLO'] = {
                SoundId = 78,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['07 Fanfarer_theCrook_1'] = {
                SoundId = 79,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['08 Fanfarer_theCrook_2'] = {
                SoundId = 80,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['09 Fanfarer_theCrook_3'] = {
                SoundId = 81,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['10 Fanfarer_theCrook_4'] = {
                SoundId = 82,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['11 Fanfarer_theCrook_5'] = {
                SoundId = 83,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['12 Fanfarer_theCrook_6'] = {
                SoundId = 84,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['01 Sloth_TomSheldon_Main'] = {
                SoundId = 85,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['02 Tom_MainTheme'] = {
                SoundId = 86,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['03 Sloth_Main'] = {
                SoundId = 87,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['04 Sloth_no_Slide'] = {
                SoundId = 88,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['05 Tom_no_solos'] = {
                SoundId = 89,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['06 Sloth_Short'] = {
                SoundId = 90,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['07 Sloth_Short_2'] = {
                SoundId = 91,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['08 Sloth_Slide'] = {
                SoundId = 92,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['09 Sloth_Slide_2'] = {
                SoundId = 93,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['01 Reap_Theme_Full'] = {
                SoundId = 94,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['02 Reap_Theme_Whistle+Perc'] = {
                SoundId = 95,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['03 Reap_Theme_Choir+Perc'] = {
                SoundId = 96,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['04 Reap_Theme_ChoirOnly'] = {
                SoundId = 97,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['05 Reap_Suspense_Full'] = {
                SoundId = 98,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['06 Reap_Shouts+Perc'] = {
                SoundId = 99,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['07 Reap_ShoutsOnly'] = {
                SoundId = 100,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['08 Reap_PercOnly'] = {
                SoundId = 101,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['09 Reap_Suspense_NoMel'] = {
                SoundId = 102,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['10 Reap_Susp_NoBassline'] = {
                SoundId = 103,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['11 Reap_Susp_NoBassline_NoMel'] = {
                SoundId = 104,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['12 Reap_Susp_MelOnly1'] = {
                SoundId = 105,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['13 Reap_Susp_MelOnly2'] = {
                SoundId = 106,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['14 Reap_Susp_MelOnly3'] = {
                SoundId = 107,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['15 Reap_Bumper1'] = {
                SoundId = 108,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['16 Reap_Bumper2'] = {
                SoundId = 109,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['17 Reap_Bumper3'] = {
                SoundId = 110,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['18 Reap_Bumper4'] = {
                SoundId = 111,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['19 Reap_Bumper5'] = {
                SoundId = 112,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['20 Reap_Bumper6'] = {
                SoundId = 113,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['21 Reap_Bumper7'] = {
                SoundId = 114,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['22 Reap_Bumper8'] = {
                SoundId = 115,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['01 Ro_MainTheme'] = {
                SoundId = 116,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['02 Ro_MainTheme_NoMel'] = {
                SoundId = 117,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['03 Ro_MainTheme_Hard'] = {
                SoundId = 118,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['04 Ro_MainTheme_Soft'] = {
                SoundId = 119,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['05 Ro_MainTheme_Gitr'] = {
                SoundId = 120,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['06 Ro_MainTheme_OnlyMel'] = {
                SoundId = 121,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['07 Ro_MainTheme_Hard_OnlyMel'] = {
                SoundId = 122,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['08 Ro_Susp'] = {
                SoundId = 123,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['09 Ro_Susp_NoMel'] = {
                SoundId = 124,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['10 Ro_Susp_PainoFig'] = {
                SoundId = 125,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['11 Ro_Susp_Swell1'] = {
                SoundId = 126,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['12 Ro_Susp_Swell2'] = {
                SoundId = 127,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['13 Ro_Susp_Swell3'] = {
                SoundId = 128,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['14 Ro_MainTheme_Fanfar_Hard'] = {
                SoundId = 129,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['15 Ro_MainTheme_Fanfar_Hard2'] = {
                SoundId = 130,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['16 Ro_MainTheme_Fanfar_Hard3'] = {
                SoundId = 131,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['01 Ular_Theme_Laidback'] = {
                SoundId = 132,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['02 Ular_Theme_Laidback_NoMel'] = {
                SoundId = 133,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['03 Ular_Theme_LessPerc'] = {
                SoundId = 134,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['04 Ular_Theme_MorePerc'] = {
                SoundId = 135,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['05 Ular_Theme_NoMel_MorePerc'] = {
                SoundId = 136,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['06 Ular_Theme_NoPerc'] = {
                SoundId = 137,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['07 Ular_Theme_Bumper1'] = {
                SoundId = 138,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['08 Ular_Theme_Bumper2'] = {
                SoundId = 139,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['09 Ular_Theme_Bumper3'] = {
                SoundId = 140,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['10 Ular_Theme_Bumper4'] = {
                SoundId = 141,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['11 Ular_Theme_Bumper5'] = {
                SoundId = 142,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['12 Ular_Theme_Bumper6'] = {
                SoundId = 143,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['13 Ular_Theme_Bumper7'] = {
                SoundId = 144,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['14 Ular_Theme_Bumper8'] = {
                SoundId = 145,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Extraction Sloth'] = {
                SoundId = 146,
            },
            ['Challenge'] = {
                SoundId = 147,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['MileHighClub'] = {
                SoundId = 148,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 850.0 },
                }
            },
            ['FrontEnd_Logos_Intro'] = {
                SoundId = 149,
            },
            ['FrontEnd_Startup_Theme'] = {
                SoundId = 150,
            },
            ['KM01_Gunner'] = {
                SoundId = 151,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM01_Landing'] = {
                SoundId = 152,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['01 Rico_Main_cut1'] = {
                SoundId = 153,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['01 Fighting'] = {
                SoundId = 154,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['02 Fighting'] = {
                SoundId = 155,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Prime_Combat_Max_Heat'] = {
                SoundId = 156,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Peak_Combat_Max_Heat'] = {
                SoundId = 157,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Heat_Combat_Max_Heat'] = {
                SoundId = 158,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Def_Tribal_Combat_Max_Heat'] = {
                SoundId = 159,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_Finale_Combat_Max_Heat'] = {
                SoundId = 160,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['km06 Ular_Theme_01'] = {
                SoundId = 161,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['15 Ular_Theme_NoMel_NoPerc_Suspense'] = {
                SoundId = 162,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['16 Ular_TribalGroove'] = {
                SoundId = 163,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cha_TheBrass_Max_Heat'] = {
                SoundId = 164,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f3m05_Reap_Broadcast'] = {
                SoundId = 165,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['MileHighClub_Combat'] = {
                SoundId = 166,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 850.0 },
                }
            },
            ['RICO_StrBumper'] = {
                SoundId = 167,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RICO_Bumper_4'] = {
                SoundId = 168,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['JC2-Theme - End Credits'] = {
                SoundId = 169,
            },
            ['Hud_Heat_Drone'] = {
                SoundId = 170,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 5.0 },
                }
            },
            ['PartyTent'] = {
                SoundId = 171,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['Settlement_Tracks_Region01'] = {
                SoundId = 172,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Tracks_Region02'] = {
                SoundId = 173,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Settlement_Tracks_Region03'] = {
                SoundId = 174,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['175 freeroam_night'] = {
                SoundId = 175,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['freeroam_day'] = {
                SoundId = 176,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['freeroam_race'] = {
                SoundId = 177,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['freeroam_vista_view'] = {
                SoundId = 178,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['End Credits'] = {
                SoundId = 179,
            },
            ['reap_stronghold_bumper'] = {
                SoundId = 180,
            },
            ['ro_stronghold_bumper'] = {
                SoundId = 181,
            },
            ['ular_stronghold_bumper'] = {
                SoundId = 182,
            },
            ['Emo_National_Anthem'] = {
                SoundId = 183,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Km02_On_Car_Roof'] = {
                SoundId = 184,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['grappling_hook'] = {
            BankID = 26,
            ['grappling_fire_wire'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['grappling_reel_loop'] = {
                SoundId = 1,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 80.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                    ['var'] = { Index = 3, Min = 0.0, Max = 4.0 },
                }
            },
            ['grappling_reel_back'] = {
                SoundId = 2,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['grappling_impact_def'] = {
                SoundId = 3,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['grappling_impact_rock'] = {
                SoundId = 4,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['grappling_impact_hardmetal'] = {
                SoundId = 5,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['grappling_impact_hollowmetal'] = {
                SoundId = 6,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['grappling_impact_body'] = {
                SoundId = 7,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['grappling_impact_dual'] = {
                SoundId = 8,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['grappling_detatch'] = {
                SoundId = 9,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['grappling_carstop'] = {
                SoundId = 10,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['grappling_detatch_dual'] = {
                SoundId = 11,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Common'] = {
            BankID = 28,
            ['64 - Intro'] = {
                SoundId = 64,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['00_KM00_02'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['01_KM00_04'] = {
                SoundId = 1,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['02_KM00_03'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['03 - (KM00_03_Dialog_tempfix)'] = {
                SoundId = 3,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['04_KM02_02A1'] = {
                SoundId = 4,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['05_KM02_02A'] = {
                SoundId = 5,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['06_KM02_02B'] = {
                SoundId = 6,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['10_KM04_05'] = {
                SoundId = 10,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['11_KM01_01B'] = {
                SoundId = 11,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['12_KM01_01C'] = {
                SoundId = 12,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['13_KM04_03'] = {
                SoundId = 13,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['14_KM03_01A'] = {
                SoundId = 14,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['15_KM04_01'] = {
                SoundId = 15,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['16_KM03_01B'] = {
                SoundId = 16,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['17_KM03_01C'] = {
                SoundId = 17,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['18_KM01_02'] = {
                SoundId = 18,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['19_KM06_09'] = {
                SoundId = 19,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM03_00B'] = {
                SoundId = 21,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM04_06'] = {
                SoundId = 22,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM05_01'] = {
                SoundId = 23,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM05_01B'] = {
                SoundId = 24,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM05_02A'] = {
                SoundId = 25,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM05_02B'] = {
                SoundId = 26,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM05_02C'] = {
                SoundId = 27,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM05_02D'] = {
                SoundId = 28,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM05_02E'] = {
                SoundId = 29,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['30_KM05_03'] = {
                SoundId = 30,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM06_08'] = {
                SoundId = 31,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM07_01'] = {
                SoundId = 32,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM07_02'] = {
                SoundId = 33,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM07_04'] = {
                SoundId = 34,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM07_07'] = {
                SoundId = 35,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM03_03'] = {
                SoundId = 48,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM01_00'] = {
                SoundId = 49,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['50 - (KM01??)'] = {
                SoundId = 50,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM01_01'] = {
                SoundId = 51,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM01_03'] = {
                SoundId = 54,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM05_03'] = {
                SoundId = 57,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM02_03'] = {
                SoundId = 58,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['KM02_03B'] = {
                SoundId = 59,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['66 - KM03_00C'] = {
                SoundId = 66,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['67 - KM03_00D'] = {
                SoundId = 67,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['68 - KM02_00'] = {
                SoundId = 68,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['69 - KM03_00A'] = {
                SoundId = 69,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['70 - KM03_00E'] = {
                SoundId = 70,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['71 - KM04_00'] = {
                SoundId = 71,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['72 - KM04_06B'] = {
                SoundId = 72,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['73 - KM06_01'] = {
                SoundId = 73,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['74 - KM06_02'] = {
                SoundId = 74,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['75 - KM06_02B'] = {
                SoundId = 75,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['76 - KM06_03'] = {
                SoundId = 76,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['77 - KM06_04'] = {
                SoundId = 77,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['78 - KM06_04B'] = {
                SoundId = 78,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['79 - KM06_10'] = {
                SoundId = 79,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['87 - KM03_03B'] = {
                SoundId = 87,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['88 - KM04_00B'] = {
                SoundId = 88,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['89 - KM06_03B'] = {
                SoundId = 89,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['90 - Fxsxb'] = {
                SoundId = 90,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['91 - f1s02'] = {
                SoundId = 91,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['92 - f1s03'] = {
                SoundId = 92,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['93 - f2s07'] = {
                SoundId = 93,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['94 - f2s01'] = {
                SoundId = 94,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['95 - f3s06'] = {
                SoundId = 95,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['96 - f3s04'] = {
                SoundId = 96,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['97 f2m05_micro_01'] = {
                SoundId = 97,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['98 f2m08_micro_01'] = {
                SoundId = 98,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['99 - Benchmark 1'] = {
                SoundId = 99,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['100 - Benchmark 2'] = {
                SoundId = 100,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['101 - Benchmark 3'] = {
                SoundId = 101,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['07_KM02_mini_Heli'] = {
                SoundId = 7,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['08_KM02_mini_TowerExplode'] = {
                SoundId = 8,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['08_KM02_mini_Bomber'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['20_KM04_mini_sub'] = {
                SoundId = 20,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['65 - KM01_micro_02 (sams)'] = {
                SoundId = 65,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f1_00a'] = {
                SoundId = 36,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f1_00b'] = {
                SoundId = 37,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f1_01'] = {
                SoundId = 38,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f1_01b'] = {
                SoundId = 39,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['40_f2_00a'] = {
                SoundId = 40,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f2_00b'] = {
                SoundId = 41,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f2_01'] = {
                SoundId = 42,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f2_01b'] = {
                SoundId = 43,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f2s04'] = {
                SoundId = 44,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f3_01'] = {
                SoundId = 45,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f3_01b'] = {
                SoundId = 46,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f3s01'] = {
                SoundId = 47,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f3s01b'] = {
                SoundId = 52,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f2s04b'] = {
                SoundId = 53,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f1s07'] = {
                SoundId = 55,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['f1s07b'] = {
                SoundId = 56,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['60 - f3t-bus'] = {
                SoundId = 60,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 10.0 },
                }
            },
            ['61 - f-boat'] = {
                SoundId = 61,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 30.0 },
                }
            },
            ['62 - f-jeep'] = {
                SoundId = 62,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 10.0 },
                }
            },
            ['63 - f3t04'] = {
                SoundId = 63,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['80 - f-speedboat'] = {
                SoundId = 80,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['timeline'] = { Index = 1, Min = 0.0, Max = 30.0 },
                }
            },
            ['81 - F1_02'] = {
                SoundId = 81,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['82 - F1_03'] = {
                SoundId = 82,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['83 - F2_02'] = {
                SoundId = 83,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['84 - F2_03'] = {
                SoundId = 84,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['85 - F3_02'] = {
                SoundId = 85,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['86 - F3_03'] = {
                SoundId = 86,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Acoustics'] = {
            BankID = 3,
            ['SlapBack_OpenField_FarOff'] = {
                SoundId = 0,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['automation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['EarlyReflection_AR_Ridge'] = {
                SoundId = 1,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['automation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['EarlyReflection_MiniGun_Ridge'] = {
                SoundId = 2,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['automation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['EarlyReflection_SMG_Ridge'] = {
                SoundId = 3,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['automation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['EarlyReflection_Sentry_Ridge'] = {
                SoundId = 4,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['automation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['EarlyReflection_Sniper_Ridge'] = {
                SoundId = 5,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 1000.0 },
                    ['automation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['EarlyReflection_Cannon/FLAK_Ridge'] = {
                SoundId = 6,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 2000.0 },
                    ['automation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Revolver_Acoustics'] = {
                SoundId = 7,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 2000.0 },
                    ['automation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['DLC_Airzooka_slap'] = {
                SoundId = 8,
                Parameters = {
                    ['distance'] = { Index = 0, Min = 0.0, Max = 2000.0 },
                    ['automation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Mission Specific'] = {
            BankID = 30,
            ['combat_'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 160.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['wsim_'] = {
                SoundId = 1,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 74.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['general'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Machines_Engines'] = {
            BankID = 31,
            ['12_Communication_Station'] = {
                SoundId = 12,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 30.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['14'] = {
                SoundId = 14,
            },
            ['f3m05 - Pirate Dish'] = {
                SoundId = 24,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Satelite Core Buzz'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 30.0 },
                }
            },
            ['Zeppelin Engine'] = {
                SoundId = 1,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Elevator Engine'] = {
                SoundId = 2,
                Parameters = {
                    ['timelinee'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Large Dish Servo'] = {
                SoundId = 3,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Small Dish Servo'] = {
                SoundId = 4,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Huge Dish Servo'] = {
                SoundId = 5,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 600.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Motorhouse_Skilift'] = {
                SoundId = 6,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Fan'] = {
                SoundId = 7,
                Parameters = {
                    ['Focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                }
            },
            ['Motorhouse'] = {
                SoundId = 8,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 40.0 },
                }
            },
            ['Pulley By'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                }
            },
            ['PulleyOnboard'] = {
                SoundId = 10,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 25.0 },
                }
            },
            ['11_Arctic_Radar'] = {
                SoundId = 11,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 40.0 },
                }
            },
            ['13_Turbine'] = {
                SoundId = 13,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Retract Wires Underwater'] = {
                SoundId = 15,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Skilift By'] = {
                SoundId = 17,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Electric_Trafo_Station'] = {
                SoundId = 18,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 6.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 30.0 },
                }
            },
            ['Electric_Tower_Small'] = {
                SoundId = 19,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 1.0 },
                }
            },
            ['Barge'] = {
                SoundId = 20,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['f3m05 - Huge Dish Creaks'] = {
                SoundId = 23,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Samsite_doors'] = {
                SoundId = 22,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Tram Start Signal'] = {
                SoundId = 16,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 25.0 },
                }
            },
            ['ChurchBells'] = {
                SoundId = 21,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['timeofday'] = { Index = 2, Min = 0.0, Max = 24.0 },
                }
            },
        },
        ['Ambiences_Environments'] = {
            BankID = 32,
            ['Sewer (Empty)'] = {
                SoundId = 3,
            },
            ['Canal (Empty)'] = {
                SoundId = 6,
            },
            ['Distant Firefight 1(Empty)'] = {
                SoundId = 8,
            },
            ['empty_10'] = {
                SoundId = 19,
            },
            ['empty_19'] = {
                SoundId = 20,
            },
            ['AC Broken (Empty)'] = {
                SoundId = 21,
            },
            ['SawMill House'] = {
                SoundId = 0,
                Parameters = {
                    ['variation'] = { Index = 0, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 70.0 },
                }
            },
            ['SawMill Round Thingie'] = {
                SoundId = 1,
                Parameters = {
                    ['variation'] = { Index = 0, Min = 0.0, Max = 30.0 },
                    ['Focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 30.0 },
                }
            },
            ['AC'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Roof Ventilationduct'] = {
                SoundId = 10,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Voltage Overtone'] = {
                SoundId = 22,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['Server Room'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Waterfall (To Tight Loop?)'] = {
                SoundId = 4,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 400.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 2, Min = 0.0, Max = 10.0 },
                }
            },
            ['dome_ambience'] = {
                SoundId = 5,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 130.0 },
                    ['variation'] = { Index = 2, Min = 0.0, Max = 45.0 },
                }
            },
            ['Drug_Factory_Amb'] = {
                SoundId = 7,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                }
            },
            ['Windchimes'] = {
                SoundId = 11,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Signs Hum'] = {
                SoundId = 12,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Store_Restau_TV'] = {
                SoundId = 13,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Store_Restau_Music'] = {
                SoundId = 14,
            },
            ['WindonBridge'] = {
                SoundId = 15,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Fountain Idle'] = {
                SoundId = 16,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 2, Min = 0.0, Max = 30.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 100.0 },
                }
            },
            ['Fountain Gush Large'] = {
                SoundId = 17,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['Casino Amb (Redundant?)'] = {
                SoundId = 18,
            },
            ['Underwater Bubbles'] = {
                SoundId = 23,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 200.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                }
            },
            ['Electric Fence'] = {
                SoundId = 24,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 30.0 },
                }
            },
        },
        ['Doors'] = {
            BankID = 33,
            ['empty_20'] = {
                SoundId = 6,
            },
            ['Sluss_door'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Metal Door Slam'] = {
                SoundId = 1,
                Parameters = {
                    ['Focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Dish Door'] = {
                SoundId = 2,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Stone Door'] = {
                SoundId = 3,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 1.5 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                }
            },
            ['Dam Door'] = {
                SoundId = 4,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 200.0 },
                }
            },
            ['Metal Door'] = {
                SoundId = 5,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Weapons_Explos'] = {
            BankID = 34,
            ['empty_8'] = {
                SoundId = 0,
            },
        },
        ['Gadgets'] = {
            BankID = 35,
            ['empty_4'] = {
                SoundId = 0,
            },
            ['empty_3'] = {
                SoundId = 1,
            },
            ['empty_2'] = {
                SoundId = 2,
            },
            ['empty'] = {
                SoundId = 3,
            },
            ['empty_18'] = {
                SoundId = 7,
            },
            ['Control_Panel_On'] = {
                SoundId = 4,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Control_Panel_Off'] = {
                SoundId = 5,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['Control_Panel_Done'] = {
                SoundId = 6,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 15.0 },
                }
            },
            ['Disarm'] = {
                SoundId = 8,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Panel Button'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 25.0 },
                }
            },
        },
        ['Wheather'] = {
            BankID = 36,
            ['Lightning'] = {
                SoundId = 0,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 30000.0 },
                    ['Timeline'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Rain_HardSurface'] = {
                SoundId = 1,
                Parameters = {
                    ['precipitation'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                }
            },
            ['Rain_SoftSurface'] = {
                SoundId = 2,
                Parameters = {
                    ['precipitation'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                }
            },
            ['Rain_Water'] = {
                SoundId = 3,
                Parameters = {
                    ['precipitation'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                }
            },
        },
        ['Explos'] = {
            BankID = 37,
            ['17 - expl_antenna_destroy'] = {
                SoundId = 17,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 400.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 4.0 },
                }
            },
            ['_24'] = {
                SoundId = 24,
            },
            ['_25'] = {
                SoundId = 25,
            },
            ['_26'] = {
                SoundId = 26,
            },
            ['_27'] = {
                SoundId = 27,
            },
            ['_28'] = {
                SoundId = 28,
            },
            ['_29'] = {
                SoundId = 29,
            },
            ['_30'] = {
                SoundId = 30,
            },
            ['_31'] = {
                SoundId = 31,
            },
            ['Space Rocket Engine'] = {
                SoundId = 36,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 2, Min = 0.0, Max = 30.0 },
                }
            },
            ['Space Rocket Take Off'] = {
                SoundId = 37,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 2, Min = 0.0, Max = 30.0 },
                }
            },
            ['_41'] = {
                SoundId = 41,
            },
            ['Silosphere'] = {
                SoundId = 0,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 6.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 400.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Electric Small'] = {
                SoundId = 1,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 1.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['2 - Electric Medium'] = {
                SoundId = 2,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 75.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Electric Large'] = {
                SoundId = 3,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Metal Chamber Huge'] = {
                SoundId = 9,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1200.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Metal Chamber Large'] = {
                SoundId = 10,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1200.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Metal Chamber Medium'] = {
                SoundId = 11,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1200.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Metal Chamber Small'] = {
                SoundId = 12,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Underwater Explosion'] = {
                SoundId = 13,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['14 - nodraket'] = {
                SoundId = 14,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Barrel Explode'] = {
                SoundId = 15,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['18 - Airplane Burning Engine'] = {
                SoundId = 18,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 300.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['20 - Checkpoint Complete'] = {
                SoundId = 20,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 300.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['32 - Airplane Crash'] = {
                SoundId = 32,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Blimp Explode'] = {
                SoundId = 34,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Tire Explosion'] = {
                SoundId = 35,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 90.0 },
                }
            },
            ['38 - Space Rocket Explode (PH)'] = {
                SoundId = 38,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 800.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['EMT Tower Explode'] = {
                SoundId = 40,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 7.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['42 - Glassdome falling'] = {
                SoundId = 42,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 15.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Canon_Explode'] = {
                SoundId = 43,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 500.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['MetalGate_Explode'] = {
                SoundId = 44,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Watermine Explosion'] = {
                SoundId = 45,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 6.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 500.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Sub_Missile_Explo'] = {
                SoundId = 47,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Temple Explosion'] = {
                SoundId = 48,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['50 - km07 cylinder e'] = {
                SoundId = 50,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['km07 cylinder L1'] = {
                SoundId = 51,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 700.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['km07 cylinder L2'] = {
                SoundId = 52,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 500.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['km07 G'] = {
                SoundId = 53,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 3.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['km07 T3'] = {
                SoundId = 54,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Explo Resource Fuel Depot'] = {
                SoundId = 55,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 8.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 600.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Lave Explosion'] = {
                SoundId = 57,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Glass cover f1m03'] = {
                SoundId = 58,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['f1m08 fireplume'] = {
                SoundId = 59,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 1.8 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['60 - f2m07 icebreak'] = {
                SoundId = 60,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['f2m05 building destroyed'] = {
                SoundId = 61,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 5.5 },
                }
            },
            ['f2m05 gate explosion'] = {
                SoundId = 62,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Lave Large Explosion'] = {
                SoundId = 63,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Seve Explosion'] = {
                SoundId = 64,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Helicopter & Plane Explosion'] = {
                SoundId = 65,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 300.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['f2m08 satellite explo'] = {
                SoundId = 66,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 6.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Big Plane Explosion'] = {
                SoundId = 67,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 7.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 700.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['f3m05 dish explosion'] = {
                SoundId = 69,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 7.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 600.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['f2m06 emptower active (PH)'] = {
                SoundId = 73,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 20.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['f2m06 emptower pulse (PH)'] = {
                SoundId = 74,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 8.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 7000.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['f2m05 millround explo'] = {
                SoundId = 75,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 7.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Light Pillar km02'] = {
                SoundId = 77,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Nuke Engine'] = {
                SoundId = 78,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 80.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 2, Min = 0.0, Max = 30.0 },
                }
            },
            ['Lasers'] = {
                SoundId = 79,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 80.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['timeline'] = { Index = 2, Min = 0.0, Max = 10.0 },
                }
            },
            ['80 ninja'] = {
                SoundId = 80,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['16 - tower env_gb87_dest'] = {
                SoundId = 16,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['39 - Airplane Hit'] = {
                SoundId = 39,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 5.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Glasscrash'] = {
                SoundId = 46,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['71 - f3m05 dish impact'] = {
                SoundId = 71,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 7.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Wooden Crate'] = {
                SoundId = 23,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 1.5 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Wooden Fence'] = {
                SoundId = 76,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 2.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['21 - Headlight Explo'] = {
                SoundId = 21,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 60.0 },
                }
            },
            ['Fuel Burning Small'] = {
                SoundId = 4,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['5 - Fuel Burning Medium'] = {
                SoundId = 5,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Fuel Burning Large'] = {
                SoundId = 6,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['7 - Gas'] = {
                SoundId = 7,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['time'] = { Index = 2, Min = 0.0, Max = 10.0 },
                }
            },
            ['8 - Steam'] = {
                SoundId = 8,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 80.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['19 - Checkpoint Flash'] = {
                SoundId = 19,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 600.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 2, Min = 0.0, Max = 30.0 },
                }
            },
            ['22 - Airplane Broken Engine'] = {
                SoundId = 22,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Blimp On Fire'] = {
                SoundId = 33,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 2000.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 20.0 },
                }
            },
            ['Water Cascade'] = {
                SoundId = 68,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 20.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['f2m06 empfence (PH)'] = {
                SoundId = 72,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 0.4 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 150.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Engine damage'] = {
                SoundId = 49,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Eng misfire'] = {
                SoundId = 56,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['70 - f3m05 dish debris'] = {
                SoundId = 70,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 2, Min = 0.0, Max = 30.0 },
                }
            },
        },
        ['Dialog Effects'] = {
            BankID = 38,
            ['RadioComm_Agency_Dial'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Agency_Off'] = {
                SoundId = 1,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Agency_On'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_BlackHand_Dial'] = {
                SoundId = 3,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_BlackHand_Off'] = {
                SoundId = 4,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_BlackHand_On'] = {
                SoundId = 5,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Gov_Dial'] = {
                SoundId = 6,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Gov_Off'] = {
                SoundId = 7,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Gov_On'] = {
                SoundId = 8,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Reapers_Dial'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Reapers_Off'] = {
                SoundId = 10,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Reapers_On'] = {
                SoundId = 11,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Roaches_Dial'] = {
                SoundId = 12,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Roaches_Off'] = {
                SoundId = 13,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Roaches_On'] = {
                SoundId = 14,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Ular_Dial'] = {
                SoundId = 15,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Ular_Off'] = {
                SoundId = 16,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Ular_On'] = {
                SoundId = 17,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Broadcast_OnOff'] = {
                SoundId = 18,
                Parameters = {
                    ['param00'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Sheldon_Off'] = {
                SoundId = 19,
                Parameters = {
                    ['param00'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
            ['RadioComm_Sheldon_On'] = {
                SoundId = 20,
                Parameters = {
                    ['param00'] = { Index = 0, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['PostEffects'] = {
            BankID = 39,
            ['PostExplosion_All_Small'] = {
                SoundId = 0,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 2, Min = 0.0, Max = 30.0 },
                }
            },
            ['PostExplosion_All_Medium'] = {
                SoundId = 1,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 2, Min = 0.0, Max = 30.0 },
                }
            },
            ['PostExplosion_All_Large'] = {
                SoundId = 2,
                Parameters = {
                    ['(distance)'] = { Index = 0, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 2, Min = 0.0, Max = 30.0 },
                }
            },
            ['Rumble_Small'] = {
                SoundId = 3,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Rumble_Medium'] = {
                SoundId = 4,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Rumble_Large'] = {
                SoundId = 5,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Stone_Small'] = {
                SoundId = 6,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Stone_Medium'] = {
                SoundId = 7,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Stone_Large'] = {
                SoundId = 8,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Fire_Small'] = {
                SoundId = 9,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Fire_Medium'] = {
                SoundId = 10,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Fire_Large'] = {
                SoundId = 11,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Metal_Small'] = {
                SoundId = 12,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Metal_Medium'] = {
                SoundId = 13,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Metal_Large'] = {
                SoundId = 14,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Wood_Small'] = {
                SoundId = 15,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Wood_Medium'] = {
                SoundId = 16,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Wood_Large'] = {
                SoundId = 17,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Glass_Small'] = {
                SoundId = 18,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Glass_Medium'] = {
                SoundId = 19,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Glass_Large'] = {
                SoundId = 20,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
            ['Debris_Metal_Constraints'] = {
                SoundId = 21,
                Parameters = {
                    ['timeline'] = { Index = 0, Min = 0.0, Max = 4.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 3, Min = 0.0, Max = 30.0 },
                }
            },
        },
        ['Chassis'] = {
            BankID = 4,
            ['1'] = {
                SoundId = 1,
            },
            ['Chassi Wind'] = {
                SoundId = 0,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 42.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Chassi Wind & Noise'] = {
                SoundId = 2,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 42.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 30.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['suspension'] = {
                SoundId = 3,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['length_difference_per_frame'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
        },
        ['PA'] = {
            BankID = 40,
            ['crowds'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['dpv_baby_m_qq_01'] = {
                SoundId = 1,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['dpv_baby_m_qq_02'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['dpv_baby_m_qq_03'] = {
                SoundId = 3,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['dpv_baby_m_qq_04'] = {
                SoundId = 4,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['f1s02_govelite_m_qq_01'] = {
                SoundId = 5,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f1s02_govelite_m_qq_02'] = {
                SoundId = 6,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f1s02_govelite_m_qq_03'] = {
                SoundId = 7,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f1s02_govelite_m_qq_04'] = {
                SoundId = 8,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f1s02_govelite_m_qq_05'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f1s07_govelite_m_qq_01'] = {
                SoundId = 10,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f1s07_govelite_m_qq_02'] = {
                SoundId = 11,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f1s07_govelite_m_qq_03'] = {
                SoundId = 12,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f1s07_govelite_m_qq_04'] = {
                SoundId = 13,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f1s07_govelite_m_qq_05'] = {
                SoundId = 14,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f2m07_govelite1_zz_m_04'] = {
                SoundId = 15,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f2m07_scientist_zz_m_03'] = {
                SoundId = 16,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f2m07_scientist_zz_m_031'] = {
                SoundId = 17,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f2s04_govelite_m_qq_01'] = {
                SoundId = 18,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f2s04_govelite_m_qq_02'] = {
                SoundId = 19,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f2s04_govelite_m_qq_03'] = {
                SoundId = 20,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f2s04_govelite_m_qq_04'] = {
                SoundId = 21,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f2s04_govelite_m_qq_05'] = {
                SoundId = 22,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f2s07_govelite_m_qq_01'] = {
                SoundId = 23,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f2s07_govelite_m_qq_02'] = {
                SoundId = 24,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f2s07_govelite_m_qq_03'] = {
                SoundId = 25,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f2s07_govelite_m_qq_04'] = {
                SoundId = 26,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f2s07_govelite_m_qq_05'] = {
                SoundId = 27,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f3m04_female_zz_f_01'] = {
                SoundId = 28,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                }
            },
            ['f3m04_female_zz_f_02'] = {
                SoundId = 29,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                }
            },
            ['f3m04_female_zz_f_03'] = {
                SoundId = 30,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                }
            },
            ['f3m04_female_zz_f_04'] = {
                SoundId = 31,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                }
            },
            ['f3m04_female_zz_f_05'] = {
                SoundId = 32,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                }
            },
            ['f3m04_female_zz_f_06'] = {
                SoundId = 33,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                }
            },
            ['f3m04_female_zz_f_07'] = {
                SoundId = 34,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                }
            },
            ['f3m04_female_zz_f_08'] = {
                SoundId = 35,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                }
            },
            ['f3m04_female_zz_f_09'] = {
                SoundId = 36,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                }
            },
            ['f3m04_female_zz_f_10'] = {
                SoundId = 37,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                }
            },
            ['f3m04_female_zz_f_11'] = {
                SoundId = 38,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                }
            },
            ['f3m04_female_zz_f_12'] = {
                SoundId = 39,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1500.0 },
                }
            },
            ['f3s01_govelite_m_qq_01'] = {
                SoundId = 40,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f3s01_govelite_m_qq_02'] = {
                SoundId = 41,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f3s01_govelite_m_qq_03'] = {
                SoundId = 42,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f3s01_govelite_m_qq_04'] = {
                SoundId = 43,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f3s01_govelite_m_qq_05'] = {
                SoundId = 44,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f3s06_govelite_m_qq_01'] = {
                SoundId = 45,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f3s06_govelite_m_qq_02'] = {
                SoundId = 46,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f3s06_govelite_m_qq_03'] = {
                SoundId = 47,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['f3s06_govelite_m_qq_04'] = {
                SoundId = 48,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['gen_govpilot_m_qq_01'] = {
                SoundId = 49,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['gen_govpilot_m_qq_02'] = {
                SoundId = 50,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['gen_govpilot_m_qq_03'] = {
                SoundId = 51,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km04_govelite1_m_qq_02'] = {
                SoundId = 52,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km06_female_zz_01'] = {
                SoundId = 53,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km06_female_zz_02'] = {
                SoundId = 54,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_01'] = {
                SoundId = 55,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_02'] = {
                SoundId = 56,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_03'] = {
                SoundId = 57,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_04'] = {
                SoundId = 58,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_05'] = {
                SoundId = 59,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_06'] = {
                SoundId = 60,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_07'] = {
                SoundId = 61,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_08'] = {
                SoundId = 62,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_09'] = {
                SoundId = 63,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_10'] = {
                SoundId = 64,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_11'] = {
                SoundId = 65,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_12'] = {
                SoundId = 66,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_13'] = {
                SoundId = 67,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['km07_countdown_f_qq_14'] = {
                SoundId = 68,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp1_m_qq_01'] = {
                SoundId = 69,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp1_m_qq_02'] = {
                SoundId = 70,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp1_m_qq_03'] = {
                SoundId = 71,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp1_m_qq_04'] = {
                SoundId = 72,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp1_m_qq_05'] = {
                SoundId = 73,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp1_m_qq_06'] = {
                SoundId = 74,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp1_m_qq_07'] = {
                SoundId = 75,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp1_m_qq_08'] = {
                SoundId = 76,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp1_m_qq_09'] = {
                SoundId = 77,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp1_m_qq_10'] = {
                SoundId = 78,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp2_m_qq_01'] = {
                SoundId = 79,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp2_m_qq_02'] = {
                SoundId = 80,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp2_m_qq_03'] = {
                SoundId = 81,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp2_m_qq_04'] = {
                SoundId = 82,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp2_m_qq_05'] = {
                SoundId = 83,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp2_m_qq_06'] = {
                SoundId = 84,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp2_m_qq_07'] = {
                SoundId = 85,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp2_m_qq_08'] = {
                SoundId = 86,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp2_m_qq_09'] = {
                SoundId = 87,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['wsim_govmp2_m_qq_10'] = {
                SoundId = 88,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['dpv_baby_m_qq_05'] = {
                SoundId = 89,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['dpv_baby_m_qq_06'] = {
                SoundId = 90,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['dpv_baby_m_qq_07'] = {
                SoundId = 91,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['dpv_baby_m_qq_08'] = {
                SoundId = 92,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['dpv_baby_m_qq_09'] = {
                SoundId = 93,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['dpv_baby_m_qq_10'] = {
                SoundId = 94,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['dpv_baby_m_qq_11'] = {
                SoundId = 95,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['dpv_baby_m_qq_12'] = {
                SoundId = 96,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['dpv_baby_m_qq_13'] = {
                SoundId = 97,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['km04_govelite1_m_qq_01'] = {
                SoundId = 98,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
            ['cut0401_baby_m_qq_01'] = {
                SoundId = 99,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 1000.0 },
                }
            },
        },
        ['Traffic'] = {
            BankID = 41,
            ['Traffic'] = {
                SoundId = 0,
                Parameters = {
                    ['amount'] = { Index = 0, Min = 0.0, Max = 20.0 },
                    ['average distance'] = { Index = 1, Min = 0.0, Max = 300.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['height'] = { Index = 3, Min = 0.0, Max = 400.0 },
                    ['variation'] = { Index = 4, Min = 0.0, Max = 30.0 },
                }
            },
        },
        ['crowds'] = {
            BankID = 42,
            ['Crowd_General_City_Amb'] = {
                SoundId = 0,
                Parameters = {
                    ['size'] = { Index = 0, Min = 0.0, Max = 0.5 },
                    ['panic'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['variation'] = { Index = 2, Min = 0.0, Max = 40.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 200.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['3dspread'] = { Index = 5, Min = 0.0, Max = 1.0 },
                }
            },
        },
        ['Engines'] = {
            BankID = 5,
            ['11'] = {
                SoundId = 11,
            },
            ['12'] = {
                SoundId = 12,
            },
            ['13'] = {
                SoundId = 13,
            },
            ['17'] = {
                SoundId = 17,
            },
            ['62'] = {
                SoundId = 81,
            },
            ['63'] = {
                SoundId = 82,
            },
            ['64'] = {
                SoundId = 83,
            },
            ['78'] = {
                SoundId = 97,
            },
            ['79'] = {
                SoundId = 98,
            },
            ['Hummer Engine'] = {
                SoundId = 0,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 4000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Hummer Engine Bludder'] = {
                SoundId = 1,
                Parameters = {
                    ['oneshot'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Hummer Start'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Hummer Stop'] = {
                SoundId = 3,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['BigTruck Engine'] = {
                SoundId = 4,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 3000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['BigTruck Engine Gear'] = {
                SoundId = 5,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['BigTruck Start'] = {
                SoundId = 6,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['BigTruck Stop'] = {
                SoundId = 7,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Small Sedan'] = {
                SoundId = 8,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 5000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Small Sedan Start'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Small Sedan Stop'] = {
                SoundId = 10,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Challenger'] = {
                SoundId = 19,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 6000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Cheyenne'] = {
                SoundId = 20,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 5000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Cheyenne startup'] = {
                SoundId = 21,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Cheyenne engstop'] = {
                SoundId = 22,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Moped 2 taktare'] = {
                SoundId = 29,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 8500.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Moped startup'] = {
                SoundId = 30,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Moped engstop'] = {
                SoundId = 31,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Traktor'] = {
                SoundId = 32,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 2700.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Traktor startup'] = {
                SoundId = 33,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Traktor engstop'] = {
                SoundId = 34,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Jeep'] = {
                SoundId = 35,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 4200.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Jeep startup'] = {
                SoundId = 36,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Jeep engstop'] = {
                SoundId = 37,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Corvette'] = {
                SoundId = 38,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 7500.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Corvette startup'] = {
                SoundId = 39,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Corvette engstop'] = {
                SoundId = 40,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Dirtbike'] = {
                SoundId = 44,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 12000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Dirtbike startup'] = {
                SoundId = 45,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Dirtbike engstop'] = {
                SoundId = 46,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Harley'] = {
                SoundId = 47,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 5500.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Harley startup'] = {
                SoundId = 48,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Harley engstop'] = {
                SoundId = 49,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Kawasaki'] = {
                SoundId = 50,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 13500.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Kawasaki startup'] = {
                SoundId = 51,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Kawasaki engstop'] = {
                SoundId = 52,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Skoter startup - Empty'] = {
                SoundId = 53,
            },
            ['Skoter engstop - Empty'] = {
                SoundId = 54,
            },
            ['ATV_engine'] = {
                SoundId = 55,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 10000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['ATV startup'] = {
                SoundId = 56,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['ATV engstop'] = {
                SoundId = 57,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Challenger startup'] = {
                SoundId = 58,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Challenger engstop'] = {
                SoundId = 59,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Vespa'] = {
                SoundId = 60,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 8000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Vespa startup'] = {
                SoundId = 61,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Vespa engstop'] = {
                SoundId = 62,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Tank'] = {
                SoundId = 63,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 4000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Turning agg - Empty'] = {
                SoundId = 64,
            },
            ['Tank startup'] = {
                SoundId = 65,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Tank engstop'] = {
                SoundId = 66,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Bus'] = {
                SoundId = 67,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 4500.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Bus startup'] = {
                SoundId = 68,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Bus engstop'] = {
                SoundId = 69,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Passat'] = {
                SoundId = 71,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 7000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Passat startup'] = {
                SoundId = 72,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Passat engstop'] = {
                SoundId = 73,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Brake Noise'] = {
                SoundId = 74,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['timeline'] = { Index = 2, Min = 0.0, Max = 4.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Turbo Noise'] = {
                SoundId = 75,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Backfires'] = {
                SoundId = 76,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Engine Flutter'] = {
                SoundId = 77,
                Parameters = {
                    ['oneshot'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Ferrari 430'] = {
                SoundId = 78,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 8500.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Ferrari startup'] = {
                SoundId = 79,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Ferrari eng stop'] = {
                SoundId = 80,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Longtail'] = {
                SoundId = 87,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 4000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                }
            },
            ['Longtail startup'] = {
                SoundId = 88,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['Longtail engstop'] = {
                SoundId = 89,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                }
            },
            ['BMW R1100S'] = {
                SoundId = 90,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 8000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['BMW R1100S startup'] = {
                SoundId = 91,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['BMW R1100S engstop'] = {
                SoundId = 92,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Monster Truck'] = {
                SoundId = 106,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 3000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Monster Truck Start'] = {
                SoundId = 107,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Monster Truck Stop'] = {
                SoundId = 108,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Speedboat'] = {
                SoundId = 23,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 4500.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 300.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Speedboat startup'] = {
                SoundId = 24,
                Parameters = {
                    ['Focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Speedboat engstop'] = {
                SoundId = 25,
                Parameters = {
                    ['Focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Big boat'] = {
                SoundId = 26,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 4000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 300.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Big boat startup'] = {
                SoundId = 27,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Big boat engstop'] = {
                SoundId = 28,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Hovercraft'] = {
                SoundId = 103,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 7000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 250.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Transport Helicopter'] = {
                SoundId = 14,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 4000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Transport Heli engstart'] = {
                SoundId = 15,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                    ['param02'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Transport Heli engstop'] = {
                SoundId = 16,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                    ['param02'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Jet_JAS'] = {
                SoundId = 18,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 9000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Jet helicopter'] = {
                SoundId = 41,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 8000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Jet helicopter startup'] = {
                SoundId = 42,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Jet helicopter engstop'] = {
                SoundId = 43,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                    ['param02'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Helicopter R44'] = {
                SoundId = 70,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 2200.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 5, Min = -180.0, Max = 180.0 },
                }
            },
            ['Cessna'] = {
                SoundId = 84,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 2900.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                }
            },
            ['Cessna startup'] = {
                SoundId = 85,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['Cessna engstop'] = {
                SoundId = 86,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['New BigJet Plane'] = {
                SoundId = 93,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 9000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                }
            },
            ['Small_Jet _Plane'] = {
                SoundId = 94,
                Parameters = {
                    ['rpm'] = { Index = 0, Min = 0.0, Max = 8000.0 },
                    ['load'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['damage'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 3, Min = 0.0, Max = 1000.0 },
                    ['focus'] = { Index = 4, Min = 0.0, Max = 1.0 },
                }
            },
            ['Small Jet startup'] = {
                SoundId = 95,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                    ['param02'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Small Jet engstop'] = {
                SoundId = 96,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['R44  startup'] = {
                SoundId = 99,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['R44 engstop'] = {
                SoundId = 100,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['Jet Fighter  startup'] = {
                SoundId = 101,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['Jet Fighter engstop'] = {
                SoundId = 102,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['Hovercraft Startup'] = {
                SoundId = 104,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
            ['Hovercraft Engstop'] = {
                SoundId = 105,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 200.0 },
                }
            },
        },
        ['FX'] = {
            BankID = 6,
            ['Horn medium'] = {
                SoundId = 0,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 300.0 },
                    ['velocity'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Door Big Open'] = {
                SoundId = 1,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Door Big Close'] = {
                SoundId = 2,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Door Small Open'] = {
                SoundId = 3,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Door Small Close'] = {
                SoundId = 4,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Reverse Warning Beep'] = {
                SoundId = 5,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 300.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                    ['time'] = { Index = 3, Min = 0.0, Max = 2.0 },
                }
            },
            ['Ice Cream'] = {
                SoundId = 6,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 500.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['CarAlarm 1'] = {
                SoundId = 7,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 250.0 },
                    ['timer'] = { Index = 2, Min = 0.0, Max = 20.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['HeliAlarm'] = {
                SoundId = 8,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 1, Min = -180.0, Max = 180.0 },
                }
            },
            ['Arve_Door_Slide'] = {
                SoundId = 9,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 20.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['LAVE_Siren'] = {
                SoundId = 10,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 500.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Ice Cream Pimped'] = {
                SoundId = 11,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 500.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                }
            },
            ['Horn big'] = {
                SoundId = 12,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 300.0 },
                    ['velocity'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Horn small'] = {
                SoundId = 13,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 300.0 },
                    ['velocity'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Horn truck 1'] = {
                SoundId = 14,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 300.0 },
                    ['velocity'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Horn truck 2'] = {
                SoundId = 15,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 300.0 },
                    ['velocity'] = { Index = 2, Min = 0.0, Max = 1.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Military Siren'] = {
                SoundId = 16,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 500.0 },
                    ['(listener angle)'] = { Index = 2, Min = -180.0, Max = 180.0 },
                    ['timeline'] = { Index = 3, Min = 0.0, Max = 45.0 },
                }
            },
        },
        ['Ground Interaction'] = {
            BankID = 7,
            ['Rolling_Water'] = {
                SoundId = 0,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 75.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Rolling_Asphalt'] = {
                SoundId = 1,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 75.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Rolling_Gravel'] = {
                SoundId = 2,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 75.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Rolling_Soil'] = {
                SoundId = 3,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 75.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 300.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Rolling_Rim'] = {
                SoundId = 4,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 8.5 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Skid_Gravel'] = {
                SoundId = 5,
                Parameters = {
                    ['skid'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Skid_Dirt'] = {
                SoundId = 6,
                Parameters = {
                    ['skid'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Skid_Asphalt'] = {
                SoundId = 7,
                Parameters = {
                    ['skid'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Skid_Water'] = {
                SoundId = 8,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Skid_Snow'] = {
                SoundId = 9,
                Parameters = {
                    ['skid'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Water Interact'] = {
                SoundId = 10,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 50.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Spin_Gravel'] = {
                SoundId = 11,
                Parameters = {
                    ['spin'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Spin_Snow'] = {
                SoundId = 12,
                Parameters = {
                    ['spin'] = { Index = 0, Min = 0.0, Max = 12.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Rolling_Snow'] = {
                SoundId = 13,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 75.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Rolling_Ice'] = {
                SoundId = 14,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 75.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Spin_Ice'] = {
                SoundId = 15,
                Parameters = {
                    ['spin'] = { Index = 0, Min = 0.0, Max = 8.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Skid_Ice'] = {
                SoundId = 16,
                Parameters = {
                    ['skid'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Spin_Asphalt'] = {
                SoundId = 17,
                Parameters = {
                    ['spin'] = { Index = 0, Min = 0.0, Max = 10.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Spin_Soil'] = {
                SoundId = 18,
                Parameters = {
                    ['spin'] = { Index = 0, Min = 0.0, Max = 9.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 150.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
            ['Wobbling Tyre'] = {
                SoundId = 19,
                Parameters = {
                    ['speed'] = { Index = 0, Min = 0.0, Max = 28.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                    ['(listener angle)'] = { Index = 3, Min = -180.0, Max = 180.0 },
                }
            },
        },
        ['Mechanics'] = {
            BankID = 8,
            ['6 - empty'] = {
                SoundId = 6,
                Parameters = {
                    ['load'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 500.0 },
                }
            },
            ['Sentry Beep'] = {
                SoundId = 0,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 100.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['SAM Warning'] = {
                SoundId = 1,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 300.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['MountedFlak_Mech'] = {
                SoundId = 2,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                }
            },
            ['SAM_Mech'] = {
                SoundId = 3,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                }
            },
            ['Sentry_Cooldown'] = {
                SoundId = 4,
                Parameters = {
                    ['focus'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 1, Min = 0.0, Max = 50.0 },
                }
            },
            ['Sentry_Mech'] = {
                SoundId = 5,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 50.0 },
                }
            },
            ['Sentry_Death'] = {
                SoundId = 7,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['focus'] = { Index = 1, Min = 0.0, Max = 1.0 },
                    ['(distance)'] = { Index = 2, Min = 0.0, Max = 100.0 },
                }
            },
        },
        ['Handling'] = {
            BankID = 9,
            ['SigGunReload_Metal'] = {
                SoundId = 0,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['SigGunReload_HardSurface'] = {
                SoundId = 1,
                Parameters = {
                    ['(velocity)'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['SigGunReload_Generic'] = {
                SoundId = 2,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['SnpRifleReload'] = {
                SoundId = 3,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 1.6 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['Machinegun_Reload'] = {
                SoundId = 4,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['ShtGunPump'] = {
                SoundId = 5,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['ShtGunShells'] = {
                SoundId = 6,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 1.0 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['PistolReload'] = {
                SoundId = 7,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 2.0 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['PistolDualReload'] = {
                SoundId = 8,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 2.0 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['SMGReload'] = {
                SoundId = 9,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 2.0 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['RocketLauncher_Reload'] = {
                SoundId = 10,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['GrenadeLauncher_Reload'] = {
                SoundId = 11,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 3.0 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
            ['airzooka reload'] = {
                SoundId = 12,
                Parameters = {
                    ['velocity'] = { Index = 0, Min = 0.0, Max = 2.0 },
                    ['distance'] = { Index = 1, Min = 0.0, Max = 25.0 },
                    ['focus'] = { Index = 2, Min = 0.0, Max = 1.0 },
                }
            },
        },
    },

    -- Build up a table to provide to the Sound Play/Create methods
    BuildArgs = function(bankname, soundname, args)
        local bank = SoundDB.Sounds[bankname]
        if bank == nil then
            error('Failed to locate sound bank')
        end

        local sound = bank[soundname]
        if sound == nil then
            error('Failed to locate sound within bank \"' .. bankname .. '\"')
        end

        -- We don't want to be modifying their table. Be kind
        -- and copy it.
        local myargs = Copy(args)
        myargs['bank_id'] = bank.BankID
        myargs['sound_id'] = sound.SoundId

        -- Figure out the 'focus' variable id. This is almost
        -- always necessary by sounds.
        local focus_id = -1
        if sound.Parameters then
            focus_id = sound.Parameters['focus'].Index
        end

        myargs['variable_id_focus'] = focus_id

        return myargs
    end,

    -- Create a sound object and return it to the user
    Create = function(bankname, soundname, args)
        return ClientSound.Create(AssetLocation.Game, SoundDB.BuildArgs(bankname, soundname, args))
    end,

    -- Play the sound once
    Play = function(bankname, soundname, args)
        ClientSound.Play(AssetLocation.Game, SoundDB.BuildArgs(bankname, soundname, args))
    end
}


achview = AchievementViewer()