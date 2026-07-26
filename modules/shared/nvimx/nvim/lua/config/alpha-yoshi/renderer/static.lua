local M = {}

---@class AlphaYoshiStaticContext
---@field draw fun(frame: integer)
---@field clear fun()

---@param context AlphaYoshiStaticContext
---@return AlphaYoshiRenderer
function M.new(context)
  local function start()
    context.draw(1)
  end

  local function stop()
    context.clear()
  end

  local function reset() end

  ---@type AlphaYoshiRenderer
  local renderer = {
    start = start,
    stop = stop,
    reset = reset,
  }

  return renderer
end

return M
