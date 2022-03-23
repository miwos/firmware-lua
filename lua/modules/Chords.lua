---@class ModuleChords : Module
local Chords = Modules.create('Chords', { shape = 'Chords' })

Chords.__hmrKeep = { 'props', 'chords' }

-- todo: fix

function Chords:init()
  ---@type MidiNoteOn[]
  self.listeningNotes = {}
  self.listening = false
  self.maxNoteInterval = 100
  self.lastNoteTime = 0

  self.chords = {}
  self.index = 1

  self.listenTimerHandler = nil
  self.stopNotesTimerHandler = nil
end

Chords:defineInOut({ Input.Midi, Input.Trigger, Output.Midi })

Chords:defineProps({
  Prop.Number('count', { max = 16, default = 3, step = 1 }),
  Prop.Switch('chord', { states = 3 }),
})

Chords:on('prop:change', function(self, name, value)
  if name == 'count' then
    self.__props.chord.states = value
  end
end)

Chords:on('prop:click', function(self, name)
  if name == 'chord' then
    self.listening = true
  end
end)

---@param note MidiNoteOn
Chords:on('input1:noteOn', function(self, note)
  if self.listening then
    self:listen(note)
  end
end)

Chords:on('input2:trigger', function(self)
  self:playNextChord()
end)

---@param note MidiNoteOn
function Chords:listen(note)
  local time = Timer.now()
  if time - self.lastNoteTime > self.maxNoteInterval then
    self.listeningNotes = {}
  end

  table.insert(self.listeningNotes, note)
  self.lastNoteTime = time

  Timer.cancel(self.listenTimerHandler)
  self.listenTimerHandler = Timer.schedule(function()
    self.listening = false
    self.chords[self.props.chord] = self.listeningNotes

    local noteValues = {}
    for _, n in pairs(self.listeningNotes) do
      noteValues[#noteValues + 1] = n.note
    end
    local matched, root, quality, add = Midi.analyzeChord(unpack(noteValues))
    if matched then
      local noteLetterDict = {
        'C',
        'C#',
        'D',
        'D#',
        'E',
        'F',
        'F#',
        'G',
        'G#',
        'A',
        'A#',
        'B',
      }

      local qualitiesDict = {
        '', -- major (omitted)
        'm', -- minor
        'dim', -- diminished
        'aug', -- augmented
        '6', -- minor seventh
        'm7b5', -- half diminished seventh
        'dim7', -- diminished seventh
        'mM7', --minor major seventh
        '7', -- seventh
        'maj7', -- major seventh
      }

      add = add == 8 and 'b9' or add

      Log.info(
        string.format(
          '%s%s%s',
          noteLetterDict[root],
          qualitiesDict[quality],
          add ~= 0 and 'add' .. add or ''
        )
      )
    end
  end, Timer.now() + self.maxNoteInterval)
end

---@param index number
function Chords:playChord(index)
  local chord = self.chords[index]
  if not chord then
    return
  end

  for _, note in pairs(chord) do
    self:output(1, note)
  end

  Timer.schedule(function()
    self:__finishNotes()
  end, Timer.now() + 100)
end

function Chords:playNextChord()
  self:playChord(self.index)
  self.index = self.index < self.props.count and self.index + 1 or 1
end

return Chords
