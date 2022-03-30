local utils = require('utils')
local PropBase = require('Prop.PropBase')

---@class PropSwitch : Prop
local PropSwitch = class(PropBase)
PropSwitch.type = 'switch'
PropSwitch.serializeFields = { 'states' }

function PropSwitch:constructor(name, args)
  PropSwitch.super.constructor(self, name, args)
  args = args or {}
  self.states = utils.default(args.state, 2)
  self.default = utils.default(args.default, 1)
end

function PropSwitch:decodeValue(rawValue)
  return math.floor(
    utils.mapValue(rawValue, Encoders.min, Encoders.max, 1, self.states) + 0.5
  )
end

function PropSwitch:encodeValue(value)
  return utils.mapValue(value, 1, self.states, Encoders.min, Encoders.max)
end

function PropSwitch:show(displayIndex)
  self.displayIndex = displayIndex
  Displays.clear(self.displayIndex)
  Displays.write(displayIndex, utils.capitalize(self.name), 1, true)
end

return PropSwitch
