---@class ModuleMetronome : Module
local Metronome = Modules.create('Metronome')

function Metronome:init()
  self.timerId = nil
  self.lastTime = Timer.now()
  self:tick()
end

Metronome:defineProps({
  time = Prop.Number({ min = 5, max = 1000, default = 1000, step = 1 }),
})

function Metronome:tick()
  self:output(1)

  local time = self.lastTime + self.props.time
  self.timerId = Timer.schedule(time, function()
    self:tick()
  end)

  self.lastTime = time
end

function Metronome:destroy()
  Timer.cancel(self.timerId)
end

return Metronome
