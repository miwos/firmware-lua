local function quote(value) return "'" .. value .. "'" end
local function bracket(value) return "[" .. value .. "]" end

local function isPrimitve(var)
  local varType = type(var)
  return (
    varType == 'number' or
    varType == 'string' or
    varType == 'boolean'    
  )
end

local function prettyValue(value)
  local valueType = type(value)
  local str = isPrimitve(value) and tostring(value) or valueType
  return valueType == 'string' and quote(str) or str
end

local function prettyKey(key)
  local keyType = type(key)
  local keyIsPrimitve = isPrimitve(key)
  local str = keyIsPrimitve and tostring(key) or type(key)
  return (not keyIsPrimitve or keyType == 'number') and bracket(str) or str
end

local function toPrettyString(var, depth, done)
  depth = depth or 0
  done = done or {}
  done[var] = true

  local str = '{\n'
  for key, value in pairs(var) do
    str = str .. string.rep(' ', depth + 1)

    if (type(value) == 'table' and not done[value]) then
      done[value] = true
      str = 
        str .. prettyKey(key) .. ' = ' .. toPrettyString(value, depth + 1, done)
      done[value] = nil
    else
      str = str ..prettyKey(key) .. ' = ' .. prettyValue(value)
      if done[value] then str = str .. ' (circular reference)' end
    end
    str = str .. '\n'
  end
  return str .. string.rep(' ', depth) .. '}'
end

---Dump variables for debugging.
---@param variable any
---@return string
local function dump(variable) print(toPrettyString(variable)) end

return dump