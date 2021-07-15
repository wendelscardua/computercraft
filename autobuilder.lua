args = {...}

rackX, rackY, rackZ = table.unpack(args)

rack = peripheral.wrap("back")
chest = peripheral.wrap("top")

function processOrder (orderId)
   local resources = colony.getWorkOrderResources(orderId)
   if not resources then return end
   print("Processing order "..orderId)
   for i, resource in pairs(resources) do
      if resource.status == "NEED_MORE" or resource.status == "DONT_HAVE" then
         needed = resource.item.count - resource.available - resource.delivering
         print("Needs "..needed.." of "..resource.item.name)
         while needed > 0 do
            if needed > 64 then
               quantity = 64
            else
               quantity = needed
            end
            commands.replaceItem("block", "~", "~1", "~", "container.0", resource.item.name, quantity)
            while rack.size() == #rack.list() do
               print("Rack is full!")
               sleep(10)
            end
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
