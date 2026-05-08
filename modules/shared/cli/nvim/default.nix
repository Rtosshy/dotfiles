{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim

    ./core/options.nix
    ./core/autocmds.nix
    ./core/keymaps.nix

    ./plugins/ui.nix
    ./plugins/oil.nix
    ./plugins/telescope.nix
    ./plugins/treesitter.nix
    ./plugins/lsp.nix
    ./plugins/formatting.nix
    ./plugins/trouble.nix
    ./plugins/lazygit.nix
    ./plugins/devdocs.nix
    ./plugins/alpha.nix
    ./plugins/yoshi-error.nix
    ./plugins/yoshi-yank.nix
    ./plugins/yoshi-paste.nix
  ];

  programs.nixvim.enable = true;
}
