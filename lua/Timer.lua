local utils = require('utils')

-- The global Timer object might have already been created by c++.
Timer = _G.Timer or {}
Timer.events = {}

function Timer.update(now)
  local finishedCallbacks = {}

  for callback, time in pairs(Timer.events) do
    if time <= now then
      -- TODO: check if canceling the timer before calling the callback has any
      -- TODO: consequences (need for interval to work)
      Timer.events[callback] = nil
      finishedCallbacks[#finishedCallbacks + 1] = callback
    end
  end

  for _, callback in ipairs(finishedCallbacks) do
    callback()
  end
end

---Schedule an event.
---@param callback function The callback function.
---@param time number The time of the event in milliseconds.
---@return function callback The provided callback
function Timer.schedule(callback, time)
  Timer.events[callback] = time
  return callback
end

function Timer.interval(callback, interval)
  local function _callback()
    callback()
    Timer.schedule(_callback, Timer.now() + interval)
  end
  return Timer.schedule(_callback, Timer.now() + interval)
end

---Reschedule an event (the same as scheduling an event, as the callback is used
---as the unique event key).
---@param callback function The callback function.
---@param time number The time of the event in milliseconds.
---@return function callback The provided callback
function Timer.reschedule(callback, time)
  Timer.events[callback] = time
end

---Cancel an event.
---@param callback function
function Timer.cancel(callback)
  if callback then
    Timer.events[callback] = nil
  end
end
