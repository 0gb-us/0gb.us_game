if io.open(minetest.get_modpath("build_0gb_us").."/INIT.LUA") then
	return minetest.debug("[build_0gb_us]: This plugin requires a case-sensitive file system to function correctly.")
end




local function craft(inv, node)
	if not build_0gb_us.craft[node] then
		return false
	elseif not inv:room_for_item("main", build_0gb_us.craft[node].output) then
		return false
	end
	for index, value in ipairs(build_0gb_us.craft[node].input) do
		if not inv:contains_item("main", value) then
			local singleitem = value:split(" ")[1]
			while not inv:contains_item("main", value) do
				if not craft(inv,singleitem) then
					return false
				end
			end
		end
	end
	for index, value in pairs(build_0gb_us.craft[node].input) do
		inv:remove_item("main", value)
	end
	inv:add_item("main", build_0gb_us.craft[node].output)
	return true
end

build_0gb_us = {
	directory = minetest.setting_get("directory.build.0gb.us") or minetest.get_worldpath().."/schems",
-- compatible with worldedit by default
	generators = {},
	place = function(player, pos, placenode, dir, updateoverride)
		local inv = player:get_inventory()
		local node = minetest.env:get_node_or_nil(pos)
		if not node or not minetest.registered_nodes[node.name] then
			return
		elseif minetest.registered_nodes[node.name].buildable_to then
			if not minetest.registered_nodes[placenode] then
				return
			elseif inv:contains_item("main",{name=placenode}) 
			or craft(inv, placenode) then
				inv:remove_item("main",{name=placenode})
				minetest.env:set_node(pos, {name=placenode, param2=dir})
				if minetest.registered_items[node.name].after_place_node then
					minetest.registered_items[node.name].after_place_node(pos, player)
-- Fixes locked chest placement in a non-hacky way. Also works for nodes defined in non-default plugins.
				end
				if not updateoverride then
					nodeupdate(pos)
-- Prevents falling nodes and attached nodes from being placed in midair. Should be (and is) overridden for things such as world edit imports, as not overriding this can prevent legitimate constructions to fall apart when imported.
				end
			end
		end
	end,
	round = function(pos)
		return {
			x = math.floor(pos.x + 0.5),
			y = math.floor(pos.y + 0.5),
			z = math.floor(pos.z + 0.5),
		}
	end,
	normalize = function(pos0, pos1)
		local min, max = {}, {}
		min.x, max.x = math.min(pos0.x, pos1.x), math.max(pos0.x, pos1.x)
		min.y, max.y = math.min(pos0.y, pos1.y), math.max(pos0.y, pos1.y)
		min.z, max.z = math.min(pos0.z, pos1.z), math.max(pos0.z, pos1.z)
		return min, max
	end,
	fill = function(player, pos0, pos1, node, dir)
		local min, max = build_0gb_us.normalize(pos0, pos1)
		for y = min.y, max.y do
			for x = min.x, max.x do
				for z = min.z, max.z do
					build_0gb_us.place(player, {x=x,y=y,z=z}, node, dir)
				end
			end
		end
end,

register_generator = function(name, func)
	build_0gb_us.generators[name]=func
end,


fillpattern = function(player, pos0, pos1, pattern, dir)
		local seed=0
		local min, max = build_0gb_us.normalize(pos0, pos1)
		local size = {x=max.x-min.x, y=max.y-min.y, z=max.z-min.z}
		if build_0gb_us.generators[pattern] then
			for x = min.x, max.x do
				for y = min.y, max.y do
					for z = min.z, max.z do
						build_0gb_us.place(player, {x=x,y=y,z=z}, build_0gb_us.generators[pattern]({x=x-min.x, y=y-min.y, z=z-min.z}, size), dir)
					end
				end
			end
		end
	
	
	end,
	export = function(name, pos0, pos1, filename)
		local min, max = build_0gb_us.normalize(pos0, pos1)
		os.execute('mkdir -p "'..build_0gb_us.directory.."/"..name..'"')
		local tosave = {}
		local minused = {}
		for y = min.y, max.y do
			for x = min.x, max.x do
				for z = min.z, max.z do
					local node = minetest.env:get_node_or_nil({x=x,y=y,z=z})
					if node then
						if not minetest.registered_items[node.name]
						or not minetest.registered_items[node.name].buildable_to then
							table.insert(tosave,{x=x,y=y,z=z,data=node.name.." "..node.param1.." "..node.param2})
							if not minused.x or x < minused.x then
								minused.x  = x
							end
							if not minused.y or y < minused.y then
								minused.y  = y
							end
							if not minused.z or z < minused.z then
								minused.z  = z
							end
						end
					end
				end
			end
		end
		if minused.x then
			local file = io.open(build_0gb_us.directory.."/"..name.."/"..filename..".we", "w")
			for _, line in ipairs(tosave) do
				file:write(line.x-minused.x.." "..line.y-minused.y.." "..line.z-minused.z.." "..line.data.."\n")
			end
			file:close()
			minetest.chat_send_player(name, "Exported.")

		else
			minetest.chat_send_player(name, "Nothing found to export.")
		end
	end,
	import = function(name, pos0, pos1, filename)
		if filename:find("/") then
			filename = build_0gb_us.directory.."/"..filename..".we"
		else
			filename = build_0gb_us.directory.."/"..name.."/"..filename..".we"
		end
		local file = io.open(filename, "r")
		if file then
			local player = minetest.env:get_player_by_name(name)
			local min, max = build_0gb_us.normalize(pos0, pos1)
			for line in file:lines() do
				local data = line:split(" ")
				if #data == 6 then
					build_0gb_us.place(player, {x=min.x+data[1],y=min.y+data[2],z=min.z+data[3]}, data[4], data[6], true)
-- Ignore data[5], which represents param1
				end
			end
			file:close()
			minetest.chat_send_player(name, "Imported.")
		else
			minetest.chat_send_player(name, "The file failed to load. It may be missing.")
		end
	end,
	find_cost = function(name, filename)
		if filename:find("/") then
			filename = build_0gb_us.directory.."/"..filename..".we"
		else
			filename = build_0gb_us.directory.."/"..name.."/"..filename..".we"
		end
		local file = io.open(filename, "r")
		if file then
			local count = {}
			for line in file:lines() do
				local data = line:split(" ")
				if #data == 6 then
					if not count[data[4]] then
						count[data[4]] = 1
					else
						count[data[4]] = count[data[4]] + 1
					end
				end
			end
			file:close()
			local responce = ""
			for key, value in pairs(count) do
				responce = responce..key.." "..value.." "
			end
			minetest.chat_send_player(name, responce)
		else
			minetest.chat_send_player(name, "The file failed to load. It may be missing.")
		end
	end,

	primitives = {},
	blueprints = {},
	craft = {},
	pos = {},
}

