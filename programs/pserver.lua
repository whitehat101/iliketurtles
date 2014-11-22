-- Peripheral Server

os.loadAPI('/iliketurtles/apis/label')

--[[

Request all methods from a server
{
  [1] = 'poll',
  [2] = {
    filter = filter -- optional
  }
}

Call a single method with optional args
{
  [1] = 'call',
  [2] = {
    filter = filter, -- optional
    method = 'method',
    args = { ... } -- optional
  }
}

Call several methods without arguments
{
  [1] = 'scan',
  [2] = {
    filter = filter, -- optional
    methods = {'method1', 'method2', 'method3'},
  }
}

]]--

-- Collect Args
local argv = {...}
assert(#argv >= 2, 'Usage: '..shell.getRunningProgram()..' protocol hostname')
local protocol = table.remove(argv, 1) .. '-peripheral'
local hostname = table.concat(argv, ' ')

-- Scan Peripherals
local peripherals

local labels
labels = label.new('/labels', {})

local function scanPeripherals()
  print('Scanning Peripherals')
  local names = {}
  peripherals = {}

  for i, name in ipairs(peripheral.getNames()) do
    local kind = peripheral.getType(name)
    if kind == 'modem' then
      if peripheral.call(name, 'isWireless') then
        rednet.open(name)
      end
    else
      print('Found: '..labels[name]..' '..name..' '..kind)
      table.insert(names, name)
      table.insert(peripherals, setmetatable({
        name = name,
        ['type'] = kind,
        methods = peripheral.getMethods(name),
      },{
        __index = peripheral.wrap(name)
      }))
    end
  end

  -- (re)Load Label Map
  labels = label.new('/labels', names)
end



local function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

local Each = {
  __index = {
    each = function (self, callback)
      for i,v in ipairs(self) do
        callback(i,v)
      end
    end
  }
}

local function getPeripherals(filter)
  filter = filter or {}
  local matches = copy(peripherals)

  -- filter by device name/label
  if filter.name then
    for i=#matches, 1, -1 do
      if labels[matches[i].name] ~= filter.name then
        table.remove(matches, i)
      end
    end
  end

  -- filter by device type
  if filter.type then
    for i=#matches, 1, -1 do
      if matches[i].type ~= filter.type then
        table.remove(matches, i)
      end
    end
  end

  return setmetatable(matches, Each)
end

local app = {}

function app.poll(request)
  print('poll!!', request)
  local devices = getPeripherals(request.filter)
  local response = {}

  devices:each(function(i, device)
    table.insert(response, {
      kind = device.kind,
      response = device.methods,
      name = labels[device.name],
    })
  end)

  return response
end

function app.call(request)
  local devices = getPeripherals(request.filter)
  local args = request.args or {}
  local response = {}
  assert(request.method, 'Required param #method missing')

  devices:each(function(i, device)
    -- prepare method call
    local call = { device[request.method] }
    for i,v in ipairs(args) do table.insert(call, v) end

    -- call in protected mode
    local _, result = pcall(unpack(call))

    table.insert(response, {
      kind = device.kind,
      response = result,
      name = labels[device.name],
    })
  end)

  return response
end

function app.scan(request)
  local devices = getPeripherals(request.filter)
  local args = request.args or {}
  local response = {}
  assert(request.methods, 'Required param #methods missing')

  devices:each(function(i, device)
    local results = {}
    for i, method in ipairs(request.methods) do
      local _, result = pcall(device[method])
      results[method] = result
    end

    table.insert(response, {
      kind = device.kind,
      response = results,
      name = labels[device.name],
    })
  end)

  return response
end

-- local pcall(peripheral.call, name, isWireless)

local function respondTo(request)
  -- print(request)
  -- print(request[1])
  -- print(request[2] or {})

  -- Promote action string to action method on app object
  -- request[1] = app[request[1]]

  -- Call action
  local success, response = pcall(app[request[1]], request[2] or {})

  return textutils.serialize({
    -- host = os.getComputerLabel() or ''..os.getComputerID(),
    host = hostname,
    day = os.day(),
    time = os.time(),
    success = success,
    response = response,
  })
end

-- Application Threads

local running = true
local function terminate()
  os.pullEventRaw('terminate')
  running = false
  print('Shutting down...')
end

local queue = {}
local function listen()
  rednet.broadcast('ONLINE', protocol..'-status')
  while running do
    pcall(function()
      local request = { rednet.receive(protocol) } -- block for rednet request
      table.insert(queue, request)                 -- push to queue O(1)
      os.queueEvent('request-queued')
    end)
  end
  rednet.broadcast('OFFLINE', protocol..'-status')
end

local function respond()
  while running do
    os.pullEventRaw('request-queued')            -- block for queued request
    while #queue > 0 do
      local id, request = unpack(table.remove(queue, 1)) -- unshift from queue O(n)
      rednet.send(id, respondTo(request), protocol)
    end
  end
end

local function watchPeripherals()
  while running do
    local event = os.pullEventRaw()
    if event == 'peripheral' or event == 'peripheral_detach' then
      scanPeripherals()
    end
  end
end

local function console()
  while running do
    pcall(function()
      local buffer, request = {}
      write('Query: ')
      buffer = read()
      if buffer ~= '' then
        request.filter = { name = buffer }
      end
      textutils.pagedPrint(respondTo({'poll', request}), 15)
    end)
  end
end

-- Main

scanPeripherals()
assert(rednet.isOpen(), 'Please attach a Wireless Modem')
rednet.host(protocol, hostname)
parallel.waitForAll(terminate, listen, respond, watchPeripherals, console)
rednet.unhost(protocol, hostname)
rednet.close()
print('Exited Cleanly')
