-- Get tables from api.lua and hide them from the global scope:
local price = landclaim_0gb_us.price
local claims = landclaim_0gb_us.claims
landclaim_0gb_us.price = nil
landclaim_0gb_us.claims = nil

minetest.register_privilege("claim_admin", "Can override claims")

minetest.register_chatcommand("claimoverride", {
	params = "on | off",
	description = "allows a claims administrator to override land claim effects",
	privs = {claim_admin=true},
	func = function(name, param)
		if param == "on" then
			landclaim_0gb_us.override[name] = true
			minetest.chat_send_player(name, "Claim override is in effect.")
		elseif param == "off" then
			landclaim_0gb_us.override[name] = nil
			minetest.chat_send_player(name, "Claim override is no longer in effect.")
		else
			minetest.chat_send_player(name, "Invalid argument given.")
		end
	end,
})

minetest.register_chatcommand("claim", {
	params = "",
	description = "claims the current map chunk",
	privs = {interact=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		if not player then
			return
		end
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
		if not player then
			return
		end
		local pos = player:getpos()
		pos.y = pos.y + .5 --compensated for Minetest's incorrect y coordinate for player objects
		local owner = landclaim_0gb_us.get_owner(pos)
		local inv = player:get_inventory()
		if owner then
			if owner == name or minetest.check_player_privs(name, {claim_admin=true}) then
				points_0gb_us.add_points(name, price.ore, price.number)
				points_0gb_us.save(name)
				chunk = landclaim_0gb_us.get_chunk(pos)
				claims[chunk] = nil
				landclaim_0gb_us.save_claims()
				minetest.chat_send_player(name, "You have renounced the claim on this area.")
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
		if not player then
			return
		end
		local pos = player:getpos()
		pos.y = pos.y + .5 --compensated for Minetest's incorrect y coordinate for player objects
		local owner = landclaim_0gb_us.get_owner(pos)
		if owner then
			if (owner == name  or minetest.check_player_privs(name, {claim_admin=true})) and name ~= param then
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
		if not player then
			return
		end
		local pos = player:getpos()
		pos.y = pos.y + .5 --compensated for Minetest's incorrect y coordinate for player objects
		local owner = landclaim_0gb_us.get_owner(pos)
		if owner then
			if owner == name or minetest.check_player_privs(name, {claim_admin=true}) then
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
	params = "(nothing) | <x>, <y>, <z>",
	description = "lists the people who may edit a given map chunk",
	privs = {interact=true},
	func = function(name, param)
		local pos = minetest.string_to_pos(param)
		if not pos then
			local player = minetest.env:get_player_by_name(name)
			if not player then
				return
			end
			pos = player:getpos()
			pos.y = pos.y + .5 --compensated for Minetest's incorrect y coordinate for player objects
		end
		local mayedit = landclaim_0gb_us.get_owner(pos)
		if mayedit then
			local chunk = landclaim_0gb_us.get_chunk(pos)
			for user, user in pairs(claims[chunk].shared) do
				mayedit = mayedit..", "..user
			end
			minetest.chat_send_player(name, mayedit)
		else
			minetest.chat_send_player(name, "This area is unowned.")
		end
		local entpos = landclaim_0gb_us.get_chunk_center(pos)
		minetest.env:add_entity(entpos, "landclaim_0gb_us:showarea")
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

