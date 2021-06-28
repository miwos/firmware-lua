---@class ModuleInput : Module
local Input = Miwos.createModule('Input')

function Input:init()
  Midi.setInputHandler(function(...)
    self:handleInput(...)
  end)
end

function Input:handleInput(index, message)
  self:output(index, message)
end

function Input:destroy()
  Midi.removeInputHandler()
end

return Input
