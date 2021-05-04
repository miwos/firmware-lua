-- The global Midi object might have already been created by c++.
-- Midi = _G.Midi or {}
Midi.TypeNoteOn = 1
Midi.TypeNoteOff = 2
Midi.TypeControlChange = 3

-- Send midi functions:

function Midi.NoteOn(note, velocity, channel)
  return Midi.Message(Midi.TypeNoteOn, { note, velocity, channel })
end

function Midi.NoteOff(note, velocity, channel)
  return Midi.Message(Midi.TypeNoteOff, { note, velocity, channel })
end

function Midi.ControlChange(control, value, channel)
  return Midi.Message(Midi.TypeControlChange, { control, value, channel })
end

function Midi.Message(type, payload)
  return { type = type, payload = payload }
end

-- Receive midi functions:

function Midi.handleNoteOn(input, ...)
  Miwos.input:output(input + 1, Midi.NoteOn(...))
end

function Midi.handleNoteOff(input, ...)
  Miwos.input:output(input + 1, Midi.NoteOff(...))
end