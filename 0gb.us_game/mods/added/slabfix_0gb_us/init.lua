for _, subname in pairs({
	"wood",
	"stone",
	"cobble",
	"brick",
	"sandstone",
}) do
	local slab = {}
	for index, value in pairs(minetest.registered_items["stairs:slab_"..subname]) do
		slab[index] = value
	end
	slab.on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		-- If it's being placed on an another similar one, replace it with
		-- a full block
		local slabpos = nil
		local slabnode = nil
		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local n0 = minetest.env:get_node(p0)
		if n0.name == "stairs:slab_" .. subname and
				p0.y+1 == p1.y then
			slabpos = p0
			slabnode = n0
		end
		if slabpos then
			-- Remove the slab at slabpos
--[[			minetest.env:remove_node(slabpos)
			-- Make a fake stack of a single item and try to place it
			local fakestack = ItemStack(recipeitem)
			pointed_thing.above = slabpos
			fakestack = minetest.item_place(fakestack, placer, pointed_thing)
			-- If the item was taken from the fake stack, decrement original
			if not fakestack or fakestack:is_empty() then
				itemstack:take_item(1)
			-- Else put old node back
			else
				minetest.env:set_node(slabpos, slabnode)
			end]]
			return itemstack
		end
		
		-- Otherwise place regularly
		return minetest.item_place(itemstack, placer, pointed_thing)
	end
	minetest.register_node(":stairs:slab_"..subname, slab)
end

minetest.debug("[slabfix_0gb_us] Plugin loaded from "..minetest.get_modpath("slabfix_0gb_us"))

