minetest.register_alias("group:stone", "default:cobble")

minetest.register_craft({
	output = 'default:clay_lump 4',
	recipe = {{'default:clay'}}
})

minetest.registered_items["default:clay"].drop = nil
minetest.registered_nodes["default:grass_1"].buildable_to = false
minetest.registered_nodes["default:grass_2"].buildable_to = false
minetest.registered_nodes["default:grass_3"].buildable_to = false
minetest.registered_nodes["default:grass_4"].buildable_to = false
minetest.registered_nodes["default:grass_5"].buildable_to = false
minetest.registered_nodes["default:junglegrass"].buildable_to = false
minetest.registered_nodes["default:lava_source"].buildable_to = false
minetest.registered_nodes["fire:basic_flame"].groups.igniter = nil

for _, node in ipairs({
	"default:clay",
	"default:grass_1",
	"default:grass_2",
	"default:grass_3",
	"default:grass_4",
	"default:grass_5",
	"default:junglegrass",
	"default:lava_source",
	"fire:basic_flame",
}) do
	minetest.register_node(":"..node, minetest.registered_nodes[node])
end

minetest.register_craft({
	output = 'default:mese_crystal',
	recipe = {
		{
			'default:mese_crystal_fragment',
			'default:mese_crystal_fragment',
			'default:mese_crystal_fragment',
		},
		{
			'default:mese_crystal_fragment',
			'default:mese_crystal_fragment',
			'default:mese_crystal_fragment',
		},
		{
			'default:mese_crystal_fragment',
			'default:mese_crystal_fragment',
			'default:mese_crystal_fragment',
		},
	}
})

minetest.register_craft({
	output = 'default:mese_crystal',
	recipe = {{'default:mese_crystal'}},
})

minetest.debug("[game_0gb_us]: Plugin loaded from\n"..minetest.get_modpath("game_0gb_us"))

