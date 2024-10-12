local function build_item(npc, item)
    minetest.chat_send_player(npc.owner, "Building " .. item .. "...")
    local inv = minetest.get_player_by_name(npc.owner):get_inventory()
    inv:add_item("main", item)
    minetest.chat_send_player(npc.owner, "I gave you your pickaxe.")
    npc.state = "idle"
end

return build_item
