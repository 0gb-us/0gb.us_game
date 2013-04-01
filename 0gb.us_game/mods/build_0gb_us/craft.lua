for index, value in pairs({
	["default:book"] = {
		input = {"default:paper 3"},
		output = "default book",
	},
	["default:bookshelf"] = {
		input = {"default:book 3","default:wood 6"},
		output = "default:bookshelf",
	},
	["default:brick"] = {
		input = {"default:clay_brick 4"},
		output = "default:brick",
	},
	["default:chest"] = {
		input = {"default:wood 8"},
		output = "default:chest",
	},
	["default:chest_locked"] = {
		input = {"default:wood 8","default:steel_ingot"},
		output = "default:chest",
	},
	["default:clay"] = {
		input = {"default:clay_lump 4"},
		output = "default:clay",
	},
	["default:dirt_with_grass"] = {
		input = {"default:dirt"},
		output = "default:dirt_with_grass",
	},
	["default:fence_wood"] = {
		input = {"default:stick 6"},
		output = "default:fence_wood 2",
	},
	["default:furnace"] = {
		input = {"default:cobble 8"},
		output = "default:furnace",
	},
	["default:ladder"] = {
		input = {"default:stick 7"},
		outpup = "default:ladder",
	},
	["default:paper"] = {
		input = {"default:papyrus 3"},
		output = "default:paper",
	},
	["default:rail"] = {
		input = {"default:steel_ingot 6","default:stick"},
		output = "default:rail 15",
	},
--[[	["default:sand"] = {
		input = {"default:sandstone"},
		output = "default:sand 4",
	},]]-- commented out to remove circular crafting loops
	["default:sandstone"] = {
		input = {"default:sand 4"},
		output = "default:sandstone",
	},
	["default:sign_wall"] = {
		input = {"default:stick","default:wood 6"},
-- Because sticks are crafted from planks, the sticks MUST be listed before the planks to avoid error in the auto-crafter
		output = "default:sign_wall",
	},
	["default:stick"] = {
		input = {"default:wood"},
		output = "default:stick 4",
	},
	["default:torch"] = {
		input = {"default:stick", "default:coal_lump"},
		output = "default:torch 4",
	},
	["default:wood"] = {
		input = {"default:tree"},
		output = "default:wood 4",
	},
	["stairs:stair_cobble"] = {
		input = {"default:cobble 6"},
		output = "stairs:stair_cobble 4",
	},
	["stairs:slab_cobble"] = {
		input = {"default:cobble 3"},
		output = "stairs:slab_cobble 3",
	},
}) do
	build_0gb_us.craft[index] = value
end

