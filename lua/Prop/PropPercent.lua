local utils = require('utils')
local PropNumber = require('Prop.PropNumber')

---@class PropPercent : PropNumber
---@field min number
---@field max number
local PropPercent = class(PropNumber)
PropPercent.type = 'percent'

function PropPercent:constructor(name, args)
  args = args or {}
  args.step = utils.default(args.step, 1)
  args.max = utils.default(args.max, 100)
  -- TODO: use `%` sign when its added to the font.
  args.unit = '%'
  PropPercent.super.constructor(self, name, args)
end

return PropPercent
