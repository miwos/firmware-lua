---@class ModuleChords : Module
local Chords = Modules.create('Chords')

function Chords:init()
  local countDefault = 3

  local propChord = Prop.Switch({
    states = countDefault,
    onClick = function()
      self.listening = true
    end,
  })

  self:defineProps({
    count = Prop.Number({
      max = 16,
      default = countDefault,
      step = 1,
      onChange = function(value)
        propChord.states = value
      end,
    }),
    chord = propChord,
  })

  self.listening = false
  self.listeningNotes = {}
  self.maxNoteInterval = 100
  self.lastNoteTime = 0

  self.chords = {}
  self.index = 1
  self.playingNotes = {}

  self.listenTimerId = nil
  self.stopNotesTimerId = nil
end

---@param note MidiNoteOn
function Chords:listen(note)
  local time = Timer.now()
  if time - self.lastNoteTime > self.maxNoteInterval then
    self.listeningNotes = {}
  end

  table.insert(self.listeningNotes, note)
  self.lastNoteTime = time

  Timer.cancel(self.listenTimerId)
  self.listenTimerId = Timer.schedule(
    Timer.now() + self.maxNoteInterval,
    function()
      self.listening = false
      self.chords[self.props.chord] = self.listeningNotes
    end
  )
end

---@param note MidiNoteOn
function Chords:input1_noteOn(note)
  if self.listening then
    self:listen(note)
  else
    self:playNextChord()
  end
end

---@param index number
function Chords:playChord(index)
  Timer.cancel(self.stopNotesTimerId)
  self:stopPlayingNotes()

  local chord = self.chords[index]
  if not chord then
    return
  end

  for _, note in pairs(chord) do
    table.insert(self.playingNotes, note)
    self:output(1, note)
  end

  self.stopNotesTimerId = Timer.schedule(Timer.now() + 1000, function()
    self:stopPlayingNotes()
  end)
end

function Chords:playNextChord()
  self:playChord(self.index)
  self.index = self.index < self.props.count and self.index + 1 or 1
end

function Chords:stopPlayingNotes()
  for _, note in pairs(self.playingNotes) do
    self:output(1, Midi.NoteOff(note.note, 0, note.channel))
  end
  self.listeningNotes = {}
end

return Chords
