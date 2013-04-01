if minetest.get_modpath("screwdriver") then
	for i=1,4,1 do
		local tool = minetest.registered_items["screwdriver:screwdriver"..i]
		local on_use = tool.on_use
		function tool.on_use(itemstack, user, pointed_thing)
			local pos = minetest.get_pointed_thing_position(pointed_thing,above)
			local node=minetest.env:get_node(pos)
			local name = user:get_player_name()
			if user:get_player_control().sneak or
			pointed_thing.type ~= "node" or
			minetest.registered_nodes[node.name].paramtype2 ~= "facedir" or
			landclaim_0gb_us.can_interact(name,pos) then
				screwdriver_handler(itemstack,user,pointed_thing)
				return itemstack
			else
				local owner = landclaim_0gb_us.get_owner(pos)
				minetest.chat_send_player(name, "Area owned by "..owner)
			end
		end
	end
end
