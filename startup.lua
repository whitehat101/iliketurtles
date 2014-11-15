-- only bootstrap iliketurtles once
if os.iliketurtles == nil then
  os.iliketurtles = true

  assert(os.loadAPI('/iliketurtles/apis/queued'))
  -- wrap core API methods into a queued object
  local methods = {
    [gps] = {'locate'}
  }
  if turtle then
    methods[turtle] = {'up','down','forward','back','turnLeft','turnRight','dig','digDown','digUp','place','placeDown','placeUp','suck','suckDown','suckUp'}
  end
  queued.wrapAll(methods)

  if turtle then
    os.loadAPI('/iliketurtles/apis/orientation')
    os.loadAPI('/iliketurtles/apis/position')
    os.loadAPI('/iliketurtles/apis/inventory')
  end

  shell.setPath(shell.path()..':/iliketurtles/programs')
  print('iliketurtles')
end
