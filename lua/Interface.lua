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

  local timerId = propChangedTimers[index]
  if timerId == nil then
    propChangedTimers[index] = Timer.schedule(
      Timer.now() + propChangedTimeout,
      function()
        Displays.write(index, prop.name)
        propChangedTimers[index] = nil
      end
    )
  else
    Timer.reschedule(timerId, Timer.now() + propChangedTimeout)
  end
end

function Interface.selectPage(index, shouldUpdateBridge)
  Interface.currentPageIndex = index
  Interface.handlePatchChange(Patches.activePatch)

  for i = 1, 3 do
    -- Mapping page leds are 4, 5, 6 (an offset of 3).
    LEDs.toggle(i + 3, i == index)
  end

  if shouldUpdateBridge then
    Bridge.sendSelectMappingPage(index)
  end
end

function Interface.handleClick(buttonIndex)
  if buttonIndex == 4 then
    Interface.selectPage(1, true)
  elseif buttonIndex == 5 then
    Interface.selectPage(2, true)
  elseif buttonIndex == 6 then
    Interface.selectPage(3, true)
  end
end

---Check if the prop is mentioned in the interface description of the patch, and
---if so, write the prop in the corresponding display.
---@param prop Prop The prop that has changed.
function Interface.handlePropChange(prop, shouldWriteValue)
  local patch = Patches.activePatch
  if not (patch and patch.mapping) then
    return
  end

  local encoders = patch.mapping[Interface.currentPageIndex].encoders
  for index, encoder in pairs(encoders) do
    if encoder[1] == prop.instance.__id and encoder[2] == prop.name then
      Interface._displayPropValue(index, prop)
      if shouldWriteValue then
        Encoders.write(index, prop:getRawValue())
      end
      break
    end
  end
end

---@param patch Patch
function Interface.handlePatchChange(patch)
  if not patch.mapping then
    return
  end

  local encoders = patch.mapping[Interface.currentPageIndex].encoders
  for index = 1, 3 do
    local encoder = encoders[index]

    if encoder then
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
    else
      Displays.clear(index, '--')
    end
  end
end
