local loaUtils = require('loa_firmware.utils')

local utils = {
  tableToJson = loaUtils.tableToJson,
}

---Call a function if it exists.
---@param fn function
---@param args table
function utils.callIfExists(fn, args)
  if fn then
    fn(unpack(args or {}))
  end
end

function utils.mapValue(value, inMin, inMax, outMin, outMax)
  return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

function utils.bpmToMillis(value)
  return 60000 / value
end

function utils.isInt(value)
  return value and value == math.floor(value)
end

function utils.getTableLength(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

---Get an id for the specific note in format 'note-velocity-channel'
---@param message MidiNoteOn|MidiNoteOff
function utils.getMidiNoteId(message)
  return message.note .. '-' .. message.channel
end

function utils.parseEventName(name)
  local separator = name:find(':')
  return name:sub(1, separator - 1), name:sub(separator + 1)
end

function utils.getUsedMemory()
  collectgarbage('collect')
  return collectgarbage('count')
end

function utils.throttle(fn, interval)
  local lastTime = 0

  return function(...)
    local args = { ... }
    local now = Timer.now()

    local function next()
      lastTime = now
      fn(unpack(args))
    end

    if lastTime and now < lastTime + interval then
      Timer.cancel(next)
      Timer.schedule(next, now + interval)
    else
      lastTime = now
      next()
    end
  end
end

---Check if a list of connections has a connection that is equal to the provided
---connection.
---@return boolean
function utils.connectionsHas(connections, connection)
  for _, otherConnection in pairs(connections) do
    local equals = true
    for i = 1, 4 do
      if connection[i] ~= otherConnection[i] then
        equals = false
      end
    end
    if equals then
      return true
    end
  end
  return false
end

function utils.capitalize(str)
  return str:sub(1, 1):upper() .. str:sub(2)
end

return utils
