if minetest.get_modpath("default") then
	local sign = minetest.registered_items["default:sign_wall"]
	local on_receive_fields = sign.on_receive_fields
	function sign.on_receive_fields(pos, formname, fields, sender)
		local name = sender:get_player_name()
		if landclaim_0gb_us.can_interact(name, pos) then
			on_receive_fields(pos, formname, fields, sender)
		else
			local owner = landclaim_0gb_us.get_owner(pos)
			minetest.chat_send_player(name, "Area owned by "..owner)
		end
	end
	minetest.register_node(":default:sign_wall", sign)
end

