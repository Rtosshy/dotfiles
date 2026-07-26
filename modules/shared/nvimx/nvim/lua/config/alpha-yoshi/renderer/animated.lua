local M = {}

---@class AlphaYoshiAnimatedContext
---@field draw fun(frame: integer)
---@field clear fun()
---@field frame_count fun(): integer
---@field frame_delay_ms fun(): integer
---@field is_active fun(): boolean

---@param context AlphaYoshiAnimatedContext
---@return AlphaYoshiRenderer
function M.new(context)
  local current_frame = 1
  local running = false
  local generation = 0

  local function start()
    if running then
      return
    end

    running = true
    generation = generation + 1
    local current_generation = generation
    local function tick()
      if current_generation ~= generation then
        return
      end
      if not context.is_active() then
        running = false
        generation = generation + 1
        context.clear()
        return
      end

      context.draw(current_frame)
      current_frame = (current_frame % context.frame_count()) + 1
      vim.defer_fn(tick, context.frame_delay_ms())
    end
    tick()
  end

  local function stop()
    if running then
      running = false
      generation = generation + 1
      context.clear()
    end
  end

  local function reset()
    current_frame = 1
  end

  ---@type AlphaYoshiRenderer
  local renderer = {
    start = start,
    stop = stop,
    reset = reset,
  }
  return renderer
end

return M
