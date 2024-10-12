minetest.register_entity("modname:npc_builder_bob", {
    initial_properties = {
        visual = "mesh",
        mesh = "character.b3d",
        textures = {"character.png"},
        physical = true,
        collide_with_objects = true,
        collisionbox = {-0.35, 0, -0.35, 0.35, 1.7, 0.35},
        selectionbox = {-0.35, 0, -0.35, 0.35, 1.7, 0.35},
    },
    on_activate = function(self, staticdata, dtime_s)
        self.state = "idle"
        self.owner = nil
    end,
    on_rightclick = function(self, clicker)
        local player_name = clicker:get_player_name()
        if self.owner == nil then
            self.owner = player_name
            minetest.chat_send_player(player_name, "I'm here to help you!")
        elseif self.owner == player_name then
            self:handle_request(clicker)
        else
            minetest.chat_send_player(player_name, "I'm already assisting someone else.")
        end
    end,
    handle_request = function(self, clicker)
        local inv = clicker:get_inventory()
        local recipe = minetest.get_craft_recipe("default:pick_wood")
        if not recipe or #recipe.items == 0 then
            minetest.chat_send_player(self.owner, "I can't make the pickaxe.")
            return
        end
        self.state = "gather_wood"
        self:find_resource("default:tree")
    end,
    find_resource = function(self, resource)
        -- Sub Lua for finding resource
        minetest.chat_send_player(self.owner, "Looking for " .. resource .. "...")
        -- Placeholder logic to simulate finding a tree
        minetest.after(5, function()
            self:gather_resource(resource)
        end)
    end,
    gather_resource = function(self, resource)
        -- Sub Lua for gathering resource
        minetest.chat_send_player(self.owner, "Gathering " .. resource .. "...")
        -- Placeholder logic to simulate cutting a tree
        minetest.after(10, function()
            self:build_item("default:pick_wood")
        end)
    end,
    build_item = function(self, item)
        -- Sub Lua for building item
        minetest.chat_send_player(self.owner, "Building " .. item .. "...")
        local inv = minetest.get_player_by_name(self.owner):get_inventory()
        inv:add_item("main", item)
        minetest.chat_send_player(self.owner, "I gave you your pickaxe.")
        self.state = "idle"
    end,
})

minetest.register_chatcommand("spawn_npc_builder_bob", {
    params = "",
    description = "Spawns NPC Builder Bob",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if player then
            local pos = player:get_pos()
            pos.y = pos.y + 1
            minetest.add_entity(pos, "modname:npc_builder_bob")
        end
    end,
})
