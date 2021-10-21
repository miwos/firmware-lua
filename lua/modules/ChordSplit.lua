local utils = require('utils')

---@class ModuleChordSplit : Module
local ChordSplit = Modules.create('ChordSplit')

function ChordSplit:init()
  self:defineProps({
    thresh = Prop.Number({ default = 3, min = 2, max = 5, step = 1 }),
  })

  self.usedOutputs = {}
  self.notes = {}

  self.lastNoteTime = 0
  self.maxNoteInterval = 25 -- ms
  self.timerId = nil
end

---@param note MidiNoteOn
function ChordSplit:input1_noteOn(note)
  local time = Timer.now()
  if time - self.lastNoteTime > self.maxNoteInterval then
    self.notes = {}
  end

  self:addNote(note)
  self.lastNoteTime = time

  Timer.cancel(self.timerId)
  local _self = self
  self.timerId = Timer.schedule(Timer.now() + self.maxNoteInterval, function()
    _self:split()
  end)
end

---@param note MidiNoteOn
function ChordSplit:addNote(note)
  table.insert(self.notes, note)
end

---@param outputIndex number
---@param note MidiNoteOn
function ChordSplit:playNote(outputIndex, note)
  self.usedOutputs[utils.getMidiNoteId(note)] = outputIndex
  self:output(outputIndex, note)
end

function ChordSplit:split()
  local outputIndex = (#self.notes < self.props.thresh) and 1 or 2

  for _, note in pairs(self.notes) do
    self:playNote(outputIndex, note)
  end
end

---@param note MidiNoteOff
function ChordSplit:input1_noteOff(note)
  local noteId = utils.getMidiNoteId(note)

  local outputIndex = self.usedOutputs[noteId]
  self.usedOutputs[noteId] = nil

  self:output(outputIndex, note)
end

return ChordSplit
