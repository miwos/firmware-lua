local utils = require('utils')
Instances = _G.Instances or {}

Instances.updateOutputs = utils.throttle(function()
  local patch = Patches.activePatch
  if not patch then
    return
  end

  local activeOutputs = {}

  for _, instance in pairs(patch.instances) do
    for outputIndex, definition in pairs(instance.__outputDefinitions) do
      local activeNotes = instance.__activeNotes[outputIndex]
      local hasActiveNotes = activeNotes
        and utils.getTableLength(activeNotes) > 0
      local hasActiveTriggers = instance.__activeTriggers[outputIndex]

      if hasActiveNotes or hasActiveTriggers then
        activeOutputs[#activeOutputs + 1] = instance.__id
          .. '-'
          .. (outputIndex - 1) -- zero-based index
      end

      if hasActiveTriggers then
        instance.__activeTriggers[outputIndex] = false
      end
    end
  end

  App.sendMessage('/instances/outputs', utils.serializeTable(activeOutputs))
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
