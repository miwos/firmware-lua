---@class ModuleHold : Module
local Hold = Modules.create('Hold', { shape = 'Transform' })

function Hold:init()
  self.lastNoteTime = 0
  self.maxNoteInterval = 100
end

Hold:defineInOut({ Input.Midi, Output.Midi })

---@param note MidiNoteOn
Hold:on('input1:noteOn', function(self, note)
  local time = Timer.now()
  if time - self.lastNoteTime > self.maxNoteInterval then
    self:__finishNotes()
  end
  self:output(1, note)
  self.lastNoteTime = time
end)

return Hold
