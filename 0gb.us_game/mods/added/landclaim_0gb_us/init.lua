if io.open(minetest.get_modpath("landclaim_0gb_us").."/INIT.LUA") then
	return minetest.debug("[landclaim_0gb_us]:\nThis plugin depends on points_0gb_us, which requires a case-sensitive file system to function correctly.")
end

local path = minetest.get_modpath("landclaim_0gb_us")
dofile(path.."/api.lua")
dofile(path.."/commands.lua")
dofile(path.."/debug.lua")

local default_place = minetest.item_place
local default_dig = minetest.node_dig

function minetest.node_dig(pos, node, digger)
	local player = digger:get_player_name()
	if landclaim_0gb_us.can_interact(player, pos) then
		default_dig(pos, node, digger)
	else
		minetest.chat_send_player(player, "Area owned by "..landclaim_0gb_us.get_owner(pos))
	end
end

function minetest.item_place(itemstack, placer, pointed_thing)
	if itemstack:get_definition().type == "node" then
	owner = landclaim_0gb_us.get_owner(pointed_thing.above)
	player = placer:get_player_name()
		if landclaim_0gb_us.can_interact(player, pointed_thing.above) then
			return default_place(itemstack, placer, pointed_thing)
		else
			minetest.chat_send_player(player, "Area owned by "..owner)
		end
	else
		return default_place(itemstack, placer, pointed_thing)
	end
end
				
landclaim_0gb_us.load_claims()
-- Load now

minetest.after(0,function()
	dofile(path.."/support/bucket.lua")
	dofile(path.."/support/build_0gb_us.lua")
	dofile(path.."/support/default.lua")
	dofile(path.."/support/doors.lua")
	dofile(path.."/support/fire.lua")
end)

minetest.debug("[landclaim_0gb_us]: Plugin loaded from\n"..minetest.get_modpath("landclaim_0gb_us"))

