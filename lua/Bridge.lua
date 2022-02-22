local Module = require('Module')
Bridge = _G.Bridge or {}

---comment
---@param signal number
---@param direction number
---@param instanceId any
---@param index any
---@param message any
function Bridge.sendInputOutput(signal, direction, instanceId, index, message)
  -- local payload = signal == Module.SignalMidi
  --   and {
  --     message.type,
  --     unpack(message:serialize()),
  --   }

  -- if payload then
  --   Bridge._sendInputOutput(
  --     signal,
  --     direction,
  --     instanceId,
  --     index,
  --     unpack(payload)
  --   )
  -- else
  --   Bridge._sendInputOutput(signal, direction, instanceId, index)
  -- end
end
