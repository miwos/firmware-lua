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
---@field handleClick function
---@field default number
---@field instance Module
---@field value number
local PropBase = class()

PropBase.serializeFields = {}

function PropBase:constructor(name, args)
  self.name = name
  args = args or {}
  self.show = utils.default(args.show, true)
  self.before = args.before
  self.after = args.after
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

  Interface.handlePropChange(self.instance, self, value, writeValue)
end

---@param rawValue number
function PropBase:__setRawValue(rawValue)
  self:__setValue(self:decodeValue(rawValue), false)
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
