---Call a function if it exists.
---@param fn function
---@param args table
local function callIfExists(fn, args)
  if fn then
    fn(unpack(args or {}))
  end
end

local function isPrimitve(var)
  local varType = type(var)
  return (
    varType == 'number' or
    varType == 'string' or
    varType == 'boolean'    
  )
end

return {
  callIfExists = callIfExists
}