{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    extraPackages = with pkgs; [
      # Essential tools for AstroNvim
      ripgrep
      fd
      git
      
      # Language servers
      lua-language-server  # Lua/Neovim config
      nil                  # Nix
      nodePackages.typescript-language-server  # TypeScript/JavaScript
      nodePackages.bash-language-server        # Bash
      pyright                                   # Python
      rust-analyzer                             # Rust
      
      # Formatters
      stylua               # Lua formatter
      nixfmt-rfc-style    # Nix formatter
      nodePackages.prettier # JS/TS/JSON formatter
      rustfmt                                   # Rust formatter
    ];
    
    extraLuaConfig = ''
      -- Bootstrap lazy.nvim
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
      end
      vim.opt.rtp:prepend(lazypath)

      -- Set up leaders before loading plugins
      vim.g.mapleader = " "
      vim.g.maplocalleader = ","

      -- Bootstrap AstroNvim
      require("lazy").setup({
        -- AstroNvim core
        {
          "AstroNvim/AstroNvim",
          version = "^4",
          import = "astronvim.plugins",
          opts = {
            colorscheme = "tokyonight",
          },
        },
        -- Tokyo Night theme
        {
          "folke/tokyonight.nvim",
          priority = 1000,
          opts = {
            style = "night",
            transparent = false,
            terminal_colors = true,
          },
        },
      }, {
        install = { colorscheme = { "tokyonight" } },
        checker = { enabled = false },
        performance = {
          rtp = {
            disabled_plugins = {
              "gzip",
              "matchit",
              "matchparen", 
              "netrwPlugin",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
      })

      -- Basic settings
      vim.opt.termguicolors = true
      
      -- Custom keymaps
      local map = vim.keymap.set
      
      -- Save file with Ctrl+s
      map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
      map("i", "<C-s>", "<Esc><cmd>w<cr>a", { desc = "Save file" })
      
      -- New file with Ctrl+n  
      map("n", "<C-n>", "<cmd>enew<cr>", { desc = "New file" })
      
      -- AstroNvim uses Ctrl+hjkl by default for window navigation, which works perfectly
      -- with our keybind hierarchy (no conflicts with terminal tools)
    '';
  };
}