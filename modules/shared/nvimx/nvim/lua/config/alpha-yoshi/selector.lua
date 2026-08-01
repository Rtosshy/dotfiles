local M = {}

---@param candidates AlphaYoshiPreset[]
---@param random? fun(): number
---@return AlphaYoshiPreset
function M.weighted(candidates, random)
  local rng = random or math.random
  local total = 0
  for _, candidate in ipairs(candidates) do
    total = total + candidate.weight
  end

  local target, accumulated = rng() * total, 0
  for _, candidate in ipairs(candidates) do
    accumulated = accumulated + candidate.weight
    if target <= accumulated then
      return candidate
    end
  end

  return candidates[1]
end

return M
