class 'AWGFactions'

function AWGFactions:__init()
    self.active = true

    Events:Subscribe( "ModuleLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
end


function AWGFactions:ModulesLoad()
    local validColors = ""
    for k,_ in pairs(awgColors) do
        validColors = validColors .. k .. "\n"
    end
    Events:Fire( "HelpAddItem",
        {
            name = "Factions",
            text = 
                "See usage details below. When using '/f join', if the specified faction name does\n" ..
                "not already exist, it is created. The password is optional when creating a new \n" ..
                "faction, but required to join one that has a password.  When a faction leader leaves\n" ..
                "the faction, it is deleted and all its members are disbanded.  \n\n" ..
                "Usage:\n\n  Joining/Creating a faction:\n\n    /f join <faction> <password>\n\n" ..
                "  Leaving a faction:\n\n    /f leave\n\n" ..
                "  Using faction chat:\n\n    /f <chat message>\n\n" ..
                "  List faction members:\n\n    /f players\n\n" ..
                "  List factions:\n\n    /f list\n\n" ..
                "  Set faction color (Must be leader. See color list below.):\n\n    /f setcolor <colorname>\n\n" ..
                "  Set faction password (Must be leader. Password cannot contain spaces):\n\n    /f setpass <password>\n\n" ..
                "  Kick faction member (Must be leader.):\n\n    /f kick <member's name>\n\n" ..
                "  Ban faction member (Must be leader.):\n\n    /f ban <member's name>\n\n" ..
                "  Unban a player (Must be leader.):\n\n    /f unban <member's name>\n\n" ..
				" Faction NPCs and Faction Missile Turrets can be placed if you have found those items\n\n" ..
				" You can put down a base anywhere - check out the faction menu by pressing 'P' when in a faction\n\n" ..
                "\n\nMore features coming soon! :)\n\n" ..
                "Below is a list of valid faction colors:\n\n" .. validColors
        } )
end

function AWGFactions:ModuleUnload()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Factions"
        } )
end



local awgFactions = AWGFactions()
