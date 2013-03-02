if io.open(minetest.get_modpath("points_0gb_us").."/INIT.LUA") then
	return minetest.debug("[points_0gb_us]: This plugin requires a case-sensitive file system to function correctly.")
end

local path = minetest.get_modpath("points_0gb_us")
dofile(path.."/api.lua")
dofile(path.."/startup.lua")
dofile(path.."/support.lua")

minetest.debug("[points_0gb_us]: Plugin loaded from\n"..minetest.get_modpath("points_0gb_us"))

