local Patch = require('Patch')

Patches = _G.Patches or {}

---@type Patch
Patches.activePatch = nil

---Load a patch from file.
---@param name string
---@return Patch
function Patches.load(name)
  local data = loadfile('lua/patches/' .. name .. '.lua')
  local patch = Patch(data)
  patch.name = name
  patch:activate()
  return patch
end

function Patches.update(name)
  if Patches.activePatch and Patches.activePatch.name == name then
    local data = loadfile('lua/patches/' .. name .. '.lua')
    Patches.activePatch:update(data)
  end
end

function Patches.changeProp(moduleId, propName, value)
  local patch = Patches.activePatch
  if not patch then
    return
  end

  patch:changeProp(moduleId, propName, value)
end
