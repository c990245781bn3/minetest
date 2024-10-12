-- Register the fireball entity
minetest.register_entity("magic_system:fireball", {
    physical = true,
    collisionbox = {0, 0, 0, 0, 0, 0},
    visual = "sprite",
    textures = {"fireball.png"},
    velocity = 10,

    on_activate = function(self, staticdata)
        local dir = self.object:get_velocity() -- Get the direction the fireball is moving
        -- Set the initial velocity (if you want it to have a certain speed right after activation)
        self.object:set_velocity(vector.multiply(dir, self.velocity))
    end,    

    -- Function to handle movement and interaction per step
    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        local node = minetest.get_node(pos)

        -- Trigger explosion if the fireball hits a node or object
        if node.name ~= "air" then
            self:explode(pos)
        end

        -- Check for collisions with players or objects
        local objects = minetest.get_objects_inside_radius(pos, 1)
        for _, obj in pairs(objects) do
            if obj:is_player() or (obj:get_luaentity() and obj:get_luaentity().name ~= "magic_system:fireball") then
                self:explode(pos)
            end
        end
    end,

    -- Function to handle the explosion effect and damage
    explode = function(self, pos)
        local radius = 3 -- Explosion radius
        local damage = 8  -- Explosion damage

        -- Add explosion particle effects
        minetest.add_particlespawner({
            amount = 50,
            time = 0.1,
            minpos = vector.subtract(pos, 1),
            maxpos = vector.add(pos, 1),
            minvel = {x = -5, y = -5, z = -5},
            maxvel = {x = 5, y = 5, z = 5},
            texture = "fireball.png",
            glow = 10,
        })

        -- Cause damage to nearby players and entities
        local objects = minetest.get_objects_inside_radius(pos, radius)
        for _, obj in pairs(objects) do
            obj:punch(self.object, 1.0, { full_punch_interval = 1.0, damage_groups = {fleshy = damage} }, nil)
        end

        -- Destroy nodes in the explosion radius
        for dx = -radius, radius do
            for dy = -radius, radius do
                for dz = -radius, radius do
                    local dist = vector.distance(pos, {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz})
                    if dist <= radius then
                        local node_pos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
                        local node = minetest.get_node(node_pos)

                        if node.name ~= "air" then
                            minetest.remove_node(node_pos)
                            -- Chance to add fire around explosion
                            if math.random() < 0.3 then
                                minetest.set_node(node_pos, {name = "fire:basic_flame"})
                            end
                        end
                    end
                end
            end
        end

        -- Remove the fireball entity after explosion
        self.object:remove()
    end,
})

-- Function to cast the fireball
local function cast_fireball(player)
    local pos = player:get_pos()
    local dir = player:get_look_dir()
    -- Calculate the starting position of the fireball
    local fireball_pos = vector.add(pos, {x = dir.x * 2, y = 1.5, z = dir.z * 2})

    -- Create the fireball entity
    local fireball = minetest.add_entity(fireball_pos, "magic_system:fireball")
    
    -- Set the fireball's velocity for longer flight (increase speed)
    local fireball_speed = 100 -- Increased speed for longer travel
    fireball:set_velocity(vector.multiply(dir, fireball_speed))
    
    -- Set a slower gravity effect to reduce falling speed
    local gravity = -4 -- Decrease the downward acceleration
    fireball:set_acceleration({x = 0, y = gravity, z = 0}) -- Apply reduced gravity effect
    
    -- Set the yaw to make the fireball align with the player's view direction
    fireball:set_yaw(player:get_look_horizontal())

    -- Inform the player
    minetest.chat_send_player(player:get_player_name(), "You cast a fireball!")
end


-- Register the magic wand tool
minetest.register_tool("magic_system:magic_wand", {
    description = "Magic Wand",
    inventory_image = "magic_wand.png",

    -- On use, cast a fireball
    on_use = function(itemstack, user, pointed_thing)
        cast_fireball(user)
        return itemstack
    end,
})

-- Register crafting recipe for the magic wand
minetest.register_craft({
    output = "magic_system:magic_wand",
    recipe = {
        {"default:stick", "default:diamondblock"},
        {"", "default:stick"},
    },
})

-- Register chat commands for fireball and healing
minetest.register_chatcommand("fireball", {
    description = "Cast a fireball",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if player then
            cast_fireball(player)
            return true, "You cast a Fireball!"
        end
        return false, "Player not found."
    end,
})

local function cast_heal(player)
    local name = player:get_player_name()
    local health = player:get_hp()
    player:set_hp(math.min(health + 5, 20)) -- Heal up to max health (20)
    minetest.chat_send_player(name, "You heal yourself!")
end

minetest.register_chatcommand("heal", {
    description = "Heal yourself",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if player then
            cast_heal(player)
            return true, "You have healed yourself!"
        end
        return false, "Player not found."
    end,
})

-- Function to cause an explosion like TNT
local function explode(pos, radius, damage)
    if not pos then
        minetest.log("error", "Invalid position for explosion")
        return
    end

    -- Add particle effects for the explosion
    minetest.add_particlespawner({
        amount = 50,
        time = 0.1,
        minpos = vector.subtract(pos, 1),
        maxpos = vector.add(pos, 1),
        minvel = {x = -5, y = -5, z = -5},
        maxvel = {x = 5, y = 5, z = 5},
        texture = "fireball.png",
        glow = 10,
    })

    -- Cause damage to nearby players/entities
    local objects = minetest.get_objects_inside_radius(pos, radius)
    for _, obj in pairs(objects) do
        obj:punch(obj, 1.0, { full_punch_interval = 1.0, damage_groups = {fleshy = damage} }, nil)
    end

    -- Destroy nodes in the explosion radius
    for dx = -radius, radius do
        for dy = -radius, radius do
            for dz = -radius, radius do
                local dist = vector.distance(pos, {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz})
                if dist <= radius then
                    local node_pos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
                    local node = minetest.get_node(node_pos)

                    if node.name ~= "air" then
                        minetest.remove_node(node_pos)

                        -- Chance to create fire like TNT
                        if math.random() < 0.3 then
                            minetest.set_node(node_pos, {name = "fire:basic_flame"})
                        end
                    end
                end
            end
        end
    end
end
