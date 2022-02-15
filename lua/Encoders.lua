-- The global Encoder object might have already been created by c++.
Encoders = _G.Encoders or {}

Encoders.min = 0
Encoders.max = 127

function Encoders.handleChange(index, rawValue)
  local patch = Patches.activePatch
  if patch then
    local instanceId, name = patch:getMappedProp(index)
    local instance = patch.instances[instanceId]

    if instance then
      local prop = instance.__props[name]
      prop:__setValue(instance, prop:decodeValue(rawValue), false)
    end
  end
end

function Encoders.handleClick(index)
  local patch = Patches.activePatch
  if patch then
    local instanceId, name = patch:getMappedProp(index)
    local instance = patch.instances[instanceId]

    if instance then
      patch.instances[instanceId].__emit('prop:click', name)
    end
  end
end
