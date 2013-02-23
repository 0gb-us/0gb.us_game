minetest.register_privilege("drain", "Lava cleanup duty? Again!?")

minetest.register_chatcommand("drain", {
	params = "",
	description = "Destroys all nodes that can be built to within the current map chunk ",
	privs = {demigod=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()

		if not landclaim_0gb_us.can_interact(name, pos) then
			owner = landclaim_0gb_us.get_owner(pos)
			minetest.chat_send_player(name, "Area owned by "..owner)
			return
		end

		local center = landclaim_0gb_us.get_chunk_center(pos)
		local min = math.max(center.y-7.5, 2)
		
		for y = min,center.y+7.5 do
			for x = center.x-7.5,center.x+7.5 do
				for z = center.z-7.5,center.z+7.5 do
					local node = minetest.env:get_node_or_nil({x=x,y=y,z=z})
					if node and minetest.registered_items[node.name].buildable_to then
						minetest.env:remove_node({x=x,y=y,z=z})
					end
				end
			end
		end
	end,
})

minetest.debug("[drain_0gb_us]:\nPlugin loaded from "..minetest.get_modpath("drain_0gb_us"))

