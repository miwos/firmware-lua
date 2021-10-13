-- The global Encoder object might have already been created by c++.
Encoder = _G.Encoder or {}

Encoder.min = 0
Encoder.max = 127

function Encoder.handleChange(index, value)
  local patch = Miwos.activePatch

  if not patch.interface then
    return
  end

  if not patch then
    return
  end

  local encoders = patch.interface.page1.encoders
  local encoder = encoders[index]
  if not encoder then
    return
  end

  local moduleId, propName = unpack(encoder)
  local module = patch.modules[moduleId]
  if not module then
    return
  end

  local prop = module.props._props[propName]
  if not prop then
    return
  end

  prop:setRawValue(value)
end
