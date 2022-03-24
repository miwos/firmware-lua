local PropBase = require('Prop.PropBase')
local utils = require('utils')

---@class PropList: Prop
local PropList = class(PropBase)

PropList.serializeFields = {}
PropList.type = 'list'

function PropList:constructor(name, args)
  PropList.super.constructor(self, name, args)
  args = args or {}
  self.length = args.length
  self.values = utils.default(args.values, {})
  self.selected = utils.default(args.selected, 1)
  self.default = utils.default(args.default, 0)
end

return PropList
