{
  pkgs,
  config,
  ...
}: {
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    oh-my-zsh = {
      enable = false;
      plugins = [
        "alias-finder"
        "brew"
        "eza"
        "z"
      ];
      extraConfig = ''
        zstyle ':omz:update' mode auto # update automatically without asking
        zstyle ':omz:update' frequency 13
      '';
    };

    zplug = {
      enable = true;
      plugins = [
        {name = "zsh-users/zsh-autosuggestions";}
        {name = "zsh-users/zsh-syntax-highlighting";}
        {name = "zsh-users/zsh-completions";}
        {name = "zsh-users/zsh-history-substring-search";}
        {name = "chisui/zsh-nix-shell";}
        {name = "nix-community/nix-zsh-completions";}
      ];
    };

    shellAliases =
      {
        # Git aliases
        gs = "${pkgs.git}/bin/git status -sb";
        gcm = "${pkgs.git}/bin/git checkout master";
        gaa = "${pkgs.git}/bin/git add --all";
        gc = "${pkgs.git}/bin/git commit -m $2";
        push = "${pkgs.git}/bin/git push";
        gpo = "${pkgs.git}/bin/git push origin";
        pull = "${pkgs.git}/bin/git pull";
        clone = "${pkgs.git}/bin/git clone";
        stash = "${pkgs.git}/bin/git stash";
        pop = "${pkgs.git}/bin/git stash pop";
        ga = "${pkgs.git}/bin/git add";
        gb = "${pkgs.git}/bin/git branch";
        gl = "${pkgs.git}/bin/git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        gm = "${pkgs.git}/bin/git merge";
        gdev = "${pkgs.git}/bin/git checkout main && ${pkgs.git}/bin/git fetch origin --prune && ${pkgs.git}/bin/git reset --hard origin/main && ${pkgs.git}/bin/git branch dev && ${pkgs.git}/bin/git checkout dev && ${pkgs.git}/bin/git reset --hard main && ${pkgs.git}/bin/git push origin dev --force";

        # Neovim aliases
        vi = "${pkgs.neovim}/bin/nvim";
        vim = "${pkgs.neovim}/bin/nvim";
        e = "$EDITOR";

        # General aliases
        "." = "z .";
        ".." = "z ..";
        "..." = "z ../../";
        "...." = "z ../../../";
        "....." = "z ../../../../";
        cd = "z";
        cls = "clear";
        ls = "${pkgs.eza}/bin/eza -F --color=auto";
        ll = "${pkgs.eza}/bin/eza -l";
        "ll." = "${pkgs.eza}/bin/eza -la";
        lls = "${pkgs.eza}/bin/eza -la --sort=size";
        llt = "${pkgs.eza}/bin/eza -la --sort=time";
        cat = "${pkgs.bat}/bin/bat";
        rm = "${pkgs.coreutils}/bin/rm -iv";
        mkdir = "${pkgs.coreutils}/bin/mkdir -p";
        cp = "${pkgs.coreutils}/bin/cp -r";
        zshclear = "echo \"\" > ~/.zsh_history";

        # Platform-specific flake rebuild
        flake-rebuild =
          if pkgs.stdenv.isLinux
          then "sudo nixos-rebuild switch --flake"
          else "sudo darwin-rebuild switch --flake";

        # Home Manager rebuild
        home-rebuild = "home-manager switch --flake";
      }
      // (
        if pkgs.stdenv.isLinux
        then {
          apt = "sudo apt";
        }
        else {}
      );

    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "firefox";
      TERMINAL = "wezterm";
    };

    initContent = ''

      # Path exports
      export PATH="/home/danny/.local/bin:$PATH"
      export PATH="$PATH:/opt/nvim-linux64/bin"

      # macOS only exports
      if [[ "$OSTYPE" == "darwin"* ]]; then
        export PATH="/usr/local/bin:$PATH"    # arm64e homebrew path (m1   )
        export PATH="/opt/homebrew/bin:$PATH" # x86_64 homebrew path (intel)
        export PATH="/Users/danny/sdk/flutter/bin:$PATH"
        export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
        export PATH="/Users/danny/.local/bin:$PATH"

      fi

      # Other exports
      export LANG=en_US.UTF-8
      export ZSH="$HOME/.oh-my-zsh"
      export VISUAL=nvim
      export XDG_DATA_DIRS="/home/danny/.nix-profile/share:$XDG_DATA_DIRS"

      # enable passphrase prompt for gpg
      export GPG_TTY=$(tty)

      # Evals
      eval "$(starship init zsh)"
      eval "$(zoxide init zsh)"

      if [ -d "/home/linuxbrew/" ]; then
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      fi
    '';
  };
}
