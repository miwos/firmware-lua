local Chorder = require('modules.Chorder')
local Arp = require('modules.Arp')

return {
  types = {
    [1] = Chorder,
    [2] = Arp
  },

  connections = {
    { 0, 1, 1, 1 },
    { 1, 1, 2, 1 },
    { 2, 1, 0, 1}
  },

  interface = {
    page1 = {
      encoders = {
        { 2, 'interval' },
        { 2, 'gate' }
      }
    }
  }
}