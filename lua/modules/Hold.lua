---@class ModuleHold : Module
local Hold = Modules.create('Hold')

function Hold:init()
  self.notes = {}
  self.lastNoteTime = 0
  self.maxNoteInterval = 100
end

---@param note MidiNoteOn
function Hold:input1_noteOn(note)
  local time = Timer.now()
  if time - self.lastNoteTime > self.maxNoteInterval then
    self:clear()
  end
  self:addNote(note)
  self.lastNoteTime = time
end

function Hold:addNote(note)
  table.insert(self.notes, note)
  self:output(1, note)
end

function Hold:clear()
  for _, note in pairs(self.notes) do
    self:output(1, Midi.NoteOff(note.note, 0, note.channel))
  end
  self.notes = {}
end

return Hold
