Interface = {
  currentPageIndex = 1,
}

local propChangedHandlers = {}
local propChangedTimeout = 1000 -- ms

---Display the prop value and switch back to displaying the prop name if the
---value has not been changed for a certain time.
---@param index number
---@param name string
---@param value number
function Interface._displayPropValue(index, name, value)
  Displays.write(index, value)
  Timer.cancel(propChangedHandlers[index])
  propChangedHandlers[index] = Timer.schedule(function()
    Displays.write(index, name)
    propChangedHandlers[index] = nil
  end, Timer.now() + propChangedTimeout)
end

---@param patch Patch
---@param index number The encoder index.
---@param encoder table
function Interface._displayEncoder(patch, index, encoder)
  local instanceId, propName = unpack(encoder)
  local instance = patch.instances[instanceId]

  if not instance then
    Log.warn(string.format("Instance@%s doesn't exist.", instanceId))
    return
  end

  local prop = instance.__props[propName]
  if not prop then
    Log.warn(
      string.format(
        "Prop '%s' doesn't exist on instance %s",
        propName,
        instance.__name
      )
    )
    return
  end

  Encoders.write(index, prop:encodeValue(instance.props[propName]))
  Displays.write(index, prop.name)
end

function Interface.selectPage(index, updateApp)
  Interface.currentPageIndex = index
  Interface.handlePatchChange(Patches.activePatch)

  for i = 1, 3 do
    -- Mapping page leds are 4, 5, 6 (an offset of 3).
    LEDs.toggle(i + 3, i == index)
  end

  if updateApp then
    Encoders.selectPage(index)
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
---@param instance Module
---@param prop Prop The prop that has changed.
function Interface.handlePropChange(instance, prop, value, shouldWriteValue)
  local patch = Patches.activePatch
  if not (patch and patch.encoders) then
    return
  end

  local encodersPage = patch.encoders[Interface.currentPageIndex]
  for index, encoder in pairs(encodersPage) do
    if encoder[1] == instance.__id and encoder[2] == prop.name then
      Interface._displayPropValue(index, prop.name, prop:getDisplayValue(value))
      if shouldWriteValue then
        Encoders.write(index, prop:encodeValue(value))
      end
      break
    end
  end
end

---@param patch Patch
function Interface.handlePatchChange(patch)
  if not patch.encoders then
    return
  end

  local encodersPage = patch.encoders[Interface.currentPageIndex]
  for index = 1, 3 do
    local encoder = encodersPage[index]
    if encoder then
      Interface._displayEncoder(patch, index, encoder)
    else
      Displays.clear(index, '--')
    end
  end
end
