---@class ModulePitchCC : Module
local PitchCC = Modules.create(
  'PitchCC',
  { shape = 'CreateWith', label = { 'Note', 'CC' } }
)

PitchCC:defineInOut({ Input.Midi, Output.Midi })

---@param self ModulePitchCC
---@param note MidiNoteOn
PitchCC:on('input1:noteOn', function(self, note)
  self:output(1, Midi.ControlChange(31, note.note, 10))
end)

return PitchCC
