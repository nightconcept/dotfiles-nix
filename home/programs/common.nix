{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    bat
    btop
    delta
    deno
    devenv
    duf
    eza
    fastfetch
    elixir_1_18
    erlang_27
    gh
    gnupg
    lazygit
    ncdu
    nmap
    neovim
    poetry
    rsync
    vim
    wget
    zip
    zoxide
  ];
}
