minetest.register_chatcommand("clearobjects", {
	params = "",
	description = "clear all objects in loaded areas",
	privs = {server=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		for _, obj in pairs(minetest.env:get_objects_inside_radius({x=0,y=0,z=0}, 1000000)) do
			if not obj:is_player() then
				obj:remove()
			end
		end
	end,
})

minetest.debug("[chatcommands_0gb_us]: Plugin loaded from\n"..minetest.get_modpath("chatcommands_0gb_us"))

