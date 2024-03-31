{pkgs, ...}: {
  users.users.danny = {
    description = "Danny";
    shell = pkgs.zsh;
  };
}
