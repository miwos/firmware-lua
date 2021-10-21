local mt = {}

function mt:__newindex(key, value)
  ---@type Prop
  local prop = self._props[key]
  if prop then
    prop:setValue(value)
  end
end

function mt:__index(key)
  ---@type Prop
  local prop = self._props[key]
  return prop and prop:getValue() or nil
end

local function Props(module, props)
  for name, prop in pairs(props) do
    prop.module = module
    prop.name = name
  end
  local t = { _props = props }
  setmetatable(t, mt)
  return t
end

return Props
