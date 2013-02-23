local directory = minetest.get_worldpath().."/points.0gb.us/"
os.execute('mkdir -p "'..directory..'"')

minetest.register_on_joinplayer(function(player)
	points_0gb_us.load(player:get_player_name())
end)

minetest.register_on_leaveplayer(function(player)
	points_0gb_us.unload(player:get_player_name())
end)

