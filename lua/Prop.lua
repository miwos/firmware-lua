local class = require('class')
local utils = require('utils')

Prop = {}

---@class Prop
---@field module Module
---@field name string
---@field value any
---@field encodeValue function
---@field decodeValue function
---@field onChange function
local PropBase = class()

function PropBase:getValue()
  return self.value
end

function PropBase:setValue(value)
  self.value = value
  utils.callIfExists(self.onChange, { value })
  Interface:propChange(self)
  Bridge.sendPropChange(self.module._id, self.name, self.value)
end

function PropBase:getRawValue()
  return self:encodeValue(self.value)
end

function PropBase:setRawValue(rawValue)
  self:setValue(self:decodeValue(rawValue))
end

---@class PropNumber : Prop
---@field min number
---@field max number
---@field step number|nil
Prop.Number = class(PropBase)

function Prop.Number:constructor(args)
  self.min = args.min or 0
  self.max = args.max or 127
  self.step = args.step
  self.value = args.default or self.min
  self.onChange = args.onChange
end

---Convert a raw encoder value to a scaled prop value.
---@param rawValue number
---@return number
function Prop.Number:decodeValue(rawValue)
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
---@param value any
---@return any
function Prop.Number:encodeValue(value)
  return utils.mapValue(value, self.min, self.max, Encoders.min, Encoders.max)
end

---Return a string representation of the value.
---@return string
function Prop.Number:getDisplayValue()
  return utils.isInt(self.step) and tostring(self.value)
    or string.format('%.2f', self.value)
end
