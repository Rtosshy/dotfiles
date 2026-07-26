local M = {}
local uv = vim.uv or vim.loop

---@param candidates AlphaYoshiPreset[]
---@return AlphaYoshiPreset
function M.weighted(candidates)
  local total = 0
  for _, candidate in ipairs(candidates) do
    total = total + candidate.weight
  end

  math.randomseed(os.time() + (uv.hrtime() % 1000000))
  local target, accumulated = math.random() * total, 0
  for _, candidate in ipairs(candidates) do
    accumulated = accumulated + candidate.weight
    if target <= accumulated then
      return candidate
    end
  end

  return candidates[1]
end

return M
