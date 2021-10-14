local Output = Modules.create('Output')

function Output:input(index, message)
  Midi.send(index, message.type, unpack(message.data))
end

return Output
