local class = require('class')

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
  for id, Ctor in pairs(self.types) do
    local module = Ctor()
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

---Activate the patch.
function Patch:activate()
  Miwos.activePatch = self

  local encoders = self.interface.page1.encoders

  for index, encoder in ipairs(encoders) do
    local moduleId, moduleParam = unpack(encoder)
    local module = self.modules[moduleId]
    if module then
      local value = module.params[moduleParam]
      Encoder.write(index - 1, value)
      Log.info('Write: ', moduleParam, index, value)
    end
  end
end

return Patch
