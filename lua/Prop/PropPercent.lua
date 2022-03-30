local utils = require('utils')
local PropNumber = require('Prop.PropNumber')

---@class PropPercent : PropNumber
---@field min number
---@field max number
local PropPercent = class(PropNumber)
PropPercent.type = 'percent'

function PropPercent:constructor(name, args)
  args = args or {}
  args.step = utils.default(args.step, 0.01)
  args.max = utils.default(args.max, 1)
  -- TODO: use `%` sign when its added to the font.
  args.unit = ''
  PropPercent.super.constructor(self, name, args)
end

---@return string
function PropPercent:formatValue()
  return utils.isInt(self.step * 100) and string.format('%i', self.value * 100)
    or string.format('%.2f', self.value * 100)
end

return PropPercent
