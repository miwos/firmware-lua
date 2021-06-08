---@class Pitcher : Module
local Pitcher = Miwos.createModule('Pitcher')

Pitcher:defineProps{
  semitones = Prop.Number{ default = 0, min = 0, max = 24 }
}

---@param message MidiNoteOn
function Pitcher:input1_noteOn(message)
  local note, velocity, channel = unpack(message.data)
  note = note + self.props.semitones
  self:output(1, Midi.NoteOn(note, velocity, channel))
end

return Pitcher