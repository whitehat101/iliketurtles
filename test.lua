print('CraftOS 1.6 Testing Simulator')
math.randomseed(os.time())

-- polyfil -- luajit names shift ops differently
bit.blogic_rshift = bit.arshift -- >>
bit.brshift = bit.rshift        -- >>>
bit.blshift = bit.lshift

local mock = {
  noop = function() end,
  str = function() return '' end,
  one = function() return 1 end,
  True = function() return true end,
  False = function() return false end,
  random50 = function() return math.random(0,1) == 0 end,
  random10 = function() return math.random(0,9) == 0 end,
}

turtle = {
  forward   = mock.True,
  back      = mock.True,
  up        = mock.True,
  down      = mock.True,
  turnLeft  = mock.True,
  turnRight = mock.True,
  digDown   = mock.True,
  digUp     = mock.True,
  dig       = mock.True,
  select    = mock.True,
  detectDown = mock.random10,
  detectUp  = mock.random10,
  detect    = mock.random10,
  getItemCount = mock.one,
}
turtle.native = turtle


shell = {
  path = mock.str,
  setPath = mock.noop,
}
gps = {
  locate = mock.noop
}

os.sleep = mock.noop
-- local ffi = require("ffi")
-- ffi.cdef[[int poll(struct pollfd *fds, unsigned long nfds, int timeout);]]
-- function os.sleep(s)
--   ffi.C.poll(nil, 0, s*1000)
-- end


local tAPIsLoading = {}
function os.loadAPI( _sPath )
    local sName = string.gsub(_sPath, "(.*/)(.*)", "%2")
    if tAPIsLoading[sName] == true then
        printError( "API "..sName.." is already being loaded" )
        return false
    end
    tAPIsLoading[sName] = true

    local tEnv = {}
    setmetatable( tEnv, { __index = _G } )
    local localPath = _sPath:gsub('/iliketurtles/', '')
    local fnAPI, err = loadfile(localPath)
    if fnAPI then
        setfenv( fnAPI, tEnv )
        fnAPI()
    else
        -- printError( err )
        print( err )
        tAPIsLoading[sName] = nil
        return false
    end

    local tAPI = {}
    for k,v in pairs( tEnv ) do
        tAPI[k] =  v
    end

    _G[sName] = tAPI
    tAPIsLoading[sName] = nil
    return true
end

os.loadAPI('ComputerCraft/vector')
dofile('startup')
if turtle then
  orientation.calibrate('north')
end

for i,file in ipairs({...}) do
  dofile(file)
end
