-- The global Encoder object might have already been created by c++.
Buttons = _G.Buttons or {}

function Buttons.handleClick(index)
  Views.activeView:handleButtonClick(index)
end
