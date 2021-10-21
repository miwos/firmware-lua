---@class ModuleChorder : Module
local Chorder = Modules.create('Chorder')

function Chorder:init()
  self:defineProps({
    pitch1 = Prop.Number({ default = 6, min = -12, max = 12, step = 1 }),
    pitch2 = Prop.Number({ default = -12, min = -12, max = 12, step = 1 }),
  })

  self.notes = {}
  self.inputs = 1
  self.outputs = 1
end

---@param note MidiNoteOn
function Chorder:input1_noteOn(note)
  self:output(1, note)
  self:sendChordNote(note.note + self.props.pitch1, note.velocity, note.channel)
  self:sendChordNote(note.note + self.props.pitch2, note.velocity, note.channel)
end

---@param note MidiNoteOn
function Chorder:input1_noteOff(note)
  self:output(1, note)
  self:clear()
end

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
