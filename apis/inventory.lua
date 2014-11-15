local data
local activeTool

-- set an initial inventory state
function set(inv, tool)
  data = inv
  local mt = getmetatable(inventory) or {}
  mt.__index = data
  setmetatable(inventory, mt)
  activeTool = tool
end

function with(item, callback)
  local prevItem = turtle.getSelectedSlot()

  -- equip requested tool
  if activeTool ~= item then
    turtle.select(inventory[activeTool])
    assert(turtle.equipLeft())

    turtle.select(inventory[item])
    assert(turtle.equipLeft())
    activeTool = item
  end

  -- restore inventory before callback
  turtle.select(prevItem)
  return callback and callback()
end

function unequip()
  assert(inventory.empty, "'empty' slot required")
  turtle.select(inventory.empty)
  if turtle.getItemCount() > 0 then
    turtle.drop()
  end
  turtle.equipLeft()
  if turtle.getItemCount() == 1 then
    if turtle.getItemCount(inventory.hoe) == 0 then
      turtle.transferTo(inventory.hoe)
    elseif turtle.getItemCount(inventory.pick) == 0 then
      turtle.transferTo(inventory.pick)
    else
      print('wtf? please reset inventory')
      while true do turtle.turnRight() end
    end
  end
  activeTool = 'empty'
end
