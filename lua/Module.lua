local class = require('class')
local Props = require('Props')
local utils = require('utils')

---@class Module : Class
---@field init function
---@field destroy function
---@field __id number Will be set in `Patch:_createMissingInstances()`
---@field __type string Will be set in `Miwos#createModule()`
---@field __events string Will be set in `Miwos#createModule()`
local Module = class()

Module.__hmrKeep = { 'props' }

function Module:constructor()
  self.__outputs = {}
  self.__unfinishedNotes = {}
  self.props = self:__createPropsProxy()
  utils.callIfExists(self.init, { self })
end

function Module:__createPropsProxy()
  local mt = {}
  local instance = self

  function mt:__newindex(key, value)
    self.__values[key] = value
    instance.__props[key]:__setValue(self, value, true)
  end

  function mt:__index(key)
    return self.__values[key]
  end

  return setmetatable({ __values = {} }, mt)
end

---Define the properties that are available on the module.
---@param props table<string, Prop>
function Module:defineProps(props)
  for name, prop in pairs(props) do
    prop.name = name
  end
  self.__props = props
end

function Module:on(event, callback)
  self.__events[event] = callback
end

function Module:__emit(event, ...)
  utils.callIfExists(self.__events[event], { self, ... })
end

---Connect an output to the input of another Module.
---@param output number The output index.
---@param moduleId number The id of the module to connect to.
---@param moduleInput number The input index of the module to connect to.
function Module:__connect(output, moduleId, moduleInput)
  self.__outputs[output] = self.__outputs[output] or {}
  table.insert(self.__outputs[output], { moduleId, moduleInput })
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
    self.__unfinishedNotes[index] = self.__unfinishedNotes[index] or {}
    self.__unfinishedNotes[index][noteId] = note:is(Midi.NoteOn) and true or nil
  end

  self:__handleOutput(index, message)
end

function Module:__handleOutput(index, message)
  if self.__outputs[index] then
    for _, input in pairs(self.__outputs[index]) do
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

  local numberedInput = 'input' .. index
  module:__emit('input:*', message)
  module:__emit('input:' .. message.name, message)
  module:__emit(numberedInput .. ':*', message)
  module:__emit(numberedInput .. ':' .. message.name, message)
end

---Finish unfinished midi notes to prevent midi panic.
---@param output? number
function Module:__finishNotes(output)
  for index, noteIds in pairs(self.__unfinishedNotes) do
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
  self.__outputs = {}
end

function Module:__destroy()
  self:__finishNotes()
  utils.callIfExists(self.destroy, { self })
end

return Module
