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
ChordSplit:on('input1:noteOn', function(self, note)
  local time = Timer.now()
  if time - self.lastNoteTime > self.maxNoteInterval then
    self.notes = {}
  end

  self:addNote(note)
  self.lastNoteTime = time

  if self.timerId == nil then
    self.timerId = Timer.schedule(Timer.now() + self.maxNoteInterval, function()
      self:split()
      self.timerId = nil
    end)
  else
    Timer.reschedule(Timer.now() + self.maxNoteInterval)
  end
end)

---@param note MidiNoteOff
ChordSplit:on('input1:noteOff', function(self, note)
  local noteId = Midi.getNoteId(note)

  local outputIndex = self.usedOutputs[noteId]
  self.usedOutputs[noteId] = nil

  if outputIndex then
    self:output(outputIndex, note)
  end
end)

---@param note MidiNoteOn
function ChordSplit:addNote(note)
  table.insert(self.notes, note)
end

---@param outputIndex number
---@param note MidiNoteOn
function ChordSplit:playNote(outputIndex, note)
  self.usedOutputs[Midi.getNoteId(note)] = outputIndex
  self:output(outputIndex, note)
end

function ChordSplit:split()
  local outputIndex = (#self.notes < self.props.thresh) and 1 or 2

  for _, note in pairs(self.notes) do
    self:playNote(outputIndex, note)
  end
end

return ChordSplit
