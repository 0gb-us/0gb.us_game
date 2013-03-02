if io.open(minetest.get_modpath("landclaim_0gb_us").."/INIT.LUA") then
	return minetest.debug("[landclaim_0gb_us]:\nThis plugin depends on points_0gb_us, which requires a case-sensitive file system to function correctly.")
end

--Configuration
local price = {
	ore = minetest.setting_get("ore.landclaim.0gb.us") or "default:stone_with_iron",
	number = tonumber(minetest.setting_get("number.landclaim.0gb.us") or 9),
}

-- Lua definitions:

landclaim_0gb_us = {}

local claims = {}
local filename = minetest.get_worldpath().."/0gb.us"

function landclaim_0gb_us.load_claims()
	local file = io.open(filename, "r")
	if file then
		for line in file:lines() do
			if line ~= "" then
				local area = line:split(" ")
				local shared = {}
				if area[3] and area[3] ~= "*" then
					for k,v in ipairs(area[3]:split(",")) do
						shared[v] = v
					end
				end
				claims[area[1]] = {owner=area[2], shared=shared}
			end
		end
		file:close()
	end
end

function landclaim_0gb_us.save_claims()
	local file = io.open(filename, "w")
	for key,value in pairs(claims) do
		local sharedata = ""
		for k,v in pairs(value.shared) do
			sharedata = sharedata..v..","
		end
		local sharestring
		if sharedata == "" then
			sharestring = "*"
		else
			sharestring = sharedata:sub(1,-2)
		end
		file:write(key.." "..value.owner.." "..sharestring.."\n")
	end
	file:close()
end

function landclaim_0gb_us.get_chunk(pos)
	local x = math.floor((pos.x+.5)/16)
	local y = math.floor((pos.y+.5)/16)
	local z = math.floor((pos.z+.5)/16)
	return x..","..y..","..z
end

function landclaim_0gb_us.get_chunk_center(pos)
	local x = math.floor((pos.x+.5)/16)*16+7.5
	local y = math.floor((pos.y+.5)/16)*16+7.5
	local z = math.floor((pos.z+.5)/16)*16+7.5
	return {x=x,y=y,z=z}
end

function landclaim_0gb_us.get_owner(pos)
	local chunk = landclaim_0gb_us.get_chunk(pos)
	if claims[chunk] then
		return claims[chunk].owner
	end
end

function landclaim_0gb_us.can_interact(name, pos)	
	local chunk = landclaim_0gb_us.get_chunk(pos)
	return claims[chunk] == nil or claims[chunk].owner == name or claims[chunk].shared[name]
end

local default_place = minetest.item_place
local default_dig = minetest.node_dig

-- Redefined Lua:

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

-- In-game additions:

minetest.register_chatcommand("landowner", {
	params = "",
	description = "tells the owner of the current map chunk",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		pos.y = pos.y + .5 --compensated for Minetest's incorrect y coordinate for player objects
		local owner = landclaim_0gb_us.get_owner(pos)
		if owner then
			minetest.chat_send_player(name, "This area is owned by "..owner)
			local entpos = landclaim_0gb_us.get_chunk_center(pos)
			minetest.env:add_entity(entpos, "landclaim_0gb_us:showarea")
		else
			minetest.chat_send_player(name, "This area is unowned.")
		end
	end,
})

minetest.register_chatcommand("claim", {
	params = "",
	description = "claims the current map chunk",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		pos.y = pos.y + .5 --compensated for Minetest's incorrect y coordinate for player objects
		local owner = landclaim_0gb_us.get_owner(pos)
		if owner then
			minetest.chat_send_player(name, "This area is already owned by "..owner)
		elseif points_0gb_us.read_points(name, price.ore) < price.number then
			minetest.chat_send_player(name, "You need to mine more "..price.ore.." before you can claim an area.")
		else
			chunk = landclaim_0gb_us.get_chunk(pos)
			claims[chunk] = {owner=name,shared={}}
			landclaim_0gb_us.save_claims()
			minetest.chat_send_player(claims[chunk].owner, "You now own this area.")
			points_0gb_us.add_points(name, price.ore, -price.number)
			points_0gb_us.save(name)
			local entpos = landclaim_0gb_us.get_chunk_center(pos)
			minetest.env:add_entity(entpos, "landclaim_0gb_us:showarea")
		end
	end,
})

minetest.register_chatcommand("unclaim", {
	params = "",
	description = "unclaims the current map chunk",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		pos.y = pos.y + .5 --compensated for Minetest's incorrect y coordinate for player objects
		local owner = landclaim_0gb_us.get_owner(pos)
		local inv = player:get_inventory()
		if owner then
			if owner == name then
				points_0gb_us.add_points(name, price.ore, price.number)
				points_0gb_us.save(name)
				chunk = landclaim_0gb_us.get_chunk(pos)
				claims[chunk] = nil
				landclaim_0gb_us.save_claims()
				minetest.chat_send_player(name, "You renounced your claim on this area.")
				local entpos = landclaim_0gb_us.get_chunk_center(pos)
				minetest.env:add_entity(entpos, "landclaim_0gb_us:showarea")
			else
				minetest.chat_send_player(name, "This area is owned by "..owner)
			end
		else
			minetest.chat_send_player(name, "This area is unowned.")
		end
	end,
})

