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

Midi.inputListeners = {}

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

function Midi.addInputListener(listener)
  table.insert(Midi.inputListeners, listener)
end

function Midi.removeInputListener(listener)
  for i = 1, #Midi.inputListeners do
    if Midi.inputListeners[i] == listener then
      table.remove(Midi.inputListeners, i)
      break
    end
  end
end

---@return MidiNoteOn
function Midi.NoteOn(note, velocity, channel, cable)
  return Midi.Message(Midi.TypeNoteOn, { note, velocity, channel, cable })
end

---@return MidiNoteOff
function Midi.NoteOff(note, velocity, channel, cable)
  return Midi.Message(Midi.TypeNoteOff, { note, velocity, channel, cable })
end

---@return MidiControlChange
function Midi.ControlChange(control, value, channel, cable)
  return Midi.Message(
    Midi.TypeControlChange,
    { control, value, channel, cable }
  )
end

function Midi.Message(type, data)
  -- `Midi.typeNames` contains all supported midi message types as keys.
  if Midi.typeNames[type] ~= nil then
    return { type = type, data = data }
  end
end

-- Receive midi functions from c++:

function Midi.handleInput(index, type, data1, data2, channel, cable)
  local message = Midi.Message(type, { data1, data2, channel, cable })

  if message then
    for i = 1, #Midi.inputListeners do
      utils.callIfExists(Midi.inputListeners[i], { index, message })
    end
  end
end
