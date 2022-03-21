local utils = require('utils')

---@class ModulePitcher : Module
local Pitcher = Modules.create('Pitcher', { shape = 'Transform' })

function Pitcher:init()
  self.usedPitches = {}
end

Pitcher:defineInOut({ Input.Midi, Output.Midi })

Pitcher:defineProps({
  Prop.Number('pitch', { default = 0, min = -24, max = 24, step = 1 }),
})

function Pitcher:sendNote(note)
  local pitchedNote = note.note + self.props.pitch
  note.note = pitchedNote
  self:output(1, note)
end

---@param message MidiNoteOn
Pitcher:on('input1:noteOn', function(self, message)
  local pitchedNote = message.note + self.props.pitch
  self.usedPitches[Midi.getNoteId(message)] = pitchedNote
  self:output(1, Midi.NoteOn(pitchedNote, message.velocity, message.channel))
end)

---@param message MidiNoteOff
Pitcher:on('input1:noteOff', function(self, message)
  local noteId = Midi.getNoteId(message)
  local pitchedNote = self.usedPitches[noteId]

  -- Sometimes `pitchedNote` is already deleted. Not sure why this happens.
  if pitchedNote then
    self.usedPitches[noteId] = nil
    self:output(1, Midi.NoteOff(pitchedNote, message.velocity, message.channel))
  else
    -- Log.warn("Can't find pitch.")
  end
end)

return Pitcher
