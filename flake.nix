{
  description = "Home Manager config built on github:dbueno/dotfiles, with local overrides";

  inputs = {
    dotfiles.url = "github:dbueno/dotfiles";
    # Homes get dotfiles' nixpkgs, home-manager and hm-login-shell-helper from
    # its mkHomeConfig; this is for the formatter and dev shell.
    nixpkgs.follows = "dotfiles/nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      dotfiles,
      ...
    }:
    let
      lib = nixpkgs.lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      # One entry per machine, keyed by its short hostname (`uname -n` up to
      # the first dot) or "sha256-<hex SHA-256 of that name, without a newline>".
      # The output is named "<username>@<host>". Every host gets dotfiles'
      # module list and overrides.nix, then its own modules.
      hosts = {
        laptop = {
          system = "aarch64-darwin";
          username = "dbueno";
          homeDirectory = "/Users/dbueno";
          stateVersion = "24.11";
          modules = [ ./hosts/laptop.nix ];
        };
        linux-box = {
          system = "aarch64-linux";
          username = "dbueno";
          homeDirectory = "/home/dbueno";
          stateVersion = "24.11";
          modules = [ ./hosts/linux-box.nix ];
        };
      };
    in
    {
      homeConfigurations = dotfiles.lib.mkHomeConfigurations {
        inherit hosts;
        modules = [
          dotfiles.homeModules.default
          ./overrides.nix
        ];
      };

      # `nix run .#switch` switches to the home named after this machine.
      apps = dotfiles.lib.mkSwitchApps self;

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
