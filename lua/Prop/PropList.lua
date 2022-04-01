local PropBase = require('Prop.PropBase')
local utils = require('utils')

---@class PropList: Prop
local PropList = class(PropBase)
PropList.serializeFields = {}
PropList.type = 'list'
PropList.Views = { Name = 1, Value = 2, Edit = 3 }

function PropList:constructor(name, args)
  PropList.super.constructor(self, name, args)
  args = args or {}
  self.length = args.length
  self.selected = utils.default(args.selected, 1)
  self.default = utils.default(args.default, {})
  self.customFormat = args.format

  self.highlighted = nil
  self.view = PropList.Views.Name
end

function PropList:setValue(value)
  assert(type(value) == 'table', 'value must be a table')
  self.value = value
end

function PropList:setListValue(index, value)
  self.value[index] = value
end

function PropList:formatValue(value)
  return self.customFormat and self.customFormat(value) or tostring(value)
end

function PropList:handleEncoderChange(value)
  if self.__ignoreEncoderChangeOnce then
    self.__ignoreEncoderChangeOnce = false
    return
  end

  self.selected = math.floor(
    utils.mapValue(value, Encoders.min, Encoders.max, 1, self.length)
  )

  if self.view ~= self.Views.Edit then
    self:switchView(self.Views.Value)
    self:switchView(self.Views.Name, 5000)
  end
end

function PropList:handleEncoderClick()
  self.instance:__emit('prop:click', self.name)
end

function PropList:show()
  self:switchView(self.Views.Name)
  -- Writing to the encoder will trigger an encoder change, but in this case
  -- the prop's value hasn't changed, so we can ignore it.
  self.__ignoreEncoderChangeOnce = true
  Encoders.write(
    self.encoder,
    utils.mapValue(self.selected, 1, self.length, Encoders.min, Encoders.max)
  )
end

function PropList:render()
  Displays.clear(self.display)

  local navigationIndex = self.selected
  local text = ''

  if self.view == PropList.Views.Name then
    -- Name
    navigationIndex = self.highlighted and self.highlighted or self.selected
    text = utils.capitalize(self.name)
  elseif self.view == PropList.Views.Value then
    -- Currently selected value
    text = self:formatValue(self.value[self.selected])
  elseif self.view == PropList.Views.Edit then
    -- Edit
    text = 'Rec...'
  end

  -- Render navigation
  for i = 1, self.length do
    local empty = self.value[i] == nil
    local active = i == navigationIndex
    local width = 8
    local half = width / 2
    local radius = (active or not empty) and half or 1
    local x = (width + half) * (i - 1) + half
    local y = Displays.height - 1 - half

    Displays.drawCircle(self.display, x, y, radius, 1, active or empty)
  end

  -- Render text and update display
  Displays.write(self.display, text, Displays.Colors.White, true)
end

return PropList
