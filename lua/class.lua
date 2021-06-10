---A very basic class helper with multiple inheritance.
---@param base table
---@return table
function class(base)
  local c = {}
  c.__index = c

  --Create a new instance.
  ---@param _ table
  ---@return table
  local function call(_, ...)
    local instance = setmetatable({}, c)
    if c.construct then
      c.construct(instance, ...)
    end
    return instance
  end

  if base then
    c.super = base
    local mt = setmetatable({ __index = base }, base)
    mt.__call = call
    setmetatable(c, mt)
  else
    setmetatable(c, { __call = call })
  end

  return c
end

return class
