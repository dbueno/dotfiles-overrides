# Changes on top of dotfiles. Plain definitions merge with dotfiles' (lists and
# attrsets add up); `lib.mkForce` replaces a value dotfiles sets.
{
  lib,
  pkgs,
  dotfiles,
  ...
}:
let
  # HTTP(S) proxy for login shells; null sets no proxy variables.
  proxy = null; # e.g. "http://proxy.example.com:3128"
  noProxy = [
    "localhost"
    "127.0.0.1"
    "::1"
    # ".corp.example.com"
  ];
in
{
  # Both spellings: curl reads only lowercase http_proxy, other tools only
  # uppercase.
  home.sessionVariables = lib.optionalAttrs (proxy != null) rec {
    http_proxy = proxy;
    https_proxy = proxy;
    no_proxy = lib.concatStringsSep "," noProxy;
    HTTP_PROXY = http_proxy;
    HTTPS_PROXY = https_proxy;
    NO_PROXY = no_proxy;
  };

  # Augment: extra packages alongside dotfiles' own.
  home.packages = [ pkgs.hello ];

  # Override: replace a value dotfiles sets.
  # programs.matplotlib.config.backend = lib.mkForce "Agg";

  # Remove a dotfiles module entirely:
  # disabledModules = [ "${dotfiles}/nix/home/gui.nix" ];

  # Replace a file dotfiles links from home-files/:
  # home.file.".config/git/config".source = lib.mkForce ./git-config;
}
