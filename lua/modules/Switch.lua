local utils = require('utils')

---@class ModuleSwitch : Module
local Switch = Modules.create('Switch')

function Switch:init()
  self:defineProps({
    state = Prop.Switch(),
  })

  self.usedOutputs = {}
end

---@param message MidiMessage
function Switch:input1(message)
  local outputIndex = self.props.state

  if message:is(Midi.NoteOn) then
    local noteId = utils.getMidiNoteId(message)
    self.usedOutputs[noteId] = outputIndex
  elseif message:is(Midi.NoteOff) then
    local noteId = utils.getMidiNoteId(message)
    outputIndex = self.usedOutputs[noteId]
    self.usedOutputs[noteId] = nil
  end

  self:output(outputIndex, message)
end

return Switch
