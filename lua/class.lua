---A very basic class helper with inheritance.
---@param base table
---@return table
function class(base)
  local c = {}
  c.__index = c
  c.__super = base

  -- 'Inherit' all of base properties and functions.
  local mt = base and { __index = base } or {}

  ---Create a new instance.
  ---@param table table
  ---@return table
  mt.__call = function(table, ...)
    local instance = {}
    setmetatable(instance, c)
    if base and base.init then
      base.init(instance, ...)
    end
    if table.init then
      table.init(instance, ...)
    end
    return instance
  end

  setmetatable(c, mt)
  return c
end

return class
