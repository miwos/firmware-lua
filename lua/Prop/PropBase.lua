local class = require('class')

---@class Prop : Class
---@field name string Will be set in `Module#defineProps()`
---@field encodeValue function
---@field decodeValue function
---@field getDisplayValue function
---@field serialize function
---@field default number
local PropBase = class()

---@param instance Module
---@param value number
---@param shouldWriteValue boolean
function PropBase:__setValue(instance, value, shouldWriteValue)
  shouldWriteValue = shouldWriteValue == nil and true or shouldWriteValue

  instance:__emit('prop:beforeChange', self.name, value)
  instance.props.__values[self.name] = value
  instance:__emit('prop:change', self.name, value)

  Bridge.sendProp(instance.__id, self.name, value)
  Interface.handlePropChange(instance, self, value, shouldWriteValue)
end

return PropBase
