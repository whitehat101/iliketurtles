-- Peripheral Server

-- Collect Args
local argv = {...}
assert(#argv >= 2, 'Usage: '..shell.getRunningProgram()..' protocol hostname')
local protocol = table.remove(argv, 1) .. '-peripheral'
local hostname = table.concat(argv, ' ')

-- Load Label Map
local labels = setmetatable(
  dofile('labels') or {},
  { __index = function(self, key) return key end }
)

-- Scan Peripherals
local peripherals
local function scanPeripherals()
  print('Scanning Peripherals')
  peripherals = {}
  for i, name in ipairs(peripheral.getNames()) do
    local kind = peripheral.getType(name)
    if kind == 'modem' then
      if peripheral.call(name, 'isWireless') then
        rednet.open(name)
      end
    else
      print('Found: '..name..' '..kind)
      table.insert(peripherals, setmetatable({
        name = name,
        kind = kind,
        methods = peripheral.getMethods(name),
      },{
        __index = peripheral.wrap(name)
      }))
    end
  end
end

-- local pcall(peripheral.call, name, isWireless)

local function respondTo(request)
  local responses = {
    -- host = os.getComputerLabel() or ''..os.getComputerID(),
    host = hostname,
    day = os.day(),
    time = os.time(),
    timestamp = 'Day '..os.day()..', '..textutils.formatTime(os.time())
  }
  for i, device in ipairs(peripherals) do
    if not request.kind or device.kind == request.kind then
      if not request.name or labels[device.name] == request.name then
        if type(request.method) == 'string' and request.method ~= '' then
          if device[request.method] then
            local call = request.argv or {}
            table.insert(call, 1, device[request.method])
            local _, result = pcall(unpack(call))
            table.insert(responses, {
              kind = device.kind,
              response = result,
              name = labels[device.name],
            })
          end
        elseif type(request.methods) == 'table' then
          local results = {}
          for i, method in request.methods do
            if device[request.method] then
              local _, result = pcall(device[method])
              results[method] = result
            end
          end
          table.insert(responses, {
            kind = device.kind,
            response = results,
            name = labels[device.name],
          })
        else
          table.insert(responses, {
            kind = device.kind,
            response = device.methods,
            name = labels[device.name],
          })
        end
      end
    end
  end
  return textutils.serialize(responses)
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
      local id, request = table.remove(queue, 1) -- unshift from queue O(n)
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
      write('Query: ')
      print(respondTo({method = read()}))
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
