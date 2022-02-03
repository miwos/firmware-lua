Interface = {
  currentPageIndex = 1,
}

local propChangedTimers = {}
local propChangedTimeout = 1000 -- ms

---Display the prop name (default behaviour).
---@param index any
---@param prop any
function Interface._displayPropName(index, prop)
  Displays.write(index, prop.name)
end

---Display the prop value and switch back to displaying the prop name if the
---value has not been changed for a certain time.
function Interface._displayPropValue(index, prop)
  Displays.write(index, prop:getDisplayValue())

  Timer.cancel(propChangedTimers[index])
  propChangedTimers[index] = Timer.schedule(
    Timer.now() + propChangedTimeout,
    function()
      Displays.write(index, prop.name)
    end
  )
end

function Interface.selectPage(index)
  Interface.currentPageIndex = index
  Log.info('Select page ' .. index)
end

---Check if the prop is mentioned in the interface description of the patch, and
---if so, write the prop in the corresponding display.
---@param prop Prop The prop that has changed.
function Interface.propChange(prop, shouldWriteValue)
  local patch = Patches.activePatch
  if not patch.mapping then
    return
  end

  local encoders = patch.mapping[1].encoders
  for index, encoder in pairs(encoders) do
    if encoder[1] == prop.instance._id and encoder[2] == prop.name then
      Interface._displayPropValue(index, prop)
      if shouldWriteValue then
        Encoders.write(index, prop:getRawValue())
      end
      break
    end
  end
end

---@param patch Patch
function Interface.patchChange(patch)
  if not patch.mapping then
    return
  end

  local encoders = patch.mapping[1].encoders
  for index, encoder in ipairs(encoders) do
    local instanceId, propName = unpack(encoder)
    local instance = patch.instances[instanceId]

    if not instance then
      Log.warn('Module #' .. instanceId .. " doesn't exist.")
      return
    end

    local prop = instance.props._props[propName]
    if not prop then
      Log.warn('Prop `' .. propName .. "` doesn't exist.")
      return
    end

    Encoders.write(index, prop:getRawValue())
    Displays.write(index, prop.name)
  end
end
