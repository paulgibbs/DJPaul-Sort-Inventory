-- GLOBAL.CHEATS_ENABLED = true
-- GLOBAL.require("debugkeys")
-- GLOBAL.require("debugtools")


--- Sort through the bag and return the items' new offsets.
-- @param items
-- @param bag Bag ID
-- @param offset
-- @return Sorted item offsets
local function dsiSortItems(items, bag, offset)
	table.sort(items, function(a, b)

		-- Sort by name then value.
		if bag[offset].sortBy == 'name' then
			if bag[offset].contents[a].obj.name ~= bag[offset].contents[b].obj.name then
				return bag[offset].contents[a].obj.name < bag[offset].contents[b].obj.name
			end
			return bag[offset].contents[a].value > bag[offset].contents[b].value

		-- Sort by value then name.
		else
			if bag[offset].contents[a].value ~= bag[offset].contents[b].value then
				return bag[offset].contents[a].value > bag[offset].contents[b].value
			end
			return bag[offset].contents[a].obj.name < bag[offset].contents[b].obj.name
		end
	end)

	return items
end

--- Sorts the player's inventory into a sensible order.
-- @param player Sort this player's inventory.
-- @param maxLights Max. number of torches to sort.
local function dsiSortInventory(player, maxLights)
	local inventory    = player and player.components.inventory
	local foodBag      = { sortBy = 'value', contents = {} }
	local lightBag     = { sortBy = 'value', contents = {} }
	local toolBag      = { sortBy = 'name',  contents = {} }
	local weaponBag    = { sortBy = 'value', contents = {} }
	local miscBag      = { sortBy = 'name',  contents = {} }
	local isPlayerHurt = (player.components.health:GetPercent() * 100) <= 30

	if player:HasTag("playerghost") or not inventory then
		return
	end

	-- Categorise the player's inventory.
	for i = 1, inventory:GetNumSlots() do
		local item = inventory:GetItemInSlot(i)

		if item then
			local bag  = miscBag
			local sort = 0

			-- Some items are odd and require special handling.
			local itemIsGear     = item.components.edible and item.components.edible.foodtype == GLOBAL.FOODTYPE.GEARS
			local itemIsWLighter = item.components.lighter and item.components.fueled and player:HasTag("lighter")


			-- Food
			if item.components.edible and (item.components.perishable or itemIsGear) then
				bag  = foodBag
				sort = isPlayerHurt and item.components.edible.healthvalue or item.components.edible.hungervalue

			-- Light
			elseif item.components.lighter and item.components.fueled then
				bag  = lightBag
				sort = item.components.fueled:GetPercent()

				-- If bag has more lights than dsiMaxLights, store the extras in miscBag.
				if #lightBag.contents >= maxLights then
					bag = miscBag
				end

			-- Tools
			elseif item.components.tool and item.components.equippable and item.components.finiteuses then
				bag  = toolBag
				sort = item.components.finiteuses:GetUses()

			-- Weapons (MUST be below the tools block)
			elseif item.components.weapon then
				bag  = weaponBag
				sort = item.components.weapon.damage
			end

				obj   = item,
				value = sort
			})
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


	-- Sort the categorised items.
	for i = 1, #sortingHat do
		local keys = {}
		for key in pairs(sortingHat[i].contents) do
			table.insert(keys, key)
		end

		-- keys contains the sorted order for the current bag (sortingHat[i]).
		keys = dsiSortItems(keys, sortingHat, i);

		for _, key in ipairs(keys) do
			itemOffset = itemOffset + 1;

			-- Re-attach the item to the player's inventory, to its sorted position.
			inventory:GiveItem(sortingHat[i].contents[key].obj, itemOffset, nil)
		end
	end

	player.SoundEmitter:PlaySound("dontstarve/creatures/perd/gobble")
end

--- Inventory must be sorted server-side, so listen for a RPC.
AddModRPCHandler(modname, "dsiRemoteSortInventory", function(player, maxLights)
	dsiSortInventory(player, maxLights)
end)


--- Press "G" to sort your inventory.
GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_G, function()
	local maxLights = GLOBAL.tonumber(GetModConfigData("dsiMaxLights"))

	-- Server-side
	if GLOBAL.TheNet:GetIsServer() then
		dsiSortInventory(GLOBAL.ThePlayer, maxLights)

	-- Client-side
	else
		GLOBAL.SendModRPCToServer(MOD_RPC[modname]["dsiRemoteSortInventory"], maxLights)
	end
end)
