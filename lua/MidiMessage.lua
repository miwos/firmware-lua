local class = require('class')

---@class MidiMessage
---@field type MidiType Will be defined by descendants.
---@field keys table Will be defined by descendants.
local MidiMessage = class()

function MidiMessage:constructor(data1, data2, channel)
  self[self.keys[1]] = data1
  self[self.keys[2]] = data2
  self.channel = channel
end

function MidiMessage:serialize()
  local data1 = self[self.keys[1]]
  local data2 = self[self.keys[2]]
  return { data1, data2, self.channel }
end

function MidiMessage:deserialize(data1, data2, channel)
  self[self.keys[1]] = data1
  self[self.keys[2]] = data2
  self.channel = channel
end

return MidiMessage
