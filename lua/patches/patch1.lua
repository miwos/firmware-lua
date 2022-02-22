local Input = require('modules.Input')
local Output = require('modules.Output')
local Chords = require('modules.Chords')
local Metronome = require('modules.Metronome')
local PitchFrom = require('modules.PitchFrom')

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
        device = 1,
        cable = 1,
      },
    },
    [3] = {
      Module = Chords,
      props = {
        count = 3,
        chord = 3,
      },
    },
    [4] = {
      Module = Metronome,
      props = {
        time = 500,
      },
    },
    [5] = {
      Module = PitchFrom,
      props = {
        pitchKey = 0,
      },
    },
  },
  connections = {
    { 4, 1, 3, 2 },
    { 1, 1, 3, 1 },
    { 3, 1, 5, 1 },
    { 5, 1, 2, 1 },
    { 1, 1, 5, 2 },
  },
  mapping = {
    {
      encoders = {
        [1] = { 3, 'chord' },
        [2] = { 3, 'count' },
        [3] = { 4, 'time' },
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
