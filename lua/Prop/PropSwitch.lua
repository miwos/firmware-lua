local utils = require('utils')
local PropBase = require('Prop.PropBase')

---@class PropSwitch : Prop
local PropSwitch = class(PropBase)
PropSwitch.type = 'switch'

function PropSwitch:constructor(name, args)
  self.name = name
  args = args or {}
  self.show = args.show == nil and true or args.show
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

function PropSwitch:serialize()
  return {
    name = self.name,
    index = self.index,
    show = self.show,
    states = self.states,
    default = self.default,
  }
end

return PropSwitch
