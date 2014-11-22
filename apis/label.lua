local Label = {}

-- if key is not set, return key as label
function Label:__index(key)
  return key
end

function new(file, keys)
  assert(fs.exists(file))
  keys = keys or {}

  local labels

  fs.open(file, 'r', function(h)
    labels = textutils.unserialize(h.readAll())
  end)

  if #keys > 0 then
    for i,key in ipairs(keys) do
      if not labels[key] then
        labels[key] = key
      end
    end

    fs.open(file, 'w', function(h)
      h.write(textutils.serialize(labels))
    end)
  end

  return setmetatable(labels, Label)
end
