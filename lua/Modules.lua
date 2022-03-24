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

  local info = module.__info or {}
  info.inputs = module.__inputDefinitions
  info.outputs = module.__outputDefinitions

  info.props = {}
  local propDefinitions = module.__propDefinitions
  if propDefinitions then
    for _, definition in pairs(propDefinitions) do
      info.props[#info.props + 1] = definition:serialize()
    end
  end

  if not wasLoaded then
    _G._LOADED[path] = nil
  end

  return utils.tableToJson(info)
end
