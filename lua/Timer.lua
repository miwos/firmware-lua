local utils = require('utils')

-- The global Timer object might have already been created by c++.
Timer = _G.Timer or {}
Timer.events = {}

function Timer.update(now)
  for callback, time in pairs(Timer.events) do
    if time <= now then
      callback()
      Timer.events[callback] = nil
    end
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
