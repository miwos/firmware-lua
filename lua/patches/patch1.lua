local Metronome = require('modules.Metronome')

return {
  instances = {
    [1] = {
      Module = Metronome,
      props = {
        time = 2000,
      },
    },
  },
  connections = {},
  mapping = {
    {
      encoders = {
        [1] = { 1, 'time' },
      },
    },
    {
      encoders = {},
    },
    {
      encoders = {},
    },
  },
}
