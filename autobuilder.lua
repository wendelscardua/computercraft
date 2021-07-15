args = {...}

rackX, rackY, rackZ = table.unpack(args)

rack = peripheral.wrap("back")

function findFreeRackSlot ()
   while true do
      for i = 1,rack.size() do
         if not rack.getItemDetail(i) then return i end
      end
      print("Rack is full... sleeping")
      sleep(10)
   end
end

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
            rackSlot = findFreeRackSlot()
            commands.replaceItem("block", rackX, rackY, rackZ, "container."..rackSlot, resource.item.name, quantity)
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
