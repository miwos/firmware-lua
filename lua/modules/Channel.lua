---@class ModuleChannel: Module
local Channel = Modules.create('Channel', { shape = 'Transform' })

Channel:defineInOut({ Input.Midi, Output.Midi })

Channel:defineProps({
  Prop.Number('ch', { min = 1, max = 16, step = 1 }),
})

---@param self ModuleChannel
Channel:on('prop:change', function(self, name)
  if name == 'ch' then
    self:__finishNotes()
  end
end)

---@param self ModuleChannel
---@param note MidiNoteOn
Channel:on('input1:noteOn', function(self, note)
  self:output(1, Midi.NoteOn(note.note, note.channel, self.props.ch))
end)

---@param self ModuleChannel
---@param note MidiNoteOff
Channel:on('input1:noteOff', function(self, note)
  self:output(1, Midi.NoteOff(note.note, note.channel, self.props.ch))
end)

return Channel
