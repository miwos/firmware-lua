local class = require('class')

---@class Delay : Module
local Delay = Modules.create('Delay', { shape = 'Effect' })

---@class DelayMessage
---@field delay Delay
---@field message MidiMessage
local DelayMessage = class()

function DelayMessage:constructor(delay, message)
  self.delay = delay
  self.message = message
  self.initialVelocity = message.velocity
  self.timerId = nil
  self.gain = 1

  self:send()
end

function DelayMessage:send()
  self.timerId = Timer.schedule(function()
    local isNoteOn = self.message:is(Midi.NoteOn)
    self.delay:output(1, self.message)

    -- Convert from percentage.
    local feedFactor = self.delay.props.feed / 100

    if isNoteOn then
      self.message.velocity = math.floor(self.initialVelocity * self.gain)
    end
    self.gain = self.gain * feedFactor

    local thresh = feedFactor * 0.01
    if feedFactor == 0 or self.gain < thresh then
      self:destroy()
    else
      self:send()
    end
  end, Timer.now() + self.delay.props.time)
end

function DelayMessage:destroy()
  Timer.cancel(self.timerId)
end

function Delay:init()
  self.messages = {}
end

Delay:defineProps({
  time = Prop.Number({ default = 500, min = 0, max = 1000, step = 1 }),
  feed = Prop.Number({ min = 0, max = 100, step = 1 }),
})

---@param message MidiMessage
Delay:on('input1:*', function(self, message)
  DelayMessage(self, message)
  self:output(1, message)
end)

return Delay
