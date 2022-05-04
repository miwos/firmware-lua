---@class ModuleLowestNote : Module
local LowestNote = Modules.create(
  'LowestNoteFilter',
  { shape = 'Filter', label = { 'Low', 'Note' } }
)

---@param a MidiNoteOn
---@param b MidiNoteOn
local function getLowerNote(a, b)
  return (b and b.note < a.note) and b or a
end

function LowestNote:init()
  ---@type MidiNoteOn
  self.lowestNote = nil
  self.maxNoteInterval = 1000
  self.lastNoteTime = 0
  self.timerId = nil
end

LowestNote:defineInOut({ Input.Midi, Output.Midi })

---@param self ModuleLowestNote
---@param note MidiNoteOn
LowestNote:on('input1:noteOn', function(self, note)
  self.lowestNote = getLowerNote(note, self.lowestNote)

  Timer.cancel(self.timerId)
  self.timerId = Timer.schedule(function()
    self:__finishNotes()
    self:output(1, self.lowestNote)
    self.lowestNote = nil
  end, Timer.now() + self.maxNoteInterval)
end)

return LowestNote
