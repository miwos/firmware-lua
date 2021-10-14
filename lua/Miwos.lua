Miwos = _G.Miwos or {}

function Miwos.destroy()
  if Patches.activePatch then
    Patches.activePatch:destroy()
  end
end

return Miwos
