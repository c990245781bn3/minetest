local function gather_resource(npc, resource)
    minetest.chat_send_player(npc.owner, "Gathering " .. resource .. "...")
    -- Placeholder logic to simulate cutting a tree
    minetest.after(10, function()
        npc:build_item("default:pick_wood")
    end)
end

return gather_resource
