local directory = minetest.get_worldpath().."/points.0gb.us/"
local points = {}

points_0gb_us = {
	load = function(name)
		points[name] = {}
		local file = io.open(directory..name, "r")
		if file then
			for line in file:lines() do
				if line ~= "" then
					local space = line:find(" ", 1, true)
					local key = line:sub(1, space-1)
					local value = line:sub(space+1)
					points[name][key] = tonumber(value)
				end
			end
			file:close()
		end
	end,

	save = function(name)
		local file = io.open(directory..name, "w")
		for key,value in pairs(points[name]) do
			file:write(key.." "..value.."\n")
		end
		file:close()
	end,

	unload = function(name)
		points[name] = nil
	end,

	read_points = function(name, node)
		return points[name][node] or 0
	end,

	add_points = function(name, node, number)
-- number can be negative
		if points[name][node] then
			points[name][node] = points[name][node] + number
		else
			points[name][node] = number
		end
	end,

	register_ore = function(ore)
		def = {}
		for key, value in pairs(minetest.registered_nodes[ore]) do
			def[key] = value
		end
		function def.after_dig_node(pos, oldnode, oldmetadata, digger)
			local name = digger:get_player_name()
			points_0gb_us.add_points(name, oldnode.name, 1)
			points_0gb_us.save(name)
		end
		minetest.register_node(":"..ore, def)
	end,
	query = function(name)
		RETURN = {}
		for key, value in pairs(points[name]) do
			RETURN[key] = value
		end
		return RETURN
	end,
}

