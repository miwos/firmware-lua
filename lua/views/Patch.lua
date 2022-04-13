local utils = require('utils')
local View = require('views.View')
local class = require('class')

---@class PatchView : View
local PatchView = class(View)
PatchView.page = 1
PatchView.part = 1
PatchView.partLeds = { 1, 2, 3 }
PatchView.pageLeds = { 4, 5, 6 }
PatchView.visibleProps = {}

function PatchView:activate()
  self:update('page', 1)
  Encoders.selectPage(1)
end

function PatchView:update(key, value)
  self[key] = value
  if self.active then
    if key == 'patch' or key == 'page' then
      self:showPage()
    end
    self:render()
  end
end

function PatchView:render()
  for i = 1, 3 do
    LEDs.toggle(self.partLeds[i], i == self.part)
    LEDs.toggle(self.pageLeds[i], i == self.page)
  end
end

function PatchView:showPage()
  for _, prop in ipairs(self.visibleProps) do
    utils.callIfExists(prop.hide, { prop })
    prop.encoder = nil
    prop.display = nil
    prop.visible = false
  end

  self.visibleProps = {}
  for index = 1, 3 do
    local prop = self:getProp(index)
    if prop then
      prop.encoder = index
      prop.display = index
      prop.visible = true
      prop:show()
      self.visibleProps[#self.visibleProps + 1] = prop
    else
      Displays.clear(index, true)
    end
  end
end

---@param encoderIndex number
---@return Prop
function PatchView:getProp(encoderIndex)
  local patch = Patches.activePatch
  if patch and patch.encoders then
    local encoders = patch.encoders[self.page]
    local encoder = encoders[encoderIndex]
    if encoder then
      local instanceId, propName = unpack(encoder)
      return Instances.getProp(instanceId, propName)
    end
  end
end

function PatchView:handleButtonClick(index)
  if index <= 3 then
    Patches.selectPart(index)
    App.selectPart(index)
  else
    local pageIndex = index - 3 -- button4 => page1, button5 => page2, ...
    self:update('page', pageIndex)
    Encoders.selectPage(pageIndex)
  end
end

function PatchView:handleEncoderChange(index, value)
  local prop = self:getProp(index)
  if prop then
    prop:handleEncoderChange(value)
  end
end

function PatchView:handleEncoderClick(index)
  local prop = self:getProp(index)
  if prop then
    prop:handleEncoderClick()
  end
end

return PatchView
