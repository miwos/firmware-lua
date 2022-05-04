---@class ModuleHold : Module
local Hold = Modules.create('Hold', { shape = 'Transform' })

function Hold:init()
  self.lastNoteTime = 0
  self.maxNoteInterval = 100
end

Hold:defineInOut({ Input.Midi, Output.Midi })

Hold:defineProps({
  Prop.Button('hold', { toggle = true }),
})

---@param self ModuleHold
Hold:on('prop:click', function(self, name, value)
  if name == 'hold' and not value then
    self:__finishNotes()
  end
end)

---@param self ModuleHold
Hold:on('input1:noteOff', function(self, note)
  if not self.props.hold then
    self:output(1, note)
  end
end)

---@param note MidiNoteOn
Hold:on('input1:noteOn', function(self, note)
  if not self.props.hold then
    self:output(1, note)
    return
  end

  local time = Timer.now()
  if time - self.lastNoteTime > self.maxNoteInterval then
    self:__finishNotes()
  end
  self:output(1, note)
  self.lastNoteTime = time
end)

return Hold
