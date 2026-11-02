# Changes on top of dotfiles, for every host. Plain definitions merge with
# dotfiles' (lists and attrsets add up); `lib.mkForce` replaces a value
# dotfiles sets. dotfiles' README lists its options and the local files its
# configs read.
{
  lib,
  pkgs,
  ...
}:
{
  # Network settings (modules/network.nix); a host can set its own.
  # overrides.network.proxy = "http://proxy.example.com:3128";
  # overrides.network.noProxy = [ ".corp.example.com" ];
  # overrides.network.caBundle = "/etc/ssl/certs/ca-bundle-with-corp.pem";

  # Augment: extra packages alongside dotfiles' own.
  home.packages = [ pkgs.hello ];

  # Augment dotfiles' lists.
  # dotfiles.cdpath = [ "/Users/me/src" ];
  # dotfiles.python.dontCheckPackages = [ "requests" ];

  # Override: replace a value dotfiles sets.
  # programs.matplotlib.config.backend = lib.mkForce "Agg";

  # Link files under ./home-files into $HOME at the same relative path, as
  # dotfiles does; one at the same path as a dotfiles file replaces it. Git
  # does not track an empty directory, so this skips one that isn't there.
  dotfiles.homeFileDirs = lib.optional (builtins.pathExists ./home-files) ./home-files;
}
