---@class ModuleTriggerReceive : Module
local TriggerReceive = Modules.create('TriggerReceive')

TriggerReceive:on('input:trigger', function(self, index)
  Log.info('trigger in on input #' .. index)
end)

return TriggerReceive
