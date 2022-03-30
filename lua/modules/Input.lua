---@class ModuleInput : Module
local Input = Modules.create('Input', { shape = 'Input' })

function Input:init()
  self.inputListener = function(...)
    self:handleInput(...)
  end

  Midi.addInputListener(self.inputListener)
end

Input:defineInOut({ Output.Midi })

Input:defineProps({
  Prop.Number('device', { list = false, min = 1, max = 16, step = 1 }),
  Prop.Number('cable', { list = false, min = 1, max = 16, step = 1 }),
})

function Input:handleInput(index, message, cable)
  local isSameDevice = index == self.props.device
  -- todo: fix, why is this commented out?
  -- local isSameCable = cable == nil or cable == self.props.cable
  if isSameDevice then
    self:output(1, message)
  end
end

function Input:destroy()
  Midi.removeInputListener(self.inputListener)
end

return Input
