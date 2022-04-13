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
    utils.mapValue(rawValue, self.encoderMin, self.encoderMax, 1, self.states)
      + 0.5
  )
end

function PropSwitch:encodeValue(value)
  return utils.mapValue(value, 1, self.states, self.encoderMin, self.encoderMax)
end

function PropSwitch:render()
  Displays.clear(self.display)

  local text = ''
  if self.view == self.Views.Name then
    -- Name
    text = utils.capitalize(self.name)
  else
    -- Value
    text = (self.value == 2) and 'On' or 'Off'
  end

  -- Render text and update display
  Displays.write(self.display, text, Displays.Colors.White, true)
end

return PropSwitch
