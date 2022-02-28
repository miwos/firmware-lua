local Input = require('modules.Input')
local Output = require('modules.Output')

return {
  instances = {
    [1] = {
      Module = Input,
      props = {
        device = 4,
        cable = 1,
      },
    },
    [2] = {
      Module = Output,
      props = {
        device = 2,
        cable = 1,
      },
    },
  },
  connections = {
    { 1, 1, 2, 1 },
  },
  mapping = {
    {
      encoders = {},
    },
    {
      encoders = {},
    },
    {
      encoders = {},
    },
  },
}
