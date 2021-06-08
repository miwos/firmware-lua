local Hold = require('modules.Hold')
local Chorder = require('modules.Chorder')
local Arp = require('modules.Arp')

return {
  types = {
    [1] = Hold,
    [2] = Chorder,
    [3] = Arp,
  },

  connections = {
    { 0, 1, 1, 1 },
    { 1, 1, 2, 1 },
    { 2, 1, 3, 1 },
    { 3, 1, 0, 1},
  },

  interface = {
    page1 = {
      encoders = {
        { 2, 'pitch1' },
        { 3, 'speed' }
      }
    }
  }
}