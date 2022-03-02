---@class ModuleMetronome : Module
local Metronome = Modules.create('Metronome', { shape = 'Metronome' })

function Metronome:init()
  self.timerId = nil
  self.lastTime = Timer.now()
  self:tick()
end

Metronome:defineInOut({ Output.Trigger })

Metronome:defineProps({
  time = Prop.Number({ min = 5, max = 1000, default = 1000, step = 1 }),
})

function Metronome:tick()
  self:output(1)

  local time = self.lastTime + self.props.time
  self.timerId = Timer.schedule(function()
    self:tick()
  end, time)

  self.lastTime = time
end

function Metronome:destroy()
  Timer.cancel(self.timerId)
end

return Metronome
