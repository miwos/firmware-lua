local class = require('class')

---@class Delay : Module
local Delay = Modules.create('Delay')

---@class DelayMessage
---@field delay Delay
---@field message MidiMessage
local DelayMessage = class()

function DelayMessage:constructor(delay, message)
  self.delay = delay
  -- We wan't to modify the note's velocity on each feedback loop, so we better
  -- make a copy in order to not muatate the original note.
  self.message = message:is(Midi.NoteOn) and message:copy() or message
  self.timerId = nil
  self.gain = 1

  self:send()
end

function DelayMessage:send()
  self.timerId = Timer.schedule(Timer.now() + self.delay.props.time, function()
    self.delay:output(1, self.message)

    if self.message:is(Midi.NoteOn) then
      self.message.velocity = math.floor(self.message.velocity * self.gain)
    end

    if self.gain > 0.1 then
      self:send()
    else
      self:destroy()
    end

    self.gain = self.gain * self.delay.props.feedback
  end)
end

function DelayMessage:destroy()
  Timer.cancel(self.timerId)
end

function Delay:init()
  self:defineProps({
    time = Prop.Number({ default = 500, min = 0, max = 1000, step = 1 }),
    feedback = Prop.Number({ default = 0, min = 0, max = 1 }),
  })

  self.messages = {}
end

---@param message MidiMessage
function Delay:input1(message)
  DelayMessage(self, message)
  self:output(1, message)
end

return Delay
