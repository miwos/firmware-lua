local utils = require('utils')
Instances = _G.Instances or {}

Instances.updateOutputs = utils.throttle(function()
  local activeOutputs = {}

  local patch = Patches.activePatch
  if patch then
    for _, instance in pairs(Patches.activePatch.instances) do
      for index, unfinishedNotes in pairs(instance.__unfinishedNotes) do
        if utils.getTableLength(unfinishedNotes) > 0 then
          activeOutputs[#activeOutputs + 1] = instance.__id
            .. '-'
            .. (index - 1) -- zero-based index
        end
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
