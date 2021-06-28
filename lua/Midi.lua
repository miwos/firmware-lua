local utils = require('utils')
-- The global Midi object might have already been created by c++.
Midi = _G.Midi or {}

Midi.TypeNoteOff = 0x80
Midi.TypeNoteOn = 0x90
Midi.TypeControlChange = 0xB0

Midi.typeNames = {
  [Midi.TypeNoteOn] = 'noteOn',
  [Midi.TypeNoteOff] = 'noteOff',
  [Midi.TypeControlChange] = 'controlChange',
}

Midi.inputHandler = nil

---@alias MidiType "Midi.TypeNoteOn" | "Midi.TypeNoteOff" | "Midi.TypeControlChange"

---@class MidiMessage
---@field type MidiType
---@field data number[]

---@class MidiNoteOn : MidiMessage
---@field data number[] note, velocity, channel

---@class MidiNoteOff : MidiMessage
---@field data number[] note, velocity, channel

---@class MidiControlChange: MidiMessage
---@field data number[] control, value, channel

---@return MidiNoteOn
function Midi.NoteOn(note, velocity, channel)
  return Midi.Message(Midi.TypeNoteOn, { note, velocity, channel })
end

---@return MidiNoteOff
function Midi.NoteOff(note, velocity, channel)
  return Midi.Message(Midi.TypeNoteOff, { note, velocity, channel })
end

---@return MidiControlChange
function Midi.ControlChange(control, value, channel)
  return Midi.Message(Midi.TypeControlChange, { control, value, channel })
end

function Midi.Message(type, data)
  -- `Midi.typeNames` contains all supported midi message types as keys.
  if Midi.typeNames[type] ~= nil then
    return { type = type, data = data }
  end
end

function Midi.setInputHandler(handler)
  Midi.inputHandler = handler
end

function Midi.removeInputHandler()
  Midi.inputHandler = nil
end

-- Receive midi functions from c++:

function Midi.handleInput(index, type, data1, data2, channel)
  local message = Midi.Message(type, { data1, data2, channel })
  if message then
    utils.callIfExists(Midi.inputHandler, { index, message })
  end
end
