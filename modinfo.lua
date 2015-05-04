name        = "DJPaul's Sort Inventory"
description = "Automatically sorts your inventory into a sensible order."
author      = "Paul Gibbs (DJPaul)"
version     = "1.0-beta-2"
forumthread = ""

api_version                = 10  --DST api version
dont_starve_compatible     = false
reign_of_giants_compatible = false
dst_compatible             = true
priority                   = 0  -- Relative mod load order

client_only_mod         = true
all_clients_require_mod = false

configuration_options = {
	{
		default = 2,
		label   = "Number of torches",
		name    = "dsiLightCount",
		options = (function()
			local values = {}
			for i = 1, 10 do
				values[#values + 1] = { description = i + 0, data = i }
			end

			return values
		end)()
	},
}