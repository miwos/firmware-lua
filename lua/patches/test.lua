local Output = require('modules.Output')
local Input = require('modules.Input')
local Chorder = require('modules.Chorder')

return {
  types = {
    [1] = Input,
    [2] = Output,
  },

  connections = {
    { 1, 1, 2, 1 },
  },

  interface = {
    page1 = {
      encoders = {},
    },
  },
}
