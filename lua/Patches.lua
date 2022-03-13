local Patch = require('Patch')

Patches = _G.Patches or {}

---@type Patch
Patches.activePatch = nil

---Load a patch from file.
---@param name string
---@return Patch
function Patches.load(name)
  if Patches.activePatch then
    Patches.activePatch:destroy()
  end
  local data = loadfile('lua/patches/' .. name .. '.lua')
  ---@type Patch
  local patch = Patch(data)
  patch.name = name
  patch:activate()
  return patch
end

function Patches.handlePropChange(instanceId, name, value)
  if Patches.activePatch then
    local instance = Patches.activePatch.instances[instanceId]
    local prop = instance.__props[name]
    if not prop then
      Log.warn(
        string.format("Prop '%s' doesn't exist on %s", name, instance.__name)
      )
    else
      prop:__setValue(instance, value)
    end
  end
end

function Patches.update(name)
  if Patches.activePatch and Patches.activePatch.name == name then
    local data = loadfile('lua/patches/' .. name .. '.lua')
    Patches.activePatch:update(data)
  end
end