os.execute('mkdir -p "'..build_0gb_us.directory..'"')

minetest.register_privilege("build", "May use the /build command to build structures")

minetest.register_chatcommand("build", {
	params = "<structure>",
	description = "Builds a structure if there are enough materials in the user's inventory",
	privs = {build=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()

		if not landclaim_0gb_us.can_interact(name, pos) then
			owner = landclaim_0gb_us.get_owner(pos)
			minetest.chat_send_player(name, "Area owned by "..owner)
			return
		elseif not build_0gb_us.blueprints[param] then
			minetest.chat_send_player(name, 'A blueprint for "'..param..'" does not exist.')
			return
		else
			local center = landclaim_0gb_us.get_chunk_center(pos)
			build_0gb_us.blueprints[param](center, player)
		end
	end,
})

minetest.register_chatcommand("pos0", {
	params = "",
	description = "Sets position zero",
	privs = {build=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = build_0gb_us.round(player:getpos())
		if not build_0gb_us.pos[name] then
			build_0gb_us.pos[name] = {}
		end
		build_0gb_us.pos[name].pos0 = pos
--[[		local select = minetest.env:add_entity(pos, "build_0gb_us:pos")
		select:init(name, "pos1")]]
		minetest.chat_send_player(name, "Position zero set to "..minetest.pos_to_string(pos))
	end,
})

minetest.register_chatcommand("pos1", {
	params = "",
	description = "Sets position one",
	privs = {build=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = build_0gb_us.round(player:getpos())
		if not build_0gb_us.pos[name] then
			build_0gb_us.pos[name] = {}
		end
		build_0gb_us.pos[name].pos1 = pos
--[[		local select = minetest.env:add_entity(pos, "build_0gb_us:pos")
		select:init(name, "pos2")]]
		minetest.chat_send_player(name, "Position one set to "..minetest.pos_to_string(pos))
	end,
})

minetest.register_chatcommand("pos", {
	params = "",
	description = "Sets position zero and one",
	privs = {build=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = build_0gb_us.round(player:getpos())
		if not build_0gb_us.pos[name] then
			build_0gb_us.pos[name] = {}
		end
		build_0gb_us.pos[name].pos0 = pos
		build_0gb_us.pos[name].pos1 = pos
--[[		local select = minetest.env:add_entity(pos, "build_0gb_us:pos")
		select:init(name, "pos")]]
		minetest.chat_send_player(name, "Position zero and one both set to "..minetest.pos_to_string(pos))
	end,
})

minetest.register_chatcommand("fill", {
	params = "<node>",
	description = "Fills an area with the given node",
	privs = {build=true},
	func = function(name, param)
		if param == "" then
			minetest.chat_send_player(name, "/fill requires an argument.")
			return
		end
		if not build_0gb_us.pos[name] or not build_0gb_us.pos[name].pos0 or not build_0gb_us.pos[name].pos1 then
			minetest.chat_send_player(name, "Use /pos0 and /pos1 to set the corners of an area.")
		else
			local player = minetest.env:get_player_by_name(name)
			build_0gb_us.fill(player, build_0gb_us.pos[name].pos0, build_0gb_us.pos[name].pos1, param)
			minetest.chat_send_player(name, "Filled.")
		end
	end,
})

minetest.register_chatcommand("fillpattern", {
	params = "<pattern>",
	description = "Fills an area with the given pattern of nodes",
	privs = {build=true},
	func = function(name, param)
		if param == "" then
			minetest.chat_send_player(name, "/fillpattern requires an argument.")
			return
		end
		if not build_0gb_us.pos[name] or not build_0gb_us.pos[name].pos0 or not build_0gb_us.pos[name].pos1 then
			minetest.chat_send_player(name, "Use /pos0 and /pos1 to set the corners of an area.")
		else
			local player = minetest.env:get_player_by_name(name)
			build_0gb_us.fillpattern(player, build_0gb_us.pos[name].pos0, build_0gb_us.pos[name].pos1, param)
			minetest.chat_send_player(name, "Filled.")
		end
	end,
})


minetest.register_chatcommand("export", {
	params = "<filename>",
	description = "Exports the selected area to a worldedit-compatible file",
	privs = {build=true},
	func = function(name, param)
		if not build_0gb_us.pos[name] or not build_0gb_us.pos[name].pos0 or not build_0gb_us.pos[name].pos1 then
			minetest.chat_send_player(name, "Use /pos0 and /pos1 to set the corners of an area.")
		elseif param:find("/") then
			minetest.chat_send_player(name, "Slashes are not allowed in file names.")
		else
			build_0gb_us.export(name, build_0gb_us.pos[name].pos0, build_0gb_us.pos[name].pos1, param)
		end
	end,
})

minetest.register_chatcommand("import", {
	params = "<filename>",
	description = "Imports a worldedit-compatible file to the selected area",
	privs = {build=true},
	func = function(name, param)
		if not build_0gb_us.pos[name] or not build_0gb_us.pos[name].pos0 or not build_0gb_us.pos[name].pos1 then
			minetest.chat_send_player(name, "Use /pos to set a spot to import to.")
		else
			build_0gb_us.import(name, build_0gb_us.pos[name].pos0, build_0gb_us.pos[name].pos1, param)
		end
	end,
})


minetest.register_chatcommand("importcost", {
	params = "<filename>",
	description = "Finds the cost of importing a given structure",
	privs = {build=true},
	func = build_0gb_us.find_cost
})


--[[minetest.register_entity("build_0gb_us:pos",{
	on_activate = function(self, staticdata, dtime_s)
		if self.owner and self.pos then
			if not build_0gb_us.pos[self.owner]
			or build_0gb_us.pos[self.owner][self.pos] ~= self.object.get_pos() then
				self.object:remove()
			end
		end
	end,
	initial_properties = {
		hp_max = 1,
		physical = true,
		weight = 0,
		collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
		visual = "cube",
		visual_size = {x=1.1, y=1.1},
		mesh = "model",
		textures = {"0gb.us_showarea.png", "0gb.us_showarea.png", "0gb.us_showarea.png", "0gb.us_showarea.png", "0gb.us_showarea.png", "0gb.us_showarea.png"}, -- number of required textures depends on visual
		colors = {}, -- number of required colors depends on visual
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = false,
	},
	init = function(self, owner, pos)
		self.owner = owner
		self.pos = pos
	end,
})]]

dofile(minetest.get_modpath("build_0gb_us").."/craft.lua")
dofile(minetest.get_modpath("build_0gb_us").."/cobble.lua")
dofile(minetest.get_modpath("build_0gb_us").."/chunk.lua")
dofile(minetest.get_modpath("build_0gb_us").."/defaultgenerators.lua")

minetest.debug("[build_0gb_us]: Plugin loaded from\n"..minetest.get_modpath("build_0gb_us"))

