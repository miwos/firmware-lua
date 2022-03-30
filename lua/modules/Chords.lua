local utils = require('utils')
---@class ModuleChords : Module
local Chords = Modules.create('Chords', { shape = 'Chords' })

function Chords:init()
  ---@type MidiNoteOn[]
  self.listeningNotes = {}
  self.listening = false
  self.maxNoteInterval = 100
  self.lastNoteTime = 0

  self.index = 1

  self.listenTimerHandler = nil
  self.stopNotesTimerHandler = nil
end

local function notesToString(notes)
  if not notes or #notes == 0 then
    return 'empty'
  end

  local pitches = {}
  local lowestPitch
  for _, note in pairs(notes) do
    local pitch = note.note
    pitches[#pitches + 1] = pitch
    if lowestPitch == nil or pitch < lowestPitch then
      lowestPitch = pitch
    end
  end

  local chordName = utils.getChordName(pitches)
  return chordName
    or string.format(
      '%s%s',
      utils.getNoteName(lowestPitch),
      (#notes > 1 and ',...' or '')
    )
end

Chords:defineInOut({ Input.Midi, Input.Trigger, Output.Midi })

Chords:defineProps({
  Prop.List('chords', {
    length = 3,
    format = notesToString,
  }),
  Prop.Number('length', { min = 1, max = 6, default = 3, step = 1 }),
})

Chords:on('prop:change', function(self, name, value)
  if name == 'length' then
    ---@type PropList
    local chords = self.__props.chords
    chords.length = value
    chords:update()
  end
end)

Chords:on('prop:click', function(self, name)
  if name == 'chords' then
    self.listening = true
    ---@type PropList
    local chords = self.__props.chords
    chords:switchView(chords.Views.Rec)
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

    ---@type PropList
    local chords = self.__props.chords
    chords:setListValue(chords.selected, self.listeningNotes)
    chords:switchView(chords.Views.Value)
    chords:switchView(chords.Views.Name, 2500)

    self:message('chord', chords.selected, notesToString(self.listeningNotes))
  end, Timer.now() + self.maxNoteInterval)
end

---@param index number
function Chords:playChord(index)
  self:__finishNotes()

  ---@type PropList
  local chords = self.__props.chords
  chords.highlighted = index
  chords:update()

  local chord = self.__props.chords.value[index]
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
  self.index = self.index < self.props.length and self.index + 1 or 1
end

return Chords
