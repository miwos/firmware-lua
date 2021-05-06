---@class ModuleArp : Module
local Arp = Miwos.createModule('Arp')

function Arp:init()
  self.notes = {}
  self.noteIndex = 1
  self.lastNoteTime = 0
  self.timerId = nil

  self.defineProps({
    interval = Prop.Number{ value = 127, min = 100, max = 1000 },
    gate = Prop.Number{ min = 0.1, max =  1 },
    hold = Prop.Boolean(false),
    test = Prop.Select{ options = { "Option1", "Option2" }}
  })
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
  if not self.props.hold then self:clear() end
end

function Arp:update()
  if self.noteIndex > #self.notes then self.noteIndex = 1 end

  local interval = self.props.interval.value
  local gateDuration = math.max(10, interval * self.props.gate)

  local note = self.notes[self.noteIndex]
  -- Check for nil because the notes might have been cleared in the meantime.
  if note ~= nil then
    self:output(1, Midi.NoteOn(unpack(note)))
    Timer.schedule(Timer.now() + gateDuration, function ()
      self:output(1, Midi.NoteOff(unpack(note)))
    end)
  end

  local _self = self
  self.timerId = Timer.schedule(Timer.now() + self.props.interval, function ()
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