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
  };

  config = lib.mkIf config.modules.home.programs.git.enable {
    programs.git = {
      enable = true;
      userName = "Danny Solivan";
      userEmail = "dark@nightconcept.net";

      signing = {
        key = "~/.ssh/id_sdev.pub";
        signByDefault = true;
      };

      extraConfig = {
        gpg = {
          format = "ssh";
          ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        };
        
        tag = {
          gpgSign = true;  # Also sign tags
        };
        
        commit = {
          gpgSign = true;  # Ensure commits are signed
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

        # Automatically rewrite HTTPS URLs to SSH for GitHub
        "url \"git@github.com:\"" = {
          insteadOf = "https://github.com/";
        };

        "url \"git@github.com:\"" = {
          insteadOf = "https://www.github.com/";
        };

        "filter \"lfs\"" = {
          process = "git-lfs filter-process";
          required = true;
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
        };
      };
    };
    
    # Create the allowed signers file for SSH signing verification
    home.file.".ssh/allowed_signers".text = ''
      dark@nightconcept.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJKTm63zFmYfGauCBlUWq7lvHFq+NVPT5RqIfjLM7MN danny@solivan.dev
    '';
  };
}