local class = require('class')
local utils = require('utils')

---@class Prop : Class
---@field name string Will be set in `Module#defineProps()`
---@field index number Will be set in `Module#defineProps()`
---@field before string
---@field after string
---@field encodeValue function
---@field decodeValue function
---@field displayValue function
---@field showName function
---@field serialize function
---@field handleEncoderClick function
---@field handleEncoderChange function
---@field default number
---@field instance Module
---@field value number
local PropBase = class()

PropBase.serializeFields = {}
PropBase.Views = { Name = 1, Value = 2 }

function PropBase:constructor(name, args)
  self.name = name
  args = args or {}
  self.before = args.before
  self.after = args.after
  self.visible = false
  self.displayIndex = nil
  self.list = args.list
end

function PropBase:update()
  if self.visible then
    self:render()
  end
end

function PropBase:show()
  self:switchView(self.Views.Name)
  -- Writing to the encoder will trigger an encoder change, but in this case
  -- the prop's value hasn't changed, so we can ignore it.
  self.ignoreEncoderChangeOnce = true
  Encoders.write(self.encoder, self:encodeValue(self.value))
end

function PropBase:create(moduleInstance)
  local prop = {
    instance = moduleInstance,
    value = utils.default(self.default, 0),
  }
  return setmetatable(prop, { __index = self })
end

---@param value number
---@param writeValue boolean default = true
---@param initial boolean default = false
function PropBase:setValue(value, writeValue, initial)
  writeValue = writeValue == nil and true or writeValue

  if not initial then
    self.instance:__emit('prop:beforeChange', self.name, value)
  end

  self.value = value

  if not initial then
    self.instance:__emit('prop:change', self.name, value)
    Instances.updateProp(self.instance.__id, self.name, value)
  end

  if writeValue and self.visible then
    Encoders.write(self.displayIndex, self:encodeValue(self.value))
  end
end

function PropBase:handleEncoderClick()
  self.instance:__emit('prop:click', self.name)
end

function PropBase:handleEncoderChange(rawValue)
  if self.ignoreEncoderChangeOnce then
    self.ignoreEncoderChangeOnce = false
    return
  end

  self:setValue(self:decodeValue(rawValue), false)
  self:switchView(self.Views.Value)
  self:switchView(self.Views.Name, 1000)
end

function PropBase:switchView(view, delay)
  if not delay then
    self.view = view
    self:update()
  else
    Timer.cancel(self.switchViewTimer)
    self.switchViewTimer = Timer.schedule(function()
      self.view = view
      self:update()
    end, Timer.now() + delay)
  end
end

function PropBase:showNameTimeout(time)
  Timer.cancel(self.showNameTimer)
  self.showNameTimer = Timer.schedule(function()
    self:showName()
  end, Timer.now() + time)
end

function PropBase:formatValue(value)
  return tostring(value)
end

function PropBase:displayValue()
  return string.format(
    '%s%s%s',
    self.before or '',
    self:formatValue(self.value),
    self.after or ''
  )
end

function PropBase:hide()
  self.visible = false
  Timer.cancel(self.showNameTimer)
end

function PropBase:serialize()
  local serialized = {}

  local defaultFields = {
    'name',
    'type',
    'index',
    'list',
    'before',
    'after',
    'default',
  }
  for _, field in ipairs(defaultFields) do
    serialized[field] = self[field]
  end

  for _, field in ipairs(self.serializeFields) do
    serialized[field] = self[field]
  end

  return serialized
end

return PropBase
