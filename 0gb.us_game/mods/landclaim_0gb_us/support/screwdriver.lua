if minetest.get_modpath("screwdriver") then
	for i=1,4,1 do
		local tool = minetest.registered_items["screwdriver:screwdriver"..i]
		local on_use = tool.on_use
		function tool.on_use(itemstack, user, pointed_thing)
			local node=minetest.env:get_node(pos)
			if itemstack:to_table().metadata == ""
			or user:get_player_control().sneak
			or pointed_thing.type ~= "node" then
				screwdriver_handler(itemstack,user,pointed_thing)
				return itemstack
			end
			local node = minetest.env:get_node(pointed_thing.below)
			local name = user:get_player_name()
			if minetest.registered_nodes[node.name].paramtype2 ~= "facedir"
			or landclaim_0gb_us.can_interact(name,pos) then
				screwdriver_handler(itemstack,user,pointed_thing)
				return itemstack
			else
				local owner = landclaim_0gb_us.get_owner(pointed_thing.below)
				minetest.chat_send_player(name, "Area owned by "..owner)
				return itemstack
			end

		end
	end
end

