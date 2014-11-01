-- this script farms a very spicific (non-optimal) pumpkin farm with 3 pumpkins

os.loadAPI('/iliketurtles/apis/travel')
os.loadAPI('/iliketurtles/apis/refuel')
inventory.set({
  pumpkin = 1,
  empty = 13,
  pick = 14,
  hoe = 15,
  fuel = 16,
})
orientation.autoCalibrate()
turtle.back()
refuel.fromEnderChest(inventory.fuel)

assert(#{...} == 8, "Incorrect Parameters.\n"..
  "Usage: pumpkin-plower heading0, x0, y0, z0, headingS, xS, yS, zS\n" ..
  "                               origin                 storage")
local heading, x0, y0, z0, storageHeading, xS, yS, zS = ...
local origin = vector.new(x0, y0, z0)
local storage = vector.new(xS, yS, zS)

-- Main Farming Routines

local function ensure(callback)
  local ret
  repeat ret = {callback()} until ret[1]
  return unpack(ret)
end

local function callAll(...)
  local ret = {}
  for i, callback in ipairs({...}) do
    ret[i] = callback()
  end
  return ret
end

function farmField()
  local loot = 0
  travel.goYthenXZ(origin)
  orientation.turn(heading)

  -- count loot
  local unregister1 = turtle.digDown.success(function()
    loot = loot + 1
  end)

  -- check for pumpkins
  local unregister2 = turtle.forward.success(function()
    if turtle.detectDown() then
      inventory.with('hoe', turtle.digDown)
    end
    inventory.with('hoe', turtle.digDown)
  end)

  for loop=1, 3 do
    ensure(turtle.forward)
    for cnt=1, 4 do
      ensure(turtle.forward)
      ensure(turtle.forward)
      if cnt ~= 4 then
        turtle.turnRight()
      end
    end
  end

  callAll(unregister1, unregister2)
  return loot
end

function deposit()
  travel.goXZthenY(storage)
  orientation.turn(storageHeading)
  redstone.setOutput('front', true)
  turtle.drop()
  redstone.setOutput('front', false)
end

-- Main "Event" Loop
print(
  "pumpkin-plower\n"..
  'origin: '..origin:tostring()..' '..heading.."\n"..
  'storage: '..storage:tostring()..' '..storageHeading.."\n"..
  'Inventory:'
)
for item, slot in pairs(inventory.get()) do print('- '..slot..' '..item) end

inventory.unequip()
turtle.select(inventory.pumpkin)
local cnt = 0
while true do
  local start, delta = os.time()
  local loot = farmField()
  cnt = cnt + 1
  delta = os.time() - start
  if delta < 0 then delta = delta + 24 end
  print('#'..cnt..' time='..delta..' loot='..loot..' ('..start..')')
  if turtle.getItemCount() >= 32 then
    deposit()
  end
end
