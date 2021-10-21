---@class ModuleOutput : Module
local Output = Modules.create('Output')

function Output:init()
  self:defineProps({
    cable = Prop.Number({ min = 1, max = 16, step = 1 }),
  })
end

---@param index number
---@param message MidiMessage
function Output:input(index, message)
  local data1, data2, channel = unpack(message:serialize())
  Midi.send(index, message.type, data1, data2, channel, self.props.cable)
end

return Output
