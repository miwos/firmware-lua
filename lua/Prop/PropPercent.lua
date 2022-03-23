local utils = require('utils')
local PropNumber = require('Prop.PropNumber')

---@class PropPercent : PropNumber
---@field min number
---@field max number
local PropPercent = class(PropNumber)
PropPercent.type = 'percent'

function PropPercent:constructor(name, args)
  args = args or {}
  args.step = args.step == nil and 0.01 or args.step
  args.max = args.max == nil and 1 or args.max
  args.unit = '%'
  PropPercent.super.constructor(self, name, args)
end

---Return a string representation of the value.
---@param value number
---@return string
function PropPercent:formatValue(value)
  return utils.isInt(self.step * 100) and string.format('%i', value * 100)
    or string.format('%.2f', value * 100)
end

return PropPercent
