---@class Delay : Module
local Delay = Miwos.createModule('Delay')

Delay:defineProps({
  time = Prop.Number({ default = 500, min = 0, max = 1000 }),
})

---@param message MidiNoteOn
function Delay:input1_noteOn(message)
  Timer.schedule(Timer.now() + self.props.time, function()
    self:output(1, Midi.NoteOn(unpack(message.data)))
  end)
end

---@param message MidiNoteOff
function Delay:input1_noteOff(message)
  Timer.schedule(Timer.now() + self.props.time, function()
    self:output(1, Midi.NoteOff(unpack(message.data)))
  end)
end

return Delay
