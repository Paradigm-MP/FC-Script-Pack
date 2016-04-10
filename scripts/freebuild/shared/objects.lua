canberotated = {}
canberotated["Weak Metal Sheet"] = Angle(0,0,math.pi)
canberotated["Moderate Metal Sheet"] = Angle(0,0,math.pi)
canberotated["Strong Metal Sheet"] = Angle(0,0,math.pi)
canberotated["Metal Sheet with Window"] = Angle(0,0,math.pi)
canberotated["Weak Wooden Slab"] = Angle(0,0,math.pi)
canberotated["Moderate Wooden Slab"] = Angle(0,0,math.pi)
canberotated["Strong Wooden Slab"] = Angle(0,0,math.pi)
objects = {}
objects["Laptop"] = "f1m07.fixedlaptop.eez/go160-a.lod"
objects["Floating Light"] = "km05.hotelbuilding01.flz/key030_01-o1.lod"
objects["Fancy Pink Light"] = "km05.hotelbuilding01.flz/key030_01-p.lod"
objects["Mirror"] = "km07.submarine.eez/key014_02-globebase.lod"
objects["Pillow"] = "areaset01.blz/go080-g.lod"
objects["Pillow 2"] = "areaset01.blz/go080-h.lod"
objects["Pillow 3"] = "areaset01.blz/go080-h1.lod"
objects["Paper Lantern"] = "km03.gamblinghouse.flz/key032_01-o1.lod"
--objects["Tram"] = "km01.statictram.eez/v110-body.lod"
--objects["GMI Access Terminal"] = "km07.submarine.eez/gp047-a.lod"

objects["Weak Wooden Slab"] = "km03.gamblinghouse.flz/key032_01-walkway.lod"
objects["Moderate Wooden Slab"] = "km03.gamblinghouse.flz/key032_01-walkway.lod"
objects["Strong Wooden Slab"] = "km03.gamblinghouse.flz/key032_01-walkway.lod"
objects["Weak Metal Sheet"] = "obj.jumpgarbage.eez/gb206-g.lod"
objects["Moderate Metal Sheet"] = "obj.jumpgarbage.eez/gb206-g.lod"
objects["Strong Metal Sheet"] = "obj.jumpgarbage.eez/gb206-g.lod"
objects["MINT"] = "f1m03airstrippile04.eez/key_003-x.lod"
objects["Weak Metal Crate"] = "f1t05bomb01.eez/go126-a.lod"
objects["Moderate Metal Crate"] = "f1t05bomb01.eez/go126-a.lod"
objects["Strong Metal Crate"] = "f1t05bomb01.eez/go126-a.lod"
objects["Chair"] = "areaset01.blz/go080-c.lod"
objects["Bed"] = "areaset01.blz/go080-d.lod" --set spawn
objects["Lounge Chair"] = "areaset01.blz/go080-l.lod" --set spawn
objects["Weak Wooden Fence"] = "areaset03.blz/gb185-f.lod"
objects["Moderate Wooden Fence"] = "areaset03.blz/gb185-f.lod"
objects["Strong Wooden Fence"] = "areaset03.blz/gb185-f.lod"
objects["Wooden Deck"] = "areaset03.blz/gb185-i.lod"
objects["Metal Sheet with Window"] = "areaset06.blz/gb184-j.lod" --wood + metal
objects["Large Metal Stairs"] = "areaset07.blz/gb095-f.lod"
objects["Light Post"] = "general.blz/go063-a.lod" --weird bb
objects["Quad Light Post"] = "general.blz/go063-c.lod" --weird bb
objects["Small Ground Light"] = "general.blz/go063-f.lod"
objects["Stadium Light"] = "general.blz/go063-i.lod"
objects["Medium Ground Light"] = "general.blz/go063-n.lod"
objects["Stop Sign"] = "general.blz/go200-f1.lod"
objects["Laser Wall Post"] = "general.blz/turret-rack.lod"
objects["Tall Wooden Fence"] = "f1m03.interiors.flz/go178-a.lod"
objects["Metal Doorframe"] = "f2m01.village.flz/gb206-b.lod"
objects["Mortar"] = "general.blz/gae09-b.lod"
--objects["Sinkhole"] = "f2m06.trees04.flz/key006_06-a.lod" --UNDERGROUND BASE ENTRANCE
--objects["MONEY MACHINE?!"] = "f3m05.skyscraper.flz/key019_01-d.lod"
objects["Fancy Wooden Fence"] = "km03.gamblinghouse.flz/key032_01-k.lod"
objects["Crafting Table"] = "33x08.flz/go113-a.lod"
objects["Door"] = "areaset05.blz/gb165-n.lod"
objects["Reinforced Door"] = "areaset05.blz/gb165-n.lod"
objects["Garage Door"] = "km01.base.flz/key036-f.lod"
objects["Air Generator"] = "areaset01.blz/gb090-f.lod"

