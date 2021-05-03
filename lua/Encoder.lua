-- The global Encoder object might have already been created by c++.
Encoder = _G.Encoder or {}

function Encoder.handleChange(index, value)
  _G.Log.info(string.format('Encoder%d = %d', index, value))
end