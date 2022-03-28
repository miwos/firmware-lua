local PatchView = require('views.Patch')
local SettingsView = require('views.Settings')
local utils = require('utils')

Views = {
  Patch = PatchView,
  -- Settings = SettingsView,
  ---@type View
  activeView = nil,
}

function Views.activate(name)
  local lastView = Views.activeView
  if lastView then
    lastView.active = false
    utils.callIfExists(lastView.deactivate, { lastView })
  end

  local view = Views[name]
  if not view then
    Log.warn(string.format("View '%s' doesn't exist.", name))
  else
    view.active = true
    Views.activeView = view
    view:activate()
  end
end
