-- Queued Function

local function enqueue(queue)
  return function(callback)
    table.insert(queue, callback)
    return function()
      for i=#queue, 1, -1 do
        if queue[i] == callback then
          table.remove(queue, i)
        end
      end
    end
  end
end

local function doCallbacks(queue, ret)
  for i, callback in ipairs(queue) do
    callback(unpack(ret))
  end
end

function new(source)
  local always, success, fail = {}, {}, {}
  return setmetatable({
    queue   = enqueue(always),
    always  = enqueue(always),
    success = enqueue(success),
    fail    = enqueue(fail),
  }, {
    __call = function (self, ...)
      local ret = {source(...)}
      if ret[1] then
        doCallbacks(success, ret)
      else
        doCallbacks(fail, ret)
      end
      doCallbacks(always, ret)
      return unpack(ret)
    end
  })
end

function wrapAll(wrap)
  for object, methods in pairs(wrap) do
    for i, method in ipairs(methods) do
      object[method] = new(object[method])
    end
  end
end
