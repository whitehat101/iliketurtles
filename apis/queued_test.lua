function function_name()
  print("Hello World")
  return 3,4,5,6,7
end

function bad_function()
  error('bad_function!')
end

fx = queued.new(function_name)
local dequeue = fx.queue(bad_function)
fx.queue(function( ... )
  print(...)
end)
dequeue()
print(fx())
