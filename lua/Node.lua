local class = require('class')
local utils = require('utils')

---@class Node
---@field _outputs table[]
---@field _id number
local Node = class()

function Node:constructor()
  self._outputs = {}
end

---Connect an output to the input of another Node.
---@param output number The output index.
---@param nodeId number The id of the node to connect to.
---@param nodeInput number The input index of the node to connect to.
function Node:connect(output, nodeId, nodeInput)
  self._outputs[output] = self._outputs[output] or {}
  table.insert(self._outputs[output], { nodeId, nodeInput })
end

---Clear all connections.
function Node:clearConnections()
  self._outputs = {}
end

---Send data to all inputs connected to the output.
---@param index number The output index.
---@param message MidiMessage The midi message to send.
function Node:output(index, message)
  Bridge.sendOutput(self._id, index, message)

  local outputs = self._outputs[index]
  if not outputs then
    return
  end

  for _, input in pairs(outputs) do
    local inputId, inputIndex = unpack(input)
    local inputNode = Modules.get(inputId)

    if inputNode then
      self:_sendOutputToInput(message, inputNode, inputIndex)
    end
  end
end

---@param message MidiMessage
---@param node Node
---@param index number
function Node:_sendOutputToInput(message, node, index)
  Bridge.sendInput(node._id, index, message)

  -- Call a midi-type agnostic function like `input1()`.
  local numberedInput = 'input' .. index
  utils.callIfExists(node[numberedInput], { node, message })

  -- Call a midi-type aware function like `input1_noteOn()`.
  local midiTypeName = message.name
  utils.callIfExists(
    node[numberedInput .. '_' .. midiTypeName],
    { node, message }
  )

  -- Call a generic `input()` function that handles any input.
  utils.callIfExists(node['input'], { node, index, message })
end

return Node
