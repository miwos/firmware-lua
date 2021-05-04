---@class ModuleArp : Module
local Arp = Miwos.createModule('Arp')

function Arp:init()
  self.notes = {}
  self.noteIndex = 1
  self.lastNoteTime = 0
  self.timerId = nil

  self.params = {
    interval = 1000,
    gate = 0.1,
    hold = false
  }
end

function Arp:setParam(name, value)
  self.params[name] = value
end

function Arp:input1_noteOn(message)
  local time = Timer.now()
  if (time - self.lastNoteTime > 100) then
    self:clear()
  end
  self:addNote(message.payload)
  self.lastNoteTime = time
  if not self.playing then
    self:update()
    self.playing = true
  end
end

function Arp:input1_noteOff()
  if not self.params.hold then self:clear() end
end

function Arp:update()
  if self.noteIndex > #self.notes then self.noteIndex = 1 end

  local interval = self.params.interval
  local gateDuration = math.max(10, interval * self.params.gate)

  local note = self.notes[self.noteIndex]
  -- Check for nil because the notes might have been cleared in the meantime.
  if note ~= nil then
    self:output(1, Midi.NoteOn(unpack(note)))
    Timer.schedule(Timer.now() + gateDuration, function ()
      self:output(1, Midi.NoteOff(unpack(note)))
    end)
  end

  local _self = self
  self.timerId = Timer.schedule(Timer.now() + self.params.interval, function ()
    Arp.update(_self)
  end)

  -- We increase the index by one, even though this may make it larger than the
  -- total number of notes, because new notes may have been added until the next
  -- time `Arp:update()` is called.
  self.noteIndex = self.noteIndex + 1
end

function Arp:addNote(note)
  table.insert(self.notes, note)
end

function Arp:clear()
  for _, note in pairs(self.notes) do
    self:output(1, Midi.NoteOff(unpack(note)))
  end
  Timer.cancel(self.timerId)
  self.notes = {}
  self.noteIndex = 1
  self.playing = false
end

return Arp