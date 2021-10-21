local Input = require('modules.Input')
local Output = require('modules.Output')
local Pitcher = require('modules.Pitcher')

return {
  types = {
    [1] = Input,
    [2] = Output,
    [3] = Pitcher,
  },
  connections = {
    { 1, 1, 3, 1 },
    { 3, 1, 2, 1 },
  },
  interface = {
    {
      encoders = {
        { 3, 'semitones' },
      },
    },
  },
}
