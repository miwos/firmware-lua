local utils = require('utils')
local PropBase = require('Prop.PropBase')

---@class PropNumber : Prop
---@field min number
---@field max number
---@field step number|nil
local PropNumber = class(PropBase)

PropNumber.serializeFields = { 'min', 'max', 'setp', 'default', 'unit' }
PropNumber.type = 'number'

function PropNumber:constructor(name, args)
  PropNumber.super.constructor(self, name, args)
  args = args or {}
  self.after = args.unit
  self.min = args.min or 0
  self.max = args.max or 127
  self.step = args.step
  self.default = utils.default(args.default, self.min)
end

---Convert a raw encoder value to a prop value.
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

---Return the encoded value.
---@return number
function PropNumber:encodeValue()
  return utils.mapValue(
    self.value,
    self.min,
    self.max,
    Encoders.min,
    Encoders.max
  )
end

---Return a string representation of the value.
---@return string
function PropNumber:formatValue()
  return utils.isInt(self.step) and string.format('%i', self.value)
    or string.format('%.2f', self.value)
end

return PropNumber