--objects["Wooden Crate"] = "km03.gamblinghouse.flz/key032_01-plantbox.lod"
vlights = {}
vlights["Light Post"] = {color = Color(255,255,255), multiplier = 2, radius = 25, adj = 1}
vlights["Quad Light Post"] = {color = Color(255,255,255), multiplier = 2, radius = 50, adj = 15}
vlights["Small Ground Light"] = {color = Color(255,255,255), multiplier = 2, radius = 7, adj = 1}
vlights["Stadium Light"] = {color = Color(255,255,255), multiplier = 2, radius = 75, adj = 25}
vlights["Medium Ground Light"] = {color = Color(255,255,255), multiplier = 2, radius = 7, adj = 1}

HPamts = {}
HPamts["Weak Wooden Slab"] = 250
HPamts["Moderate Wooden Slab"] = 500
HPamts["Strong Wooden Slab"] = 1000
HPamts["Weak Metal Sheet"] = 250
HPamts["Moderate Metal Sheet"] = 500
HPamts["Strong Metal Sheet"] = 1000
HPamts["MINT"] = 500
HPamts["Weak Metal Crate"] = 500
HPamts["Moderate Metal Crate"] = 1000
HPamts["Strong Metal Crate"] = 2000
HPamts["Chair"] = 150
HPamts["Bed"] = 250
HPamts["Lounge Chair"] = 250
HPamts["Weak Wooden Fence"] = 200
HPamts["Moderate Wooden Fence"] = 400
HPamts["Strong Wooden Fence"] = 800
HPamts["Wooden Deck"] = 750
HPamts["Metal Sheet with Window"] = 1500
HPamts["Large Metal Stairs"] = 750
HPamts["Light Post"] = 250
HPamts["Quad Light Post"] = 400
HPamts["Small Ground Light"] = 100
HPamts["Stadium Light"] = 600
HPamts["Medium Ground Light"] = 100
HPamts["Stop Sign"] = 150
HPamts["Laser Wall Post"] = 500
HPamts["Tall Wooden Fence"] = 750
HPamts["Metal Doorframe"] = 500
HPamts["Fancy Wooden Fence"] = 300
HPamts["Crafting Table"] = 350
HPamts["Door"] = 500
HPamts["Mortar"] = 400
HPamts["Garage Door"] = 1300
HPamts["Reinforced Door"] = 1100
HPamts["Air Generator"] = 750

expID = {}
expID["Weak Wooden Slab"] = 422
expID["Moderate Wooden Slab"] = 422
expID["Strong Wooden Slab"] = 422
expID["Weak Metal Sheet"] = 378
expID["Moderate Metal Sheet"] = 378
expID["Strong Metal Sheet"] = 378
expID["MINT"] = 15
expID["Weak Metal Crate"] = 378
expID["Moderate Metal Crate"] = 378
expID["Strong Metal Crate"] = 378
expID["Chair"] = 422
expID["Bed"] = 422
expID["Lounge Chair"] = 422
expID["Weak Wooden Fence"] = 328
expID["Moderate Wooden Fence"] = 328
expID["Strong Wooden Fence"] = 328
expID["Wooden Deck"] = 422
expID["Metal Sheet with Window"] = 378
expID["Large Metal Stairs"] = 378
expID["Light Post"] = 245
expID["Quad Light Post"] = 245
expID["Small Ground Light"] = 245
expID["Stadium Light"] = 245
expID["Medium Ground Light"] = 245
expID["Stop Sign"] = 378
expID["Laser Wall Post"] = 231
expID["Tall Wooden Fence"] = 328
expID["Metal Doorframe"] = 378
expID["Fancy Wooden Fence"] = 328
expID["Crafting Table"] = 422
expID["Door"] = 378
expID["Mortar"] = 378
expID["Garage Door"] = 378
expID["Reinforced Door"] = 378
expID["Air Generator"] = 378