args = {...}

width = args[1]
height = args[2]
depth = args[3]
ret = args[4]

z_signal = 1
y_signal = 1

for x = 1,width do
   print("X = "..x)
   for z = 1,depth do
      print("Z = "..z)
      if z > 1 then
         if turtle.detect() then
            turtle.dig()
         end
         turtle.forward()
      end
      for y = 1,height-1 do
         print("Y = "..y)
         if y_signal > 0 then
            if turtle.detectUp() then
               turtle.digUp()
            end
            turtle.up()
         else
            if turtle.detectDown() then
               turtle.digDown()
            end
            turtle.down()
         end
      end
      y_signal = -y_signal
   end
   if x == width + 0 then
      break
   end
   if z_signal > 0 then
      turtle.turnRight()
      if turtle.detect() then
         turtle.dig()
      end
      turtle.forward()
      turtle.turnRight()
      z_signal = -1
   else
      turtle.turnLeft()
      if turtle.detect() then
         turtle.dig()
      end
      turtle.forward()
      turtle.turnLeft()
      z_signal = 1
   end
end

if (ret == "return") then
   print("Returning...")
   if width % 2 == 0 then
      turtle.turnRight()
      for x = 1,width-1 do
         turtle.forward()
      end
      turtle.turnRight()
   else
      turtle.turnLeft()
      for x = 1,width-1 do
         turtle.forward()
      end
      turtle.turnRight()
      for z = 1,depth-1 do
         turtle.back()
      end
   end
   if (width * depth) % 2 == 1 then
      for y = 1,height-1 do
         turtle.down()
      end
   end
end
print("TADA!")
print("end")
