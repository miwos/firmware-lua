local class = require('class')

---@class Prop : Class
---@field name string Will be set in `Module#defineProps()`
---@field index number Will be set in `Module#defineProps()`
---@field before string
---@field after string
---@field encodeValue function
---@field decodeValue function
---@field getDisplayValue function
---@field serialize function
---@field default number
local PropBase = class()

PropBase.serializeFields = {}

function PropBase:constructor(name, args)
  self.name = name
  args = args or {}
  self.show = args.show == nil and true or args.show
  self.before = args.before
  self.after = args.after
end

---@param instance Module
---@param value number
---@param writeValue boolean default = true
---@param initial boolean default = false
function PropBase:__setValue(instance, value, writeValue, initial)
  writeValue = writeValue == nil and true or writeValue

  if not initial then
    instance:__emit('prop:beforeChange', self.name, value)
  end

  instance.props.__values[self.name] = value

  if not initial then
    instance:__emit('prop:change', self.name, value)
    Instances.updateProp(instance.__id, self.name, value)
  end

  Interface.handlePropChange(instance, self, value, writeValue)
end

function PropBase:formatValue(value)
  return value
end

function PropBase:getDisplayValue(value)
  return string.format(
    '%s%s%s',
    self.before or '',
    self:formatValue(value),
    self.after or ''
  )
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
