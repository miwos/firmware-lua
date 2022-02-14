local class = require('class')
local Module = require('Module')

Modules = _G.Modules or {}

---Return a new module class.
---@param name string
---@return table
function Modules.create(name)
  local newModule = class(Module)
  newModule.__type = name
  newModule.__events = {}
  return newModule
end

function Modules.get(id)
  return Patches.activePatch and Patches.activePatch.instances[id] or nil
end
