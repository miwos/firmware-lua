local function quote(value) return "'" .. value .. "'" end
local function doubleQuote(value) return '"' .. value .. '"' end
local function bracket(value) return "[" .. value .. "]" end

---Check wether a value is primitive (number, boolean, string) or complex
---(table, function, ...)
---@param value any
---@return boolean
local function isPrimitve(value)
  local valueType = type(value)
  return (
    valueType == 'number' or
    valueType == 'string' or
    valueType == 'boolean'
  )
end

---Return a json-valid representation of the value.
---@param value any
---@return string
local function valueToJson(value)
  local valueType = type(value)
  local str = isPrimitve(value) and tostring(value) or doubleQuote(valueType)
  return valueType == 'string' and doubleQuote(quote(str)) or str
end

---Return a json-valid representation of the key.
---@param key any
---@return string
local function keyToJson(key)
  local keyType = type(key)
  local keyIsPrimitve = isPrimitve(key)
  local str = keyIsPrimitve and tostring(key) or type(key)
  return (not keyIsPrimitve or keyType == 'number') and bracket(str) or str
end

---Convert a table into a json representation.
---based on https://stackoverflow.com/a/64796533/12207499, thanks Francisco!
---@param t table
---@return string
local function tableToJson(t, done)
  done = done or {}
  done[t] = true

  local str = '{'
  local key, value = next(t, nil)
  while key do
    if (type(value) == 'table' and not done[value]) then
      done[value] = true
      str = str .. string.format(
        '"%s":%s',
        keyToJson(key),
        tableToJson(value, done)
      )

      done[value] = nil
    else
      str = str .. 
        string.format('"%s":%s', keyToJson(key), valueToJson(value))
    end

    key, value = next(t, key)
    if key then str = str .. ',' end
  end
  return str .. '}'
end

---Dump a value to the console.
---@param value any
local function dump(value)
  -- We wrap the result of `valueToJson()` into a bracket so the dump remains
  -- valid json.
  Log.dump(
    type(value) == 'table' and tableToJson(value) or bracket(valueToJson(value))
  )
end

return dump