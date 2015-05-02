-- GLOBAL.require("debugtools")

--[[
Round a float to the specified number of decimal places.
--]]
local function round(number, decimalPlaces)
	local multiplier = 10^(decimalPlaces or 1)
	return math.floor(number * multiplier + 0.5) / multiplier
end

--[[
Sorts the player's inventory into a sensible order.
--]]
local function dsiSortInventory()
	local player    = GLOBAL.ThePlayer
	local inventory = player and player.components.inventory
	local foodBag   = {}
	local lightBag  = {}
	local toolBag   = {}
	local weaponBag = {}
	local miscBag   = {}
	local sortedInv = {}

	if not inventory then
		return {}
	end

	-- Categorise the player's inventory.
	for i = 1, inventory.maxslots do
		local item = inventory.itemslots[i]

		if item then
			-- Food
			if item.components.edible and item.components.perishable then
				table.insert(foodBag, {
					obj   = item,
					value = round(item.components.edible.hungervalue)
				})

			-- Light
			elseif item.components.lighter and item.components.fueled then
				table.insert(lightBag, {
					obj   = item,
					value = (player:HasTag("lighter") and 1000) or item.components.fueled:GetPercent()
				})

			-- Weapons
			elseif item.components.weapon then
				table.insert(weaponBag, {
					obj   = item,
					value = item.components.weapon.damage
				})

			-- Tools
			elseif item.components.tool and item.components.equippable and item.components.finiteuses then
				table.insert(toolBag, {
					obj   = item,
					value = item.components.finiteuses:GetUses()
				})

			-- Everything else
			else
				table.insert(miscBag, {
					obj   = item,
					value = 0
				})
			end
		end

		-- Detach the item from the player's inventory.
		inventory:RemoveItem(item, true)
	end


	--[[
	"Oh you may not think I'm pretty,
	But don't judge on what you see,
	I'll eat myself if you can find
	A smarter hat than me."
	--]]
	local sortingHat = {
		lightBag,
		toolBag,
		weaponBag,
		foodBag,
		miscBag,
	}

	local itemOffset = 0

	-- Sort the categorised items by name then value.
	for i = 1, #sortingHat do
		local keys = {}
		for key in pairs(sortingHat[i]) do
			table.insert(keys, key)
		end

		table.sort(keys, function(a, b)
			if sortingHat[i][a].obj.name ~= sortingHat[i][b].obj.name then
				return sortingHat[i][a].obj.name < sortingHat[i][b].obj.name
			end

			return sortingHat[i][a].value < sortingHat[i][b].value
		end)

		-- keys contains the sorted order for the current bag (sortingHat[i]).
		for _, key in ipairs(keys) do
			itemOffset = itemOffset + 1;

			-- Re-attach the item to the player's inventory, to its sorted position.
			inventory:GiveItem(sortingHat[i][key].obj, itemOffset, nil)
		end
	end

	player.SoundEmitter:PlaySound("dontstarve/creatures/perd/gobble")
end

--[[
Press "G" to sort your inventory.
--]]
GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_G, function()
	dsiSortInventory()
end)
