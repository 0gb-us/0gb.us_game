if minetest.get_modpath("doors") then
	function landclaim_0gb_us.protect_against_door(door)
		local definition = minetest.registered_items[door]
		local on_place = definition.on_place
		function definition.on_place(itemstack, placer, pointed_thing)
			local bottom = pointed_thing.above
			local top = {x=pointed_thing.above.x, y=pointed_thing.above.y+1, z=pointed_thing.above.z}
			local name = placer:get_player_name()
			if landclaim_0gb_us.can_interact(name, top) and landclaim_0gb_us.can_interact(name, bottom) then
				return on_place(itemstack, placer, pointed_thing)
			else
				topowner = landclaim_0gb_us.get_owner(top)
				bottomowner = landclaim_0gb_us.get_owner(bottom)
				if topowner and bottomowner and topowner ~= bottomowner then
					minetest.chat_send_player(name, "Area owned by "..topowner.." and "..bottomowner)
				elseif topowner then
					minetest.chat_send_player(name, "Area owned by "..topowner)
				else
					minetest.chat_send_player(name, "Area owned by "..bottomowner)
				end
			end
		end
	end

	landclaim_0gb_us.protect_against_door("doors:door_wood")
	landclaim_0gb_us.protect_against_door("doors:door_steel")
end

