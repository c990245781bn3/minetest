local function find_resource(npc, resource)
    minetest.chat_send_player(npc.owner, "Looking for " .. resource .. "...")
    -- Placeholder logic to simulate finding a tree
    minetest.after(5, function()
        npc:gather_resource(resource)
    end)
end

return find_resource
