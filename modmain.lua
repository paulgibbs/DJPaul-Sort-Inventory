-- GLOBAL.CHEATS_ENABLED = true
-- GLOBAL.require("debugkeys")
-- GLOBAL.require("debugtools")


--- Sort through the bag and return the items' new offsets.
--
-- @param items
-- @param bag Bag ID
-- @param offset
-- @return Sorted item offsets
local function sortItems(items, bag, offset)
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

--- Is the item a food for the current player?
--
-- @param inst InventoryItem object
-- @return bool
local function itemIsFood(inst)
	local itemIsGear = inst.components.edible and inst.components.edible.foodtype == GLOBAL.FOODTYPE.GEARS
	return inst.components.edible and (inst.components.perishable or itemIsGear)
end

--- Is the item a light?
--
-- @param inst InventoryItem object
-- @return bool
local function itemIsLight(inst)
	return inst.components.lighter and inst.components.fueled
end

--- Is the item a tool?
--
-- @param inst InventoryItem object
-- @return bool
local function itemIsTool(inst)
	return inst.components.tool and inst.components.equippable and inst.components.finiteuses
end

--- Is the item a weapon?
--
-- @param inst InventoryItem object
-- @return bool
local function itemIsWeapon(inst)
	return inst.components.weapon and true
end

--- Is the item a priority resource?
-- These items were manually selected from a frequency analysis of recipe components in the game
-- as of 10th March 2015. The idea is that the player will care most about having a quantity of
-- these items (because they are used commonly in item recipes), so let's sort them together.
--
-- @param inst InventoryItem object
-- @return bool
local function itemIsResource(inst)
	-- Highest frequency to lowest fequency
	local items = {
		"Twigs",
		"Nightmare Fuel",
		"Rope",
		"Gold Nugget",
		"Boards",
		"Silk",
		"Papyrus",
		"Cut Grass",
		"Thulecite",
		"Cut Stone",
		"Flint",
		"Log",
		"Living Log",
		"Pig Skin",
		"Thulecite Fragments",
	}

	for i = 1, #items do
		local keys = {}
		if items[i] == inst.name then
			return true
		end
	end

	return false
end

--- Sorts the player's inventory into a sensible order.
--
-- @param player Sort this player's inventory.
-- @param maxLights Max. number of torches to sort.
local function sortInventory(player, maxLights)
	local inventory    = player and player.components.inventory or nil
	local backpack     = inventory and inventory:GetOverflowContainer() or nil
	local foodBag      = { sortBy = 'value', contents = {} }
	local lightBag     = { sortBy = 'value', contents = {} }
	local toolBag      = { sortBy = 'name',  contents = {} }
	local weaponBag    = { sortBy = 'value', contents = {} }
	local resourceBag  = { sortBy = 'name',  contents = {} }
	local miscBag      = { sortBy = 'name',  contents = {} }
	local isPlayerHurt = (player.components.health:GetPercent() * 100) <= 30

	if player:HasTag("playerghost") or not inventory then
		return
	end


	local backpackSlotCount = backpack and backpack:GetNumSlots() or 0
	local invSlotCount      = inventory:GetNumSlots()
	local totalSlots        = backpackSlotCount + invSlotCount


	-- Categorise the player's inventory.
	for i = 1, totalSlots do
		local item = nil

		-- Loop through the main inventory and the backpack.
		if i <= invSlotCount then
			item = inventory:GetItemInSlot(i)
		else
			item = backpack:GetItemInSlot(i - totalSlots)
		end

		if item then
			local bag  = miscBag
			local sort = 0

			-- Food
			if itemIsFood(item) then
				bag  = foodBag
				sort = isPlayerHurt and item.components.edible.healthvalue or item.components.edible.hungervalue

			-- Light
			elseif itemIsLight(item) then
				bag  = lightBag
				sort = item.components.fueled:GetPercent()

				-- If bag has more lights than maxLights, store the extras in miscBag.
				if #lightBag.contents >= maxLights then
					bag = miscBag
				end

			-- Tools
			elseif itemIsTool(item) then
				bag  = toolBag
				sort = item.components.finiteuses:GetUses()

			-- Weapons (MUST be below the tools block)
			elseif itemIsWeapon(item) then
				bag  = weaponBag
				sort = item.components.weapon.damage

			-- Priority resources
			elseif itemIsResource(item) then
				bag = resourceBag
			end


			table.insert(bag.contents, {
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
		keys = sortItems(keys, sortingHat, i);

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
	sortInventory(player, maxLights)
end)


--- Press "G" to sort your inventory.
GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_G, function()
	local maxLights = GLOBAL.tonumber(GetModConfigData("maxLights"))

	-- Server-side
	if GLOBAL.TheNet:GetIsServer() then
		sortInventory(GLOBAL.ThePlayer, maxLights)

	-- Client-side
	else
		GLOBAL.SendModRPCToServer(MOD_RPC[modname]["dsiRemoteSortInventory"], maxLights)
	end
end)
