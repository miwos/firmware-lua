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

---@param note MidiNoteOn
function Pitcher:input1_noteOn(note)
  local pitchedNote = note.note + self.props.pitch
  self.usedPitches[utils.getMidiNoteId(note)] = pitchedNote

  self:output(1, Midi.NoteOn(pitchedNote, note.velocity, note.channel))
end

---@param note MidiNoteOff
function Pitcher:input1_noteOff(note)
  local noteId = utils.getMidiNoteId(note)
  local pitchedNote = self.usedPitches[noteId]
  self.usedPitches[noteId] = nil

  self:output(1, Midi.NoteOff(pitchedNote, note.velocity, note.channel))
end

return Pitcher
