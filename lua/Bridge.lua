Bridge = _G.Bridge or {}

---@param instanceId number
---@param index number
---@param message MidiMessage
function Bridge.sendInput(instanceId, index, message)
  Bridge._sendInputOutput(
    'in',
    instanceId,
    index,
    message.type,
    unpack(message:serialize())
  )
end

---@param instanceId number
---@param index number
---@param message MidiMessage
function Bridge.sendOutput(instanceId, index, message)
  Bridge._sendInputOutput(
    'out',
    instanceId,
    index,
    message.type,
    unpack(message:serialize())
  )
end
