Interface = {
  activePage = 1,
}

---Write a property to the display.
---@param displayIndex any
---@param prop table
function Interface:_displayProp(displayIndex, prop)
  Display.write(displayIndex, prop.name .. ': ' .. prop:getDisplayValue())
end

---Check if the prop is mentioned in the interface description of the patch, and
---if so, write the prop in the corresponding display.
---@param prop Prop The prop that has changed.
function Interface:propChange(prop)
  local patch = Miwos.activePatch

  local encoders = patch.interface.page1.encoders
  for index, encoder in pairs(encoders) do
    if encoder[1] == prop.module._id and encoder[2] == prop.name then
      self:_displayProp(index, prop)
    end
  end
end

---@param patch Patch
function Interface:patchChange(patch)
  local encoders = patch.interface.page1.encoders
  for index, encoder in ipairs(encoders) do
    local moduleId, propName = unpack(encoder)
    local module = patch.modules[moduleId]
    local prop = module and module.props._props[propName]
    if prop then
      Encoder.write(index, prop:getRawValue())
      self:_displayProp(index, prop)
    end
  end
end
