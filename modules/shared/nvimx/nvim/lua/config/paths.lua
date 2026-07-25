local uv = vim.uv or vim.loop
local config_dir = uv.fs_realpath(vim.fn.stdpath('config')) or vim.fn.stdpath('config')

local function find_repo_root()
  local candidate = config_dir
  for _ = 1, 8 do
    if uv.fs_stat(candidate .. '/assets/frames') then
      return candidate
    end
    local parent = vim.fn.fnamemodify(candidate, ':h')
    if parent == candidate then
      break
    end
    candidate = parent
  end
  return config_dir
end

local repo_root = find_repo_root()

return {
  repo = repo_root,
  asset = function(relative)
    return repo_root .. '/assets/' .. relative
  end,
}
