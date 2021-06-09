local utils = require('utils')

---@class ModuleArp : Module
local Arp = Miwos.createModule('Arp')

Arp.minGateDuration = 5 -- ms

function Arp:init()
  self:defineProps({
    speed = Prop.Number({
      default = 240,
      min = 30,
      max = 1300,
      step = 1,
      onChange = function(value)
        self.interval = utils.bpmToMillis(value)
      end,
    }),
    gate = Prop.Number({ default = 0.5, min = 0, max = 1 }),
    hold = Prop.Number({ default = 0 }),
  })

  self.notes = {}
  self.noteIndex = 1
  self.lastNoteTime = 0
  self.timerId = nil
  self.interval = 150
end

---@param message MidiNoteOn
function Arp:input1_noteOn(message)
  -- Treat notes that are played close to each other in time as the input chord.
  local time = Timer.now()
  if time - self.lastNoteTime > 100 then
    self:clear()
  end

  self:addNote(message.data)
  self.lastNoteTime = time

  if not self.playing then
    self:update()
    self.playing = true
  end
end

function Arp:input1_noteOff()
  self:clear()
  -- if not self.props.hold then self:clear() end
end

function Arp:update()
  if self.noteIndex > #self.notes then
    self.noteIndex = 1
  end

  local gateDuration = math.max(
    self.minGateDuration,
    self.interval * self.props.gate
  )

  local note = self.notes[self.noteIndex]
  -- Check for nil because the notes might have been cleared in the meantime.
  if note ~= nil then
    self:output(1, Midi.NoteOn(unpack(note)))
    Timer.schedule(Timer.now() + gateDuration, function()
      self:output(1, Midi.NoteOff(unpack(note)))
    end)
  end

  local _self = self
  self.timerId = Timer.schedule(Timer.now() + self.interval, function()
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

function Arp:destroy()
  Timer.cancel(self.timerId)
end

return Arp
