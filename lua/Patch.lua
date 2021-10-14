local class = require('class')

---@class Patch
---@field activePatch Patch
---@field name string Same as file name, will be set by `Patches.loadPatch()`.
---@field connections number[]
---@field types table<string, Module> Module can be an instance or a constructor.
---@field modules table<string, Module> Module is an instance.
local Patch = class()

---@class PatchData
---@field types table<string, Module>
---@field connections number[]
---@field interface table

---Initialize patch.
---@param data PatchData
function Patch:constructor(data)
  self.types = data.types
  self.connections = data.connections
  self.interface = data.interface
  ---@type table<string, Module>
  self.modules = {}

  self:_initModules()
  self:_makeConnections()
end

---Initialize modules.
function Patch:_initModules()
  for id, constructor in pairs(self.types) do
    if not self.modules[id] then
      local module = constructor()
      module._id = id
      module._patch = self
      self.modules[id] = module
    end
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
  Patches.activePatch = self
  Interface:patchChange(self)
end

function Patch:changeProp(moduleId, propName, value, valueIsRaw)
  local module = self.modules[moduleId]
  if not module then
    return
  end

  local prop = module.props._props[propName]
  if not prop then
    return
  end

  if valueIsRaw then
    prop:setRawValue(value)
  else
    prop:setValue(value)
  end
end

function Patch:update(data)
  -- Remove old modules that are not part of the updated patch.
  local removeIds = {}
  for id in pairs(self.modules) do
    if not data.types[id] then
      table.insert(removeIds, id)
    end
  end
  for _, id in pairs(removeIds) do
    self.modules[id] = nil
  end

  -- Now we can update the types and initialize all modules that were not
  -- already part of the old patch.
  self.types = data.types
  self:_initModules()

  -- Clear and redo all connections (in case something changed).
  for _, module in pairs(self.modules) do
    module:clearConnections()
  end
  self.connections = data.connections
  self:_makeConnections()

  -- Finally, update the interface.
  self.interface = data.interface
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
