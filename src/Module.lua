local utils = require('utils')
local Module = {}

local midiTypeNames = {
  'noteOn',
  'noteOff',
  'controlChange'
}

---Initialize the module.
---@param patch table The patch this module belongs to.
function Module:init(patch)
  self._patch = patch
  self._outputs = {}
end

---Connect an output to the input of another module.
---@param output number The output index.
---@param moduleId number The id of the module to connect to.
---@param input number The input index of the module to connect to.
function Module:connect(output, moduleId, input)
  self._outputs[output] = { moduleId, input }
end

---Return a human readable name for debugging (e.g.: delay1)
---@return string
function Module:_name()
  return self._type .. self._id
end

---Send data to output.
---@param index number The output index.
---@param message table The midi message to send.
function Module:output(index, message)
  local output = self._outputs[index]
  if not output then return end

  local moduleId, input = unpack(output)
  local module = self._patch.modules[moduleId]
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

---Finish unfinished midi notes to prevent midi panic.
function Module:_finishNotes()
end

return Module