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

function PropNumber:encodeValue(value)
  return utils.mapValue(value, self.min, self.max, Encoders.min, Encoders.max)
end

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
    local prefix = self.before and (' ' .. self.after) or ''
    local suffix = self.after and (' ' .. self.after) or ''
    text = prefix .. self:formatValue(self.value) .. suffix
  end

  -- Render progress bar
  utils.renderProgressBar(
    self.display,
    utils.mapValue(self.value, self.min, self.max, 0, 1)
  )

  -- Render text and update display
  Displays.write(self.display, text, Displays.Colors.White, true)
end

return PropNumber
