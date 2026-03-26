if vim.g.vscode then
  require('config.vscode')
else
  require('config.native')
end

require('config.always')
