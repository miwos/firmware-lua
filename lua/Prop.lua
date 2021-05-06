local class = require 'class'

---@class PropBase
local PropBase = class()

---@class PropNumber : PropBase
local PropNumber = class(PropBase)

---@param value number
---@param min? number
---@param max? number
function PropNumber:init(value, min, max)
  
end

---@class PropBoolean : PropBase
local PropBoolean = class(PropBase)

Prop = {}

---@param arg table | number
---@overload fun(value: number)
---@return PropNumber
function Prop.Number(arg)
  return type(arg) == "number" 
    and PropNumber(arg) 
    or PropNumber(arg.value, arg.min, arg.max)
end

---@param value boolean
function Prop.Boolean(value) return PropBoolean(value) end