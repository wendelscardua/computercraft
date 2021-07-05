function turn ()
   if math.random() < 0.1 then
      turtle.turnRight()
      turtle.turnRight()
   elseif math.random() < 0.2 then
      turtle.turnLeft()
   else
      turtle.turnRight()
   end
end

while true do
   while not turtle.inspectDown() do
      turtle.down()
   end

   local has_block, data = turtle.inspect()
   if math.random() < 0.1 then
      turn()
   elseif not has_block then
      turtle.forward()
   elseif data.tags["minecraft:carpets"] then
      turtle.dig()
      turtle.forward()
      turtle.turnRight()
      turtle.turnRight()
      turtle.place()
      turtle.turnRight()
      turtle.turnRight()
   elseif data.tags["minecraft:stairs"] then
      turtle.up()
      turtle.forward()
   else
      turn()
   end
end
