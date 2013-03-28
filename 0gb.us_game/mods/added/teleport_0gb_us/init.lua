if io.open(minetest.get_modpath("teleport_0gb_us").."/INIT.LUA") then
	return minetest.debug("[teleport_0gb_us] This plugin depends on points_0gb_us, which requires a case-sensitive file system to function correctly.")
end

-- Configuration:
local price = {
	ore = minetest.setting_get("ore.teleport.0gb.us") or "default:stone_with_coal",
	number = tonumber(minetest.setting_get("number.teleport.0gb.us") or 99),
}

-- END OF CONFIGURATION --

local directory = minetest.get_worldpath().."/teleport.0gb.us/"
local teleport = {}
local page = {}
local formspecpage = {}

os.execute('mkdir -p "'..directory..'"')

local function build_pages(name)
	formspecpage[name] = {""}
	local x = 0
	local y = 6
	local z = 0
	for key, value in pairs(teleport[name]) do
		if y == 6 then
			y = 0
			z = z + 1
			formspecpage[name][z] = ""
		end

		formspecpage[name][z] = formspecpage[name][z].."button["..x..".5,"..y..";3,1;teleport.teleport.0gb.us;"..key.."]"
		x = x + 3

		if x == 12 then
			x = 0
			y = y + 1
		end
	end
end

local function load(player)
	local name = player:get_player_name()
	teleport[name] = {}
	page[name] = 1
	local file = io.open(directory..name, "r")
	if file then
		for line in file:lines() do
			if line ~= "" then
				local space = line:find(" ", 1, true)
				local key = line:sub(1, space-1)
				local value = line:sub(space+1)
				teleport[name][key] = minetest.string_to_pos(value)
			end
		end
		file:close()
	end
	build_pages(name)
end

local function save(name)
	local file = io.open(directory..name, "w")
	for key,value in pairs(teleport[name]) do
		file:write(key.." "..minetest.pos_to_string(value).."\n")
	end
	file:close()
	build_pages(name)
end

minetest.register_on_joinplayer(function(player)
	inventory_plus.register_button(player, "go.teleport.0gb.us", "Warp Points")
	load(player)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	teleport[name] = nil
	page[name] = nil
end)

local function warp(name, warp)
	if teleport[name][warp] then
		local player = minetest.env:get_player_by_name(name)
		if not player then
			return
		end
		player:setpos(teleport[name][warp])
		minetest.chat_send_player(name, "Teleporting to "..warp)
	else
		minetest.chat_send_player(name, "You don't have a warp point by that name.")
	end
end

local function removewarp(name, warp)
	if teleport[name][warp] then
		points_0gb_us.add_points(name, price.ore, price.number)
		points_0gb_us.save(name)
		teleport[name][warp] = nil
		save(name)
		minetest.chat_send_player(name, 'Warp point "'..warp..'" removed.')
	else
		minetest.chat_send_player(name, "You don't have a warp point by that name.")
	end
end

local function setnewwarp(name, warp)
	if not string.find(warp, "^[%w_%-]+$") then
		minetest.chat_send_player(name, "The chosen warp point name contains invalid characters, or is blank.")
	elseif warp:len() > 19 then
		minetest.chat_send_player(name, "The warp point name may have no more than nineteen characters.")
	elseif teleport[name][warp] then
		minetest.chat_send_player(name, "You already have a warp point by that name.")
	elseif points_0gb_us.read_points(name, price.ore) < price.number then
		minetest.chat_send_player(name, "You need to mine more "..price.ore.." before you can set a warp point.")
	else
		points_0gb_us.add_points(name, price.ore, -price.number)
		points_0gb_us.save(name)
		local player = minetest.env:get_player_by_name(name)
		if not player then
			return
		end
		teleport[name][warp] = player:getpos()
		save(name)
		minetest.chat_send_player(name, 'Warp point "'..warp..'" added at current location.')
	end
end

local function setwarp(name, warp)
	if teleport[name][warp] then
		local player = minetest.env:get_player_by_name(name)
		if not player then
			return
		end
		teleport[name][warp] = player:getpos()
		save(name)
		minetest.chat_send_player(name, 'Warp point "'..warp..'" moved to current location.')
	else
		minetest.chat_send_player(name, "You don't have a warp point by that name.")
	end
end

