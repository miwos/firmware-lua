local Input = require('modules.Input')
local Output = require('modules.Output')
local Switch = require('modules.Switch')

return {
  types = {
    [1] = Input,
    [2] = Output,
    [3] = Output,
    [4] = Switch,
  },
  connections = {
    { 1, 1, 4, 1 },
    { 4, 1, 2, 1 },
    { 4, 2, 3, 1 },
  },
  props = {
    [3] = { cable = 2 },
  },
  interface = {
    {
      encoders = {
        { 4, 'state' },
      },
    },
  },
}
