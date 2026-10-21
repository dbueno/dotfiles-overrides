{
  description = "Home Manager config built on github:dbueno/dotfiles, with local overrides";

  inputs = {
    dotfiles.url = "github:dbueno/dotfiles";
    # Homes get dotfiles' nixpkgs, home-manager and hm-login-shell-helper from
    # its mkHomeConfig; this is for the formatter, dev shell and switch app.
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

      # Every host gets dotfiles' module list and overrides.nix, then its own
      # modules. An override module can drop one of dotfiles' modules with
      # `disabledModules = [ "${dotfiles}/nix/home/gui.nix" ];`.
      mkHome =
        { modules, ... }@args:
        dotfiles.lib.mkHomeConfig (
          args
          // {
            modules = [
              dotfiles.homeModules.default
              ./overrides.nix
            ]
            ++ modules;
            extraSpecialArgs = { inherit dotfiles; };
          }
        );

      # One entry per machine, keyed by its short hostname (`uname -n` up to
      # the first dot). The output is named "<username>@<host>".
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

      homeName = host: args: "${args.username}@${host}";

      # `nix run .#switch [host] [home-manager args]` switches to the home for
      # this machine, or the named host; with neither, it offers this
      # system's hosts to pick from.
      mkSwitch =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          names = lib.mapAttrsToList homeName (lib.filterAttrs (_: h: h.system == system) hosts);
        in
        pkgs.writeShellApplication {
          name = "switch";
          runtimeInputs = [ dotfiles.inputs.home-manager.packages.${system}.home-manager ];
          text = ''
            homes=(${lib.escapeShellArgs names})
            host=$(uname -n)
            name="$USER@''${host%%.*}"
            if [[ $# -gt 0 && $1 != -* ]]; then
              name=$1
              [[ $name == *@* ]] || name="$USER@$name"
              shift
            fi

            if [[ " ''${homes[*]} " != *" $name "* ]]; then
              echo "No home named $name for ${system}." >&2
              if [[ ''${#homes[@]} -eq 0 || ! -t 0 ]]; then
                echo "Configured: ''${homes[*]:-none}" >&2
                exit 1
              fi
              PS3="Switch to which home? "
              name=
              select choice in "''${homes[@]}"; do
                [[ -n $choice ]] && name=$choice && break
              done
              [[ -n $name ]] || exit 1
            fi

            exec home-manager switch --flake "${self}#$name" "$@"
          '';
        };
    in
    {
      homeConfigurations = lib.mapAttrs' (host: args: {
        name = homeName host args;
        value = mkHome args;
      }) hosts;

      apps = lib.genAttrs systems (system: {
        switch = {
          type = "app";
          program = lib.getExe (mkSwitch system);
        };
      });

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
