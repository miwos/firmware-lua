local Module = require('Module')
local Patch = require('Patch')
local class = require('class')

Miwos = {
  ---@type Module
  input = Module(),
  ---@type Module
  output = Module(),
  ---@type Patch
  activePatch = nil,
}

---Send midi message to midi devices.
---@param index number The midi device index.
---@param message table The midi message.
function Miwos.output:input(index, message)
  local actions = {
    [Midi.TypeNoteOn] = Midi.sendNoteOn,
    [Midi.TypeNoteOff] = Midi.sendNoteOff,
    [Midi.TypeControlChange] = Midi.sendControlChange,
  }

  local action = actions[message.type]
  if action then
    -- Decrease index, because we use zero-based index in c++.
    action(index - 1, unpack(message.data))
  end
end

---Return a new module class.
---@param name string
---@return table
function Miwos.createModule(name)
  local newModule = class(Module)
  newModule._type = name
  return newModule
end

---Load a patch from file.
---@param name string
---@return Patch
function Miwos.loadPatch(name)
  local data = loadfile('lua/patches/' .. name .. '.lua')
  local patch = Patch(data)
  patch:activate()
  return patch
end

return Miwos
