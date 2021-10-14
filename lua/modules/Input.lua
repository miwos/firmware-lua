---@class ModuleInput : Module
local Input = Miwos.createModule('Input')

function Input:init()
  self.inputListener = function(...)
    self:handleInput(...)
  end

  Midi.addInputListener(self.inputListener)
end

function Input:handleInput(index, message)
  self:output(index, message)
end

function Input:destroy()
  Midi.removeInputListener(self.inputListener)
end

return Input
