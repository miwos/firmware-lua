---@class ModuleTest : Module
local Test = Modules.create('Test')

function Test:init()
  self.usedPitches = {}
end

Test:defineProps({
  Prop.Number('param1', { default = 0, min = 0, max = 127, step = 1 }),
  Prop.Number('param2', { default = 0, min = 0, max = 127, step = 1 }),
  Prop.Number('param3', { default = 0, min = 0, max = 127, step = 1 }),
  Prop.Number('param4', { default = 0, min = 0, max = 127, step = 1 }),
  Prop.Number('param5', { default = 0, min = 0, max = 127, step = 1 }),
  Prop.Number('param6', { default = 0, min = 0, max = 127, step = 1 }),
})

return Test
