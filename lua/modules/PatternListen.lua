local utils = require('utils')
---@class ModulePatternListen : Module
local PatternListen = Modules.create(
  'PatternListen',
  { shape = 'SlotsVertical' }
)

PatternListen.__hmrKeep = { 'props', 'pattern' }

function PatternListen:init()
  self.pattern = { 0, 1000, 2000 }
  self.notes = {}

  self.toleranceMin = 0 -- ms
  self.toleranceMax = 500 -- ms

  self.recording = false
end

PatternListen:defineInOut({ Input.Midi, Output.Trigger })

PatternListen:defineProps({
  Prop.Button('record', { toggle = true }),
  Prop.Percent('precise', { default = 0.8, before = '+ ' }),
  Prop.Percent('speed', { default = 0.2, before = '+ ' }),
})

---@param self ModulePatternListen
PatternListen:on('prop:click', function(self, name)
  if name == 'record' then
    self:toggleRecording(self.props.record)
  end
end)

---@param self ModulePatternListen
---@param note MidiNoteOn
PatternListen:on('input1:noteOn', function(self, note)
  local now = Timer.now()
  if self.recording then
    self.pattern[#self.pattern + 1] = now
    self:message('recording', unpack(self.pattern))
  else
    self.notes[#self.notes + 1] = now

    if #self.notes > #self.pattern then
      self.notes = {
        unpack(self.notes, #self.notes - #self.pattern + 1),
      }
    end

    if self:checkForPattern() then
      self.notes = {}
      self:output(1)
      self:message('match')
    end
  end
end)

function PatternListen:toggleRecording(state)
  if state then
    self.recording = true
    self.pattern = {}
    self:message('record', true, Timer.now())
  else
    self.recording = false
    local offset = self.pattern[1]
    for i = 1, #self.pattern do
      self.pattern[i] = self.pattern[i] - offset
    end
    self:message('record', false)
    self:message('pattern', unpack(self.pattern))
  end
end

function PatternListen:checkForPattern()
  if #self.pattern == 0 or #self.notes < #self.pattern then
    -- Either an empty pettern or not enough notes yet.
    return false
  end

  local notesOffset = self.notes[1]
  local notesDuration = self.notes[#self.notes] - notesOffset
  local patternDuration = self.pattern[#self.pattern]

  local durationDeviation = self.props.speed * patternDuration
  local minDuration = patternDuration - durationDeviation
  local maxDuration = patternDuration + durationDeviation
  if notesDuration < minDuration or notesDuration > maxDuration then
    return
  end

  local stretch = patternDuration / notesDuration
  local tolerance = utils.mapValue(
    self.props.precise,
    0,
    1,
    self.toleranceMax,
    self.toleranceMin
  )

  for i = 1, #self.pattern do
    local min = self.pattern[i] - tolerance
    local max = self.pattern[i] + tolerance
    local time = (self.notes[i] - notesOffset) * stretch
    if time < min or time > max then
      return false
    end
  end

  return true
end

return PatternListen
