class 'Crafting'

function Crafting:__init()
	craft_objects = {}
	--
	spawnargs = {}
	spawnargs.model = "33x08.flz/go113-a.lod"
	spawnargs.collision = "33x08.flz/go113_lod1-a_col.pfx"
	spawnargs.angle = Angle(0, 0, 0)
	spawnargs.position = Vector3(-12284.782, 610.939, 4764.233)
	--
	spawnargs.position = Vector3(-7474.247070, 205.287933, -4128.164063)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(-7508.759766, 205.547272, -4180.291504)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(-7448.913086, 204.271225, -4153.169922)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(-9077.731445, 586.475220, 4172.966309)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(-9070.349609, 586.732422, 4221.801758)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(-9111.225586, 586.169434, 4227.382813)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(1088.011719, 202.513824, 1156.683228)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(1091.988403, 203.622574, 1098.588623)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(1034.894775, 201.530243, 1108.689941)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(10795.414063, 201.442566, -8525.071289)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(10797.247070, 202.130661, -8466.424805)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(10861.266602, 206.548645, -8495.297852)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(7242.098633, 822.714172, -1129.418945)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(7231.377930, 822.862122, -1208.895386)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(7193.725098, 831.629333, -1186.844482)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(7277.903320, 823.265869, -1195.994019)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(-4919.951660, 214.198212, 3043.795166)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(-4985.898926, 214.839508, 3085.366455)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(-4887.791016, 214.793961, 3001.918457)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	--
	spawnargs.position = Vector3(-4982.800293, 214.954407, 3023.926758)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	
	spawnargs.position = Vector3(-12599.072266, 218.778015, 15089.377930)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	
	---
	spawnargs.position = Vector3(-12720.390625, 218.927689, 15053.388672)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	
	spawnargs.position = Vector3(-12693.334961, 218.931915, 15172.744141)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	
	spawnargs.position = Vector3(-12340.858398, 214.763306, 15052.302734)
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	
	
	
	--noob island loot things
	spawnargs.position = Vector3(-12518.165039, 218.878418, 15056.418945)
	spawnargs.model = "general.blz/go155-a.lod"
	spawnargs.collision = "general.blz/go155_lod1-a_col.pfx"
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
	
	spawnargs.position = Vector3(-12521.566406, 218.874405, 15044.579102)
	spawnargs.model = "km03.gamblinghouse.flz/key032_01-f.lod"
	spawnargs.collision = "km03.gamblinghouse.flz/key032_01_lod1-f_col.pfx"
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)

	spawnargs.position = Vector3(-12523.795898, 218.866425, 15033.341797)
	spawnargs.model = "geo.cbb.eez/go152-a.lod"
	spawnargs.collision = "km05.hotelbuilding01.flz/key030_01_lod1-n_col.pfx"
	v = StaticObject.Create(spawnargs)
	v:SetStreamDistance(350)
	table.insert(craft_objects, v)
end

function Crafting:OnModUnload()
	for index, object in pairs(craft_objects) do
		if IsValid(object) then object:Remove() end
	end
end

crafting = Crafting()

Events:Subscribe("ModuleUnload", crafting, crafting.OnModUnload)