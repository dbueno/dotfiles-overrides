# Host-specific changes for linux-box, on top of overrides.nix.
{
  # hm-login-shell-helper isn't installed here, and there is no display.
  dotfiles.loginShell.enable = false;
  dotfiles.gui.enable = false;

  # No display, so render plots to files.
  programs.matplotlib.config.backend = "Agg";
}
