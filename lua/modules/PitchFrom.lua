---@class ModulePitchFrom : Module
local PitchFrom = Modules.create('PitchFrom', { shape = 'TransformWith' })

function PitchFrom:init()
  self.usedPitches = {}
  self.pitch = 0
end

PitchFrom:defineInOut({ Input.Midi, Input.Midi, Output.Midi })

PitchFrom:defineProps({
  key = Prop.Number({ min = 0, max = 12, step = 1 }),
})

---@param message MidiNoteOn
PitchFrom:on('input1:noteOn', function(self, message)
  local pitchedNote = message.note + self.pitch
  self.usedPitches[Midi.getNoteId(message)] = pitchedNote
  self:output(1, Midi.NoteOn(pitchedNote, message.velocity, message.channel))
end)

---@param message MidiNoteOff
PitchFrom:on('input1:noteOff', function(self, message)
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

---@param message MidiNoteOn
PitchFrom:on('input2:noteOn', function(self, message)
  self.pitch = message.note - 60 -- C4
end)

return PitchFrom
