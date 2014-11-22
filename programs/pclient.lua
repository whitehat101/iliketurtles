-- Peripheral Client

--[[

Request all methods from a server
{
  [1] = 'poll',
  filter = filter -- optional
}

Call a single method with optional args
{
  [1] = 'call',
  filter = filter, -- optional
  method = 'method',
  args = { ... } -- optional
}

Call several methods without arguments
{
  [1] = 'scan',
  filter = filter, -- optional
  methods = {'method1', 'method2', 'method3'},
}

]]--

-- Collect Args
local argv = {...}
assert(#argv >= 3, 'Usage: '..shell.getRunningProgram()..' protocol host command [args]')
local protocol = table.remove(argv, 1) .. '-peripheral'
local host = table.remove(argv, 1)
local command = table.remove(argv, 1)

-- Scan Peripherals
local cache = {}


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

-- Application Threads

local function listen()
  local responses = {}
  repeat
    local id, response = rednet.receive(protocol, 1) -- block for rednet response
    if id then
      table.insert(responses, textutils.unserialize(response)) -- push to queue O(1)
    end
  until not id

  print(#responses..' Results:')

  textutils.pagedPrint(textutils.serialize(responses), 15)
end

local function request()
  local id = assert(rednet.lookup(protocol, host), 'Host could not be resolved: '..host..':'..protocol)
  local body = {}

  if command == "scan" then
    body = { methods = argv }
  elseif command == "call" then
    local method = table.remove(argv, 1)
    body = { method = method, args = argv }
  end

  if host ~= '*' then
    rednet.send(id, { command, body }, protocol)
  else
    rednet.broadcast({ command, body }, protocol)
  end
end

-- local function console()
--   while running do
--     pcall(function()
--       local buffer, request = {}
--       write('Query: ')
--       buffer = read()
--       if buffer ~= '' then
--         request.filter = { name = buffer }
--       end
--       textutils.pagedPrint(respondTo({'poll', buffer}), 15)
--     end)
--   end
-- end

-- Main

for i, name in ipairs(peripheral.getNames()) do
  if peripheral.getType(name) == 'modem' and peripheral.call(name, 'isWireless') then
    rednet.open(name)
  end
end
assert(rednet.isOpen(), 'Please attach a Wireless Modem')

parallel.waitForAll(listen, request)
rednet.close()
print('Exited Cleanly')
