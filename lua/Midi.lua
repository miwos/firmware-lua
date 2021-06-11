-- The global Midi object might have already been created by c++.
Midi = _G.Midi or {}

Midi.TypeNoteOn = 1
Midi.TypeNoteOff = 2
Midi.TypeControlChange = 3

Midi.typeNames = {
  [Midi.TypeNoteOn] = 'noteOn',
  [Midi.TypeNoteOff] = 'noteOff',
  [Midi.TypeControlChange] = 'controlChange',
}

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
  return { type = type, data = data }
end

-- Receive midi functions:

function Midi.handleNoteOn(input, ...)
  Miwos.input:output(input + 1, Midi.NoteOn(...))
end

function Midi.handleNoteOff(input, ...)
  Miwos.input:output(input + 1, Midi.NoteOff(...))
end
