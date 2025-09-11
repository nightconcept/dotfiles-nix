{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (builtins) map;
  inherit (lib.strings) concatStrings;

  # Tokyo Night colors
  red = "#f7768e";
  orange = "#ff9e64";
  yellow = "#e0af68";
  light_yellow = "#cfc9c2";
  green = "#9ece6a";
  teal = "#73daca";
  light_teal = "#b4f9f8";
  cyan = "#2ac3de";
  light_blue = "#7dcfff";
  blue = "#7aa2f7";
  magenta = "#bb9af7";
  white = "#c0caf5";
  foreground = "#a9b1d6";
  foreground_gutter = "#9aa5ce";
  comment = "#565f89";
  dark_gray = "#3b4261";
  black = "#414868";
  bg = "#1a1b26";
  bg_highlight = "#292e42";
  bg_dark = "#16161e";
  segment_bg = dark_gray; # Background for segments matching gradient
  terminal_black = black;
  fg = foreground;
  fg_dark = foreground_gutter;
in {
  programs.starship = {
    enable = true;

    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      # Format with box drawing characters and gradient blocks - matches P10k style
      format = "$line_break[╭─](${comment})[░▒▓](${segment_bg})$os$username$hostname[ ](fg:${segment_bg} bg:${segment_bg})[ ](fg:${white} bg:${segment_bg})$directory[](fg:${segment_bg})$git_branch$git_status[](fg:${segment_bg})$fill[](fg:${segment_bg})$status$cmd_duration$all$nix_shell$time[▓▒░](${segment_bg})[─╮](${comment})$line_break[╰─](${comment})$character";

      # Right prompt format
      right_format = "[─╯](${comment})";

      # Add newline before prompt like P10k
      add_newline = true;

      palette = "tokyo_night";

      palettes.tokyo_night = {
        red = "${red}";
        orange = "${orange}";
        yellow = "${yellow}";
        light_yellow = "${light_yellow}";
        green = "${green}";
        teal = "${teal}";
        light_teal = "${light_teal}";
        cyan = "${cyan}";
        light_blue = "${light_blue}";
        blue = "${blue}";
        magenta = "${magenta}";
        white = "${white}";
        foreground = "${foreground}";
        foreground_gutter = "${foreground_gutter}";
        comment = "${comment}";
        dark_gray = "${dark_gray}";
        black = "${black}";
        bg = "${bg}";
        bg_highlight = "${bg_highlight}";
        bg_dark = "${bg_dark}";
        segment_bg = "${segment_bg}";
        terminal_black = "${terminal_black}";
        fg = "${fg}";
        fg_dark = "${fg_dark}";
      };

      # Fill module to create the extended line
      fill = {
        symbol = "─";
        style = "fg:${comment}";
      };

      # OS module - show OS icon
      os = {
        disabled = false;
        style = "fg:${white} bg:${segment_bg}";
        format = "[ $symbol]($style)";
        symbols = {
          Windows = "";
          Ubuntu = "󰕈";
          SUSE = "";
          Raspbian = "󰐿";
          Mint = "󰣭";
          Macos = "󰀵";
          Manjaro = "";
          Linux = "󰌽";
          Gentoo = "󰣨";
          Fedora = "󰣛";
          Alpine = "";
          Amazon = "";
          Android = "";
          Arch = "󰣇";
          Artix = "󰣇";
          CentOS = "";
          Debian = "";
          Redhat = "󱄛";
          RedHatEnterprise = "󱄛";
        };
      };

      # Username - only show on SSH
      username = {
        show_always = false;
        style_user = "fg:${cyan} bg:${segment_bg} bold";
        style_root = "fg:${red} bg:${segment_bg} bold";
        format = "[$user]($style)";
      };

      # Hostname - only show on SSH
      hostname = {
        ssh_only = true;
        format = "[@$hostname ](fg:${cyan} bg:${segment_bg} bold)";
        disabled = false;
      };

      # Directory with proper spacing and separator
      directory = {
        style = "fg:${cyan} bg:${segment_bg} bold";
        format = "[   $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        truncate_to_repo = false;
      };

      # Git branch
      git_branch = {
        symbol = "";
        style = "fg:${magenta} bg:${segment_bg}";
        format = "[ on ](fg:${foreground_gutter} bg:${segment_bg})[$symbol $branch ]($style)";
      };

      # Git status - with file counts like P10k
      git_status = {
        style = "fg:${red} bg:${segment_bg}";
        format = "[$ahead_behind$all_status]($style)";
        conflicted = "~$count ";
        ahead = "[⇡$count ](fg:${magenta} bg:${segment_bg})";
        behind = "[⇣$count ](fg:${magenta} bg:${segment_bg})";
        diverged = "[⇕$ahead_count ⇣$behind_count ](fg:${magenta} bg:${segment_bg})";
        up_to_date = "";
        untracked = "?$count ";
        stashed = "*$count ";
        modified = "!$count ";
        staged = "+$count ";
        renamed = "»$count ";
        deleted = "✘$count ";
      };

      # Status - show success/error symbol with background
      status = {
        style = "fg:${green} bg:${segment_bg}";
        success_symbol = "[✔](fg:${green} bg:${segment_bg})";
        error_symbol = "[✗](fg:${red} bg:${segment_bg})";
        format = "[ $symbol ]($style)";
        map_symbol = false;
        disabled = false;
      };

      # Command duration with background
      cmd_duration = {
        min_time = 3000;
        show_milliseconds = false;
        style = "fg:${yellow} bg:${segment_bg}";
        format = "[](fg:${white} bg:${segment_bg})[ took $duration ]($style)";
      };

      # Nix shell with background
      nix_shell = {
        style = "fg:${blue} bg:${segment_bg} bold";
        format = "[](fg:${white} bg:${segment_bg})[ $state  ]($style)";
        impure_msg = "impure ";
        pure_msg = "pure ";
        unknown_msg = "";
      };

      # Time with background
      time = {
        disabled = false;
        time_format = "%H:%M:%S";
        style = "fg:${comment} bg:${segment_bg}";
        format = "[](fg:${white} bg:${segment_bg})[ at $time ]($style)";
      };

      # Line break
      line_break = {
        disabled = false;
      };

      # Character - prompt symbol
      character = {
        disabled = false;
        success_symbol = "[❯](bold fg:${green})";
        error_symbol = "[❯](bold fg:${red})";
        vimcmd_symbol = "[❮](bold fg:${green})";
        vimcmd_replace_one_symbol = "[❮](bold fg:${magenta})";
        vimcmd_replace_symbol = "[❮](bold fg:${magenta})";
        vimcmd_visual_symbol = "[❮](bold fg:${yellow})";
      };

      # Programming languages with backgrounds
      nodejs = {
        symbol = "";
        style = "fg:${green} bg:${segment_bg}";
        format = " [$symbol ($version) ]($style)";
        disabled = false;
      };

      rust = {
        symbol = "";
        style = "fg:${orange} bg:${segment_bg}";
        format = " [$symbol ($version) ]($style)";
        disabled = false;
      };

      python = {
        symbol = "";
        style = "fg:${yellow} bg:${segment_bg}";
        format = " [$symbol ($pyenv_prefix)($version)(\($virtualenv\)) ]($style)";
        disabled = false;
      };

      golang = {
        symbol = "";
        style = "fg:${cyan} bg:${segment_bg}";
        format = " [$symbol ($version) ]($style)";
        disabled = false;
      };

      c = {
        symbol = "";
        style = "fg:${blue} bg:${segment_bg}";
        format = " [$symbol ($version) ]($style)";
        disabled = false;
      };

      php = {
        symbol = "";
        style = "fg:${magenta} bg:${segment_bg}";
        format = " [$symbol ($version) ]($style)";
        disabled = false;
      };

      java = {
        symbol = "";
        style = "fg:${red} bg:${segment_bg}";
        format = " [$symbol ($version) ]($style)";
        disabled = false;
      };

      kotlin = {
        symbol = "";
        style = "fg:${magenta} bg:${segment_bg}";
        format = " [$symbol ($version) ]($style)";
        disabled = false;
      };

      haskell = {
        symbol = "";
        style = "fg:${magenta} bg:${segment_bg}";
        format = " [$symbol ($version) ]($style)";
        disabled = false;
      };

      ruby = {
        symbol = "";
        style = "fg:${red} bg:${segment_bg}";
        format = " [$symbol ($version) ]($style)";
        disabled = false;
      };

      # Container/Environment tools with backgrounds
      docker_context = {
        symbol = "";
        style = "fg:${cyan} bg:${segment_bg}";
        format = " [$symbol $context ]($style)";
        disabled = false;
      };

      conda = {
        symbol = "";
        style = "fg:${green} bg:${segment_bg}";
        format = " [$symbol $environment ]($style)";
        ignore_base = false;
        disabled = false;
      };

      aws = {
        symbol = "󰸏";
        style = "fg:${orange} bg:${segment_bg}";
        format = " [$symbol ($profile )(\($region\)) ]($style)";
        disabled = false;
      };

      azure = {
        symbol = "󰠅";
        style = "fg:${blue} bg:${segment_bg}";
        format = " [$symbol ($subscription) ]($style)";
        disabled = false;
      };

      gcloud = {
        symbol = "󱇶";
        style = "fg:${blue} bg:${segment_bg}";
        format = " [$symbol ($project) ]($style)";
        disabled = false;
      };

      kubernetes = {
        symbol = "󱃾";
        style = "fg:${blue} bg:${segment_bg}";
        format = " [$symbol $context( \($namespace\)) ]($style)";
        disabled = false;
      };

      terraform = {
        symbol = "󱁢";
        style = "fg:${magenta} bg:${segment_bg}";
        format = " [$symbol $workspace ]($style)";
        disabled = false;
      };

      package = {
        symbol = "📦";
        style = "fg:${orange} bg:${segment_bg}";
        format = " [$symbol ($version) ]($style)";
        disabled = false;
      };
    };
  };
}
