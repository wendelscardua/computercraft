--[[ Compacta Minerals 1 ]]--
--[[ /tmp/minerals deve estar livre ]]--
--[[ Rode com /tmp/minerals na frente ]]--

function goMinerals ()
   turtle.up()
   turtle.up()
end

function goTmp ()
   turtle.down()
   turtle.down()
end

function suck16 ()
   for i = 1,16 do
      turtle.select(i)
      if not turtle.suck() then
         return false
      end
   end
   return true
end

function drop16 ()
   for i = 1,16 do
      if turtle.getItemCount(i) > 0 then
         turtle.select(i)
         turtle.drop()
      else
         break
      end
   end
end

--[[ drops n slots ]]--
function flush (n)
   for i=1,n do
      turtle.select(i)
      turtle.drop()
   end
end

--[[ detect if select slot can be smelted ]]--
function smeltable ()
   local data = turtle.getItemDetail()
   return data.name == "minecraft:raw_iron" or
      data.name == "minecraft:raw_gold" or
      data.name == "cavesandcliffs:raw_copper" or
      data.name == "cavesandcliffs:raw_iron" or
      data.name == "cavesandcliffs:raw_gold"
end

--[[ detect if select slot can be zipped ]]--
function wanted ()
   local data = turtle.getItemDetail()
   if data.count < 9 then
      return false
   end
   print("Lots of "..data.name)
   return data.name == "minecraft:coal" or
      data.name == "minecraft:iron_nugget" or
      data.name == "minecraft:gold_nugget" or
      data.name == "minecraft:iron_ingot" or
      data.name == "minecraft:gold_ingot" or
      data.name == "minecraft:emerald" or
      data.name == "minecraft:diamond" or
      data.name == "minecraft:lapis_lazuli" or
      data.name == "cavesandcliffs:copper_ingot" or
      data.name == "betterendforge:thallasium_ingot"
end

--[[ compact mineral, moving to 1st slot ]]--
function compact ()
   print("Zipping")
   turtle.transferTo(11)
   turtle.select(11)
   local total = turtle.getItemCount()
   local crafted = math.floor(total / 9)
   for i = 0,2 do
      for j = 0,2 do
         turtle.transferTo(i * 4 + j + 1, crafted)
      end
   end
   turtle.select(1)
   turtle.craft()
   if total % 9 > 0 then
      turtle.select(11)
      turtle.transferTo(2)
   end
end

--[[ Move from Minerals 1 to tmp2...]]--
--[[... drop there then go back to tmp ]]--
function saveToTmp2 ()
   print("Separating for smelting")
   goTmp()
   turtle.back()
   turtle.turnLeft()
   turtle.forward()
   turtle.forward()
   turtle.turnRight()
   turtle.forward()
   turtle.drop()
   turtle.back()
   turtle.turnRight()
   turtle.forward()
   turtle.forward()
   turtle.turnLeft()
   turtle.forward()
end

--[[ Main ]]--

while turtle.forward() do
end

print("Moving all to /tmp/minerals")

goMinerals()
while suck16() do
   goTmp()
   drop16()
   goMinerals()
end
goTmp()
drop16()

print("Moving back to Minerals 1")

slot = 0

while true do
   slot = slot + 1
   turtle.select(slot)
   if not turtle.suck() then
      flush(slot - 1)
      break
   end
   if smeltable() then
      goMinerals()
      flush(slot - 1)
      turtle.select(slot)
      saveToTmp2()
      slot = 0
   elseif wanted() then
      goMinerals()
      flush(slot - 1)
      turtle.select(slot)
      compact()
      flush(2)
      goTmp()
      slot = 0
   end
   if slot == 16 then
      goMinerals()
      flush(16)
      goTmp()
      slot = 0
   end
end

turtle.back()

print("TADA")
