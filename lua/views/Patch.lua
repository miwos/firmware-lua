local utils = require('utils')
local View = require('views.View')
local class = require('class')

---@class PatchView : View
local PatchView = class(View)
PatchView.partLeds = { 1, 2, 3 }
PatchView.pageLeds = { 4, 5, 6 }
PatchView.visibleProps = {}

function PatchView:activate()
  self:selectPage(1)
end

function PatchView:showPart(index)
  for i = 1, 3 do
    LEDs.toggle(self.partLeds[i], i == index)
  end
end

function PatchView:showPage()
  for i = 1, 3 do
    LEDs.toggle(self.pageLeds[i], i == self.pageIndex)
  end

  for _, prop in ipairs(self.visibleProps) do
    prop:hide()
  end

  self.visibleProps = {}
  for index = 1, 3 do
    local prop = self:getProp(index)
    if prop then
      prop:show(index)
      self.visibleProps[#self.visibleProps + 1] = prop
    else
      Displays.clear(index)
    end
  end
end

function PatchView:selectPage(index, updateApp)
  self.pageIndex = index

  if updateApp then
    Encoders.selectPage(index)
  end

  self:showPage()
end

---@param encoderIndex number
---@return Prop
function PatchView:getProp(encoderIndex)
  local patch = Patches.activePatch
  if patch and patch.encoders then
    local encoders = patch.encoders[self.pageIndex]
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
    self:selectPage(pageIndex, true)
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
