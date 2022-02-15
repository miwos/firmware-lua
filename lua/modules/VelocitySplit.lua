local VelocitySplit = Modules.create('VelocitySplit')

function VelocitySplit:init()
  self.usedOutputs = {}
end

VelocitySplit:defineProps({
  thresh = Prop.Number({ default = 63, min = 0, max = 127, step = 1 }),
})

---@param message MidiMessage
VelocitySplit:on('input1:*', function(self, message)
  local outputIndex = 1

  if message:is(Midi.NoteOn) then
    local noteId = Midi.getNoteId(message)
    ---@type MidiNoteOn
    local note = message
    outputIndex = (note.velocity < self.props.thresh) and 1 or 2
    self.usedOutputs[noteId] = outputIndex
  elseif message:is(Midi.NoteOff) then
    local noteId = Midi.getNoteId(message)
    outputIndex = self.usedOutputs[noteId]
    self.usedOutputs[noteId] = nil
  end

  self:output(outputIndex, message)
end)

return VelocitySplit
