local utils = require('utils')

---@class ModulePitcher : Module
local Pitcher = Modules.create('Pitcher')

function Pitcher:init()
  self:defineProps({
    pitch = Prop.Number({ default = 0, min = -24, max = 24, step = 1 }),
  })

  self.usedPitches = {}
end

function Pitcher:sendNote(note)
  local pitchedNote = note.note + self.props.pitch
  note.note = pitchedNote
  self:output(1, note)
end

---@param message MidiNoteOn
function Pitcher:input1_noteOn(message)
  local pitchedNote = message.note + self.props.pitch
  self.usedPitches[Midi.getNoteId(message)] = pitchedNote
  self:output(1, Midi.NoteOn(pitchedNote, message.velocity, message.channel))
end

---@param message MidiNoteOff
function Pitcher:input1_noteOff(message)
  local noteId = Midi.getNoteId(message)
  local pitchedNote = self.usedPitches[noteId]

  -- Sometimes `pitchedNote` is already deleted. Not sure why this happens.
  if pitchedNote then
    self.usedPitches[noteId] = nil
    self:output(1, Midi.NoteOff(pitchedNote, message.velocity, message.channel))
  else
    Log.warn("Can't find pitch.")
  end
end

Pitcher:on('input1:noteOn', Pitcher.input1_noteOn)
Pitcher:on('input1:noteOff', Pitcher.input1_noteOff)

return Pitcher
