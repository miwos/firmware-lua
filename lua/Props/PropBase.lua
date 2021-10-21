local class = require('class')
local utils = require('utils')

---@class Prop
---@field module Module
---@field name string
---@field value any
---@field encodeValue function
---@field decodeValue function
---@field onChange function
local PropBase = class()

function PropBase:getValue()
  return self.value
end

function PropBase:setValue(value, writeValue)
  -- By default we write the value to the encoder as soon as the
  -- prop changes. in `Prop#setRawvalue()` we deactivate this behaviour, because
  -- the raw value comes from the encoder, so no need to write it again.
  writeValue = writeValue == nil and true or writeValue

  self.value = value
  utils.callIfExists(self.onChange, { value })
  Interface:propChange(self, writeValue)
  Bridge.sendPropChange(self.module._id, self.name, self.value)
end

function PropBase:getRawValue()
  return self:encodeValue(self.value)
end

function PropBase:setRawValue(rawValue)
  self:setValue(self:decodeValue(rawValue), false)
end

return PropBase
