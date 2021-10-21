local class = require('class')
local MidiMessage = require('Midi.MidiMessage')

local function messageFactory(type, name, keys)
  local Message = class(MidiMessage)
  Message.type = type
  Message.keys = keys
  Message.name = name
  return Message
end

return {
  ---@class MidiNoteOn : MidiMessage
  ---@field note number
  ---@field velocity number
  NoteOn = messageFactory(0x90, 'noteOn', { 'note', 'velocity' }),

  ---@class MidiNoteOff : MidiMessage
  ---@field note number
  ---@field velocity number
  NoteOff = messageFactory(0x80, 'noteOff', { 'note', 'velocity' }),

  ---@class MidiControlChange : MidiMessage
  ---@field controler number
  ---@field value number
  ControlChange = messageFactory(
    0xB0,
    'controlChange',
    { 'controler', 'value' }
  ),
}
