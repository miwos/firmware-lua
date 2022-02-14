---@class ModuleOutput : Module
local Output = Modules.create('Output')

function Output:init()
  self._unfinishedNotes = {}

  self:defineProps({
    device = Prop.Number({
      min = 1,
      max = 16,
      step = 1,
      default = 1,
      onChange = function()
        self:__finishNotes()
      end,
    }),
    cable = Prop.Number({
      min = 1,
      max = 16,
      step = 1,
      onChange = function()
        self:__finishNotes()
      end,
    }),
  })
end

Output:on('input1:*', function(self, message)
  self:output(1, message)
end)

---Override `Module.__handleOutput()` to send the message directly via midi.
---@param message MidiMessage
function Output:__handleOutput(_, message)
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
