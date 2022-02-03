local class = require('class')
local Node = require('Node')
local Props = require('Props')
local utils = require('utils')

---@class Module : Node
-- Will both be set in `Patch#_initModules()`
---@field _patch Patch
---@field _id number
-- Will be set in `Miwos#createModule()`
---@field _type string
---@field destroy function
---@field defineProps function
---@field props table
---@field _saveState function
---@field _destroy function

local Module = class(Node)

---See `Module#_applyState` and `Module#_saveState`.
Module.__hmrKeep = {}

function Module:constructor()
  Module.super.constructor(self)
  self.props = {}
  self._unfinishedNotes = {}
  utils.callIfExists(self.init, { self })
end

---Define the properties that are available on the module.
---@param props table<string, Prop>
function Module:defineProps(props)
  self.props = Props(self, props)
end

---Send data to output.
---@param index number The output index.
---@param message MidiMessage The midi message to send.
function Module:output(index, message)
  local type = message.type
  if message:is(Midi.NoteOn) or message:is(Midi.NoteOff) then
    ---@type MidiNoteOn|MidiNoteOff
    local note = message
    local key = index .. utils.getMidiNoteId(note)
    self._unfinishedNotes[key] = type == Midi.NoteOn.type
        and {
          index,
          note.note,
          note.channel,
        }
      or nil
  end
  Module.super.output(self, index, message)
end

---Return a human readable name for debugging (e.g.: delay1)
---@return string
function Module:_name()
  return self._type .. self._id
end

---Finish unfinished midi notes to prevent midi panic.
function Module:_finishNotes()
  for _, data in pairs(self._unfinishedNotes) do
    local output, note, channel = unpack(data)
    Module.super.output(self, output, Midi.NoteOff(note, 0, channel))
  end
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
  if data and Patches.activePatch then
    Patches.activePatch:updateModule(data.type, module)
  end
end

---Decline a HMR if this file (the base class) is modified instead of an actual
---module.
---@return boolean - Wether or not to decline the HMR.
function Module.__hmrDecline(_, module)
  -- Only actual modules that inherit from Module have a `_type`.
  return not module._type
end

function Module:_destroy()
  self:_finishNotes()
  utils.callIfExists(self.destroy, { self })
end

return Module
