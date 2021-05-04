_LOADED = {}

require('Timer')
require('Encoder')
require('Midi')
require('Miwos')

local patch = Miwos.loadPatch('patch1')
patch:activate()