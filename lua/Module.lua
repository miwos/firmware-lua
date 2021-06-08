local utils = require('utils')
local class = require('class')

---@class Module
local Module = class()
Module.__hmrKeep = {}
Module._props = {}

local midiTypeNames = {
  'noteOn',
  'noteOff',
  'controlChange'
}

---Initialize the module.
function Module:init()
  self._outputs = {}

  -- Will be set in `Patch#_initModules()`
  self._patch = nil
  self._id = nil
  
  -- Will be set in `Miwos#createModule()`
  self._type = nil

  -- Unitialize default values.
  self.props = {}
  for key, prop in pairs(self._props) do
    self.props[key] = prop.default
  end
end

function Module:defineProps(props)
  self._props = props
end

---Connect an output to the input of another module.
---@param output number The output index.
---@param moduleId number The id of the module to connect to.
---@param input number The input index of the module to connect to.
function Module:connect(output, moduleId, input)
  self._outputs[output] = { moduleId, input }
end

---Send data to output.
---@param index number The output index.
---@param message table The midi message to send.
function Module:output(index, message)
  local output = self._outputs[index]
  if not output then return end

  local moduleId, input = unpack(output)
  local module = moduleId == 0 and Miwos.output or self._patch.modules[moduleId]
  if not module then return end
  
  -- Call a midi-type agnostic function like `input1()`.
  local numberedInput = 'input' .. input
  utils.callIfExists(module[numberedInput], { module, message })

  -- Call a midi-type aware function like `input1_noteOn()`.
  local midiType =  midiTypeNames[message.type]
  utils.callIfExists(module[numberedInput .. '_' .. midiType], { module, message })

  -- Call a generic `input()` function that handles any input.
  utils.callIfExists(module.input, { module, input, message })
end

---Update a prop.
---@param name string - The prop name.
---@param value number - The raw encoder value.
function Module:updateProp(name, value)
  local prop = self._props[name]
  if prop then
    local oldValue = self.props[name]
    self.props[name] = value
    utils.callIfExists(self['propChange_' .. name], { self, value, oldValue })
  else
    Log.warning(string.format("No prop '%s' on module %s", name, self._type))
  end
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
    if state[property] ~= nil then self[property] = state[property] end
  end
end

function Module.__hmrDispose(OldModule)
  -- The type is set by `Miwos.createModule()` therefore we have to transfer it.
  return { type = OldModule._type }
end

function Module.__hmrAccept(data, module)
  if data then Miwos.activePatch:updateModule(data.type, module) end
end

function Module:destroy() end

return Module