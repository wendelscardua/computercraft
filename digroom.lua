args = {...}

os.loadAPI("apis/smartle.lua")

width = args[1]
height = args[2]
depth = args[3]
ret = args[4]

z_signal = 1
y_signal = 1

smartle.setOrigin()

for x = 1,width do
   print("X = "..x)
   for z = 1,depth do
      print("Z = "..z)
      if z > 1 then
         if smartle.detect() then
            smartle.dig()
         end
         smartle.forward()
      end
      for y = 1,height-1 do
         print("Y = "..y)
         if y_signal > 0 then
            if smartle.detectUp() then
               smartle.digUp()
            end
            smartle.up()
         else
            if smartle.detectDown() then
               smartle.digDown()
            end
            smartle.down()
         end
      end
      y_signal = -y_signal
   end
   if x == width + 0 then
      break
   end
   if z_signal > 0 then
      smartle.turnRight()
      if smartle.detect() then
         smartle.dig()
      end
      smartle.forward()
      smartle.turnRight()
      z_signal = -1
   else
      smartle.turnLeft()
      if smartle.detect() then
         smartle.dig()
      end
      smartle.forward()
      smartle.turnLeft()
      z_signal = 1
   end
end

if (ret == "return") then
   print("Returning...")
   smartle.goTo(0, 0, 0, 0, -1)
end
print("TADA!")
print("end")
