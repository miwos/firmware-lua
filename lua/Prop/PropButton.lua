local utils = require('utils')
local PropBase = require('Prop.PropBase')

---@class PropButton : Prop
local PropButton = class(PropBase)
PropButton.type = 'button'
PropButton.valueType = 'boolean'
PropButton.serializeFields = { 'toggle' }

function PropButton:constructor(name, args)
  args = args or {}
  PropButton.super.constructor(self, name, args)
  self.toggle = args.toggle
  self.default = utils.default(args.default, false)
end

function PropButton:show()
  self:render()
end

function PropButton:setValue(value, _, emitEvents)
  -- True or false might be serialized to 1 and 0.
  if value == 1 then
    value = true
  elseif value == 0 then
    value = false
  end

  PropButton.super.setValue(self, value, false, emitEvents)
end

function PropButton:handleEncoderClick()
  if self.toggle then
    self:setValue(not self.value)
  end
  self.instance:__emit('prop:click', self.name)
  self.instance:__emit('prop:change', self.name, self.value)
end

-- Do nothing.
function PropButton:handleEncoderChange() end

function PropButton:render()
  Displays.clear(self.display)

  local color = Displays.Colors.White
  local width = 8
  local height = self.value and 5 or 8
  local x = 2
  local y = Displays.height - height
  Displays.drawRect(self.display, x, y, width, height, color, true)

  Displays.drawLine(
    self.display,
    0,
    Displays.height - 1,
    x + width + 2,
    Displays.height - 1,
    color
  )

  Displays.write(self.display, utils.capitalize(self.name), color, true)
end

return PropButton
