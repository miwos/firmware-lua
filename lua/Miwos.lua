local Patch = require('Patch')
local class = require('class')
local Module = require('Module')

Miwos = {
  ---@type Patch
  activePatch = nil,
}

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
