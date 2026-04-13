{ pkgs, ... }: {
  home.username = "tosshy";
  home.homeDirectory = "/Users/tosshy";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    ripgrep
    bat
    neovim
    gh
    ghq
    peco
    eza
    lazygit
    claude-code
    wezterm
  ];

  programs.fish = {
    enable = true;

    functions = {
      peco_select_history_order = ''
        if test (count $argv) = 0
            set peco_flags --layout=top-down
        else
            set peco_flags --layout=bottom-up --query "$argv"
        end
        history | peco $peco_flags | read foo
        if [ $foo ]
            commandline $foo
        else
            commandline ""
        end
      '';

      history = ''
        builtin history --show-time='%Y/%m/%d %H:%M:%S ' | sort
      '';

      peco_ghq = ''
        set -l query (commandline)
        if test -n $query
            set peco_flags --query "$query"
        end
        ghq list --full-path | peco $peco_flags | read recent
        if [ $recent ]
            cd $recent
            commandline -r ""
            commandline -f repaint
        end
      '';

      fish_user_key_bindings = ''
        bind \cr peco_select_history_order
        bind \co peco_ghq
      '';
    };

    shellAbbrs = {
      sc = "source $HOME/.config/fish/config.fish";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      ls = "eza --icons";
      ll = "eza --icons -lhg --time-style long-iso";
      la = "eza --icons -lhag --time-style long-iso";
      lt = "eza --icons --tree";
      grep = "rg";
      cat = "bat";
    };

    shellInit = ''
      set -gx CLAUDE_CONFIG_DIR $HOME/.claude
      set -gx TMUX_THEME nord
    '';

    interactiveShellInit = ''
      set -g fish_greeting ""

      # Syntax highlight colors
      set -g fish_color_command green --bold
      set -g fish_color_param white
      set -g fish_color_option cyan
      set -g fish_color_quote yellow
      set -g fish_color_error red --bold
      set -g fish_color_autosuggestion brblack
      set -g fish_color_valid_path --underline
      set -g fish_color_operator magenta
      set -g fish_color_escape cyan
      set -g fish_color_comment brblack
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.mise.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      format = "[░▒▓](#a3aed2)[  ](bg:#a3aed2 fg:#090c0c)[](bg:#769ff0 fg:#a3aed2)$directory[](fg:#769ff0 bg:#394260)$git_branch$git_status[](fg:#394260 bg:#212736)$nodejs$rust$golang$php[](fg:#212736 bg:#1d2230)$time[ ](fg:#1d2230)\n$character";

      directory = {
        style = "fg:#e3e5e5 bg:#769ff0";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:#394260";
        format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
      };

      git_status = {
        style = "bg:#394260";
        format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      php = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:#1d2230";
        format = "[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    options = [ "--cmd" "cd" ];
  };
}

