if minetest.get_modpath("build_0gb_us") then
	local place = build_0gb_us.place
	function build_0gb_us.place(player, pos, node, dir)
		if landclaim_0gb_us.can_interact(player:get_player_name(), pos) then
			place(player, pos, node, dir)
		else
			local owner = landclaim_0gb_us.get_owner(pos)
			minetest.chat_send_player(name, "This area is owned by "..owner)
		end
	end
end

