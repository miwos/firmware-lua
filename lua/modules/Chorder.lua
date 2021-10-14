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

function Chorder:input1_noteOn(message)
  self:output(1, message)
  local note, velocity, channel = unpack(message.data)
  self:sendChordNote(note + self.props.pitch1, velocity, channel)
  self:sendChordNote(note + self.props.pitch2, velocity, channel)
end

function Chorder:input1_noteOff(message)
  self:output(1, message)
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
