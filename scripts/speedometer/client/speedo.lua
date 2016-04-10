-- Code by Arkadius
class 'SpeedoClient'
 
function SpeedoClient:__init( ... )
 
        -- Sets speedo to enabled by default, filling animation on, scale 130, speedfactor 3.6 and min and max health colours
        self.enabled = true
        self.speedFill = true
        self.speedScale = 110
        self.speedFactor = 3.6
        self.min_health = Color( 255,  78, 69 )
		self.max_health = Color( 55,  204, 73 )
		
		
        -- Subscribes to required events
		Events:Subscribe("LocalPlayerEnterVehicle", self, self.EnterVehicle)
		Events:Subscribe("LocalPlayerExitVehicle", self, self.ExitVehicle)
        
end

function SpeedoClient:EnterVehicle()
	self.render = Events:Subscribe("Render", self, self.SpeedoRender)
end

function SpeedoClient:ExitVehicle()
	if self.render then Events:Unsubscribe(self.render) end
end
  
-- Where the real stuff goes down
function SpeedoClient:SpeedoRender( ... )
        -- Grabs players current vehicle, initiates meter limit and sets border width for all three components
        local vehicle = LocalPlayer:GetVehicle()
        local vehicleTopSpeed = 270
        local borderWidth = self.speedScale / 30
        local largeMarkerSpacing = vehicleTopSpeed / 10
        local smallMarkerSpacing = vehicleTopSpeed / 2
        
        -- Stops rendering if speedo disabled/vehicle doesn't exist/player not in vehicle
        if not self.enabled or not IsValid(vehicle) or not LocalPlayer:InVehicle() then
                return
        end
		
		local abs = math.abs
		local sin = math.sin
		local pi = math.pi
		local cos = math.cos
		local floor = math.floor
        
        -- Sets what the top value on the meter should be depending on the vehicle the player is in
        if vehicle:GetClass() == 1 then
                vehicleTopSpeed = 540
        end
        
        
        -- Initiates all useful variables; health, speed, rpm
        local vehicleHealth = vehicle:GetHealth()
        local vehicleVelocity = -vehicle:GetAngle() * vehicle:GetLinearVelocity()
        local currentRPM = abs(vehicle:GetRPM() / 15000)
        local currentSpeed = abs((vehicleVelocity.z * self.speedFactor) / vehicleTopSpeed)
        local currentGear = vehicle:GetTransmission():GetGear()
        
        -- Uses speedo scale to set rpm scale
        local rpmScale = self.speedScale * (1 - (sin(pi / 8)))
        
        -- Sets speedo and rpm positions
        local speedPosition = Vector2(Render.Width  - (1.4  * self.speedScale), Render.Height - (self.speedScale * 1.15))
        local rpmPosition = speedPosition + Vector2(-(self.speedScale) * (cos(pi / 8)), (self.speedScale) * (sin(pi / 8)))
        
        -- Initiates angles of both meter needles
        local angleSpeed = 0
        local angleRPM = 0
        
        
        
        -- HEALTH BAR STUFF
        -- Sets the bar location and size
        local bgBarLocation = speedPosition + Vector2(self.speedScale * 1.1, -self.speedScale)
        local bgBarSize = Vector2(self.speedScale / 5, self.speedScale * 2)
 
        -- Draws border and black background of health bar
        Render:FillArea(bgBarLocation, bgBarSize , Color.White)
        Render:FillArea(bgBarLocation + Vector2(borderWidth, borderWidth), Vector2(bgBarSize.x - (2 * borderWidth), bgBarSize.y - (2 * borderWidth)) , Color.Black)
        
        -- Sets colour of bar, location and size and draws it
        local colourBar = math.lerp(self.min_health, self.max_health, vehicleHealth)
        local colourBarLocation = bgBarLocation + Vector2(borderWidth, borderWidth + ( (1 - vehicleHealth) * 2 * self.speedScale) )
        local colourBarSize = Vector2((self.speedScale / 5) - (2 * borderWidth), (vehicleHealth * 2 * self.speedScale) - (2 * borderWidth))
        Render:FillArea(colourBarLocation, colourBarSize, colourBar)
        
        
        
        -- RPM STUFF
        -- Makes sure RPM meter renders only when in a land vehicle
        if vehicle:GetClass() == 2 then
                
                -- Draws rpm speed background and inner circle
                Render:FillCircle(rpmPosition, borderWidth + rpmScale, Color.White)
                Render:FillCircle(rpmPosition, rpmScale, Color.Black)
                Render:FillCircle(rpmPosition, rpmScale / 10, Color.Red)
                
                -- Only draws the gear and rpm (in text) if the scale is big enough
                if self.speedScale >= 110 then
                
                        -- Sets the rpm string and location and writes it under the needle
                        local rpmString = string.format("%i rpm", floor(currentRPM * 15000))
                        local rpmStringPos = rpmPosition + Vector2(-Render:GetTextWidth(rpmString, floor(rpmScale / 7.5)) / 2, rpmScale * 0.775)
                        Render:DrawText(rpmStringPos, rpmString, Color.White, floor(rpmScale / 7.5))
                        
                        -- Initiates the gear and assumes it to be 1st
                        local gearString = "1st Gear"
                        
                        -- Decides what gear the vehicle is in and also if its reversing
                        if currentGear >= 4 then        
                                gearString = tostring(currentGear) .. "th Gear"
                        elseif currentGear == 3 then
                                gearString= "3rd Gear"
                        elseif vehicle:GetTransmission():GetGear() == 2 then
                                gearString = "2nd Gear"
                        elseif vehicleVelocity.z > 1 then
                                gearString = "Reverse"
                        end
                        
 
                        -- Sets position and write text
                        local gearStringPos = rpmPosition + Vector2(-Render:GetTextWidth(gearString, floor(rpmScale / 6)) / 2, rpmScale * 0.6)
                        Render:DrawText(gearStringPos, gearString, Color.White, floor(rpmScale / 6))
                
                end
                
                -- Works out angle of needle
                angleRPM = ((5 / 4) * pi) - (pi * (3 / 4) * currentRPM)
                
                -- Sets start and end of the needle and draws it
                local rpmPoint = rpmPosition + Vector2(rpmScale * (3 / 4) * cos(angleRPM), rpmScale * (3 / 4) * -sin(angleRPM))
                local rpmBase1 = rpmPosition + Vector2((rpmScale / 20) * cos(angleRPM - (pi / 2)), (rpmScale / 20) * -sin(angleRPM - (pi / 2)))
                local rpmBase2 = rpmPosition + Vector2((rpmScale / 20) * cos(angleRPM + (pi / 2)), (rpmScale / 20) * -sin(angleRPM + (pi / 2)))
                Render:FillTriangle(rpmPoint, rpmBase1, rpmBase2, Color.Red)
                
                -- Draws RPM meter markers
                for i = pi * ( 5 / 4 ), (1 / 2) * pi, -(pi * 0.75) / 15 do
                        
                        -- Sets start and end of marker
                        local lineLocation = Vector2(rpmScale * cos(i) + rpmPosition.x, rpmScale * -sin(i) + rpmPosition.y)
                        local lineTarget = Vector2((rpmScale - (rpmScale / 10)) * cos(i) + rpmPosition.x, (rpmScale - (rpmScale / 10)) * -sin(i) + rpmPosition.y)
                        
                        -- Checks to see if needle has passed it if so go red if not white
                        if i - (pi / 300) >= angleRPM then
                                Render:DrawLine(lineTarget, lineLocation, Color.Red)
                        else
                                Render:DrawLine(lineTarget, lineLocation, Color.White)
                        end
                        
                end
                
                -- Draws large RPM meter markers
                for i = pi * ( 5 / 4 ), (1 / 2) * pi, -(pi * 0.75) / 60 do
                        
                        -- Sets start and end of marker
                        local lineLocation = Vector2(rpmScale * cos(i) + rpmPosition.x, rpmScale * -sin(i) + rpmPosition.y)
                        local lineTarget = Vector2((rpmScale - (rpmScale / 20)) * cos(i) + rpmPosition.x, (rpmScale - (rpmScale / 20)) * -sin(i) + rpmPosition.y)
                        
                        -- Checks to see if needle has passed it if so go red if not white
                        if i - (pi / 300) >= angleRPM then
                                Render:DrawLine(lineTarget, lineLocation, Color.Red)
                        else
                                Render:DrawLine(lineTarget, lineLocation, Color.White)
                        end
                        
                end
                
        end
        
 
        
        -- SPEED STUFF
        -- Draws background and inner circle
        Render:FillCircle(speedPosition, self.speedScale + borderWidth, Color.White)
        Render:FillCircle(speedPosition, self.speedScale, Color.Black)
        Render:FillCircle(speedPosition, self.speedScale / 10, Color.Red)
        
        -- Sets the speed being written to screen
        speedString = string.format("%i", floor(currentSpeed * vehicleTopSpeed))
 
        -- Sets position of the speed and kmh text and writes both
        local speedStringPos1 = speedPosition + Vector2(-Render:GetTextWidth(speedString, floor(self.speedScale / 4)) / 2, self.speedScale * 0.5)
        local speedStringPos2 = speedPosition + Vector2(-Render:GetTextWidth("KM/H", floor(self.speedScale / 7.5)) / 2, self.speedScale * 0.75)
        Render:DrawText(speedStringPos1, speedString, Color.White, floor(self.speedScale / 4))
        Render:DrawText(speedStringPos2, "KM/H", Color.White, floor(self.speedScale / 7.5))
 
 
        -- Works out angle and limits it to a certain angle
        if currentSpeed > 1 then
                angleSpeed = (-pi / 4) - (pi / 300)
        else
                angleSpeed = ((5 / 4) * pi) - ((pi * (3 / 2)) * currentSpeed)
        end
                
        -- Sets start and end of needle and draws it
        local speedPoint = speedPosition + Vector2(self.speedScale * (3 / 4) * cos(angleSpeed), self.speedScale * (3 / 4) * -sin(angleSpeed))
        local speedBase1 = speedPosition + Vector2(2 * borderWidth * cos(angleSpeed + (pi / 2)), 2 * borderWidth * -sin(angleSpeed + (pi / 2)))
        local speedBase2 = speedPosition + Vector2(2 * borderWidth * cos(angleSpeed - (pi / 2)), 2 * borderWidth * -sin(angleSpeed - (pi / 2)))
        Render:FillTriangle(speedPoint, speedBase1, speedBase2, Color.Red)
 
        -- Draws out the speed meter markers
        for i = (pi * ( 5 / 4)), -(1 / 4) * pi, -((pi * 1.5) / smallMarkerSpacing) do
                
                -- Sets start and end of marker and draws it
                local lineLocation = Vector2(self.speedScale * cos(i), self.speedScale * -sin(i)) + speedPosition
                local lineTarget = Vector2((self.speedScale - (borderWidth * 2)) * cos(i), (self.speedScale - (borderWidth * 2)) * -sin(i)) + speedPosition
 
                -- Checks what colour it should draw the marker in; red if equal to speed, yellow if equal to reverse speed and white by default
                if i - (pi / 300) >= angleSpeed then
                        if vehicleVelocity.z > 0 then
                                Render:DrawLine(lineTarget, lineLocation, Color.Gold)
                        else
                                Render:DrawLine(lineTarget, lineLocation, Color.Red)
                        end
                else
                        Render:DrawLine(lineTarget, lineLocation, Color.White)
                end
                
        end
        
        
 
        -- Draws the large speed markers
        for i = (pi * ( 5 / 4)), -(1 / 4) * pi, -((pi * 1.5) / largeMarkerSpacing) do
               
                -- Sets start and end of marker and draws it
                local lineLocation = Vector2(self.speedScale * cos(i), self.speedScale * -sin(i)) + speedPosition
                local lineTarget = Vector2((self.speedScale - (borderWidth * 4)) * cos(i), (self.speedScale - (borderWidth * 4)) * -sin(i)) + speedPosition
 
                -- Checks what colour it should draw the marker in; red if equal to speed, yellow if equal to reverse speed and white by default
                if i - (pi / 300) >= angleSpeed then
                        if vehicleVelocity.z > 0 then
                                Render:DrawLine(lineTarget, lineLocation, Color.Gold)
                        else
                                Render:DrawLine(lineTarget, lineLocation, Color.Red)
                        end
                else
                        Render:DrawLine(lineTarget, lineLocation, Color.White)
                end
                
        end
end
 
-- Creates clock object
local objectSpeedo = SpeedoClient()
 