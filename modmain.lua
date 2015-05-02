GLOBAL.require("debugtools")

--[[
Round a float to the specified number of decimal places.
--]]
local function round(number, decimalPlaces)
	local multiplier = 10^(decimalPlaces or 1)
	return math.floor(number * multiplier + 0.5) / multiplier
end

GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_G, function()
	dsiGetInventoryDetails()
end)

function dsiGetInventoryDetails()
	print("in dsiGetInventoryDetails");
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

	local itemOffset = 1

	-- Sort the categorised items, by name then value.
	for i = 1, #sortingHat do
		local keys = {}
		for key in pairs(sortingHat[i]) do
			table.insert(keys, key)
		end

		local sortByNameThenValue = function(a, b)
			if sortingHat[i][a].obj.name ~= sortingHat[i][b].obj.name then
				return sortingHat[i][a].obj.name < sortingHat[i][b].obj.name
			end

			return sortingHat[i][a].value < sortingHat[i][b].value
		end
		table.sort(keys, sortByNameThenValue)


		-- keys contains the sorted order for the current bag (sortingHat[i]).
		for _, key in ipairs(keys) do
			local originalSlot = inventory:GetItemSlot(sortingHat[i][key].obj)
			local newItem      = inventory:GetItemInSlot(originalSlot)
			local newSlot      = itemOffset
			local originalItem = inventory:GetItemInSlot(newSlot)

			-- Remove both items from the inventory. The items aren't deleted.
			inventory:RemoveItem(newItem, true)
			if (originalItem) then
				inventory:RemoveItem(originalItem, true)
			end

			-- Re-add both items to the inventory in their new positions.
			inventory:GiveItem(newItem, newSlot, nil)
			if (originalItem) then
				inventory:GiveItem(originalItem, originalSlot, nil)
			end

			itemOffset = itemOffset + 1;
		end
	end

	player.SoundEmitter:PlaySound("dontstarve/creatures/perd/gobble")
end


--[[
	local hasBackpack   = player.replica.inventory:GetOverflowContainer()
	local overflow = self:GetOverflowContainer()
	if overflow ~= nil then
--]]

--[[
[sticks][torch]

1) from 2 to 1
2) from 1 to 2

First move works OK. Then item-previously-in-1 is in limbo.
Subsequent Gi
--]]
