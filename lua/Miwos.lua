Miwos = _G.Miwos or {}

function Miwos.destroy()
  if Patches.activePatch then
    Patches.activePatch:destroy()
  end
end

function Miwos.getMemoryUsage()
  return collectgarbage('count')
end

return Miwos
