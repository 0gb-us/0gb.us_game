if minetest.get_modpath("landclaim_0gb_us") then
	function build_0gb_us.chunk_select(name)
		local player = minetest.env:get_player_by_name(name)
		local pos = landclaim_0gb_us.get_chunk_center(player:getpos())
		if not build_0gb_us.pos[name] then
			build_0gb_us.pos[name] = {}
		end
		build_0gb_us.pos[name].pos0 = {x=pos.x-7.5,y=pos.y-7.5,z=pos.z-7.5}
		build_0gb_us.pos[name].pos1 = {x=pos.x+7.5,y=pos.y+7.5,z=pos.z+7.5}
	end

	minetest.register_chatcommand("chunk", {
		params = "",
		description = "Selects the current map chunk",
		privs = {build=true},
		func = function(name, param)
			build_0gb_us.chunk_select(name)
	--[[		local select = minetest.env:add_entity(pos, "build_0gb_us:pos")
			select:init(name, "pos")]]
			minetest.chat_send_player(name, "Map chunk selected.")
		end,
	})
end

