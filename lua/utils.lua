---Call a function if it exists.
---@param fn any
---@param args any
local function callIfExists(fn, args)
  if fn then
    fn(unpack(args or {}))
  end
end

return {
  callIfExists = callIfExists
}