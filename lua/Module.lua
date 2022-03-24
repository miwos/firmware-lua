local class = require('class')
local utils = require('utils')

---@class Module : Class
---@field init function
---@field destroy function
---@field __type string Will be set in `Modules#create()`
---@field __events string Will be set in `Modules#create()`
---@field __id number Will be set in `Patch:_createMissingInstances()`
---@field __name string Will be set in `Patch:_createMissingInstances()`
---@field __props table<string, Prop>
---@field __info { shape: string }
---@field __inputDefinitions { signal: number }[]
---@field __outputDefinitions { signal: number }[]
local Module = class()

Module.__hmrKeep = { 'props' }

function Module:constructor()
  self.__unfinishedNotes = {}
  self.__outputs = {}

  self.__props = {}
  for _, definition in ipairs(self.__propDefinitions) do
    self.__props[definition.name] = definition:create(self)
  end
  self.props = self:__createPropsProxy()

  utils.callIfExists(self.init, { self })
end

function Module:__getProp(name)
  local prop = self.__props[name]
  if prop then
    return prop
  else
    Log.warn(
      string.format("Prop '%s' doesn't exist on module %s.", name, self.__type)
    )
  end
end

function Module:__createPropsProxy()
  local mt = {}
  local instance = self

  function mt:__newindex(key, value)
    local prop = instance:__getProp(key)
    if prop then
      prop:__setValue(value, true)
    end
  end

  function mt:__index(key)
    local prop = instance:__getProp(key)
    return prop and prop.value or nil
  end

  return setmetatable({}, mt)
end

---Define the inputs and outputs that are available on the module.
---@param inputsOutputs InputOutput[]
function Module:defineInOut(inputsOutputs)
  local inputs = {}
  local outputs = {}

  for i = 1, #inputsOutputs do
    local inputOutput = inputsOutputs[i]
    local category = inputOutput.direction == Direction.In and inputs or outputs
    -- We can omit the direction as the inputs/outputs are already grouped.
    category[#category + 1] = { signal = inputOutput.signal }
  end

  self.__inputDefinitions = inputs
  self.__outputDefinitions = outputs
end

---Define the properties that are available on the module.
---@param definitions Prop[]
function Module:defineProps(definitions)
  for index, prop in ipairs(definitions) do
    prop.index = index
  end
  self.__propDefinitions = definitions
end

---@param event string
---@param callback function
function Module:on(event, callback)
  self.__events[event] = callback
end

---@param event string
---@param ... any
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

function Module:message(name, ...)
  App.sendMessage('/instance/message', self.__id, name, ...)
end

---Send data to all inputs connected to the output.
---@param index number The output index.
---@param message MidiMessage The midi message to send.
function Module:output(index, message)
  local signal = message and Signal.Midi or Signal.Trigger

  if signal == Signal.Midi then
    local isNoteOn = message:is(Midi.NoteOn)
    local isNoteOff = message:is(Midi.NoteOff)
    if isNoteOn or isNoteOff then
      ---@type MidiNoteOn|MidiNoteOff
      local note = message
      local noteId = Midi.getNoteId(note.note, note.channel)
      self.__unfinishedNotes[index] = self.__unfinishedNotes[index] or {}
      self.__unfinishedNotes[index][noteId] = note:is(Midi.NoteOn) and true
        or nil
    end
  end

  self:__handleOutput(signal, index, message)
  Instances.updateOutputs()
end

---@param signal number
---@param index number
---@param message MidiMessage
function Module:__handleOutput(signal, index, message)
  if self.__outputs[index] then
    for _, input in pairs(self.__outputs[index]) do
      local inputId, inputIndex = unpack(input)
      local inputInstance = Patches.activePatch
        and Patches.activePatch.instances[inputId]

      if inputInstance then
        self:__sendOutputToInput(inputInstance, inputIndex, message)
      end
    end
  end
end

---@param message MidiMessage
---@param instance Module
---@param index number
function Module:__sendOutputToInput(instance, index, message)
  local name = message and message.name or 'trigger'
  local numberedInput = 'input' .. index

  instance:__emit('input:*', index, message)
  instance:__emit('input:' .. name, index, message)
  instance:__emit(numberedInput .. ':*', message)
  instance:__emit(numberedInput .. ':' .. name, message)
end

---Finish unfinished midi notes to prevent midi panic.
---@param output? number
function Module:__finishNotes(output)
  for index, noteIds in pairs(self.__unfinishedNotes) do
    if not output or index == output then
      for noteId in pairs(noteIds) do
        local note, channel = Midi.parseNoteId(noteId)
        self:__handleOutput(Signal.Midi, index, Midi.NoteOff(note, 0, channel))
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
