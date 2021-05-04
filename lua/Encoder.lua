-- The global Encoder object might have already been created by c++.
Encoder = _G.Encoder or {}

function Encoder.handleChange(index, value)
  local patch = Miwos.activePatch

  if not patch then return end

  local encoders = patch.interface.page1.encoders
  local encoder = encoders[index + 1]
  if not encoder then return end

  local moduleId, moduleParam = unpack(encoder)
  local module = patch.modules[moduleId]
  if not module then return end

  module.params[moduleParam] = value
end