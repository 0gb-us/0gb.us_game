if minetest.get_modpath("fire") then
	landclaim_0gb_us.default_flame_should_extinguish = fire.flame_should_extinguish

	function fire.flame_should_extinguish(pos)
		local corner0 = landclaim_0gb_us.can_interact("fire!", {x=pos.x-1,y=pos.y-1,z=pos.z-1})
		local corner1 = landclaim_0gb_us.can_interact("fire!", {x=pos.x-1,y=pos.y-1,z=pos.z+1})
		local corner2 = landclaim_0gb_us.can_interact("fire!", {x=pos.x-1,y=pos.y+1,z=pos.z-1})
		local corner3 = landclaim_0gb_us.can_interact("fire!", {x=pos.x-1,y=pos.y+1,z=pos.z+1})
		local corner4 = landclaim_0gb_us.can_interact("fire!", {x=pos.x+1,y=pos.y-1,z=pos.z-1})
		local corner5 = landclaim_0gb_us.can_interact("fire!", {x=pos.x+1,y=pos.y-1,z=pos.z+1})
		local corner6 = landclaim_0gb_us.can_interact("fire!", {x=pos.x+1,y=pos.y+1,z=pos.z-1})
		local corner7 = landclaim_0gb_us.can_interact("fire!", {x=pos.x+1,y=pos.y+1,z=pos.z+1})
		if corner0 and corner1 and corner2 and corner3 and corner4 and corner5 and corner6 and corner7 then
			return landclaim_0gb_us.default_flame_should_extinguish(pos)
		else
			return true
		end
	end
end

