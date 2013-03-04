--Configuration
local price = {
	ore = minetest.setting_get("ore.landclaim.0gb.us") or "default:stone_with_iron",
	number = tonumber(minetest.setting_get("number.landclaim.0gb.us") or 9),
}

landclaim_0gb_us = {
	override = {}
}

local claims = {}
local filename = minetest.get_worldpath().."/landclaim.0gb.us"

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
		or (landclaim_0gb_us.override[name] and minetest.check_player_privs(name, {claim_admin=true}))
end

