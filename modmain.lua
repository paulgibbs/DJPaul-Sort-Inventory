--add a post init function for the inventory component
function dumptable(obj, indent, recurse_levels)
	indent = indent or 1
	local i_recurse_levels = recurse_levels or 1
    if obj then
		local dent = ""
		if indent then
			for i=1,indent do dent = dent.."\t" end
		end
    	if type(obj)==type("") then
    		print(obj)
    		return
    	end
        for k,v in pairs(obj) do
            if type(v) == "table" and i_recurse_levels>0 then
                print(dent.."K: ",k)
                dumptable(v, indent+1, i_recurse_levels-1)
            else
                print(dent.."K: ",k," V: ",v)
            end
        end
    end
end


--[[
Round a float to the specified number of decimal places.
--]]
local function round(number, decimalPlaces)
	local multiplier = 10^(decimalPlaces or 1)
	return math.floor(number * multiplier + 0.5) / multiplier
end



local mymod = {}
GLOBAL.c_djpaul = function()
	print("Hello World.")
	mymod.dsiGetInventoryDetails()
end


function mymod:dsiGetInventoryDetails()
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
		item = inventory.itemslots[i]

		if item then
			-- Food
			if item.components.edible then
				table.insert(foodBag, {
					name     = item.name,
					position = i,
					value    = round(item.components.edible.hungervalue)
				})

			-- Light
			elseif item.components.lighter and item.components.fueled then
				table.insert(lightBag, {
					name     = item.name,
					position = i,
					value    = (player:HasTag("lighter") and 1000) or item.components:GetPercent()
				})

			-- Weapons
			elseif item.components.weapon then
				table.insert(weaponBag, {
					name     = item.name,
					position = i,
					value    = item.components.weapon.damage
				})

			-- Tools
			elseif item.components.tool and item.components.equippable and item.components.finiteuses then
				table.insert(toolBag, {
					name     = item.name,
					position = i,
					value    = item.components.finiteuses:GetUses()
				})

			-- Everything else
			else
				table.insert(miscBag, {
					name     = item.name,
					position = i,
					value    = 0
				})
			end
		end
	end

	-- Sort the categorised items, by name then value.
	--table.sort(foodBag, sortItems)

	local keys = {}
	for k in pairs(foodBag) do table.insert(keys, k) end
		table.sort(keys, function(a, b) return foodBag[a]['value'] > foodBag[b]['value'] end)
	for _, k in ipairs(keys) do print(k, foodBag[k]['name'] .. '(' .. foodBag[k]['value'] .. ')') end

--[[
	for k, v in pairs(foodBag, lightBag, weaponBag, toolBag, miscBag) do
		table.insert(sortedInv, v)
	end
	return sortedInv
--]]
end


--[[
	local hasBackpack   = player.replica.inventory:GetOverflowContainer()
	local overflow = self:GetOverflowContainer()
	if overflow ~= nil then
--]]