# Host-specific changes for laptop, on top of overrides.nix.
{ pkgs, ... }:
{
  # Only this host gets these.
  home.packages = [ pkgs.cowsay ];
}
