local class = require('class')
local utils = require('utils')

Prop = {}

---@class PropBase
local PropBase = class()

---@class PropNumber : PropBase
Prop.Number = class(PropBase)

function Prop.Number:init(args)
  self.min = args.min or 0
  self.max = args.max or 127
  self.step = args.step
  self.default = args.default or self.min
end

---Convert a raw encoder value to a scaled prop value.
---@param rawValue number
---@return number
function Prop.Number:decodeValue(rawValue)
  local scaledValue = utils.mapValue(rawValue, Encoder.min, Encoder.max, self.min, self.max)
  return self.step
    and math.ceil(scaledValue / self.step) * self.step
    or scaledValue
end

---Convert a scaled prop value to a raw encoder value.
---@param value any
---@return any
function Prop.Number:encodeValue(value)
  return utils.mapValue(value, self.min, self.max, Encoder.min, Encoder.max)
end

function Prop.Number:displayValue(value)
  return utils.isInt(self.step)
    and tostring(value)
    or string.format('%.2f', value)
end