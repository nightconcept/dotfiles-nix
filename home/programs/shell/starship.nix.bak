{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (builtins) map;
  inherit (lib.strings) concatStrings;

  # P10k Classic colors (256 color codes converted to hex)
  red = "#d70000"; # 160
  orange = "#d78700"; # 172
  yellow = "#d7af00"; # 178
  light_yellow = "#afaf87"; # 144
  green = "#5fd700"; # 76 (git branch in P10k)
  teal = "#5fd7d7"; # 80
  light_teal = "#87d7d7"; # 116
  cyan = "#00afff"; # 39 (directory color)
  light_blue = "#5fafd7"; # 74 (nix shell)
  blue = "#0087ff"; # 33
  magenta = "#af5fff"; # 135
  white = "#eeeeee"; # 255
  foreground = "#bcbcbc"; # 250
  foreground_gutter = "#6c6c6c"; # 242
  comment = "#6c6c6c"; # 242 (frame/ornament color)
  dark_gray = "#444444"; # 238 (background)
  black = "#303030"; # 236
  bg = "#303030"; # 236 (terminal background)
  bg_highlight = "#444444"; # 238
  bg_dark = "#1c1c1c"; # 234
  segment_bg = "#444444"; # 238 (P10k background)
  terminal_black = black;
  fg = foreground;
  fg_dark = foreground_gutter;

  # Variable colors that change based on palette
  git_branch_color = green; # Green in P10k, will be magenta in Tokyo Night
in {
  programs.starship = {
    enable = true;

    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      # Format with box drawing characters and gradient blocks - matches P10k style
      format = "$line_break[╭─](${comment})[](fg:${segment_bg})$os$username$hostname[ ](fg:${foreground_gutter} bg:${segment_bg})$directory$git_branch$git_status[](fg:${segment_bg})$fill[](fg:${segment_bg})$nix_shell$time[](fg:${segment_bg})[─╮ ](${comment})$line_break[╰─ ](${comment})$character";

      # Right prompt format
      right_format = "[─╯](${comment})";

      # Add newline before prompt like P10k
      add_newline = false;

      palette = "p10k_classic";

      palettes.p10k_classic = {
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
          Arch = "󰣇";
          Artix = "󰣇";
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
        style = "fg:${git_branch_color} bg:${segment_bg}";
        format = "[](fg:${foreground_gutter} bg:${segment_bg})[ $symbol $branch ]($style)";
      };

      # Git status - with file counts like P10k
      git_status = {
        format = "$ahead_behind$all_status";
        conflicted = "~$count ";
        ahead = "[⇡$count ](fg:${git_branch_color} bg:${segment_bg})";
        behind = "[⇣$count ](fg:${git_branch_color} bg:${segment_bg})";
        diverged = "[⇡$ahead_count ⇣$behind_count ](fg:${git_branch_color} bg:${segment_bg})";
        up_to_date = "";
        untracked = "[?$count ](fg:${yellow} bg:${segment_bg})";
        stashed = "[*$count ](fg:${green} bg:${segment_bg})";
        modified = "[!$count ](fg:${yellow} bg:${segment_bg})";
        staged = "[+$count ](fg:${yellow} bg:${segment_bg})";
        renamed = "[»$count ](fg:${yellow} bg:${segment_bg})";
        deleted = "[✘$count ](fg:${red} bg:${segment_bg})";
      };

      # Status - show success/error symbol with background
      status = {
        style = "fg:${green} bg:${segment_bg}";
        success_symbol = "[✔](fg:${green} bg:${segment_bg})";
        error_symbol = "[✘](fg:${red} bg:${segment_bg})";
        format = "[ $symbol ]($style)";
        map_symbol = false;
        disabled = true;
      };

      # Command duration with background
      cmd_duration = {
        min_time = 10000;
        show_milliseconds = false;
        style = "fg:${yellow} bg:${segment_bg}";
        format = "[](fg:${foreground_gutter} bg:${segment_bg})[ took $duration ]($style)";
        disabled = true;
      };

      # Nix shell with background
      nix_shell = {
        style = "fg:${light_blue} bg:${segment_bg} bold";
        format = "[ $state  ]($style)";
        impure_msg = "impure ";
        pure_msg = "pure ";
        unknown_msg = "";
      };

      # Time with background
      time = {
        disabled = false;
        time_format = "%H:%M:%S";
        style = "fg:${foreground} bg:${segment_bg}";
        format = "[](fg:${foreground_gutter} bg:${segment_bg})[ $time   ]($style)";
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

      python = {
        symbol = "";
        style = "fg:${yellow} bg:${segment_bg}";
        format = " [$symbol ($pyenv_prefix)($version)(\($virtualenv\)) ]($style)";
        disabled = false;
      };

      # Container/Environment tools with backgrounds
      docker_context = {
        symbol = "";
        style = "fg:${cyan} bg:${segment_bg}";
        format = " [$symbol $context ]($style)";
        disabled = false;
      };
    };
  };
}
