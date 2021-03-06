-- Ender Storage Refueling
local slot, side
local function refuel(ret, msg)
  if msg == "Out of fuel" then
    local item = turtle.getSelectedSlot()
    turtle.select(slot)
    turtle.native['place'..side]()
    turtle.native['suck'..side](1)
    turtle.refuel(1)
    inventory.with('pick', turtle.native['dig'..side])
    turtle.select(item)
  end
end

function fromEnderChest(_slot, _side)
  slot = assert(_slot)
  side = _side or 'Up'
  turtle.up.fail(refuel)
  turtle.down.fail(refuel)
  turtle.forward.fail(refuel)
  turtle.back.fail(refuel)
end
