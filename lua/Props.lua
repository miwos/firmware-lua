local mt = {}

function mt:__newindex(key, value)
  self._values[key] = value
end

function mt:__index(key)
  return self._values[key]
end

local function Props()
  local props = { _values = {} }
  setmetatable(props, mt)
  return props
end

return Props
