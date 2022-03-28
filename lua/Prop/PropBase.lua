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
---@field serialize function
---@field handleEncoderClick function
---@field handleEncoderChange function
---@field default number
---@field instance Module
---@field value number
local PropBase = class()

PropBase.serializeFields = {}

function PropBase:constructor(name, args)
  self.name = name
  args = args or {}
  self.before = args.before
  self.after = args.after
  self.visible = false
  self.displayIndex = nil
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
function PropBase:__setValue(value, writeValue, initial)
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
    Encoders.write(self.displayIndex, self:encodeValue())
  end
end

function PropBase:handleEncoderChange(rawValue)
  if self.ignoreEncoderChangeOnce then
    self.ignoreEncoderChangeOnce = false
    return
  end

  self:__setValue(self:decodeValue(rawValue), false)
  Displays.write(self.displayIndex, self:formatValue())

  Timer.cancel(self.timerId)
  self.timerId = Timer.schedule(function()
    Displays.write(self.displayIndex, utils.capitalize(self.name))
  end, Timer.now() + 1000)
end

function PropBase:formatValue()
  return self.value
end

function PropBase:displayValue()
  return string.format(
    '%s%s%s',
    self.before or '',
    self:formatValue(),
    self.after or ''
  )
end

function PropBase:show(displayIndex)
  self.visible = true
  self.displayIndex = displayIndex

  Displays.write(displayIndex, utils.capitalize(self.name))

  -- Writing to the encoder will trigger an encoder change, but in this case
  -- the prop's value hasn't changed, so we can ignore it.
  self.ignoreEncoderChangeOnce = true
  Encoders.write(displayIndex, self:encodeValue())
end

function PropBase:hide()
  self.visible = false
  Timer.cancel(self.timerId)
end

function PropBase:serialize()
  local serialized = {}

  local defaultFields = { 'name', 'type', 'index', 'show', 'before', 'after' }
  for _, field in ipairs(defaultFields) do
    serialized[field] = self[field]
  end

  for _, field in ipairs(self.serializeFields) do
    serialized[field] = self[field]
  end

  return serialized
end

return PropBase
