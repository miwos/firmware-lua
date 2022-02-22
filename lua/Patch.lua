local class = require('class')

---@class Patch
---@field name string Same as file name, will be set by `Patches.loadPatch()`.
---@field instances table<string, Module>
---@field connections number[]
---@field mapping MappingPage[]
local Patch = class()

---@class PatchData
---@field instances table<string, PatchDataInstance>
---@field connections number[]
---@field mapping MappingPage[]

---@class PatchDataInstance
---@field Module Module
---@field props table<string, number>

---@class MappingPage
---@field encoders table[]

---Initialize patch.
---@param data PatchData
function Patch:constructor(data)
  self.data = data
  self.mapping = data.mapping
  self.connections = data.connections
  self.instances = {}
  self:_createMissingInstances()
  self:_makeConnections()
end

---Initialize modules.
function Patch:_createMissingInstances()
  for id, definition in pairs(self.data.instances) do
    if not self.instances[id] then
      ---@type Module
      local instance = definition.Module()
      instance.__id = id
      instance.__name = instance.__type .. '@' .. instance.__id
      self.instances[id] = instance

      if definition.props then
        for name, value in pairs(definition.props) do
          local prop = instance.__props[name]
          if prop then
            prop:__setValue(instance, value)
          else
            Log.warn(
              "Prop '"
                .. name
                .. "' doesn't exist on "
                .. instance.__type
                .. '@'
                .. id
            )
          end
        end
      end
    end
  end
end

---Connect modules.
function Patch:_makeConnections()
  for _, connection in pairs(self.connections) do
    local fromId, output, toId, input = unpack(connection)
    assert(self.instances[fromId], 'Instance@' .. fromId .. " doesn't exist.")
    self.instances[fromId]:__connect(output, toId, input)
  end
end

function Patch:_clearConnections()
  for _, instance in pairs(self.instances) do
    instance:__clearConnections()
  end
end

---Activate the patch and initialize the encoders.
function Patch:activate()
  Patches.activePatch = self
  Interface.handlePatchChange(self)
end

function Patch:getProp(instanceId, propName)
  local instance = self.instances[instanceId]
  return instance and instance.__props[propName]
end

---@param encoderIndex number
---@return number, string -- InstanceId and prop name.
function Patch:getMappedProp(encoderIndex)
  if not self.mapping then
    return
  end

  local encoders = self.mapping[Interface.currentPageIndex].encoders
  local encoder = encoders[encoderIndex]
  if not encoder then
    Log.warn('Encoder #' .. encoderIndex .. " isn't mapped to anything.")
    return
  end

  local instanceId, propName = unpack(encoder)
  return instanceId, propName
end

function Patch:handlePropClick(instanceId, propName)
  self.instances[instanceId].__emit('prop:change', propName)
end

---@param data PatchData
function Patch:update(data)
  self.data = data
  self.connections = data.connections
  self.mapping = data.mapping

  -- Remove unused instances and modules.
  local removeIds = {}
  local keepModules = {}

  for id, instance in pairs(self.instances) do
    if data.instances[id] then
      keepModules[instance.__type] = true
    else
      table.insert(removeIds, id)
    end
  end

  for _, instance in pairs(self.instances) do
    if not keepModules[instance.__type] then
      _G._LOADED['modules.' .. instance.__type] = nil
    end
  end

  for _, id in pairs(removeIds) do
    self.instances[id] = nil
  end

  -- This will only create new instances that were not already part of patch.
  self:_createMissingInstances()

  -- Clear and redo all connections in case something changed.
  self:_clearConnections()
  self:_makeConnections()

  Interface.handlePatchChange(self)
end

---Update a single module instance.
---@param id any
---@param instance Module
---@param NewModule Module
function Patch:_updateInstance(id, instance, NewModule)
  local state = instance:__saveState()
  instance:__destroy()

  local newInstance = NewModule()
  newInstance:__applyState(state)
  newInstance.__id = id

  self.instances[id] = newInstance
end

---Update all module instances of the specified Module.
---@param type string
---@param NewModule Module
function Patch:updateModule(type, NewModule)
  local updatedModule = false
  for id, instance in pairs(self.instances) do
    if instance.__type == type then
      self:_updateInstance(id, instance, NewModule)
      updatedModule = true
    end
  end

  -- If we changed an instance we have to redo the connections.
  if updatedModule then
    self:_clearConnections()
    self:_makeConnections()
  end
end

function Patch:destroy()
  for _, module in pairs(self.instances) do
    module:__destroy()
  end
end

return Patch
