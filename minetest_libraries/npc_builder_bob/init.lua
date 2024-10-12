local find_resource = dofile(minetest.get_modpath("modname").."/find_resource.lua")
local gather_resource = dofile(minetest.get_modpath("modname").."/gather_resource.lua")
local build_item = dofile(minetest.get_modpath("modname").."/build_item.lua")

minetest.register_entity("builder_bob:npc_builder_bob", {
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
        find_resource(self, "default:tree")
    end,
    gather_resource = gather_resource,
    build_item = build_item,
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
