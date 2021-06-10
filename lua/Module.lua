local class = require('class')
local Node = require('Node')
local Props = require('Props')
local utils = require('utils')

---@class Module : Node
-- Will both be set in `Patch#_initModules()`
---@field _patch Patch
---@field _id Patch
-- Will be set in `Miwos#createModule()`
---@field _type string
---@field destroy function
---@field defineProps function
---@field props table

local Module = class(Node)

---See `Module#_applyState` and `Module#_saveState`.
Module.__hmrKeep = {}

function Module:construct()
  Module.super.construct(self)
  self.props = {}
  utils.callIfExists(self.init, { self })
end

---Define the properties that are available on the module.
---@param props table<string, Prop>
function Module:defineProps(props)
  self.props = Props(self, props)
end

---Return a human readable name for debugging (e.g.: delay1)
---@return string
function Module:_name()
  return self._type .. self._id
end

---Finish unfinished midi notes to prevent midi panic.
function Module:_finishNotes()
end

---Save the module instance's state. Only properties defined in `__hmrKeep` are
---saved. Note: unlike `__hmrAccept()` and `__hmrDispose()` this function is
---called for each instance (see `Patch#updateModule()`).
---@return table - the state
function Module:_saveState()
  local state = {}
  for _, property in pairs(self.__hmrKeep) do
    state[property] = self[property]
  end
  return state
end

---Apply the module instance's state. See `Module#_saveState()`.
---@param state table
function Module:_applyState(state)
  for _, property in pairs(self.__hmrKeep) do
    if state[property] ~= nil then
      self[property] = state[property]
    end
  end
end

---Save the old module's type so we can restore it after a HMR.
---@param OldModule Module
---@return table
function Module.__hmrDispose(OldModule)
  return { type = OldModule._type }
end

---Update all module instances after a HMR.
---@param data table
---@param module Module
function Module.__hmrAccept(data, module)
  if data and Miwos.activePatch then
    Miwos.activePatch:updateModule(data.type, module)
  end
end

return Module
