minetest.after(1, function()
	for _,ore in ipairs({
		"default:stone_with_coal",
		"default:stone_with_iron",
		"default:stone_with_mese",
		"default:stone_with_gold",
		"default:stone_with_diamond",
		"default:stone_with_copper",
	}) do
		if minetest.registered_nodes[ore] then
			points_0gb_us.register_ore(ore)
		end
	end
end)


