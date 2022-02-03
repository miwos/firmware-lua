local Input = require('modules.Input')
local Output = require('modules.Output')
local Pitcher = require('modules.Pitcher')

return {
  instances = {
    [1] = { Module = Input },
    [2] = { Module = Output },
    [3] = { Module = Pitcher },
  },
  connections = {
    { 1, 1, 3, 1 },
    { 3, 1, 2, 1 },
  },
  mapping = {
    {
      encoders = {
        { 3, 'pitch' },
      },
    },
  },
}
