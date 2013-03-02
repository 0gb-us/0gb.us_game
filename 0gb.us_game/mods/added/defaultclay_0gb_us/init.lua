minetest.registered_items["default:clay"].drop = nil

minetest.register_craft({
	output = 'default:clay_lump 4',
	recipe = {{'default:clay'}}
})

minetest.debug("[defaultclay_0gb_us]: Plugin loaded from\n"..minetest.get_modpath("defaultclay_0gb_us"))

