local privileges = minetest.setting_get("privileges.chatcommands.0gb.us")
if privileges then
	local grantable = {}
	for key, value in pairs(privileges:split(",")) do
		grantable[value] = true
	end
	minetest.register_chatcommand("grant", {
		params = "<name> <privilege>|all",
		description = "Give privilege to player",
		privs = {},
		func = function(name, param)
			local grantname, grantprivstr = string.match(param, "([^ ]+) (.+)")
			if not grantname or not grantprivstr then
				minetest.chat_send_player(name, "Invalid parameters (see /help grant)")
				return
			end
			local grantprivs = minetest.string_to_privs(grantprivstr)
			if grantprivstr == "all" then
				grantprivs = grantable
			end
			local privs = minetest.get_player_privs(grantname)
			local privs_known = true
			for priv, _ in pairs(grantprivs) do
				if priv ~= "interact" and priv ~= "shout" and priv ~= "interact_extra" and not minetest.check_player_privs(name, {privs=true}) then
					minetest.chat_send_player(name, "Your privileges are insufficient.")
					return
				end
				if not grantable[priv] then
					minetest.chat_send_player(name, "Ungrantable privilege: "..priv)
					privs_known = false
				end
				privs[priv] = true
			end
			if not privs_known then
				return
			end
			minetest.set_player_privs(grantname, privs)
			minetest.log(name..' granted ('..minetest.privs_to_string(grantprivs, ', ')..') privileges to '..grantname)
			minetest.chat_send_player(name, "Privileges of "..grantname..": "..minetest.privs_to_string(minetest.get_player_privs(grantname), ' '))
			if grantname ~= name then
				minetest.chat_send_player(grantname, name.." granted you privileges: "..minetest.privs_to_string(grantprivs, ' '))
			end
		end,
	})

	minetest.register_chatcommand("revoke", {
		params = "<name> <privilege>|all",
		description = "Remove privilege from player",
		privs = {},
		func = function(name, param)
			if not minetest.check_player_privs(name, {privs=true}) and 
					not minetest.check_player_privs(name, {basic_privs=true}) then
				minetest.chat_send_player(name, "Your privileges are insufficient.")
				return
			end
			local revokename, revokeprivstr = string.match(param, "([^ ]+) (.+)")
			if not revokename or not revokeprivstr then
				minetest.chat_send_player(name, "Invalid parameters (see /help revoke)")
				return
			end
			local revokeprivs = minetest.string_to_privs(revokeprivstr)
			local privs = minetest.get_player_privs(revokename)
			for priv, _ in pairs(revokeprivs) do
				if priv ~= "interact" and priv ~= "shout" and priv ~= "interact_extra" and not minetest.check_player_privs(name, {privs=true}) then
					minetest.chat_send_player(name, "Your privileges are insufficient.")
					return
				end
			end
			if revokeprivstr == "all" then
				revokeprivs = {}
				for key, value in pairs(grantable) do
					privs[key] = nil
					table.insert(revokeprivs, value)
				end
			else
				for priv, _ in pairs(revokeprivs) do
					if grantable[priv] then
						privs[priv] = nil
					else
						revokeprivs[priv] = nil
					end
				end
			end
			minetest.set_player_privs(revokename, privs)
			minetest.log(name..' revoked ('..minetest.privs_to_string(revokeprivs, ', ')..') privileges from '..revokename)
			minetest.chat_send_player(name, "Privileges of "..revokename..": "..minetest.privs_to_string(minetest.get_player_privs(revokename), ' '))
			if revokename ~= name then
				minetest.chat_send_player(revokename, name.." revoked privileges from you: "..minetest.privs_to_string(revokeprivs, ' '))
			end
		end,
	})
end

minetest.register_chatcommand("teleport", {
	params = "<to_name>",
	description = "teleport to given player",
	privs = {teleport=true},
	func = function(name, param)
		local location = minetest.env:get_player_by_name(param)
		if location then
			coords = location:getpos()
			player = minetest.env:get_player_by_name(name)
			if not player then
				return
			end
			player:setpos(coords)
			minetest.chat_send_player(name, "Teleported to "..param..".")
		else
			minetest.chat_send_player(name, 'Player "'..param..'" not found.')
		end
	end,
})

minetest.chatcommands["give"] = nil
minetest.chatcommands["giveme"] = nil
minetest.chatcommands["spawnentity"] = nil

if not minetest.get_modpath("logpulverize_0gb_us") then
	minetest.chatcommands["pulverize"] = nil
end

minetest.chatcommands["rollback"] = nil

minetest.register_chatcommand("clearobjects", {
	params = "",
	description = "clear all objects in loaded areas",
	privs = {server=true},
	func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		for _, obj in pairs(minetest.env:get_objects_inside_radius({x=0,y=0,z=0}, 1000000)) do
			if not obj:is_player() then
				obj:punch(player,0, {}, nil)
-- Do NOT replace this with obj:remove()
			end
		end
	end,
})

minetest.debug("[chatcommands_0gb_us]: Plugin loaded from\n"..minetest.get_modpath("chatcommands_0gb_us"))

