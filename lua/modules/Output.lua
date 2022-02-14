---@class ModuleOutput : Module
local Output = Modules.create('Output')

function Output:init()
  self:defineProps({
    device = Prop.Number({ min = 1, max = 16, step = 1, default = 1 }),
    cable = Prop.Number({ min = 1, max = 16, step = 1 }),
  })
end

---@param message MidiMessage
function Output:input1(message)
  local data1, data2, channel = unpack(message:serialize())
  Midi.send(
    self.props.device,
    message.type,
    data1,
    data2,
    channel,
    self.props.cable
  )
end

return Output
