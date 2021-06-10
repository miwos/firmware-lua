local class = require('class')
local utils = require('utils')

---@class Node
local Node = class()

function Node:construct()
  self._outputs = {}
end

---Connect an output to the input of another Node.
---@param output number The output index.
---@param nodeId number The id of the node to connect to.
---@param nodeInput number The input index of the node to connect to.
function Node:connect(output, nodeId, nodeInput)
  self._outputs[output] = { nodeId, nodeInput }
end

---Send data to output.
---@param index number The output index.
---@param message table The midi message to send.
function Node:output(index, message)
  local output = self._outputs[index]
  if not output then
    return
  end

  local id, input = unpack(output)
  local node = id == 0 and Miwos.output or Miwos:getModule(id)
  if not node then
    return
  end

  -- Call a midi-type agnostic function like `input1()`.
  local numberedInput = 'input' .. input
  utils.callIfExists(node[numberedInput], { node, message })

  -- Call a midi-type aware function like `input1_noteOn()`.
  local midiTypeName = Midi.typeNames[message.type]
  utils.callIfExists(
    node[numberedInput .. '_' .. midiTypeName],
    { node, message }
  )

  -- Call a generic `input()` function that handles any input.
  utils.callIfExists(node.input, { node, input, message })
end

return Node
