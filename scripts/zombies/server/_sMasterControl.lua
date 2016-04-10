class 'MasterControl'
global_zombies = {}
respawn_queue = {}

function MasterControl:__init()
	self.hordes = {}
	self.timer = Timer()
	self.time = 0
	self.lastRenderTime = 0
	
	Events:Subscribe("PreTick", self, self.Tasker)
	Events:Subscribe("SecondTick", self, self.SecondTick)
	Events:Subscribe("ModuleUnload", self, self.Unload)
	Network:Subscribe("ZombieRetarget", self, self.ZombieRetarget)
	Network:Subscribe("ZombieHit", self, self.ZombieHit)
	Network:Subscribe("DamageZombie", self, self.DamageZombie)
	
	zombie_drops = {}
	table.insert(zombie_drops, "Water (1)")
	table.insert(zombie_drops, "Water (1)")
	table.insert(zombie_drops, "Water (1)")
	table.insert(zombie_drops, "Water (2)")
	table.insert(zombie_drops, "Water (2)")
	table.insert(zombie_drops, "Bread (1)")
	table.insert(zombie_drops, "Beef (1)")
	table.insert(zombie_drops, "Mango (2)")
	table.insert(zombie_drops, "Salad (1)")
	table.insert(zombie_drops, "Ice Cream (2)")
	
	table.insert(zombie_drops, "Scrap Metal (2)")
	table.insert(zombie_drops, "Scrap Metal (3)")
	table.insert(zombie_drops, "Iron (2)")
	table.insert(zombie_drops, "Steel (1)")
	table.insert(zombie_drops, "Machine Parts (1)")
	table.insert(zombie_drops, "Machine Parts (2)")
end

function MasterControl:Tasker()
	self.time = self.timer:GetMilliseconds()
	if self.time - self.lastRenderTime < 1000 / updatesPerSecond then return end
	
	local i = 1
	while i <= #self.hordes do
		self.hordes[i]:Update()
		--print("updated horde")
		i = i + 1
	end
	
	self.lastRenderTime = self.time
end

function MasterControl:NewHorde(file)
	local horde  = Horde(self)
	local result = horde:Parse(file)
	if result then
		table.insert(self.hordes, horde)
		print("horde " .. file .. " - " .. " loaded")
	else
		print(file .. " is not valid for parsing")
	end
end

function MasterControl:ZombieRetarget(args, player)
	if not IsValid(player) then return end
	for wno_id, ply in pairs(args.izombies) do
		if type(ply) == "number" then
			if global_zombies[wno_id] then
				global_zombies[wno_id]:UnTarget()
			end
		else
			if global_zombies[wno_id] then
				global_zombies[wno_id]:SetTarget(ply)
			end
		end
	end
end

function MasterControl:ZombieHit(args, player)
	if IsValid(player) then
		player:Damage(args.dmg)
	end
end

function MasterControl:DamageZombie(args, player)
	if global_zombies[args.id] then
		local z = global_zombies[args.id]
		local old_health = z:GetHealth()
		z:Damage(args.damage)
		if z:GetHealth() <= 0 and old_health > 0 then
			local xp = (player:GetValue("Level") or 10) * 5
			player:SetNetworkValue("Experience", player:GetValue("Experience") + xp)
			player:SetMoney(player:GetMoney() + 10)
			print(tostring(player) .. " got " .. tostring(xp) .. " for killing zombie")
			local drop_chance = math.random(1, 5)
			if drop_chance == 1 then
				local portalgun = math.random(1, 500) == 500
				if portalgun == true then table.insert(spawn_table, "Portal Gun (1)") end
				if drop_chance == 1 then
					local spawn_table = {}
					table.insert(spawn_table, table.randomvalue(zombie_drops))
					table.insert(spawn_table, table.randomvalue(zombie_drops))
					Events:Fire("SpawnDropboxServerside", {spawn_table = spawn_table, pos = args.actor_pos, ang = Angle(0, 0, 0)})
				end
			end
		end
	end
end

function MasterControl:SecondTick()
	local current_time = self.timer:GetSeconds()
	for wno_id, itable in pairs(respawn_queue) do
		if current_time - itable.time > respawnTime then
			local iWNO = WorldNetworkObject.GetById(wno_id)
			if iWNO and IsValid(iWNO) then
				itable.zombie:Respawn()
			end
			respawn_queue[wno_id] = nil
		end
	end
end

function MasterControl:Unload()
	for i = 1, #self.hordes do
		self.hordes[i]:Remove()
	end
end