local class = require('class')
local utils = require('utils')

---@class Prop
---@field super table
---@field instance Module
---@field name string
---@field value any
---@field encodeValue function
---@field decodeValue function
---@field getDisplayValue function
---@field onChange function
---@field onClick function
local PropBase = class()

function PropBase:constructor(args)
  self.onChange = args.onChange
  self.onClick = args.onClick
end

function PropBase:getValue()
  return self.value
end

function PropBase:setValue(value, shouldWriteValue)
  -- By default we write the value to the encoder as soon as the
  -- prop changes. in `Prop#setRawvalue()` we deactivate this behaviour, because
  -- the raw value comes from the encoder, so no need to write it again.
  shouldWriteValue = shouldWriteValue == nil and true or shouldWriteValue

  utils.callIfExists(self.onChange, { value })
  self.value = value
  Interface.handlePropChange(self, shouldWriteValue)
  Bridge.sendProp(self.instance.__id, self.name, self.value)
end

function PropBase:getRawValue()
  return self:encodeValue(self.value)
end

function PropBase:setRawValue(rawValue)
  self:setValue(self:decodeValue(rawValue), false)
end

function PropBase:click()
  utils.callIfExists(self.onClick)
end

return PropBase
