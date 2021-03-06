-- Add Position tracking to native turtle API

-- Internally orientation is stored as a vector
local Vector = vector
local v = Vector.new(0,0,0)

local unit = {
  y = Vector.new(0,1,0)
}

-- Replace native movement methods to track all movement

turtle.forward.success(function()
  v = v + orientation.vector()
end)

turtle.back.success(function()
  v = v - orientation.vector()
end)

turtle.up.success(function()
  v = v + unit.y
end)

turtle.down.success(function()
  v = v - unit.y
end)

-- TODO gps detection
gps.locate.success(function(x, y, z)
  v = Vector.new(x, y, z)
end)

function tostring()
  return '('..v.x..', '..v.y..', '..v.z..') '..orientation.tostring()
end

function vector()
  return Vector.new(v.x, v.y, v.z)
end

-- auto calibrate

-- if turtle.native.detect then
--   v = vector.new(assert(gps.locate(2)))
--   turtle.native.forward()
--   orientation.calibrate(vector.new(assert(gps.locate(2)))-v)
--   turtle.native.back()
--   print(turtle.position())
-- end
