# Host-specific changes for linux-box, on top of overrides.nix.
{
  dotfiles,
  ...
}:
{
  # dotfiles' module list is set up for a Mac; swap in its Linux host module.
  disabledModules = [ "${dotfiles}/nix/hosts/mac.nix" ];
  imports = [ "${dotfiles}/nix/hosts/linux.nix" ];

  # No display here, so render plots to files.
  programs.matplotlib.config.backend = "Agg";
}
