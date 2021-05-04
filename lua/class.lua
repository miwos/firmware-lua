---A very basic class helper with inheritance.
---@param super table
---@return table
function class(super)
  local c = {}

  -- Inherit super by making a shallow copy.
  if type(super) == 'table' then
    for key,value in pairs(super) do c[key] = value end
    c._super = super
  end

  c.__index = c
  local mt = {}

  ---Create a new instance.
  ---@param table table
  ---@return table
  mt.__call = function(table, ...)
    local instance = {}
    setmetatable(instance, c)
    if super and super.init then super.init(instance, ...) end
    if table.init then table.init(instance, ...) end
    return instance
  end

  setmetatable(c, mt)
  return c
end

return class