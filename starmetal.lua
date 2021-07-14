-- automate transformation from iron ore into starmetal ore

chest = peripheral.find("minecraft:chest")

function findIron ()
   for slot, item in pairs(chest.list()) do
      if item.name == "minecraft:iron_ore" then
         return slot
      end
   end
   return nil
end

while true do
   local found, data = turtle.inspect()
   if found and data.name == "astralsorcery:starmetal_ore" then
      turtle.select(3)
      turtle.dig()
      chest.pullItems("right", 3, 1)
   elseif found and data.name == "minecraft:iron_ore" then
      sleep(1)
   else
      slot = findIron()
      if slot then
         if found then
            turtle.select(1)
            turtle.dig()
         end
         chest.pushItems("right", slot, 1, 2)
         turtle.select(2)
         turtle.place()
         sleep(1)
      elseif not found then
         turtle.select(1)
         turtle.place()
         sleep(10)
      end
   end
end
