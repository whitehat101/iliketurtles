function north()
  return orientation.turnNorth() and turtle.forward()
end

function east()
  return orientation.turnEast() and turtle.forward()
end

function south()
  return orientation.turnSouth() and turtle.forward()
end

function west()
  return orientation.turnWest() and turtle.forward()
end

local function goN(move, meters)
  local traveled = 0
  move = assert(turtle[move])
  for x=1, meters do
    if move() then
      traveled = traveled + 1
    else
      break
    end
  end
  return traveled
end

function goX(meters)
  meters = assert(meters)
  -- print('goX', meters)
  if meters > 0 then
    orientation.turnEast()
    return goN('forward', math.floor(meters))
  elseif meters < 0 then
    orientation.turnWest()
    return goN('forward', math.floor(-meters))
  elseif meters == 0 then
    return 0
  end
end

function goY(meters)
  meters = assert(meters)
  -- print('goY', meters)
  if meters > 0 then
    return goN('up', math.floor(meters))
  elseif meters < 0 then
    return goN('down', math.floor(-meters))
  elseif meters == 0 then
    return 0
  end
end

function goZ(meters)
  meters = assert(meters)
  -- print('goZ', meters)
  if meters > 0 then
    orientation.turnSouth()
    return goN('forward', math.floor(meters))
  elseif meters < 0 then
    orientation.turnNorth()
    return goN('forward', math.floor(-meters))
  elseif meters == 0 then
    return 0
  end
end

local function shuffled(tab)
  local n, order, res = #tab, {}, {}

  for i=1,n do order[i] = { rnd = math.random(), idx = i } end
  table.sort(order, function(a,b) return a.rnd < b.rnd end)
  for i=1,n do res[i] = tab[order[i].idx] end
  return res
end


local moves = {
  north,
  turtle.down,
  turtle.down,
  east,
  west,
  south,
  turtle.up,
  turtle.up,
}
local function panic()
  local movesLength = #moves
  local fear = math.random(1,3)
  --local move = moves[math.random(movesLength)]
  print('panic fear='..fear)

  repeat
    if moves[math.random(movesLength)]() then
      fear = fear - 1
    --else
      --move = moves[math.random(movesLength)]
    end
  until fear == 0
end

function follow(destination, range)
  range = range or 1
  local function delta() return destination - position.vector() end
  if delta():length() <= range then
    return
  end
  local function lazyDirections(delta)
    return shuffled({
      function() return goX(delta.x) end,
      function() return goY(delta.y) end,
      function() return goZ(delta.z) end,
    })
  end

  local loop = 0
  repeat
    loop = loop + 1
    local traveled = 0
    for i,direction in ipairs(lazyDirections(delta():normalize():round())) do
      traveled = traveled + direction()
    end

    if traveled == 0 then
      panic()
    end
    -- print(position.tostring())
  until delta():length() <= range
  -- print('travel.follow loop='..loop)
end

function go(x,y,z, range)
  range = range or 1
  local destination = vector.new(x,y,z)
  local function delta() return destination - position.vector() end
  local function lazyDirections(delta)
    return shuffled({
      function() return goX(delta.x) end,
      function() return goY(delta.y) end,
      function() return goZ(delta.z) end,
    })
  end

  local loop = 0
  repeat
    loop = loop + 1
    local traveled = 0
    local direction
    for i,direction in ipairs(lazyDirections(delta():normalize():round())) do
      traveled = traveled + direction()
    end

    if traveled == 0 then
      panic()
    end
    -- print(position.tostring())
  until delta():length() <= range
  --print('travel.go loop='..loop)
end

function goXZthenY(loc)
  local pos = position.vector()
  pos.x, pos.z = loc.x, loc.z
  follow(pos, 0)
  follow(loc, 0)
end

function goYthenXZ(loc)
  local pos = position.vector()
  pos.y = loc.y
  follow(pos, 0)
  follow(loc, 0)
end
