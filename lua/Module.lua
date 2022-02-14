local class = require('class')
local Props = require('Props')
local utils = require('utils')

---@class Module : Class
---@field init function
---@field destroy function
---@field __id number
---@field __type string Will be set in `Miwos#createModule()`
---@field __events string Will be set in `Miwos#createModule()`
local Module = class()

Module.__hmrKeep = { 'props' }
-- Module.__events = {}

function Module:on(event, callback)
  self.__events[event] = callback
end

function Module:constructor()
  self.props = {}
  self._outputs = {}
  self._unfinishedNotes = {}
  utils.callIfExists(self.init, { self })
end

---Define the properties that are available on the module.
---@param props table<string, Prop>
function Module:defineProps(props)
  self.props = Props(self, props)
end

---Connect an output to the input of another Module.
---@param output number The output index.
---@param moduleId number The id of the module to connect to.
---@param moduleInput number The input index of the module to connect to.
function Module:__connect(output, moduleId, moduleInput)
  self._outputs[output] = self._outputs[output] or {}
  table.insert(self._outputs[output], { moduleId, moduleInput })
end

---Send data to all inputs connected to the output.
---@param index number The output index.
---@param message MidiMessage The midi message to send.
function Module:output(index, message)
  Bridge.sendOutput(self.__id, index, message)

  local isNoteOn = message:is(Midi.NoteOn)
  local isNoteOff = message:is(Midi.NoteOff)
  if isNoteOn or isNoteOff then
    ---@type MidiNoteOn|MidiNoteOff
    local note = message
    local noteId = Midi.getNoteId(note.note, note.channel)
    self._unfinishedNotes[index] = self._unfinishedNotes[index] or {}
    self._unfinishedNotes[index][noteId] = note:is(Midi.NoteOn) and true or nil
  end

  self:__handleOutput(index, message)
end

function Module:__handleOutput(index, message)
  if self._outputs[index] then
    for _, input in pairs(self._outputs[index]) do
      local inputId, inputIndex = unpack(input)
      local inputNode = Modules.get(inputId)

      if inputNode then
        self:__sendOutputToInput(message, inputNode, inputIndex)
      end
    end
  end
end

---@param message MidiMessage
---@param module Module
---@param index number
function Module:__sendOutputToInput(message, module, index)
  Bridge.sendInput(module.__id, index, message)

  local payload = { module, message }
  local numberedInput = 'input' .. index

  utils.callIfExists(module.__events['input:*'], payload)
  utils.callIfExists(module.__events['input:' .. message.name], payload)

  utils.callIfExists(module.__events[numberedInput .. ':*'], payload)
  utils.callIfExists(
    module.__events[numberedInput .. ':' .. message.name],
    payload
  )
end

---Finish unfinished midi notes to prevent midi panic.
---@param output? number
function Module:__finishNotes(output)
  for index, noteIds in pairs(self._unfinishedNotes) do
    if not output or index == output then
      for noteId in pairs(noteIds) do
        local note, channel = Midi.parseNoteId(noteId)
        self:__handleOutput(index, Midi.NoteOff(note, 0, channel))
      end
    end
  end
end

---Save the module instance's state. Only properties defined in `__hmrKeep` are
---saved. Note: unlike `__hmrAccept()` and `__hmrDispose()` this function is
---called for each instance (see `Patch#updateModule()`).
---@return table - the state
function Module:__saveState()
  local state = {}
  for _, property in pairs(self.__hmrKeep) do
    state[property] = self[property]
  end
  return state
end

---Apply the module instance's state. See `Module#__saveState()`.
---@param state table
function Module:__applyState(state)
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
  return { type = OldModule.__type }
end

---Update all module instances after a HMR.
---@param data table
---@param module Module
function Module.__hmrAccept(data, module)
  if data and Patches.activePatch then
    Patches.activePatch:updateModule(data.type, module)
  end
end

---Decline a HMR if this file (the base class) is modified instead of an actual
---module.
---@return boolean - Wether or not to decline the HMR.
function Module.__hmrDecline(_, module)
  -- Only actual modules that inherit from Module have a `__type`.
  return not module.__type
end

---Clear all connections.
function Module:__clearConnections()
  self._outputs = {}
end

function Module:__destroy()
  self:__finishNotes()
  utils.callIfExists(self.destroy, { self })
end

return Module
