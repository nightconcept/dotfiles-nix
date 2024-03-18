{config, ...}: {
  programs.git = {
    enable = true;
    userName = "Danny Solivan";
    userEmail = "dark@nightconcept.net";

    extraConfig = {
      github = {
        user = "nightconcept";
      };
      core = {
        excludesfile = "~/.gitnignore";
        editor = "nvim";
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

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --color-only --dark --paging=never";
          useConfig = false;
        };
      };
    };
  };
}
