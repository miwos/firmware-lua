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
  self.selected = utils.default(args.selected, 1)
  self.default = utils.default(args.default, {})
  self.customFormat = args.format
  self.showingValue = false
end

function PropList:__setValue(value)
  assert(type(value) == 'table', 'value must be a table')
  self.value = value
end

function PropList:setCurrentValue(value)
  self.value[self.selected] = value
  if self.visible then
    self:showCurrentValue()
  end
end

function PropList:handleEncoderChange(value)
  if self.ignoreEncoderChangeOnce then
    self.ignoreEncoderChangeOnce = false
    return
  end

  self.selected = math.floor(
    utils.mapValue(value, Encoders.min, Encoders.max, 1, self.length)
  )
  self:showCurrentValue()
  self:showNameTimeout(2000)
end

function PropList:handleEncoderClick()
  self.instance:__emit('prop:click', self.name)
  Timer.cancel(self.showNameTimer)
end

function PropList:formatValue()
  local value = self.value[self.selected]
  return self.customFormat and self.customFormat(value) or tostring(value)
end

function PropList:show(displayIndex)
  self.visible = true
  self.displayIndex = displayIndex

  self:showName()

  -- Writing to the encoder will trigger an encoder change, but in this case
  -- the prop's value hasn't changed, so we can ignore it.
  self.ignoreEncoderChangeOnce = true
  Encoders.write(
    displayIndex,
    utils.mapValue(self.selected, 1, self.length, Encoders.min, Encoders.max)
  )
end

function PropList:showHighlight(index)
  if not self.showingValue == true then
    self:showName(index)
  end
end

function PropList:showName(index)
  self.showingValue = false
  Displays.clear(self.displayIndex)
  self:showNavigation(index)
  Displays.write(self.displayIndex, utils.capitalize(self.name), 1, true)
end

function PropList:showArm(text)
  local state = false

  local function update()
    state = not state
    Displays.clear(self.displayIndex, false)
    self:showNavigation()
    if state then
      Displays.write(self.displayIndex, text, 1, false)
    end
    Displays.display(self.displayIndex)
  end

  self.armTimer = Timer.interval(update, 500)
  update()
end

function PropList:hideArm()
  Timer.cancel(self.armTimer)
end

function PropList:showNavigation(active)
  if not self.visible then
    return
  end

  active = active == nil and self.selected or active

  for i = 1, self.length do
    local radius = 4
    local x = (radius * 2 + 4) * (i - 1) + radius
    local y = Displays.height - 1 - radius
    local fill = i == active
    Displays.drawCircle(self.displayIndex, x, y, radius, 1, fill, false)
  end
end

function PropList:showCurrentValue()
  self.showingValue = true
  Displays.clear(self.displayIndex)
  self:showNavigation(self.selected)
  Displays.write(self.displayIndex, self:formatValue(), 1, true)
end

return PropList
