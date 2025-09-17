{
  pkgs,
  config,
  ...
}: {
  home.sessionPath = [
    "/home/danny/.local/bin"
    "/opt/nvim-linux64/bin"
  ] ++ (if pkgs.stdenv.isDarwin then [
    "/usr/local/bin"
    "/opt/homebrew/bin"  
    "/Users/danny/.local/bin"
  ] else []);

  programs.fish = {
    enable = true;

    shellAliases =
      {
        # Git aliases
        gs = "${pkgs.git}/bin/git status -sb";
        gcm = "${pkgs.git}/bin/git checkout master";
        gaa = "${pkgs.git}/bin/git add --all";
        gc = "${pkgs.git}/bin/git commit -m";
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
        fishclear = "echo \"\" > ~/.local/share/fish/fish_history";

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

    shellInit = ''
      # Set environment variables
      set -gx EDITOR nvim
      set -gx BROWSER firefox
      set -gx TERMINAL wezterm
      set -gx LANG en_US.UTF-8
      set -gx VISUAL nvim
      set -gx GPG_TTY (tty)
      set -gx XDG_DATA_DIRS /home/danny/.nix-profile/share $XDG_DATA_DIRS

      # Load API keys from sops if available
      if test -r "$XDG_RUNTIME_DIR/secrets/gemini_api_key"
          set -gx GEMINI_API_KEY (cat "$XDG_RUNTIME_DIR/secrets/gemini_api_key")
      end

      # Shell integrations
      starship init fish | source
      zoxide init fish | source
      any-nix-shell fish --info-right | source

      # Conditional brew setup
      if test -d "/home/linuxbrew/"
          eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
      end
    '';

    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }
    ];

    functions = {
      fish_greeting = {
        description = "Greeting to show when starting a fish shell";
        body = "";
      };
    };
  };
}