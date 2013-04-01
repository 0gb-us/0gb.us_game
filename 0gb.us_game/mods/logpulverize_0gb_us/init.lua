if io.open(minetest.get_modpath("logpulverize_0gb_us").."/INIT.LUA") then
	return minetest.debug("[logpulverize_0gb_us]:\nThis plugin requires a case-sensitive file system to function correctly.")
end

local directory = minetest.get_worldpath().."/logpulverize.0gb.us/"
os.execute('mkdir -p "'..directory..'"')

local func = minetest.chatcommands.pulverize.func
function minetest.chatcommands.pulverize.func(name, param)
	local player = minetest.env:get_player_by_name(name)
	if player and not player:get_wielded_item():is_empty() then
		local file = io.open(directory..name, "a")
		file:write(player:get_wielded_item():to_string().."\n")
		file:close()
	end
	func(name, param)
end

minetest.debug("[logpulverize_0gb_us]: Plugin loaded from\n"..minetest.get_modpath("logpulverize_0gb_us"))

