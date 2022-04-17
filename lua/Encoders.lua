-- The global Encoder object might have already been created by c++.
Encoders = _G.Encoders or {}

function Encoders.handleChange(index, value)
  Views.activeView:handleEncoderChange(index, value)
end
