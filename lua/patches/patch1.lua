local Output = require('modules.Output')
local Input = require('modules.Input')
local Hold = require('modules.Hold')
local Chorder = require('modules.Chorder')
local Arp = require('modules.Arp')

return {
  types = {
    [1] = Input,
    [2] = Output,
    [3] = Chorder,
    [4] = Arp,
    [5] = Hold,
  },

  connections = {
    { 1, 1, 5, 1 },
    { 5, 1, 3, 1 },
    { 3, 1, 4, 1 },
    { 4, 1, 2, 1 },
  },

  interface = {
    page1 = {
      encoders = {
        { 4, 'speed' },
        { 4, 'gate' },
      },
    },
  },
}
