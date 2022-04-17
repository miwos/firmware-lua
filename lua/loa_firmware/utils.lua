---From https://stackoverflow.com/a/66370080/12207499, thanks PiFace!
local function isArray(t)
  return #t > 0 and next(t, #t) == nil
end

local function serializeValue(value)
  local valueType = type(value)
  local noQuotes = valueType == 'boolean'
    or valueType == 'number'
    or valueType == 'nil'
  return noQuotes and tostring(value) or ("'" .. tostring(value) .. "'")
end

local function serializeKey(key)
  return type(key) == 'string' and key or '[' .. key .. ']'
end

local utils = {}

---Based on https://stackoverflow.com/a/64796533/12207499, thanks Francisco!
function utils.serializeTable(t, done)
  done = done or {}
  done[t] = true

  local str = '{'
  local key, value = next(t, nil)
  while key do
    local valueJson
    if type(value) == 'table' and not done[value] then
      done[value] = true
      valueJson = utils.serializeTable(value, done)
      done[value] = nil
    else
      valueJson = serializeValue(value)
    end

    str = str
      .. (isArray(t) and valueJson or serializeKey(key) .. '=' .. valueJson)

    key, value = next(t, key)
    if key then
      str = str .. ','
    end
  end
  return str .. '}'
end

function utils.dump(...)
  local args = { ... }
  local str = ''
  for i = 1, select('#', ...) do
    local value = args[i]
    str = str
      .. (i > 1 and ', ' or '')
      .. (
        type(value) == 'table' and utils.serializeTable(value)
        or serializeValue(value)
      )
  end
  return '{' .. str .. '}'
end

return utils
