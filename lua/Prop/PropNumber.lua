local utils = require('utils')
local PropBase = require('Prop.PropBase')

---@class PropNumber : Prop
---@field min number
---@field max number
---@field step number|nil
local PropNumber = class(PropBase)

PropNumber.serializeFields = { 'min', 'max', 'setp', 'default', 'unit' }
PropNumber.type = 'number'

local function ease(x)
  return 1.383493
    + (0.00001915815 - 1.383493) / (1 + (x / 0.3963062) ^ 1.035488)
end

function PropNumber:constructor(name, args)
  PropNumber.super.constructor(self, name, args)
  args = args or {}
  self.before = args.before
  self.unit = args.unit
  self.min = args.min or 0
  self.max = args.max or 127
  self.step = args.step
  self.scale = args.scale
  self.default = utils.default(args.default, self.min)
  self.encoderMax = math.floor(ease((self.max - self.min) / 127) * 127)
end

function PropNumber:encodeValue(value)
  return utils.mapValue(
    value,
    self.min,
    self.max,
    self.encoderMin,
    self.encoderMax
  )
end

function PropNumber:decodeValue(rawValue)
  local scaledValue = utils.mapValue(
    rawValue,
    self.encoderMin,
    self.encoderMax,
    self.min,
    self.max
  )

  return self.step and math.ceil(scaledValue / self.step) * self.step
    or scaledValue
end

function PropNumber:formatValue(value)
  return utils.isInt(self.step) and string.format('%i', value)
    or string.format('%.2f', value)
end

function PropNumber:render()
  Displays.clear(self.display)

  local text = ''
  if self.view == self.Views.Name then
    -- Name
    text = utils.capitalize(self.name)
  else
    -- Value
    text = (self.before or '')
      .. self:formatValue(self.value)
      .. (self.unit or '')
  end

  -- Render progress scale or bar
  local min = self.min > 0 and self.min - 1 or self.min
  local normalizedValue = utils.mapValue(self.value, min, self.max, 0, 1)

  utils.renderProgressBar(
    self.display,
    normalizedValue,
    self.scale and self.max
  )

  -- Render text and update display
  Displays.write(self.display, text, Displays.Colors.White, true)
end

return PropNumber
