local function can_modify(pos, player)
	local chestpos = {x=pos.x,y=pos.y-1,z=pos.z}
	local node = minetest.env:get_node_or_nil(chestpos)
	if not node then
		return false
	elseif node.name ~= "default:chest_locked" then
		return true
	else
		local meta = minetest.env:get_meta(chestpos)
		return meta:get_string("owner") == player:get_player_name()
	end
end

local function parse_shop(text)
	local input = text:match('^"" Input: ([%w_: ]*) Output: [%w_: ]* ""$')
	local output = text:match('^"" Input: [%w_: ]* Output: ([%w_: ]*) ""$')
-- " Input: default:iron_lump 9 Output: default:papyrus "
	if input and output then
		return { input=input, output=output }
	end
end

local sign = {}
for key, value in pairs(minetest.registered_items["default:sign_wall"]) do
	sign[key] = value
end

local on_receive_fields = sign.on_receive_fields
sign.can_dig = can_modify

function sign.on_receive_fields(pos, formname, fields, sender)
	if can_modify(pos, sender) then
		on_receive_fields(pos, formname, fields, sender)
	else
		minetest.chat_send_player(sender:get_player_name(), "You may not edit this sign.")
	end
end

function sign.on_punch(pos, node, puncher)
	if can_modify(pos, puncher) or not puncher:is_player() then
		return
	end
	local chestpos = {x=pos.x,y=pos.y-1,z=pos.z}
	local chestinv = minetest.env:get_meta(chestpos):get_inventory()
	local signtext = minetest.env:get_meta(pos):get_string("infotext")
	local playerinv = puncher:get_inventory()

	local shop = parse_shop(signtext)
	if shop then
		if not chestinv:room_for_item("main", shop.input) then
			minetest.chat_send_player(puncher:get_player_name(), "ERROR: Chest inventory is full.")
		elseif not chestinv:contains_item("main", shop.output) then
			minetest.chat_send_player(puncher:get_player_name(), "ERROR: Chest is out of inventory.")
		elseif not playerinv:room_for_item("main", shop.output) then
			minetest.chat_send_player(puncher:get_player_name(), "ERROR: Your inventory if full.")
		elseif not playerinv:contains_item("main", shop.input) then
			minetest.chat_send_player(puncher:get_player_name(), "ERROR: Your inventory does not contain the required items.")
		else
			local input = playerinv:remove_item("main", shop.input)
			chestinv:add_item("main", input)
			local output = chestinv:remove_item("main", shop.output)
			playerinv:add_item("main", output)
			minetest.chat_send_player(puncher:get_player_name(), "You paid "..shop.input.." and recieved "..shop.output..".")
		end
	end
end

function sign.on_place(itemstack, placer, pointed_thing)
	if can_modify(pointed_thing.above, placer) or not placer:is_player() then
		return minetest.item_place(itemstack, placer, pointed_thing)
	else
		minetest.chat_send_player(placer:get_player_name(), "You may not place a sign here.")
	end
end

minetest.register_node(":default:sign_wall", sign)

minetest.debug("[barter_0gb_us]:\nPlugin loaded from "..minetest.get_modpath("barter_0gb_us"))

