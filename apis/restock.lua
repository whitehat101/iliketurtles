-- Ender Storage Restocking
local slot, side
local function restock(ret, msg)
  if msg == "No items to place" then
    local item = turtle.getSelectedSlot()
    turtle.select(slot)
    turtle.native['place'..side]()

    turtle.select(item)
    turtle.native['suck'..side](64)

    turtle.select(slot)
    inventory.with('pick', turtle.native['dig'..side])

    turtle.select(item)
  end
end

function fromEnderChest(_slot, _side)
  slot = assert(_slot)
  side = _side or 'Up'
  turtle.place.fail(restock)
  turtle.placeUp.fail(restock)
  turtle.placeDown.fail(restock)
end

