local utils = {}

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
  local timerId = nil

  return function(...)
    local args = { ... }
    local now = Timer.now()

    local function next()
      lastTime = now
      fn(unpack(args))
    end

    if lastTime and now < lastTime + interval then
      if not timerId then
        timerId = Timer.schedule(now + interval, next)
      else
        Timer.reschedule(now + interval, next)
      end
    else
      lastTime = now
      next()
    end
  end
end

return utils
