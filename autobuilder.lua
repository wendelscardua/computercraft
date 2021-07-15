args = {...}

rackX, rackY, rackZ = table.unpack(args)

rack = peripheral.wrap("back")
chest = peripheral.wrap("up")

function processOrder (orderId)
   print("Processing order "..orderId)
   for i, resource in pairs(colony.getWorkOrderResources(orderId)) do
      if resource.status == "NEED_MORE" or resource.status == "DONT_HAVE" then
         needed = resource.item.count - resource.available - resource.delivering
         print("Creating "..needed.." of "..resource.item.name)
         while needed > 0 do
            if needed > 64 then
               quantity = 64
            else
               quantity = needed
            end
            result = commands.replaceItem("block", "~", "~1", "~", "container.0", resource.item.name, quantity)
            print(textutils.serialize(result))
            chest.pushItems("back", 1)
            needed = needed - quantity
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
