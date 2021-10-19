---@class ModuleInput : Module
local Input = Modules.create('Input')

function Input:init()
  self:defineProps({
    cable = Prop.Number({ min = 1, max = 16, default = 1, step = 1 }),
  })

  self.inputListener = function(...)
    self:handleInput(...)
  end

  Midi.addInputListener(self.inputListener)
end

function Input:handleInput(index, message)
  if message.cable == self.props.cable then
    self:output(index, message)
  end
end

function Input:destroy()
  Midi.removeInputListener(self.inputListener)
end

return Input
