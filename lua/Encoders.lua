-- The global Encoder object might have already been created by c++.
Encoders = _G.Encoders or {}

Encoders.min = 0
Encoders.max = 127

function Encoders.handleChange(index, value)
  Views.activeView:handleEncoderChange(index, value)
end

function Encoders.handleClick(index)
  Views.activeView:handleEncoderClick(index)
end
