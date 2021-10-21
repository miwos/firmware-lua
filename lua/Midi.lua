local utils = require('utils')
local MidiMessages = require('MidiMessages')

-- The global Midi object might have already been created by c++.
Midi = _G.Midi or {}

-- Add each midi message class to the `Midi` table, so we can call for example
-- `Midi.NoteOn()`. Also create a dictionary by type to quickly look up
-- messages.
local typeMessageDict = {}
for name, Message in pairs(MidiMessages) do
  Midi[name] = Message
  typeMessageDict[Message.type] = Message
end

Midi.inputListeners = {}

function Midi.addInputListener(listener)
  table.insert(Midi.inputListeners, listener)
end

function Midi.removeInputListener(listener)
  for i = 1, #Midi.inputListeners do
    if Midi.inputListeners[i] == listener then
      table.remove(Midi.inputListeners, i)
      break
    end
  end
end

function Midi.handleInput(index, messageType, data1, data2, channel, cable)
  local Message = typeMessageDict[messageType]
  if Message == nil then
    return
  end

  local message = Message()
  message:deserialize(data1, data2, channel)

  for i = 1, #Midi.inputListeners do
    utils.callIfExists(Midi.inputListeners[i], { index, message, cable })
  end
end
