---@class Delay : Module
local Delay = Modules.create('Delay')

Delay:defineProps({
  time = Prop.Number({ default = 500, min = 0, max = 1000 }),
})

---@param note MidiNoteOn
function Delay:input1_noteOn(note)
  Timer.schedule(Timer.now() + self.props.time, function()
    self:output(1, note)
  end)
end

---@param note MidiNoteOff
function Delay:input1_noteOff(note)
  Timer.schedule(Timer.now() + self.props.time, function()
    self:output(1, note)
  end)
end

return Delay
