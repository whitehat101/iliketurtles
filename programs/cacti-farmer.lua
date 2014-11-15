os.loadAPI('/iliketurtles/apis/travel')
os.loadAPI('/iliketurtles/apis/refuel')
local inventory = {
  fuel = 16,
  cacti = 1,
}
orientation.autoCalibrate()
refuel.fromEnderChest(inventory.fuel)

assert(#{...} >= 7, "Incorrect Parameters.\n"..
  "Usage: cacti-farmer heading, x, y, z, xS, yS, zS, [farmSize = 9], [rest = 0]\n"..
  "                             origin   storage")
local heading, x0, y0, z0, xS, yS, zS, farmSize, rest = ...
local origin = vector.new(x0, y0, z0)
local storage = vector.new(xS, yS, zS)
farmSize = farmSize or 9
rest = rest or 0

-- Main Farming Routines

local function farmCactus()
  if turtle.detectDown() then
    turtle.digDown()
    turtle.down()
    turtle.digDown()
    turtle.up()
  end
end

local turns = {
  [0] = turtle.turnLeft,
  [1] = turtle.turnRight,
}

function farmField()
  travel.goYthenXZ(origin)
  orientation.turn(heading)
  farmCactus()

  for walk = 1, farmSize do
    for i = 1, farmSize - 1 do
      turtle.forward()
      farmCactus()
      os.sleep(rest)
    end
    if walk ~= farmSize then
      local turn = turns[walk % 2]
      turn()
      turtle.forward()
      farmCactus()
      os.sleep(rest)
      turn()
    end
  end
end

function depositCactus()
  travel.goXZthenY(storage)
  redstone.setOutput('bottom', true)
  turtle.dropDown()
  redstone.setOutput('bottom', false)
end

-- Main "Event" Loop
print(
  "cacti-farmer\n"..
  'origin: '..origin:tostring()..' '..heading.."\n"..
  'storage: '..storage:tostring().."\n"..
  'farmSize: '..farmSize.."\n"..
  'rest: '..rest.."\n"..
  'Inventory:'
)
for item, slot in pairs(inventory) do print('- '..slot..' '..item) end

turtle.select(inventory.cacti)
while true do
  farmField()
  if turtle.getItemCount() >= 32 then
    depositCactus()
  end
end
