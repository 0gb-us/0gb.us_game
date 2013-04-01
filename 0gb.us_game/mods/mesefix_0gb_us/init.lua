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

minetest.debug("[mesefix_0gb_us]: Plugin loaded from\n"..minetest.get_modpath("mesefix_0gb_us"))

