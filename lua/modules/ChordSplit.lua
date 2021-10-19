local utils = require('utils')

---@class ModuleChordSplit : Module
local ChordSplit = Modules.create('ChordSplit')

function ChordSplit:init()
  self:defineProps({
    thresh = Prop.Number({ default = 3, min = 2, max = 5, step = 1 }),
  })

  self.playingNotes = {}
  self.currentNotes = {}

  self.lastNoteTime = 0
  self.maxNoteInterval = 25 -- ms
  self.timerId = nil
end

function ChordSplit:input1_noteOn(message)
  local time = Timer.now()
  if time - self.lastNoteTime > self.maxNoteInterval then
    self.currentNotes = {}
  end

  self:addNote(message)
  self.lastNoteTime = time

  Timer.cancel(self.timerId)
  local _self = self
  self.timerId = Timer.schedule(Timer.now() + self.maxNoteInterval, function()
    _self:split()
  end)
end

function ChordSplit:addNote(note)
  table.insert(self.currentNotes, note)
end

function ChordSplit:playNote(outputIndex, note)
  table.insert(self.playingNotes, note)
  note.outputIndex = outputIndex
  self:output(
    outputIndex,
    Midi.NoteOn(note.data[1], note.data[2], note.channel)
  )
end

function ChordSplit:split()
  local outputIndex = (#self.currentNotes < self.props.thresh) and 1 or 2

  for _, note in pairs(self.currentNotes) do
    self:playNote(outputIndex, note)
  end
end

---@param message MidiMessage
function ChordSplit:input1_noteOff(message)
  local outputIndex = -1
  local playingNoteIndex = nil

  -- Find the output index that was used to play the note so we can send
  -- the note off message to the same index.
  for i, note in pairs(self.playingNotes) do
    if note.data[1] == message.data[1] and note.channel == message.channel then
      outputIndex = note.outputIndex or outputIndex
      playingNoteIndex = i
      break
    end
  end

  if playingNoteIndex ~= nil then
    table.remove(self.playingNotes, playingNoteIndex)
  end

  self:output(outputIndex, Midi.NoteOff(unpack(message.data), message.channel))
end

return ChordSplit
