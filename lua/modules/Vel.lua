---@class ModuleVel: Module
local Vel = Modules.create('Vel', { shape = 'Transform' })

Vel:defineInOut({ Input.Midi, Output.Midi })

Vel:defineProps({
  Prop.Number('vel', { min = 0, max = 127, step = 1, default = 100 }),
})

---@param self ModuleVel
---@param note MidiNoteOn
Vel:on('input1:noteOn', function(self, note)
  self:output(1, Midi.NoteOn(note.note, self.props.vel, note.channel))
end)

---@param self ModuleVel
---@param note MidiNoteOff
Vel:on('input1:noteOff', function(self, note)
  self:output(1, note)
end)

return Vel
