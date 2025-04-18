# WARNING: Keep this file encrypted
{config, ...}: {
  programs.git = {
    enable = true;
    userName = "Danny Solivan";
    userEmail = "dark@nightconcept.net";

    signing = {
      key = "432928BF8B0A767DB68A01451C5E44D950920340";
      signByDefault = true;
    };

    extraConfig = {
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
}
