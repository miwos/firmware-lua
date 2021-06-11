local Hold = require('modules.Hold')

return {
  types = {
    [1] = Hold,
  },

  connections = {
    { 0, 1, 1, 1 },
    { 1, 1, 0, 1 },
  },

  interface = {
    page1 = {
      encoders = {},
    },
  },
}
