---@class ModuleInput : Module
local Input = Modules.create('Input')

function Input:init()
  self:defineProps({
    device = Prop.Number({ min = 1, max = 16, step = 1, default = 1 }),
    cable = Prop.Number({ min = 1, max = 16, step = 1 }),
  })

  self.inputListener = function(...)
    self:handleInput(...)
  end

  Midi.addInputListener(self.inputListener)
end

function Input:handleInput(index, message, cable)
  local isSameDevice = index == self.props.device
  -- local isSameCable = cable == nil or cable == self.props.cable
  if isSameDevice then
    self:output(1, message)
  end
end

function Input:destroy()
  Midi.removeInputListener(self.inputListener)
end

return Input
