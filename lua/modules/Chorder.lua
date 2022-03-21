---@class ModuleChorder : Module
local Chorder = Modules.create('Chorder', { shape = 'Round' })

function Chorder:init()
  self.notes = {}
end

Chorder:defineInOut({ Input.Midi, Output.Midi })

Chorder:defineProps({
  Prop.Number('pitch1', { default = 6, min = -12, max = 12, step = 1 }),
  Prop.Number('pitch2', { default = -12, min = -12, max = 12, step = 1 }),
})

---@param note MidiNoteOn
Chorder:on('input1:noteOn', function(self, note)
  self:output(1, note)
  self:sendChordNote(note.note + self.props.pitch1, note.velocity, note.channel)
  self:sendChordNote(note.note + self.props.pitch2, note.velocity, note.channel)
end)

---@param note MidiNoteOn
Chorder:on('input1:noteOff', function(self, note)
  self:output(1, note)
  self:clear()
end)

function Chorder:sendChordNote(...)
  table.insert(self.notes, { ... })
  self:output(1, Midi.NoteOn(...))
end

function Chorder:clear()
  for _, note in pairs(self.notes) do
    self:output(1, Midi.NoteOff(unpack(note)))
  end
  self.notes = {}
end

return Chorder
