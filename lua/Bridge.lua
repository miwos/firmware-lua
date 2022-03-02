local utils = require('utils')
Bridge = _G.Bridge or {}

---@param signal number
---@param direction number
---@param instanceId any
---@param index any
---@param message any
function Bridge.sendInputOutput(signal, direction, instanceId, index, message)
  local payload = signal == Signal.Midi
    and {
      message.type,
      unpack(message:serialize()),
    }

  if payload then
    Bridge._sendInputOutput(
      signal,
      direction,
      instanceId,
      index,
      unpack(payload)
    )
  else
    Bridge._sendInputOutput(signal, direction, instanceId, index)
  end
end

Bridge.sendActiveOutputs = utils.throttle(function()
  local activeOutputs = {}

  local patch = Patches.activePatch
  if patch then
    for _, instance in pairs(Patches.activePatch.instances) do
      for index, unfinishedNotes in pairs(instance.__unfinishedNotes) do
        if utils.getTableLength(unfinishedNotes) > 0 then
          activeOutputs[#activeOutputs + 1] = instance.__id .. '-' .. index
        end
      end
    end
  end

  Bridge._sendActiveOutputs(table.concat(activeOutputs, ','))
end, 50)
