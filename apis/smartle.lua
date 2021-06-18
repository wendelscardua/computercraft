-- Smarter turtle API

-- coordinates
local x -- usually from west to east
local y -- from below to above
local z -- usually from north to south

-- direction
local xd, zd

-- Defines current position/orientation as origin
function setOrigin()
   x = 0
   y = 0
   z = 0

   xd = 0
   zd = -1
end

setOrigin()

-- multi step movement functions

function up(n)
   n = n or 1
   for i = 1, n do
      if not turtle.up() then
         return false
      end
      y = y + 1
   end
   return true
end

function down(n)
   n = n or 1
   for i = 1, n do
      if not turtle.down() then
         return false
      end
      y = y - 1
   end
   return true
end

function forward(n)
   n = n or 1
   for i = 1, n do
      if not turtle.forward() then
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
      if not turtle.back() then
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
