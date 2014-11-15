os.loadAPI('/iliketurtles/apis/refuel')
os.loadAPI('/iliketurtles/apis/restock')

inventory.set({
  floor = 1,
  pick = 14,
  floor_chest = 15,
  fuel_chest = 16,
}, 'pick')

refuel.fromEnderChest(inventory.fuel_chest, '')
restock.fromEnderChest(inventory.floor_chest, '')

local function ensure(callback)
  local ret
  repeat ret = {callback()} until ret[1]
  return unpack(ret)
end


-- count blocks palced
local highscore = 0
turtle.placeUp.success(function()
  highscore = highscore + 1
  print('Blocks Placed: '..highscore)
end)

-- place blocks
local sensor = assert(peripheral.find('openperipheral_sensor'), 'Sensor Peripheral Missing!')
turtle.forward.success(function()
  ensure(turtle.placeUp)

  if sensor.sonicScan()[66].type == 'SOLID' then
    turtle.turnRight()
  end
end)

-- Main "Event" Loop

turtle.select(inventory.floor)

while true do
  -- Callbacks OP
  ensure(turtle.forward)
end
