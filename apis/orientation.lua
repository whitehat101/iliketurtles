-- Add Oriention tracking to native turtle API

-- Internally orientation is stored as a vector
local Vector = vector
local v = { x=0, z=0 }

-- Calibrate orientation via string
local calibration = {
  north = { 0,-1},
  east  = { 1, 0},
  south = { 0, 1},
  west  = {-1, 0},
}

function calibrate(face)
  if type(face) == 'string' then
    local mapped = calibration[face]
    if mapped then
      v.x, v.z = mapped[1], mapped[2]
      return true
    end
  else -- vector
    v.x, v.z = face.x, face.z
    return true
  end
  return false
end

-- Add callbacks to track changes in orientation

-- |0 -1| x
-- |1  0| z
turtle.turnRight.queue(function()
  v.x, v.z = -v.z, v.x
end)

-- | 0 1| x
-- |-1 0| z
turtle.turnLeft.queue(function()
  v.x, v.z = v.z, -v.x
end)

-- Auto-Calibrate orientation from gps signals
function autoCalibrate(...)
  local initial
  local direction
  local gpsArgs = {...}

  -- calibrate orientation from gps movements
  local unregister
  unregister = gps.locate.success(function(x, y, z)
    local current = Vector.new(x, y, z)
    local unregisterForward, unregisterBack

    if not initial then
      initial = current

      unregisterForward = turtle.forward.success(function()
        unregisterForward()
        unregisterBack()
        direction = 'forward'
        gps.locate(unpack(gpsArgs))
      end)

      unregisterBack = turtle.back.success(function()
        unregisterForward()
        unregisterBack()
        direction = 'back'
        gps.locate(unpack(gpsArgs))
      end)

    elseif initial ~= current then
      if direction == 'forward' then
        calibrate(current-initial)
      else
        calibrate(initial-current)
      end
      unregister()
      initial, unregister, unregisterForward, unregisterBack = nil
    end
  end)

  return gps.locate(unpack(gpsArgs))
end

-- Relative 180 turn
local turns = {
  turtle.turnRight,
  turtle.turnLeft
}

function turnAround()
  local turn = turns[math.random(2)]
  return turn() and turn()
end

-- Absolute Turns

-- dot        - the dot product of current and desired directions
-- orthogonal - the vector component orthogonal to the desired direction
local function vectorTurn(dot, orthogonal)
  if dot == 1 then
    return true
  elseif dot == -1 then
    return turnAround()
  elseif dot == 0 then
    if orthogonal == 1 then
      return turtle.turnLeft()
    elseif orthogonal == -1 then
      return turtle.turnRight()
    else
      error("Calibrate before using absolute turns [e.g.: orientation.calibrate('north')]")
    end
  end
end

function turnNorth()
  return vectorTurn(-v.z, v.x)
end
function turnEast()
  return vectorTurn(v.x, v.z)
end
function turnSouth()
  return vectorTurn(v.z, -v.x)
end
function turnWest()
  return vectorTurn(-v.x, -v.z)
end

function turn(direction)
  local method = 'turn'..direction:gsub("^%l", string.upper)
  local f = assert(orientation[method], 'MethodMissing: '..method)
  return f()
end

function vector()
  return Vector.new(v.x, 0, v.z)
end

-- Map vector to words
local vectorToWord = {
 [-1] = {[0] = 'west'},
  [0] = {
        [-1] = 'north',
         [1] = 'south',
  },
  [1] = {[0] = 'east'},
}

function tostring()
  return vectorToWord[v.x][v.z]
end

heading = tostring -- alias
facing = tostring  -- alias