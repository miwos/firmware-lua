-- The global Encoder object might have already been created by c++.
Encoders = _G.Encoders or {}

Encoders.min = 0
Encoders.max = 127

function Encoders.handleChange(index, rawValue)
  local patch = Patches.activePatch

  if not patch then
    return
  end

  if not patch.interface then
    return
  end

  local encoders = patch.interface.page1.encoders
  local encoder = encoders[index]
  if not encoder then
    return
  end

  local moduleId, propName = unpack(encoder)
  patch:changeProp(moduleId, propName, rawValue, true)
end
