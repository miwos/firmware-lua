local class = require('class')
local utils = require('utils')

---@class Patch
local Patch = class()

---@class PatchArgs
---@field types table<string, Module>
---@field connections number[]
---@field interface table

---Initialize patch.
---@param args PatchArgs
function Patch:init(args)
  self.types = args.types
  self.connections = args.connections
  self.interface = args.interface
  self.modules = {}

  self:_initModules()
  self:_makeConnections()
  Miwos.input._patch = self
  Miwos.output._patch = self
end

---Initialize modules.
function Patch:_initModules()
  for id, Module in pairs(self.types) do
    local module = Module()
    module._id = id
    module._patch = self
    self.modules[id] = module
  end
end

---Connect modules.
function Patch:_makeConnections()
  for _, connection in pairs(self.connections) do
    local fromId, output, toId, input = unpack(connection)

    local fromModule = fromId == 0 and Miwos.input or self.modules[fromId]
    fromModule:connect(output, toId, input)
  end
end

---Activate the patch and initialize the encoders.
function Patch:activate()
  Miwos.activePatch = self

  local encoders = self.interface.page1.encoders
  for index, encoder in ipairs(encoders) do
    local moduleId, propName = unpack(encoder)
    local module = self.modules[moduleId]
    local prop = module and module._props[propName]
    if prop then
      local rawValue = prop:encodeValue(prop.default)
      Encoder.write(index, rawValue)
      Log.info(string.format('Write encoder#%d: %d', index, rawValue))
    end
  end
end

---Update a single module instance.
---@param id any
---@param module Module
---@param NewModule Module
function Patch:_updateModuleInstance(id, module, NewModule)
  local state = module:_saveState()
  local newModule = NewModule()
  newModule:_applyState(state)
  newModule._id = id
  newModule._patch = self
  module:destroy()
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

return Patch
