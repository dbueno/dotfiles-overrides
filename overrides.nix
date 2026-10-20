# Changes on top of dotfiles. Plain definitions merge with dotfiles' (lists and
# attrsets add up); `lib.mkForce` replaces a value dotfiles sets.
{
  lib,
  pkgs,
  dotfiles,
  ...
}:
{
  # Augment: extra packages alongside dotfiles' own.
  home.packages = [ pkgs.hello ];

  # Override: replace a value dotfiles sets.
  programs.matplotlib.config.backend = lib.mkForce "Agg";

  # Remove a dotfiles module entirely:
  # disabledModules = [ "${dotfiles}/nix/home/gui.nix" ];

  # Replace a file dotfiles links from home-files/:
  # home.file.".config/git/config".source = lib.mkForce ./git-config;
}
