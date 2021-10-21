---@class ModuleSwitch : Module
local Switch = Modules.create('Switch')

function Switch:init()
  self:defineProps({
    state = Prop.Boolean({ default = 0, min = -24, max = 24, step = 1 }),
  })

  self.usedPitches = {}
end
