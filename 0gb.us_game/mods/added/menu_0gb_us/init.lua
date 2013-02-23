local function set_formspec(player)
	player:set_inventory_formspec(
		"size[8,9.5]\
		list[current_player;main;0,3.5;8,6;]\
		list[current_player;craft;3,0;3,3;]\
		list[current_player;craftpreview;7,1;1,1;]\
		button[0,0.1;3,0.5;skins;Choose Skin]"..
--		button[0,0.85;3,0.5;craftguide.0gb.us;Craft Guide]\
		"button[0,1.6;3,0.5;go.teleport.0gb.us;Warp Points]\
		button[0,2.35;3,0.5;die;Die (Respawn)]"
	)
end

minetest.register_on_joinplayer(function(player)
	set_formspec(player)
	local inv = player:get_inventory()
	inv:set_size("main", 8*6)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.main then
		set_formspec(player)
	elseif fields.die then
		player:set_hp(0)
	end
end)

minetest.register_chatcommand("die", {
	params = "",
	description = "kills you, causing you to respawn",
	privs = {},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		player:set_hp(0)
	end,
})

minetest.debug("[menu_0gb_us]:\nPlugin loaded from "..minetest.get_modpath("menu_0gb_us"))

