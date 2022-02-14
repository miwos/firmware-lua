local utils = require('utils')

---@class ModulePitcher : Module
local Pitcher = Modules.create('Pitcher')

-- Pitcher.on('input1:*', function(self, message)

-- end)

-- Pitcher.input(1).on('note', '')

-- Pitcher.on('note-on', 'handleNoteOn')

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
  self.usedPitches[utils.getMidiNoteId(message)] = pitchedNote
  self:output(1, Midi.NoteOn(pitchedNote, message.velocity, message.channel))
end

---@param message MidiNoteOff
function Pitcher:input1_noteOff(message)
  local noteId = utils.getMidiNoteId(message)

  -- Sometimes `pitchedNote` is already deleted. Not sure why this happens
  -- exactly.
  local pitchedNote = self.usedPitches[noteId]
  if pitchedNote == nil then
    return
  end

  self.usedPitches[noteId] = nil
  self:output(1, Midi.NoteOff(pitchedNote, message.velocity, message.channel))
end

return Pitcher
