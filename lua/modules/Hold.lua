---@class ModuleHold : Module
local Hold = Modules.create('Hold')

function Hold:init()
  self.notes = {}
  self.lastNoteTime = 0
end

function Hold:input1_noteOn(message)
  local time = Timer.now()
  if time - self.lastNoteTime > 100 then
    self:clear()
  end
  self:addNote(message.data)
  self.lastNoteTime = time
end

function Hold:addNote(note)
  table.insert(self.notes, note)
  self:output(1, Midi.NoteOn(unpack(note)))
end

function Hold:clear()
  for _, note in pairs(self.notes) do
    self:output(1, Midi.NoteOff(unpack(note)))
  end
  self.notes = {}
end

return Hold
