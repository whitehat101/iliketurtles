-- Ender Storage Refueling
local fuel
local function refuel(ret, msg)
  if not ret and msg == "Out of fuel" then
    local item = turtle.getSelectedSlot()
    turtle.select(fuel)
    turtle.placeUp()
    turtle.suckUp(1)
    turtle.refuel(1)
    inventory.with('pick', turtle.digUp)
    turtle.select(item)
  end
end

function fromEnderChest(slot)
  fuel = assert(slot)
  turtle.up.queue(refuel)
  turtle.down.queue(refuel)
  turtle.forward.queue(refuel)
  turtle.back.queue(refuel)
end

function unregister()
  turtle.up.dequeue(refuel)
  turtle.down.dequeue(refuel)
  turtle.forward.dequeue(refuel)
  turtle.back.dequeue(refuel)
end