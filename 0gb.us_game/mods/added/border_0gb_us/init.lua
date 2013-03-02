local allowedchunks = 483*3
local poswall = allowedchunks*16+15
local negwall = -allowedchunks*16

local function iswall(pos)
	for key, value in pairs(pos) do
		if value < negwall or value > poswall then
			return true
		end
	end
end

local default_dig = minetest.node_dig
function minetest.node_dig(pos, node, digger)
	if iswall(pos) then
		local name = digger:get_player_name()
		minetest.chat_send_player(name, "You have reached the edge of the map. Digging is prohibited here.")
	else
		default_dig(pos, node, digger)
	end
end

local default_place = minetest.item_place
function minetest.item_place(itemstack, placer, pointed_thing)
	if iswall(pointed_thing.above) then
		local name = placer:get_player_name()
		minetest.chat_send_player(name, "You have reached the edge of the map. Placing items is prohibited here.")
	else
		return default_place(itemstack, placer, pointed_thing)
	end
end

local default_drop = minetest.item_drop
function minetest.item_drop(itemstack, dropper, pos)
	if iswall(pos) then
		local name = dropper:get_player_name()
		minetest.chat_send_player(name, "You have reached the edge of the map. Dropping items is prohibited here.")
	else
		return default_drop(itemstack, dropper, pos)
	end
end

minetest.debug("[border_0gb_us]: Plugin loaded from\n"..minetest.get_modpath("border_0gb_us"))

