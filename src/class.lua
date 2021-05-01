---A very basic class helper with inheritance.
---@param super table
---@return table
local function class(super)
  local obj = {}
  obj.__index = obj

  -- Inherit super class by making a shallow copy.
  if type(super) == 'table' then
    for key,value in pairs(super) do obj[key] = value end
    obj.super = super
  end

  setmetatable(obj, {
    __call = function (table, ...)
      local instance = setmetatable({}, obj)
      if super.init then super.init(instance, ...) end
      if table.init then table.init(instance, ...) end
      return instance
    end
  })

  return obj
end

return class