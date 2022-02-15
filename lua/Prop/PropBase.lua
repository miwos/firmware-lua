local class = require('class')

---@class Prop
---@field name string Will be set in `Module#defineProps()`
---@field encodeValue function
---@field decodeValue function
---@field getDisplayValue function
local PropBase = class()

function PropBase:__setValue(instance, value, shouldWriteValue)
  shouldWriteValue = shouldWriteValue == nil and true or shouldWriteValue

  instance:__emit('prop:beforeChange', self.name, value)
  instance.props.__values[self.name] = value
  instance:__emit('prop:change', self.name, value)
  Interface.handlePropChange(instance, self, value, shouldWriteValue)
end

return PropBase
