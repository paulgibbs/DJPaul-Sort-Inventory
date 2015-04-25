function inventorypostinit(component,inst)
	if not item or not item.components.equippable or not item:IsValid() then
		return
	end

	print("hello inventory init!")
end

--add a post init function for the inventory component
--AddComponentPostInit("inventory", inventorypostinit)

GLOBAL.c_djpaul = function()
	print("Hello World")
end