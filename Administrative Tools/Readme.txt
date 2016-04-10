Administrative Tools How-to

These tools are meant for private servers only and are used for the following:

	- Place/remove/edit loot spawns
	- Place/remove/edit vehicle spawns
	- Create paths for zombies

editor:

	- Used to position loot within the server.
	- If unloaded, all unsaved loot will be lost.
	- Needs to be loaded for lootplacer to work correctly.
	- Open up the editor menu with 'L'.
	- Controls should be self-explanatory.
	
LootPlacer:

	- Used to place, remove, and edit loot.
	- Commands:
		- /lootmode ... Toggles loot editing mode on/off.
		- /showloot ... Toggles whether you can see nearby loot or not.
		- /alpha AMT ... Sets the loot indicators' transparency to specified AMT.
		- /radius AMT ... Sets the loot indicators' radii to specified AMT.
		- /range AMT ... Sets the range at which you can see the loot visual indicators.
		- /undo ... Deletes the last placed lootbox.
		- /saveloot ... Saves all the loot in the server. You MUST use this to save your loot.
		- /sky ... Teleports you 500m above your current location.
		- /dupes ... Iterates through all loot in the server to check for duplicates. TAKES A LONG TIME.
	- Keys while in lootmode:
		- 1 ... Places a tier 1 lootbox at look location.
		- 2 ... Places a tier 2 lootbox at look location.
		- 3 ... Places a tier 3 lootbox at look location.
	- After making edits, copy lootspawns.txt and overwrite lootspawns.txt in the main server and reload
		
PathMaker:

	- Used to create paths for zombies. It can also be used to for other purposes.
	- the text files in the module must all follow a certain format, see them for an example
	- Paths can be loaded to see them in the world by going to sPathMaker and adding an entry
	  with the LoadExistingPath function
	- Type /start to start a new path
	- After starting, press Numpad 0 to place a new point
	- The closest point to you is marked red
	- To remove the closest point press 6
	- Type /end NameofPath to end the path and save it. It gets saved as a text document.
        - Saving a path with the name of an existing path would override it.
	
	
Vehicles:

	- Used to place/remove/edit vehicle spawns.
	- Commands:
		- /vmode ... Toggles vehicle editing mode on/off.
		- /cvg ... Teleports you through all of the civilian ground vehicle spawns.
		- /cvw ... Teleports you through all of the civilian water vehicle spawns.
		- /cvh ... Teleports you through all of the civilian helicopter vehicle spawns.
		- /cvp ... Teleports you through all of the civilian plane vehicle spawns.
		- /mig ... Teleports you through all of the military ground vehicle spawns.
		- /miw ... Teleports you through all of the military water vehicle spawns.
		- /mih ... Teleports you through all of the military helicopter vehicle spawns.
		- /mip ... Teleports you through all of the military plane vehicle spawns.
	- Once in vehicle editing mode, instructions will be displayed on the screen.
	- All edits to spawns are automatically saved.
	- Reload the module to see vehicles spawn at new spawn points.
	- After making edits, copy this spawns.txt and overwrite the spawns.txt in the main server and reload
