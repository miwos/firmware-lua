local Module = require('Module')
local class = require('class')

Miwos = {
  input = Module(),
  output = Module()
}

---Send midi message to midi devices.
---@param index number The midi device index.
---@param message table The midi message.
function Miwos.output:input(index, message)
  local actions = {
    [Midi.TypeNoteOn] = Midi.sendNoteOn,
    [Midi.TypeNoteOff] = Midi.sendNoteOff,
    [Midi.TypeControlChange] = Midi.sendControlChange
  }

  local action = actions[message.type]
  if action then
    -- Decrease index, because we use zero-based index in c++.
    action(index - 1, unpack(message.payload))
  end
end

---Return a new module class.
---@return any
function Miwos.Module()
  return class(Module)
end

return Miwos