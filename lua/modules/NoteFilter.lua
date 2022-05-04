---@class ModuleNoteFilter : Module
local NoteFilter = Modules.create('NoteFilter', { shape = 'Filter' })

NoteFilter:defineInOut({ Input.Midi, Output.Midi })

NoteFilter:defineProps({
  Prop.Number('note', { min = 0, max = 127, default = 60, step = 1 }),
})

---@param self ModuleNoteFilter
NoteFilter:on('prop:change', function(self, name)
  if name == 'note' then
    self:__finishNotes()
  end
end)

---@param self ModuleNoteFilter
---@param message MidiMessage
NoteFilter:on('input1:*', function(self, message)
  local isNote = message:is(Midi.NoteOn) or message:is(Midi.NoteOff)
  if isNote then
    ---@type MidiNoteOn
    local note = message
    if note.note == self.props.note then
      self:output(1, note)
    end
  end
end)

return NoteFilter
