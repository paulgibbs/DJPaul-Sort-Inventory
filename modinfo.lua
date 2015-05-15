name        = "DJPaul's Sort Inventory"
description = 'Automatically sorts your inventory into a sensible order.\nPress "G" to sort.'
author      = "Paul Gibbs (DJPaul)"
version     = "1.0-beta-3"
forumthread = ""

api_version                = 10  -- DST api version
dont_starve_compatible     = false
reign_of_giants_compatible = false
dst_compatible             = true
priority                   = 0  -- Relative load order
server_filter_tags         = { "djpaul", "sort inventory" }

client_only_mod         = false
all_clients_require_mod = false

configuration_options = {
	{
		default = 2,
		label   = "Number of torches:",
		name    = "maxLights",
		options = (function()
			local values = {}
			for i = 1, 10 do
				values[#values + 1] = { description = i, data = i }
			end

			return values
		end)()
	},
	{
		default = "resources",
		label   = "Store these in backpack:",
		name    = "backpackCategory",
		options = {
			{ description = "Food", data = "food" },
			{ description = "Lights", data = "light" },
			{ description = "Tools", data = "tools" },
			{ description = "Weapons", data = "weapons" },
			{ description = "Resources", data = "resources" },
			{ description = "Junk", data = "misc" }
		}
	},
}
