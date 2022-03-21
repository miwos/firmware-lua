---@class ModuleChordSplit : Module
local ChordSplit = Modules.create('ChordSplit', { shape = 'Split' })

function ChordSplit:init()
  self.usedOutputs = {}
  self.notes = {}

  self.lastNoteTime = 0
  self.maxNoteInterval = 25 -- ms
  self.timerHandler = nil
end

ChordSplit:defineInOut({ Input.Midi, Output.Midi, Output.Midi })

ChordSplit:defineProps({
  Prop.Number('thresh', { default = 3, min = 2, max = 5, step = 1 }),
})

---@param note MidiNoteOn
ChordSplit:on('input1:noteOn', function(self, note)
  local time = Timer.now()
  if time - self.lastNoteTime > self.maxNoteInterval then
    self.notes = {}
  end

  self:addNote(note)
  self.lastNoteTime = time

  Timer.cancel(self.timerHandler)
  self.timerHandler = Timer.schedule(function()
    self:split()
  end, Timer.now() + self.maxNoteInterval)
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
