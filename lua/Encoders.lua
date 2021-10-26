-- The global Encoder object might have already been created by c++.
Encoders = _G.Encoders or {}

Encoders.min = 0
Encoders.max = 127

function Encoders.handleChange(index, rawValue)
  local patch = Patches.activePatch
  local prop = patch and patch:getMappedProp(index)
  if prop then
    prop:setRawValue(rawValue)
  end
end

function Encoders.handleClick(index)
  local patch = Patches.activePatch
  local prop = patch and patch:getMappedProp(index)
  if prop then
    prop:click()
  end
end
