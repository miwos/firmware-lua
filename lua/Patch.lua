local class = require('class')
local utils = require('utils')

---@class Patch
---@field connections number[]
---@field types table<string, Module> Module can be an instance or a constructor.
---@field modules table<string, Module> Module is an instance.
local Patch = class()

---@class PatchArgs
---@field types table<string, Module>
---@field connections number[]
---@field interface table

---Initialize patch.
---@param args PatchArgs
function Patch:constructor(args)
  self.types = args.types
  self.connections = args.connections
  self.interface = args.interface
  ---@type table<string, Module>
  self.modules = {}

  self:_initModules()
  self:_makeConnections()
end

---Initialize modules.
function Patch:_initModules()
  for id, constructor in pairs(self.types) do
    local module = constructor()
    module._id = id
    module._patch = self
    self.modules[id] = module
  end
end

---Connect modules.
function Patch:_makeConnections()
  for _, connection in pairs(self.connections) do
    local fromId, output, toId, input = unpack(connection)
    self.modules[fromId]:connect(output, toId, input)
  end
end

---Activate the patch and initialize the encoders.
function Patch:activate()
  Miwos.activePatch = self
  Interface:patchChange(self)
end

---Update a single module instance.
---@param id any
---@param module Module
---@param NewModule Module
function Patch:_updateModuleInstance(id, module, NewModule)
  local state = module:_saveState()
  module:_destroy()

  local newModule = NewModule()
  newModule:_applyState(state)
  newModule._id = id
  newModule._patch = self

  self.modules[id] = newModule
end

---Update all module instances of the specified type.
---@param type string
---@param NewModule Module
function Patch:updateModule(type, NewModule)
  local updatedModule = false
  for id, module in pairs(self.modules) do
    if module._type == type then
      self:_updateModuleInstance(id, module, NewModule)
      updatedModule = true
    end
  end

  -- If we changed a module we have to redo the connections.
  if updatedModule then
    self:_makeConnections()
  end
end

function Patch:destroy()
  for _, module in pairs(self.modules) do
    module:_destroy()
  end
end

return Patch
