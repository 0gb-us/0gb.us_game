function build_0gb_us.replace_with_cobble(node)
	if not minetest.registered_nodes[node] or minetest.registered_nodes[node].buildable_to then
		return "air"
	elseif minetest.registered_nodes[node].paramtype == "light" then
		if minetest.registered_nodes[node].paramtype2 == "facedir" then
			return "stairs:stair_cobble"
		else
			return "stairs:slab_cobble"
		end
	elseif minetest.registered_nodes[node].on_construct then
		return "default:furnace"
	elseif minetest.registered_nodes[node].groups.falling_node then
		return "default:gravel"
	else
		return "default:cobble"
	end
end

function build_0gb_us.import_as_cobble(name, pos0, pos1, filename)
	if filename:find("/") then
		filename = build_0gb_us.directory.."/"..filename..".we"
	else
		filename = build_0gb_us.directory.."/"..name.."/"..filename..".we"
	end
	local file = io.open(filename, "r")
	if file then
		local player = minetest.env:get_player_by_name(name)
		if not player then
			return
		end
		local min, max = build_0gb_us.normalize(pos0, pos1)
		for line in file:lines() do
			local data = line:split(" ")
			if #data == 6 then
				local cobble = build_0gb_us.replace_with_cobble(data[4])
				build_0gb_us.place(player, {x=min.x+data[1],y=min.y+data[2],z=min.z+data[3]}, cobble, data[6], true)
-- Ignore data[5], which represents param1
			end
		end
		file:close()
		minetest.chat_send_player(name, "Imported as cobble.")
	else
		minetest.chat_send_player(name, "The file failed to load. It may be missing.")
	end
end

minetest.register_chatcommand("import_cobble", {
	params = "<filename>",
	description = "Imports a worldedit-compatible file to the selected area in cobble form",
	privs = {build=true},
	func = function(name, param)
		if not build_0gb_us.pos[name] or not build_0gb_us.pos[name].pos0 or not build_0gb_us.pos[name].pos1 then
			minetest.chat_send_player(name, "Use /pos to set a spot to import to.")
		else
			build_0gb_us.import_as_cobble(name, build_0gb_us.pos[name].pos0, build_0gb_us.pos[name].pos1, param)
		end
	end,
})

