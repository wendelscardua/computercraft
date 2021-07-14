args = {...}

debug = args[1]

rack = peripheral.wrap("minecolonies:rack_0")
mainChest = peripheral.wrap("minecraft:chest_0")
auxChest = peripheral.wrap("minecraft:chest_1")

recLevel = 0

function size4 (recipe)
   return {
      recipe[1], recipe[2], nil, nil,
      recipe[3], recipe[4]
   }
end

function size9 (recipe)
   return {
      recipe[1], recipe[2], recipe[3], nil,
      recipe[4], recipe[5], recipe[6], nil,
      recipe[7], recipe[8], recipe[9], nil
   }
end

function multiformat (list, value)
   local result = {}
   for i, v in pairs(list) do
      result[i] = string.format(v, value)
   end
   return result
end

function multimat (target, quantity, recipe, materials)
   for i, material in pairs(materials) do
      craftables[string.format(target, material)] = {
         quantity = quantity,
         recipe = multiformat(recipe, material)
      }
   end
end

wood_kind = { 'minecraft:dark_oak', 'minecraft:jungle', 'minecraft:oak', 'minecraft:spruce' }

craftables = {
   ['minecraft:coarse_dirt'] = {
      quantity = 4,
      recipe = size4(
         {
            'minecraft:dirt', 'minecraft:gravel',
            'minecraft:gravel', 'minecraft:dirt'
         }
      )
   },
   ['minecraft:iron_door'] = {
      quantity = 3,
      recipe = size9(
         {
            'minecraft:iron_ingot', 'minecraft:iron_ingot', nil,
            'minecraft:iron_ingot', 'minecraft:iron_ingot', nil,
            'minecraft:iron_ingot', 'minecraft:iron_ingot', nil
         }
      )
   },
   ['minecraft:ladder'] = {
      quantity = 4,
      recipe = size9(
         {
            'minecraft:stick', nil, 'minecraft:stick',
            'minecraft:stick', 'minecraft:oak_planks', 'minecraft:stick',
            'minecraft:stick', nil, 'minecraft:stick'
         }
      )
   }
}

multimat('%s_fence',
         3,
         size9(
            {
               nil, nil, nil,
               '%s_planks', 'minecraft:stick', '%s_planks',
               '%s_planks', 'minecraft:stick', '%s_planks'
            }
         ),
         wood_kind)

multimat('%s_fence_gate',
         1,
         size9(
            {
               nil, nil, nil,
               'minecraft:stick', '%s_planks', 'minecraft:stick',
               'minecraft:stick', '%s_planks', 'minecraft:stick'
            }
         ),
         wood_kind)

multimat('%s_ladder',
         3,
         size9(
            {
               'minecraft:stick', nil, 'minecraft:stick',
               'minecraft:stick', 'minecraft:%s_planks', 'minecraft:stick',
               'minecraft:stick', nil, 'minecraft:stick'
            }
         ),
         wood_kind)

multimat('%s_planks',
         4,
         { '%s_log' },
         wood_kind)

multimat('%s_sign',
         3,
         size9(
            {
               '%s_planks', '%s_planks', '%s_planks',
               nil, 'minecraft:stick', nil,
               nil, 'minecraft:stick', nil
            }
         ),
         wood_kind)

multimat('%s_slab',
         6,
         size9(
            {
               nil, nil, nil,
               '%s_planks', '%s_planks', '%s_planks'
            }
         ),
         wood_kind)

multimat('%s_stairs',
         4,
         size9(
            {
               '%s_planks', nil, nil,
               '%s_planks', '%s_planks', nil,
               '%s_planks', '%s_planks', '%s_planks'
            }
         ),
         wood_kind)

function findInChest (chest, name)
   for i, item in pairs(chest.list()) do
      if item.name == name then
         return i, item.count
      end
   end
   return nil, 0
end

function requireResource (name, quantity)
   if quantity > 64 then quantity = 64 end

   print (recLevel..">> Requiring "..quantity.. " of "..name)

   while true do
      local index, count = findInChest(mainChest, name)

      if count > 0 then
         return index, count
      end

      if craftables[name] then
         craft(name, quantity)
      else
         print (recLevel..">> Please put "..quantity.." "..name.." on main chest")
         sleep(10)
      end
   end
end

function move (fromInv, toInv, fromSlot, quantity, slot)
   if toInv == turtle then
      toName = "turtle_0"
   else
      toName = peripheral.getName(toInv)
   end
   if fromInv == turtle then
      fromName = "turtle_0"
   else
      fromName = peripheral.getName(fromInv)
   end

   print (recLevel..">> Moving "..quantity.." from "..fromName.."["..fromSlot.."] to "..toName)
   if fromName == 'turtle_0' then
      toInv.pullItems(fromName, fromSlot, quantity, slot)
   else
      fromInv.pushItems(toName, fromSlot, quantity, slot)
   end
end

function craft (recipeName, quantity)
   recLevel = recLevel + 1

   print(recLevel..">> Crafting "..quantity.." of "..recipeName)
   local numRecipes = math.ceil(quantity / craftables[recipeName].quantity)

   print(recLevel..">> selecting for aux chest")

   local aggregated = {}

   for i, name in pairs(craftables[recipeName].recipe) do
      if aggregated[name] then
         aggregated[name] = aggregated[name] + 1
      else
         aggregated[name] = 1
      end
   end

   for name, aggregatedCount in pairs(aggregated) do
      local needed = numRecipes * aggregatedCount
      while needed > 0 do
         print(recLevel..">> "..recipeName.." recipe needs "..needed.." "..name)
         local index, count = requireResource(name, numRecipes * aggregatedCount)
         move(mainChest, auxChest, index, count)
         needed = needed - count
      end
   end

   print(recLevel..">> moving to turtle")

   for recipeSlot, name in pairs(craftables[recipeName].recipe) do
      local index, count = findInChest(auxChest, name)
      move(auxChest, turtle, index, numRecipes, recipeSlot)
   end

   print(recLevel..">> craft!")

   turtle.select(1)
   local success, message = turtle.craft(numRecipes)
   if not success then
      print (recLevel..">> Craft error: "..message)
      exit(1)
   end

   print(recLevel..">> delivering crafted")
   move(turtle, mainChest, 1, numRecipes * craftables[recipeName].quantity)

   recLevel = recLevel - 1
end

function processOrder (orderId)
   print("Processing order "..orderId)
   for i, resource in pairs(colony.getWorkOrderResources(orderId)) do
      if resource.status == "NEED_MORE" or resource.status == "DONT_HAVE" then
         needed = resource.item.count - resource.available - resource.delivering
         print("Needs "..needed.." "..resource.item.name)
         while needed > 0 do
            local foundIndex, foundQuantity = requireResource(resource.item.name, needed)
            if foundQuantity > needed then
               print("Found "..needed.."+")
               foundQuantity = needed
            else
               print("Found "..foundQuantity)
            end
            move(mainChest, rack, foundIndex, foundQuantity)
            needed = needed - foundQuantity
         end
      end
   end
end

while true do
   for i, order in pairs(colony.getWorkOrders()) do
      processOrder(order.id)
   end
   sleep(30)
end
