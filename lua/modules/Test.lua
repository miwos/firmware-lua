---@class ModuleTest : Module
local Test = Modules.create('Test')

function Test:init()
  self.usedPitches = {}
end

Test:defineProps({
  param1 = Prop.Number({ default = 0, min = 0, max = 127, step = 1 }),
  param2 = Prop.Number({ default = 0, min = 0, max = 127, step = 1 }),
  param3 = Prop.Number({ default = 0, min = 0, max = 127, step = 1 }),
  param4 = Prop.Number({ default = 0, min = 0, max = 127, step = 1 }),
  param5 = Prop.Number({ default = 0, min = 0, max = 127, step = 1 }),
  param6 = Prop.Number({ default = 0, min = 0, max = 127, step = 1 }),
})

return Test
