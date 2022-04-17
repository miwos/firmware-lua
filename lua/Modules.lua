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
  local path = 'modules.' .. id
  local wasLoaded = _G._LOADED[path]

  ---@type Module
  local module = require('modules.' .. id)
  local info = module:__serialize()

  if not wasLoaded then
    _G._LOADED[path] = nil
  end

  return info
end
