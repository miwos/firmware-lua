local utils = require('utils')

---@class ModulePitcher : Module
local Pitcher = Modules.create('Pitcher')

function Pitcher:init()
  self:defineProps({
    semitones = Prop.Number({ default = 0, min = -24, max = 24, step = 1 }),
  })

  self.usedPitches = {}
end

function Pitcher:sendNote(note)
  local pitchedNote = note.note + self.props.semitones
  note.note = pitchedNote
  self:output(1, note)
end

---@param note MidiNoteOn
function Pitcher:input1_noteOn(note)
  local pitchedNote = note.note + self.props.semitones
  self.usedPitches[utils.getMidiNoteId(note)] = pitchedNote

  note.note = pitchedNote
  self:output(1, note)
end

---@param note MidiNoteOff
function Pitcher:input1_noteOff(note)
  local noteId = utils.getMidiNoteId(note)
  local pitchedNote = self.usedPitches[noteId]
  self.usedPitches[noteId] = nil

  note.note = pitchedNote
  self:output(1, note)
end

return Pitcher
