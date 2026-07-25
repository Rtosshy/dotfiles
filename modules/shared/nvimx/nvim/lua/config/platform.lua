if vim.fn.has('mac') ~= 1 then
  return
end

require('platform.yoshi-error')
require('platform.yoshi-paste')
require('platform.yoshi-yank')
