---@class ModuleKeySplit : Module
local KeySplit = Modules.create(
  'KeySplit',
  { shape = 'Split', label = 'Key\\nSplit' }
)

function KeySplit:init()
  self.usedOutputs = {}
  self.notes = {}
end

KeySplit:defineInOut({ Input.Midi, Output.Midi, Output.Midi })

KeySplit:defineProps({
  Prop.Number('divider', { min = 22, max = 107, step = 1, default = 60 }),
})

---@param self ModuleKeySplit
---@param note MidiNoteOn
KeySplit:on('input1:noteOn', function(self, note)
  local outputIndex = note.note < self.props.divider and 1 or 2
  self.usedOutputs[Midi.getNoteId(note)] = outputIndex
  self:output(outputIndex, note)
end)

---@param self ModuleKeySplit
---@param note MidiNoteOff
KeySplit:on('input1:noteOff', function(self, note)
  local noteId = Midi.getNoteId(note)
  local outputIndex = self.usedOutputs[noteId]
  self.usedOutputs[noteId] = nil
  if outputIndex then
    self:output(outputIndex, note)
  else
    Log.warn('No output index found')
  end
end)

return KeySplit
