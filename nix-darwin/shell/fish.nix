{ ... }: {
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
      drs = {
        expansion = "darwin-rebuild switch --flake ~/ghq/github.com/Rtosshy/dotfiles/nix-darwin";
        position = "anywhere";
      };
    };

    shellInit = ''
      set -gx CLAUDE_CONFIG_DIR $HOME/.claude
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
}
