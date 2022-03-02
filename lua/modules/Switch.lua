---@class ModuleSwitch : Module
local Switch = Modules.create('Switch', { shape = 'Split' })

function Switch:init()
  self.usedOutputs = {}
end

Switch:defineInOut({ Input.Midi, Output.Midi, Output.Midi })

Switch:defineProps({
  state = Prop.Switch(),
})

---@param message MidiMessage
Switch:on('input1:*', function(self, message)
  local outputIndex = self.props.state

  if message:is(Midi.NoteOn) then
    local noteId = Midi.getNoteId(message)
    self.usedOutputs[noteId] = outputIndex
  elseif message:is(Midi.NoteOff) then
    local noteId = Midi.getNoteId(message)
    outputIndex = self.usedOutputs[noteId]
    self.usedOutputs[noteId] = nil
  end

  self:output(outputIndex, message)
end)

return Switch
