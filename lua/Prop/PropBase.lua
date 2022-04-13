local class = require('class')
local utils = require('utils')

---@class Prop : Class
---@field value any
---@field default any
---@field instance Module The owner of the prop.
---@field display number The display the prop is rendered on, if visible.
---@field encoder number The encoder the prop is using, if visible.
---@field render function Abstract
---@field encodeValue function Abstract
---@field decodeValue function Abstract
local PropBase = class()
PropBase.serializeFields = {}
PropBase.Views = { Name = 1, Value = 2 }

function PropBase:constructor(name, args)
  self.name = name
  args = args or {}
  self.encoderMin = 0
  self.encoderMax = 50
  self.list = args.list
  self.visible = false
end

---Create a new clone.
---@param moduleInstance Module
---@return Prop
function PropBase:create(moduleInstance)
  local prop = {
    instance = moduleInstance,
    value = utils.default(self.default, 0),
  }
  return setmetatable(prop, { __index = self })
end

---Set the value and optionally emit the corresponding events on the instance
---and/or write the value to the encoder.
---@param writeValue boolean Wether to write the value to the encoder or not. (default = true)
---@param emitEvents boolean Wether to emit events on the instance or not. (default = true)
function PropBase:setValue(value, writeValue, emitEvents)
  writeValue = writeValue == nil and true or writeValue
  emitEvents = emitEvents == nil and true or emitEvents

  if emitEvents then
    self.instance:__emit('prop:beforeChange', self.name, value)
  end

  self.value = value

  if emitEvents then
    self.instance:__emit('prop:change', self.name, value)
    Instances.updateProp(
      self.instance.__id,
      self.name,
      self:serializeValue(value)
    )
  end

  if writeValue and self.visible then
    Encoders.write(self.encoder, self:encodeValue(self.value))
  end
end

function PropBase:serializeValue(value)
  return value
end

function PropBase:deserializeValue(value)
  return value
end

function PropBase:handleEncoderClick()
  self.instance:__emit('prop:click', self.name)
end

function PropBase:handleEncoderChange(rawValue)
  if self.__ignoreEncoderChangeOnce then
    self.__ignoreEncoderChangeOnce = false
    return
  end

  self:setValue(self:decodeValue(rawValue), false)
  self:switchView(self.Views.Value)
  self:switchView(self.Views.Name, 1000)
end

function PropBase:updateEncoderRange()
  Encoders.setRange(self.encoder, self.encoderMin, self.encoderMax)
end

---Start showing the prop an a display.
function PropBase:show()
  self:switchView(self.Views.Name)
  -- Writing to the encoder will trigger an encoder change, but in this case
  -- the prop's value hasn't changed, so we can ignore it.
  self.__ignoreEncoderChangeOnce = true
  self:updateEncoderRange()
  Encoders.write(self.encoder, self:encodeValue(self.value))
end

---Switch to another view (either immediately or after a delay) and re-render.
---@param view number
---@param delay number
function PropBase:switchView(view, delay)
  Timer.cancel(self.__switchViewTimer)
  if not delay then
    self.view = view
    self:update()
  else
    self.__switchViewTimer = Timer.schedule(function()
      self.view = view
      self:update()
    end, Timer.now() + delay)
  end
end

---Re-renderthe prop if visible.
function PropBase:update()
  if self.visible then
    self:render()
  end
end

---Cleanup rendering.
function PropBase:hide()
  Timer.cancel(self.__switchViewTimer)
end

function PropBase:serialize()
  local serialized = {}

  local defaultFields = { 'name', 'type', 'index', 'list', 'default' }
  for _, field in ipairs(defaultFields) do
    serialized[field] = self[field]
  end

  for _, field in ipairs(self.serializeFields) do
    serialized[field] = self[field]
  end

  return serialized
end

return PropBase
