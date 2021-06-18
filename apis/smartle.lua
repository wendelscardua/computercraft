-- Smarter turtle API

-- coordinates
local x -- usually from west to east
local y -- from below to above
local z -- usually from north to south

-- direction
local xd, zd

-- dig-while-moving flag
local forceMove = false

-- Defines current position/orientation as origin
function setOrigin(x0, y0, z0, xd0, zd0)
   x = x0 or 0
   y = y0 or 0
   z = z0 or 0

   xd = xd0 or 0
   zd = zd0 or -1
end

setOrigin()

-- affects forceMove flag

function setForceMove(flag)
   forceMove = flag
end

-- internal movement functions, applying forceMove if needed

function internalForward ()
   if forceMove and not turtle.forward() then dig() end
   return turtle.forward()
end

function internalBack ()
   if forceMove and not turtle.back() then
      turnRight(2)
      dig()
      turnRight(2)
   end
   return turtle.back()
end

function internalUp ()
   if forceMove and not turtle.up() then digUp() end
   return turtle.up()
end

function internalDown ()
   if forceMove and not turtle.down() then digDown() end
   return turtle.down()
end

-- multi step movement functions

function up(n)
      n = n or 1
      for i = 1, n do
      if not internalUp() then
         return false
      end
      y = y + 1
   end
   return true
end

function down(n)
   n = n or 1
   for i = 1, n do
      if not internalDown() then
         return false
      end
      y = y - 1
   end
   return true
end

function forward(n)
   n = n or 1
   for i = 1, n do
      if not internalForward() then
         return false
      end
      x = x + xd
      z = z + zd
   end
   return true
end

function back(n)
   n = n or 1
   for i = 1, n do
      if not internalBack() then
         return false
      end
      x = x - xd
      z = z - zd
   end
   return true
end

function turnRight(n)
   n = n or 1
   for i = 1, n do
      xd, zd = -zd, xd
      turtle.turnRight()
   end
end

function turnLeft(n)
   n = n or 1
   for i = 1, n do
      xd, zd = zd, -xd
      turtle.turnLeft()
   end
end

-- turn to specific orientation
function turnTo(xd2, zd2)
   if xd2 == 1 and zd2 == 0 then
      if xd == -1 then
         turnRight(2)
      elseif zd == 1 then
         turnLeft(1)
      elseif zd == -1 then
         turnRight(1)
      end
      return true
   elseif xd2 == -1 and zd2 == 0 then
      if xd == 1 then
         turnRight(2)
      elseif zd == 1 then
         turnRight(1)
      elseif zd == -1 then
         turnLeft(1)
      end
      return true
   elseif xd2 == 0 and zd2 == 1 then
      if zd == -1 then
         turnRight(2)
      elseif xd == 1 then
         turnRight(1)
      elseif xd == -1 then
         turnLeft(1)
      end
      return true
   elseif xd2 == 0 and zd2 == -1 then
      if zd == 1 then
         turnRight(2)
      elseif xd == 1 then
         turnLeft(1)
      elseif xd == -1 then
         turnRight(1)
      end
      return true
   else
      return false
   end
end

-- move to coordinate
function goTo(x2, y2, z2, xd2, zd2)
   if not goToY(y2) then return false end

   delta_x = math.abs(x2 - x)
   delta_z = math.abs(z2 - z)

   if x2 > x then
      dir_x = 1
   else
      dir_x = -1
   end

   if z2 > z then
      dir_z = 1
   else
      dir_z = -1
   end

   if delta_x == 0 then
      return goToZ(z2)
   elseif delta_z == 0 then
      return goToX(x2)
   elseif dir_x == xd then
      if not goToX(x2) then
         return false
      end
      if not goToZ(z2) then
         return false
      end
   elseif dir_z == zd then
      if not goToZ(z2) then
         return false
      end
      if not goToX(x2) then
         return false
      end
   else
      if not goToX(x2) then
         return false
      end
      if not goToZ(z2) then
         return false
      end
   end
   if xd2 and zd2 then return turnTo(xd2, zd2) end
   return true
end

function goToX(x2)
   if x2 > x then
      turnTo(1, 0)
      return forward(x2 - x)
   elseif x2 < x then
      turnTo(-1, 0)
      return forward(x - x2)
   else
      return true
   end
end

function goToY(y2)
   if y2 > y then
      if not up(y2 - y) then return false end
   elseif y2 < y then
      if not down(y - y2) then return false end
   end
   return true
end

function goToZ(z2)
   if z2 > z then
      turnTo(0, 1)
      return forward(z2 - z)
   elseif z2 < z then
      turnTo(0, -1)
      return forward(z - z2)
   else
      return true
   end
end

-- run in circles, usually as an indicator of something
function dance ()
   turnRight(4)
end

-- wait until items are available
-- everything is optional
function require(slot, minAmount, itemName, verbose)
   minAmount = minAmount or 1
   if slot then
      turtle.select(slot)
      while true do
         local details = turtle.getItemDetail(slot)
         if details and (not itemName or itemName == details.name) and details.count >= minAmount then
            if not (verbose == nil) then print("Thanks") end
            return
         end
         if verbose then
            print("I need "..minAmount.." of "..(itemName or "anything").." on slot "..slot)
            verbose = false
         end
         dance()
      end
   else
      while true do
         for i = 1, 16 do
            local details = turtle.getItemDetail(i)
            if details and (not itemName or itemName == details.name) and details.count >= minAmount then
               turtle.select(i)
               if not (verbose == nil) then print("Thanks") end
               return
            end
         end
         if verbose then
            print("I need "..minAmount.." of "..(itemName or "anything"))
            verbose = false
         end
         dance()
      end
   end
end

-- extend turtle
dig = turtle.dig
digUp = turtle.digUp
digDown = turtle.digDown
detect = turtle.detect
detectUp = turtle.detectUp
detectDown = turtle.detectDown
