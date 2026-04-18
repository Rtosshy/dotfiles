-- Neovim 0.12 では tree-sitter のハイライトエンジンはネイティブだが、
-- 各言語のパーサー (.so) とクエリファイル (highlights.scm) が別途必要。
-- nvim-treesitter はそれらの配布・管理を担うプラグインとして利用する。
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup({
        ensure_installed = {
          'lua',
          'go',
          'rust',
          'yaml',
          'bash',
          'fish',
          'c',
          'cpp',
          'nix',
        },
      })

      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}
