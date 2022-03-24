local utils = require('utils')
-- The global Encoder object might have already been created by c++.
Encoders = _G.Encoders or {}

Encoders.min = 0
Encoders.max = 127

function Encoders.handleChange(index, rawValue)
  local patch = Patches.activePatch
  if patch then
    local instanceId, name = patch:getMappedProp(index)
    local prop = Instances.getProp(instanceId, name)
    if prop then
      prop:__setRawValue(rawValue)
    end
  end
end

function Encoders.handleClick(index)
  local patch = Patches.activePatch
  if patch then
    local instanceId, name = patch:getMappedProp(index)
    local instance = patch.instances[instanceId]
    if not instance then
      return
    end

    local prop = instance.__props[name]
    if prop then
      utils.callIfExists(prop.handleClick, { prop, name })
    end

    instance:__emit('prop:click', name)
  end
end