local function renamewarp(name, warp, newwarp)
	if not string.find(newwarp, "^[%w_%-]+$") then
		minetest.chat_send_player(name, "The chosen warp point name contains invalid characters, or is blank.")
	elseif teleport[name][newwarp] then
		minetest.chat_send_player(name, "The chosen warp point name is already in use.")
	elseif not teleport[name][warp] then
		minetest.chat_send_player(name, "That warp point does not exist.")
	elseif newwarp:len() > 19 then
		minetest.chat_send_player(name, "The warp point name may have no more than nineteen characters.")
	else 
		teleport[name][newwarp] = teleport[name][warp]
		teleport[name][warp] = nil
		save(name)
		minetest.chat_send_player(name, "Warp point renamed.")
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if fields["go.teleport.0gb.us"] or fields["teleport.teleport.0gb.us"] then
		if fields["teleport.teleport.0gb.us"] then
			warp(name, fields["teleport.teleport.0gb.us"])
		end

		if fields["go.teleport.0gb.us"] == "<< Back" then
			page[name] = ((page[name] - 2) % #formspecpage[name]) +1
		elseif fields["go.teleport.0gb.us"] == "Next >>" then
			page[name] = (page[name] % #formspecpage[name]) + 1
		elseif page[name] > #formspecpage[name] then
			page[name] = 1
		end

		inventory_plus.set_inventory_formspec(player,
			"size[13,7.5]"..
			"button[0.5,6.5;3,1;main;Back to main menu]"..
			"button[3.5,6.5;3,1;go.teleport.0gb.us;<< Back]"..
			"button[6.5,6.5;3,1;go.teleport.0gb.us;Next >>]"..
			"button[9.5,6.5;3,1;edit.teleport.0gb.us;Edit warp point]"..
			formspecpage[name][page[name]]
		)

	elseif fields["edit.teleport.0gb.us"] then
		inventory_plus.set_inventory_formspec(player,
			"size[13,7.5]"..
			"field[8.3,0.5;4,1;name.teleport.0gb.us;Warp point name:;]"..
			"field[8.3,1.5;4,1;newname.teleport.0gb.us;New warp point name:;]"..
			"button[8,2;4,1;edit.teleport.0gb.us;Rename warp point]"..
			"button[8,3;4,1;edit.teleport.0gb.us;Remove warp point]"..
			"button[8,4;4,1;edit.teleport.0gb.us;Add warp point here]"..
			"button[8,5;4,1;edit.teleport.0gb.us;Move warp point here]"..
			"button[0.5,6.5;3,1;main;Back to main menu]"..
			"button[9.5,6.5;3,1;go.teleport.0gb.us;Back to warp points]"
		)
		if fields["name.teleport.0gb.us"] then
			if fields["edit.teleport.0gb.us"] == "Remove warp point" then
				removewarp(name, fields["name.teleport.0gb.us"])
			elseif fields["edit.teleport.0gb.us"] == "Move warp point here" then
				setwarp(name, fields["name.teleport.0gb.us"])
			elseif fields["edit.teleport.0gb.us"] == "Add warp point here" then
				setnewwarp(name, fields["name.teleport.0gb.us"])
			elseif fields["newname.teleport.0gb.us"] then
				renamewarp(name, fields["name.teleport.0gb.us"], fields["newname.teleport.0gb.us"])
			end
		end
	end
end)

minetest.register_chatcommand("warp", {
	params = "<warp point>",
	description = "teleports you to one of your warp points",
	privs = {},
	func = warp,
})

minetest.register_chatcommand("setnewwarp", {
	params = "<warp point>",
	description = "adds a new warp point at your current location",
	privs = {},
	func = setnewwarp,
})

minetest.register_chatcommand("setwarp", {
	params = "<warp point>",
	description = "moves one of your warp points to your current location",
	privs = {},
	func = setwarp,
})

minetest.register_chatcommand("renamewarp", {
	params = "<warp point> <new name>",
	description = "renames a warp point",
	privs = {},
	func = function(name, param)
		params = param:split(" ")
		if params[2] then
			renamewarp(name, params[1], params[2])
		else
			minetest.chat_send_player(name, "/renamewarp requires two parameters.")
		end
	end,
})

minetest.register_chatcommand("removewarp", {
	params = "<warp point>",
	description = "removes a warp point",
	privs = {},
	func = removewarp,
})

minetest.register_chatcommand("listwarps", {
	params = "",
	description = "lists all of your warp points",
	privs = {},
	func = function(name, param)
		for key, value in pairs(teleport[name]) do
			minetest.chat_send_player(name, key..": "..minetest.pos_to_string(value))
		end
	end,
})

minetest.debug("[teleport_0gb_us]: Plugin loaded from\n"..minetest.get_modpath("teleport_0gb_us"))

