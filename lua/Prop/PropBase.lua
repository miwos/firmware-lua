local class = require('class')

---@class Prop : Class
---@field name string Will be set in `Module#defineProps()`
---@field index number Will be set in `Module#defineProps()`
---@field encodeValue function
---@field decodeValue function
---@field getDisplayValue function
---@field serialize function
---@field default number
local PropBase = class()

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

return PropBase
