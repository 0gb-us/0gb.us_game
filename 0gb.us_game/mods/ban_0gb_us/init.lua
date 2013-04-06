
ban_0gb_us = {}
ban_0gb_us.temp_bans = {}
ban_0gb_us.temp_bans_filename = minetest.get_worldpath().."/ban_0gb_us_temp_bans"

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if ban_0gb_us:is_temp_baned(name, minetest.get_player_ip(name)) then
		minetest.ban_player(name) --hacky kick
		minetest.after(5, minetest.unban_player_or_ip, name)
	end
end)

minetest.register_chatcommand("temp_ban", {
	params = "<name> <time>",
	description = "Temporarily bans a player, time is in seconds",
	privs = {ban=true},
	func = function(name, param)
		local found, _, banname, time = param:find("^([^%s]+)%s([%d]+)$")
		if not found then
			minetest.chat_send_player(name, "Invalid usage, see /help temp_ban")
			return
		end
		if ban_0gb_us.temp_bans[banname] then
			minetest.chat_send_player(name, "Already banned")
			return
		end
		if not minetest.env:get_player_by_name(banname) then
			minetest.chat_send_player(name, "Player not online")
			return
		end

		local ip = minetest.get_player_ip(banname)
		time=tonumber(time)
		minetest.ban_player(banname) --hacky kick
		minetest.after(5, minetest.unban_player_or_ip, banname)
		ban_0gb_us.temp_bans[banname] = {name=banname, ip=ip, time=os.time()+time}
		ban_0gb_us:save_temp()
		minetest.log("action", name.." banned "..ip.."|"..banname.." for "..tostring(time).." seconds")
		minetest.chat_send_player(name, "Banned "..ip.."|"..banname.." for "..tostring(time).." seconds")
end})

minetest.register_chatcommand("temp_unban", {
	params = "<name>",
	description = "Unbans a player that was temporarily banned",
	privs = {ban=true},
	func = function(name, param)
		if ban_0gb_us.temp_bans[param] then
			entry = ban_0gb_us.temp_bans[param]
			ban_0gb_us:remove_expired()
			minetest.log("action", name.." unbanned "..entry.ip.."|"..entry.name.." ("..tostring(entry.time-os.time()).." seconds left)")
			minetest.chat_send_player(name, "Unbanned "..entry.ip.."|"..entry.name.." ("..tostring(entry.time-os.time()).." seconds left)")
			ban_0gb_us.temp_bans[param] = nil
			ban_0gb_us:save_temp()
		else
			minetest.chat_send_player(name, "Player not banned")
		end
end})

minetest.register_chatcommand("temp_banlist", {
	params = "",
	description = "Lists players currently temporarily banned",
	privs = {},
	func = function(name, param)
		ban_0gb_us:remove_expired()
		local entry_found = false
		for _, entry in pairs(ban_0gb_us.temp_bans) do
			minetest.chat_send_player(name, entry.ip.."|"..entry.name.." ("..tostring(entry.time-os.time()).." seconds left)")
			entry_found = true
		end
		if not entry_found then
			minetest.chat_send_player(name, "No entries found")
		end
end})

function ban_0gb_us:save_temp()
	file, err = io.open(self.temp_bans_filename, "w")
	if err then return end
	file:write(minetest.serialize(self.temp_bans))
	file:close()
end

function ban_0gb_us:load_temp()
	file, err = io.open(self.temp_bans_filename, "r")
	if err then return end
	self.temp_bans = minetest.deserialize(file:read("*a"))
	if type(self.temp_bans) ~= "table" then self.temp_bans = {} end
	file:close()
end

ban_0gb_us:load_temp()

function ban_0gb_us:remove_expired()
	local changed = false
	local time = os.time()
	for _, entry in pairs(self.temp_bans) do
		if entry.time <= time then
			self.temp_bans[entry.name] = nil
			changed = true
		end
	end
	if changed then
		self:save_temp()
	end
end

function ban_0gb_us:is_temp_baned(name, ip)
	self:remove_expired()
	for _, entry in pairs(self.temp_bans) do
		if entry.name == name or entry.ip == ip then
			return true
		end
	end
	return false
end