minetest.register_chatcommand("sharearea", {
	params = "<name>",
	description = "shares the current map chunk with <name>",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		pos.y = pos.y + .5 --compensated for Minetest's incorrect y coordinate for player objects
		local owner = landclaim_0gb_us.get_owner(pos)
		if owner then
			if owner == name and name ~= param then
				if minetest.auth_table[param] then
					claims[landclaim_0gb_us.get_chunk(pos)].shared[param] = param
					landclaim_0gb_us.save_claims()
					minetest.chat_send_player(name, param.." may now edit this area.")
					minetest.chat_send_player(param, name.." has just shared an area with you.")
					local entpos = landclaim_0gb_us.get_chunk_center(pos)
					minetest.env:add_entity(entpos, "landclaim_0gb_us:showarea")
				else
					minetest.chat_send_player(name, param.." is not a valid player.")
				end
			else
				minetest.chat_send_player(name, "This area is owned by "..owner)
			end
		else
			minetest.chat_send_player(name, "This area is unowned.")
		end
	end,
})

minetest.register_chatcommand("unsharearea", {
	params = "<name>",
	description = "unshares the current map chunk with <name>",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		pos.y = pos.y + .5 --compensated for Minetest's incorrect y coordinate for player objects
		local owner = landclaim_0gb_us.get_owner(pos)
		if owner then
			if owner == name then
				if name ~= param then
					claims[landclaim_0gb_us.get_chunk(pos)].shared[param] = nil
					landclaim_0gb_us.save_claims()
					minetest.chat_send_player(name, param.." may no longer edit this area.")
					minetest.chat_send_player(param, name.." has just revoked your editing privileges in an area.")
					local entpos = landclaim_0gb_us.get_chunk_center(pos)
					minetest.env:add_entity(entpos, "landclaim_0gb_us:showarea")
				else
					minetest.chat_send_player(name, 'Use "/unclaim" to unclaim the aria.')
				end
			else
				minetest.chat_send_player(name, "This area is owned by "..owner)
			end
		else
			minetest.chat_send_player(name, "This area is unowned.")
		end
	end,
})

minetest.register_chatcommand("mayedit", {
	params = "",
	description = "lists the people who may edit the current map chunk",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		pos.y = pos.y + .5 --compensated for Minetest's incorrect y coordinate for player objects
		local mayedit = landclaim_0gb_us.get_owner(pos)
		if mayedit then
			local chunk = landclaim_0gb_us.get_chunk(pos)
			for user, user in pairs(claims[chunk].shared) do
				mayedit = mayedit..", "..user
			end
			minetest.chat_send_player(name, mayedit)
			local entpos = landclaim_0gb_us.get_chunk_center(pos)
			minetest.env:add_entity(entpos, "landclaim_0gb_us:showarea")
		else
			minetest.chat_send_player(name, "This area is unowned.")
		end
	end,
})


minetest.register_entity("landclaim_0gb_us:showarea",{
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(16,function()
			self.object:remove()
		end)
	end,
	initial_properties = {
		hp_max = 1,
		physical = true,
		weight = 0,
		collisionbox = {-8,-8,-8,8,8,8},
		visual = "mesh",
		visual_size = {x=16.1, y=16.1},
		mesh = "0gb.us_showarea.x",
		textures = {"0gb.us_showarea.png", "0gb.us_showarea.png", "0gb.us_showarea.png", "0gb.us_showarea.png", "0gb.us_showarea.png", "0gb.us_showarea.png"}, -- number of required textures depends on visual
		colors = {}, -- number of required colors depends on visual
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = false,
	}
})

minetest.register_chatcommand("showarea", {
	params = "",
	description = "highlights the boundaries of the current protected area",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		pos.y = pos.y + .5 --compensated for Minetest's incorrect y coordinate for player objects
		local owner = landclaim_0gb_us.get_owner(pos)
		if owner or param == "override" then
			if landclaim_0gb_us.can_interact(name, pos) or param == "override" then
				local entpos = landclaim_0gb_us.get_chunk_center(pos)
				minetest.env:add_entity(entpos, "landclaim_0gb_us:showarea")
			else
				minetest.chat_send_player(name, "This area is owned by "..owner)
			end
		else
			minetest.chat_send_player(name, "This area is unowned.")
		end
	end,
})

minetest.after(0,function()
	local path = minetest.get_modpath("landclaim_0gb_us")
	dofile(path.."/bucket.lua")
	dofile(path.."/build_0gb_us.lua")
	dofile(path.."/default.lua")
	dofile(path.."/doors.lua")
	dofile(path.."/fire.lua")

	dofile(path.."/debug.lua")
end)

minetest.debug("[landclaim_0gb_us]: Plugin loaded from\n"..minetest.get_modpath("landclaim_0gb_us"))

