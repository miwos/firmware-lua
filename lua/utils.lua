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

---Get an id for the specific note in format 'note-velocity-channel'
---@param note MidiNoteOn|MidiNoteOff
function utils.getMidiNoteId(note)
  return note.note .. '-' .. note.channel
end

function utils.getUsedMemory()
  collectgarbage('collect')
  return collectgarbage('count')
end

return utils
