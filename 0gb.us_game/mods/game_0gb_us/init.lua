minetest.register_craft({
	output = 'default:clay_lump 4',
	recipe = {{'default:clay'}}
})

minetest.registered_items["default:clay"].drop = nil
minetest.register_node(":default:clay", minetest.registered_nodes["default:clay"])
end
