-- The global Encoder object might have already been created by c++.
Buttons = _G.Buttons or {}

function Buttons.handleClick(index, duration)
  Log.info(index, duration)
  Views.activeView:handleButtonClick(index, duration)
end
