Signal = { Midi = 1, Trigger = 2 }
Direction = { In = 1, Out = 2 }

---@class InputOutput
---@field direction number
---@field signal number

Input = {
  ---@classInputOutput
  Midi = { direction = Direction.In, signal = Signal.Midi },
  ---@classInputOutput
  Trigger = { direction = Direction.In, signal = Signal.Trigger },
}

Output = {
  ---@class InputOutput
  Midi = { direction = Direction.Out, signal = Signal.Midi },
  ---@class InputOutput
  Trigger = { direction = Direction.Out, signal = Signal.Trigger },
}
