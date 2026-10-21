{
  description = "Home Manager config built on github:dbueno/dotfiles, with local overrides";

  inputs = {
    dotfiles.url = "github:dbueno/dotfiles";
    # Homes get dotfiles' nixpkgs, home-manager and hm-login-shell-helper from
    # its mkHomeConfig; this is for the formatter and dev shell.
    nixpkgs.follows = "dotfiles/nixpkgs";
  };

  outputs =
    { nixpkgs, dotfiles, ... }:
    let
      lib = nixpkgs.lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      # homeModules.default is dotfiles' module list. An override module can
      # drop one with `disabledModules = [ "${dotfiles}/nix/home/gui.nix" ];`.
      mkHome =
        { modules, ... }@args:
        dotfiles.lib.mkHomeConfig (
          args
          // {
            modules = [ dotfiles.homeModules.default ] ++ modules;
            extraSpecialArgs = { inherit dotfiles; };
          }
        );

      # One entry per machine; the output is named "<username>@<host>", which
      # `home-manager --flake .` picks by default on that machine.
      hosts = {
        example = {
          system = "aarch64-darwin";
          username = "dbueno";
          homeDirectory = "/Users/dbueno";
          stateVersion = "24.11";
          modules = [ ./overrides.nix ];
        };
      };
    in
    {
      homeConfigurations = lib.mapAttrs' (host: args: {
        name = "${args.username}@${host}";
        value = mkHome args;
      }) hosts;

      formatter = lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      devShells = lib.genAttrs systems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = with nixpkgs.legacyPackages.${system}; [
            nil
            nixd
          ];
        };
      });
    };
}
