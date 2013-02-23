-- This is a dummy version of inventory_plus, used to allow compatibility with things that depend on it without actually needing to use the actual inventory_plus. Useful for when you want to define a custom menu.

inventory_plus = {}
inventory_plus.register_button = function(player,name,label) end
inventory_plus.set_inventory_formspec = function(player,formspec)
	player:set_inventory_formspec(formspec)
end

minetest.debug("[inventory_plus]:\nWait a minute. This isn't the real inventory_plus ...")

