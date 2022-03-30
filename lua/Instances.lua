local utils = require('utils')
Instances = _G.Instances or {}

Instances.updateOutputs = utils.throttle(function()
  local activeOutputs = {}

  local patch = Patches.activePatch
  if not patch then
    return
  end

  for _, instance in pairs(patch.instances) do
    for outputIndex, definition in pairs(instance.__outputDefinitions) do
      local isActive = false
      if definition.signal == Signal.Midi then
        local activeNotes = instance.__activeNotes[outputIndex]
        isActive = activeNotes and utils.getTableLength(activeNotes) > 0
      elseif definition.signal == Signal.Trigger then
        isActive = instance.__activeTriggers[outputIndex]
      end

      if isActive then
        activeOutputs[#activeOutputs + 1] = instance.__id
          .. '-'
          .. (outputIndex - 1) -- zero-based index
      end
    end
  end

  Instances._updateOutputs(table.concat(activeOutputs, ','))
end, 50)

function Instances.getProp(instanceId, name)
  local patch = Patches.activePatch
  if not patch then
    return
  end

  local instance = patch.instances[instanceId]
  if not instance then
    return
  end

  return instance.__props[name]
end
