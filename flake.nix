{
  description = "Home Manager config built on github:dbueno/dotfiles, with local overrides";

  inputs = {
    dotfiles.url = "github:dbueno/dotfiles";
    # Homes get dotfiles' nixpkgs and home-manager from its mkHomeConfig;
    # this is for the formatter and dev shell.
    nixpkgs.follows = "dotfiles/nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      dotfiles,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      hostConfig = import ./hosts.nix;
    in
    {
      # Hosts are in hosts.nix.
      homeConfigurations = dotfiles.lib.mkHomeConfigurations {
        inherit (hostConfig) defaults hosts;
        modules = [
          dotfiles.homeModules.default
          ./modules/network.nix
          ./overrides.nix
        ];
        # Modules take `inputs` to use this flake's inputs, e.g.
        # `nix.registry.otherpkgs.flake = inputs.otherpkgs;`.
        extraSpecialArgs = { inherit inputs; };
      };

      # `nix run .#switch` switches to the home named after this machine;
      # `nix run .#repl` opens `nix repl` on this flake.
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
