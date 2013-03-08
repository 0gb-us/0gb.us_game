if minetest.get_modpath("build_0gb_us") then
	local place = build_0gb_us.place
	function build_0gb_us.place(player, pos, node, dir, updateoverride)
		local name = player:get_player_name()
		if landclaim_0gb_us.can_interact(name, pos) then
			place(player, pos, node, dir, updateoverride)
		else
			local owner = landclaim_0gb_us.get_owner(pos)
			minetest.chat_send_player(name, "This area is owned by "..owner)
		end
	end
end

