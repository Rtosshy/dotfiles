{
  pkgs,
  nvimx,
  lockDir,
  extraPackages,
}:

let
  nvimxLib = import "${nvimx}/nix/lib" {
    inherit pkgs;
    lazyNvimSeed = nvimx.lib.lazyNvimSeed;
  };

  baseEnv = nvimxLib.makeEnv {
    package = pkgs.neovim-unwrapped;
    inherit lockDir extraPackages;
  };

  # nvimx records lazy.nvim's build metadata in the lock, but does not yet
  # execute plugin builds. Use nixpkgs' derivations for the two native plugins.
  # They are pinned to the same revisions by this repository's flake.lock.
  pluginDrvs = baseEnv.pluginDrvs // {
    "blink.cmp" = pkgs.vimPlugins.blink-cmp;
    "telescope-fzf-native.nvim" = pkgs.vimPlugins.telescope-fzf-native-nvim;
  };

  farm = pkgs.linkFarm "nvimx-plugins" (
    [
      {
        name = "lazy.nvim";
        path = "${baseEnv.farm}/lazy.nvim";
      }
    ]
    ++ pkgs.lib.mapAttrsToList (name: path: { inherit name path; }) pluginDrvs
  );

  bootstrap = import "${nvimx}/nix/lib/bootstrap.nix" { inherit pkgs; } { inherit farm; };
  wrapped = import "${nvimx}/nix/lib/wrapper.nix" { inherit pkgs; } {
    package = pkgs.neovim-unwrapped;
    inherit bootstrap extraPackages;
  };
in
baseEnv
// {
  inherit
    bootstrap
    farm
    pluginDrvs
    wrapped
    ;
}
