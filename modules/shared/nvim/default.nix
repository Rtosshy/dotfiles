{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    nixpkgs.source = pkgs.path;
    imports = [
      ./core/options.nix
      ./core/autocmds.nix
      ./core/commands.nix
      ./core/keymaps.nix
      ./core/autoreload.nix

      ./plugins/oil.nix
      ./plugins/ui.nix
      ./plugins/noice.nix
      ./plugins/telescope.nix
      ./plugins/flash.nix
      ./plugins/treesitter.nix
      ./plugins/completion.nix
      ./plugins/autopairs.nix
      ./plugins/lsp.nix
      ./plugins/formatting.nix
      ./plugins/trouble.nix
      ./plugins/gitsigns.nix
      ./plugins/diffview.nix
      ./plugins/lazygit.nix
      ./plugins/devdocs.nix
      ./plugins/alpha.nix
      ./plugins/live-share.nix
      ./plugins/lz-n.nix
    ];
  };
}
