local class = require('class')
local Module = require('Module')
local utils = require('utils')

Modules = _G.Modules or {}

---Return a new module class.
---@param name string
---@return table
function Modules.create(name, info)
  ---@type Module
  local newModule = class(Module)
  newModule.__type = name
  newModule.__events = {}
  newModule.__info = info
  return newModule
end

function Modules.getInfo(id)
  ---@type Module
  local path = 'modules.' .. id
  local wasLoaded = _G._LOADED[path]
  local module = require('modules.' .. id)

  local info = module.__info or {}
  info.props = {}
  if module.__props then
    for name, prop in pairs(module.__props) do
      info.props[name] = prop:serialize()
    end
  end

  if not wasLoaded then
    _G._LOADED[path] = nil
  end

  return utils.tableToJson(info)
end
