local utils = require('utils')
local MidiMessage = require('MidiMessage')

-- The global Midi object might have already been created by c++.
Midi = _G.Midi or {}

Midi.TypeNoteOff = 0x80
Midi.TypeNoteOn = 0x90
Midi.TypeControlChange = 0xB0

---@alias MidiType "Midi.TypeNoteOn" | "Midi.TypeNoteOff" | "Midi.TypeControlChange"
Midi.typeNames = {
  [Midi.TypeNoteOn] = 'noteOn',
  [Midi.TypeNoteOff] = 'noteOff',
  [Midi.TypeControlChange] = 'controlChange',
}

Midi.inputListeners = {}

---@class MidiNoteOn : MidiMessage
---@field note number
---@field velocity number
Midi.NoteOn = class(MidiMessage)
Midi.NoteOn.type = Midi.TypeNoteOn
Midi.NoteOn.keys = { 'note', 'velocity' }

---@class MidiNoteOff : MidiMessage
---@field note number
---@field velocity number
Midi.NoteOff = class(MidiMessage)
Midi.NoteOff.type = Midi.TypeNoteOff
Midi.NoteOff.keys = { 'note', 'velocity' }

---@class MidiControlChange : MidiMessage
---@field controler number
---@field value number
Midi.ControlChange = class(MidiMessage)
Midi.ControlChange.type = Midi.TypeControlChange
Midi.ControlChange.keys = { 'controler', 'value' }

local typeMessageDict = {
  [Midi.TypeNoteOn] = Midi.NoteOn,
  [Midi.TypeNoteOff] = Midi.NoteOff,
  [Midi.TypeControlChange] = Midi.ControlChange,
}

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

function Midi.handleInput(index, messageType, data1, data2, channel, cable)
  local Message = typeMessageDict[messageType]
  if Message == nil then
    return
  end

  local message = Message()
  message:deserialize(data1, data2, channel)

  for i = 1, #Midi.inputListeners do
    utils.callIfExists(Midi.inputListeners[i], { index, message, cable })
  end
end
