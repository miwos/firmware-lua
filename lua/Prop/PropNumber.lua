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

function PropNumber:show(displayIndex)
  self.visible = true
  self.displayIndex = displayIndex

  self:showName()

  -- Writing to the encoder will trigger an encoder change, but in this case
  -- the prop's value hasn't changed, so we can ignore it.
  self.ignoreEncoderChangeOnce = true
  Encoders.write(displayIndex, self:encodeValue())
end

function PropNumber:showName()
  Displays.clear(self.displayIndex)
  self:showProgressBar()
  Displays.write(self.displayIndex, utils.capitalize(self.name), 1, true)
end

function PropNumber:showProgressBar()
  utils.drawProgressBar(
    self.displayIndex,
    utils.mapValue(self.value, self.min, self.max, 0, 1)
  )
end

function PropNumber:handleEncoderChange(rawValue)
  if self.ignoreEncoderChangeOnce then
    self.ignoreEncoderChangeOnce = false
    return
  end

  self:__setValue(self:decodeValue(rawValue), false)

  Displays.clear(self.displayIndex)
  self:showProgressBar()
  local prefix = self.before and (' ' .. self.after) or ''
  local suffix = self.after and (' ' .. self.after) or ''
  Displays.write(
    self.displayIndex,
    prefix .. self:formatValue() .. suffix,
    1,
    true
  )

  self:showNameTimeout(1000)
end

return PropNumber
