---@class ModuleOutput : Module
local Output = Modules.create('Output')

function Output:init()
  self:defineProps({
    cable = Prop.Number({ min = 1, max = 16, step = 1 }),
  })
end

function Output:input(index, message)
  message.data[4] = self.props.cable
  Midi.send(index, message.type, unpack(message.data))
end

return Output
