{
  config,
  lib,
  ...
}:
let
  # Import our custom lib functions
  moduleLib = import ../../../lib/module { inherit lib; };
  inherit (moduleLib) mkBoolOpt enabled disabled;
in
{
  options.modules.home.programs.git = {
    enable = mkBoolOpt true "Enable git with comprehensive configuration";
    userName = lib.mkOption {
      type = lib.types.str;
      default = "Danny Solivan";
      description = "Git user name";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "dark@nightconcept.net";
      description = "Git user email";
    };
    enableSigning = mkBoolOpt true "Enable SSH commit signing (requires SSH module and SOPS secrets)";
  };

  config = lib.mkIf config.modules.home.programs.git.enable (let
    # Only enable signing if explicitly enabled AND we have SSH module
    # SSH module provides public key and allowed_signers file
    signingEnabled = config.modules.home.programs.git.enableSigning 
      && config.modules.home.programs.ssh.enable;
  in {
    programs.git = {
      enable = true;
      userName = config.modules.home.programs.git.userName;
      userEmail = config.modules.home.programs.git.userEmail;

      signing = lib.mkIf signingEnabled {
        key = "~/.ssh/id_sdev.pub";
        signByDefault = true;
      };

      extraConfig = {
        gpg = lib.mkIf signingEnabled {
          format = "ssh";
        };
        
        "gpg \"ssh\"" = lib.mkIf signingEnabled {
          allowedSignersFile = "~/.ssh/allowed_signers";
        };
        
        github = {
          user = "nightconcept";
        };

        alias = {
          del = "branch -D";
          undo = "reset HEAD~ --mixed";
          clear = "!git reset --hard";
        };
        core = {
          excludesfile = "~/.gitnignore";
          editor = "code";
          pager = "delta";
          ignorecase = false;
          rebase = false;
        };

        color = {
          status = "auto";
          diff = "auto";
          branch = "auto";
          interactive = "auto";
          grep = "auto";
          ui = true;
        };

        interactive = {
          diffFitler = "delta --color-only";
        };

        delta = {
          enable = true;
          navigate = true;
          light = false;
          side-by-side = false;
          options.syntax-theme = "catppuccin";
        };

        fetch = {
          prune = false;
        };

        pull = {
          ff = "only";
        };

        push = {
          default = "current";
        };

        rebase = {
          autoStash = true;
          autosquash = true;
        };

        init = {
          defaultBranch = "main";
        };

        hub = {
          protocol = "https";
        };

        "filter \"lfs\"" = {
          process = "git-lfs filter-process";
          required = true;
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
        };
      };
    };
  });
}