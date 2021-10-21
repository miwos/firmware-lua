local class = require('class')

---@class MidiMessage
---@field type number The midi type.
---@field name string A human readable midi type name (e.g.: 'noteOn').
---@field keys table Name aliases for midi data1 and data2 (e.g.: for a noteOn
---message this would be `{ 'note', 'velocity' }`).
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
