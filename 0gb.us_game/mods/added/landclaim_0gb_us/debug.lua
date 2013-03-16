minetest.register_chatcommand("claimdebug", {
	params = "",
	description = "debug command",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		pos.y = pos.y + .5 --compensated for Minetest's incorrect y coordinate for player objects
		minetest.chat_send_player(name, landclaim_0gb_us.get_chunk(pos))
		local entpos = landclaim_0gb_us.get_chunk_center(pos)
		minetest.env:add_entity(entpos, "landclaim_0gb_us:showarea")
	end,
})

