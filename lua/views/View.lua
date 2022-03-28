local utils = require('utils')

---@class View
---@field active boolean
---@field deactivate function
---@field handleEncoderChange function
---@field handleEncoderClick function
---@field handleButtonClick function
local View = {}

function View:update(name, data)
  if self.active then
    local handlerName = 'update' .. utils.capitalize(name)
    utils.callIfExists(self[handlerName], { self, data })
  end
end

return View
