local Input = require('modules.Input')
local Output = require('modules.Output')
local Arp = require('modules.Arp')

return {
  types = {
    [1] = Input,
    [2] = Output,
    [3] = Arp,
  },

  connections = {
    { 1, 1, 3, 1 },
    { 3, 1, 2, 1 },
  },

  interface = {
    {
      encoders = {
        { 3, 'speed' },
      },
    },
  },
}

-- local Output = require('modules.Output')
-- local Input = require('modules.Input')
-- local Chorder = require('modules.Chorder')
-- local Arp = require('modules.Arp')

-- return {
--   types = {
--     [1] = Input,
--     [2] = Output,
--     [3] = Chorder,
--     [4] = Arp,
--   },

--   connections = {
--     { 1, 1, 3, 1 },
--     { 3, 1, 4, 1 },
--     { 4, 1, 2, 1 },
--   },

--   interface = {
--     {
--       encoders = {
--         { 4, 'speed' },
--         { 4, 'gate' },
--       },
--     },
--   },
-- }
