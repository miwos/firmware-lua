---@class Pitcher : Module
local Pitcher = Miwos.createModule('Pitcher')

function Pitcher:init()
  self:defineProps({
    semitones = Prop.Number({ default = 0, min = 0, max = 24 }),
  })
end

---@param message MidiNoteOn
function Pitcher:input1_noteOn(message)
  local note, velocity, channel = unpack(message.data)
  note = note + self.props.semitones
  self:output(1, Midi.NoteOn(note, velocity, channel))
end

---@param message MidiNoteOff
function Pitcher:input1_noteOff(message)
  local note, velocity, channel = unpack(message.data)
  note = note + self.props.semitones
  self:output(1, Midi.NoteOff(note, velocity, channel))
end

return Pitcher
