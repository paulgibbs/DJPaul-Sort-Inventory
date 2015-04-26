--add a post init function for the inventory component
--AddComponentPostInit("inventory", inventorypostinit)
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
	mymod.dsiSortInventory()
end


function mymod:dsiSortInventory()
	print("in dsiSortInventory");
	local player    = GLOBAL.ThePlayer
	local inventory = player and player.components.inventory
	local bag       = {}

	if not inventory then
		return
	end


	for i = 1, inventory.maxslots do
		item = inventory.itemslots[i]

		if item then
			local itemType  = "other"
			local itemValue = 0

			if item.components.edible then
				itemType  = "food"
				itemValue = round(item.components.edible.hungervalue)
			elseif item.components.weapon then
				itemType  = "weapon"
				itemValue = item.components.weapon.damage
			elseif item.components.lighter and item.components.fueled then
				itemType  = "light"
				itemValue = (player:HasTag("lighter") and 1000) or item.components:GetPercent()
			elseif item.components.tool and item.components.equippable and item.components.finiteuses then
				itemType  = "tool"
				itemValue = item.components.finiteuses:GetUses()
			end

			local item = {
				name     = item.name,
				position = i,
				type     = itemType,
				value    = itemValue
			}
			--		inventory.itemslots[i]

			table.insert(bag, item)
		end
	end

	dumptable(bag)
end


--[[
	local hasBackpack   = player.replica.inventory:GetOverflowContainer()
	local overflow = self:GetOverflowContainer()
	if overflow ~= nil then
--]]