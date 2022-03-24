local utils = require('utils')
local PropBase = require('Prop.PropBase')

---@class PropSwitch : Prop
local PropSwitch = class(PropBase)
PropSwitch.type = 'switch'

function PropSwitch:constructor(name, args)
  PropSwitch.super.constructor(self, name, args)
  args = args or {}
  self.states = utils.default(args.state, 2)
  self.value = utils.default(args.default, 1)
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
---@return number
function PropSwitch:encodeValue()
  return utils.mapValue(self.value, 1, self.states, Encoders.min, Encoders.max)
end

---Return a string representation of the value.
---@return string
function PropSwitch:displayValue()
  return tostring(self.value)
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
