---@class ModuleOutput : Module
local Output = Modules.create('Output', { shape = 'Output' })

Output:defineInOut({ Input.Midi })

Output:defineProps({
  device = Prop.Number({ show = false, min = 1, max = 16, step = 1 }),
  cable = Prop.Number({ show = false, min = 1, max = 16, step = 1 }),
})

Output:on('prop:beforeChange', function(self)
  -- Finish the notes *before* either `device` or `cable` has changed, so we can
  -- send all unfinished notes to their correct location.
  self:__finishNotes()
end)

Output:on('input1:*', function(self, message)
  self:output(1, message)
end)

---Override `Module.__handleOutput()` to send the message directly via midi.
---@param message MidiMessage
function Output:__handleOutput(_, _, message)
  local data1, data2, channel = unpack(message:serialize())
  Midi.send(
    self.props.device,
    message.type,
    data1,
    data2,
    channel,
    self.props.cable
  )
end

return Output
