local Node = require('Node')
local Module = require('Module')
local Patch = require('Patch')
local class = require('class')

Miwos = {
  ---@type Module
  input = Node(),
  ---@type Module
  output = Node(),
  ---@type Patch
  activePatch = nil,
}

---Send midi message to midi devices.
---@param index number The midi device index.
---@param message MidiMessage The midi message.
function Miwos.output:input(index, message)
  local actions = {
    [Midi.TypeNoteOn] = Midi.sendNoteOn,
    [Midi.TypeNoteOff] = Midi.sendNoteOff,
    [Midi.TypeControlChange] = Midi.sendControlChange,
  }

  local action = actions[message.type]
  if action then
    action(index, unpack(message.data))
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

function Miwos.getModule(id)
  return Miwos.activePatch and Miwos.activePatch.modules[id] or nil
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

function Miwos.destroy()
  if Miwos.activePatch then
    Miwos.activePatch:destroy()
  end
end

return Miwos
