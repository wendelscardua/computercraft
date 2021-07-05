while true do
   local has_block, data = turtle.inspect()
   if not has_block then
      turtle.forward()
   elseif data.name == "minecraft:red_carpet" then
      turtle.dig()
      turtle.forward()
      turtle.turnRight()
      turtle.turnRight()
      turtle.place()
      turtle.turnRight()
      turtle.turnRight()
   elseif math.random() < 0.1 then
      turtle.turnRight()
      turtle.turnRight()
   elseif math.random() < 0.2 then
      turtle.turnLeft()
   else
      turtle.turnRight()
   end
end
