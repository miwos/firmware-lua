local utils = require('utils')
local PropBase = require('Prop.PropBase')

---@class PropNumber : Prop
---@field min number
---@field max number
---@field step number|nil
local PropNumber = class(PropBase)

function PropNumber:constructor(args)
  self.min = args.min or 0
  self.max = args.max or 127
  self.step = args.step
  self.default = args.default or self.min
end

---Convert a raw encoder value to a scaled prop value.
---@param rawValue number
---@return number
function PropNumber:decodeValue(rawValue)
  local scaledValue = utils.mapValue(
    rawValue,
    Encoders.min,
    Encoders.max,
    self.min,
    self.max
  )

  return self.step and math.ceil(scaledValue / self.step) * self.step
    or scaledValue
end

---Convert a scaled prop value to a raw encoder value.
---@param value number
---@return number
function PropNumber:encodeValue(value)
  return utils.mapValue(value, self.min, self.max, Encoders.min, Encoders.max)
end

---Return a string representation of the value.
---@param value number
---@return string
function PropNumber:getDisplayValue(value)
  return utils.isInt(self.step) and string.format('%i', value)
    or string.format('%.2f', self.value)
end

return PropNumber
