LEDs = _G.LEDs or {}

local onIndexes = {}
local brightness = 32 -- 0 - 255

function LEDs.toggle(index, state)
  if state then
    table.insert(onIndexes, index)
    LEDs.write(index, brightness)
  else
    table.remove(onIndexes, index)
    LEDs.write(index, 0)
  end
end

function LEDs.setBrightness(value)
  brightness = value
  for _, index in ipairs(onIndexes) do
    LEDs.write(index, brightness)
  end
end
