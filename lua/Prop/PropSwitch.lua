local utils = require('utils')
local PropBase = require('Prop.PropBase')

---@class PropSwitch : Prop
local PropSwitch = class(PropBase)

function PropSwitch:constructor(args)
  self.states = args.states or 2
  self.value = args.default or 1
end

---Convert a raw encoder value to a scaled prop value.
---@param rawValue number
---@return number
function PropSwitch:decodeValue(rawValue)
  return math.floor(
    utils.mapValue(rawValue, Encoders.min, Encoders.max, 1, self.states) + 0.5
  )
end

---Convert a scaled prop value to a raw encoder value.
---@param value number
---@return number
function PropSwitch:encodeValue(value)
  return utils.mapValue(value, 1, self.states, Encoders.min, Encoders.max)
end

---Return a string representation of the value.
---@return string
function PropSwitch:getDisplayValue(value)
  return tostring(value)
end

return PropSwitch
