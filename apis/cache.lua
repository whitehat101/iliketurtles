local Cache = {}

function Cache:set( key, value )
  self[key:tostring()] = value
end

function Cache:get( key )
  return self[key:tostring()]
end

function new()
  return setmetatable({}, Cache)
end
