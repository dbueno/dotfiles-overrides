# dotfiles-overrides

A Home Manager config that takes everything from
[dbueno/dotfiles](https://github.com/dbueno/dotfiles) and layers local changes
on top. Homes are built with dotfiles' `lib.mkHomeConfig` and
`homeModules.default`, so they use dotfiles' nixpkgs, overlay and
hm-login-shell-helper; `nix flake update dotfiles` moves them together.

- `flake.nix`: the `hosts` set gives each machine's username, home directory,
  system and stateVersion; outputs are named `<username>@<host>`.
- `overrides.nix`: additions and overrides. Plain definitions merge with
  dotfiles'; `lib.mkForce` replaces; `disabledModules` drops a dotfiles module.

To try uncommitted changes in a local dotfiles checkout:

```sh
home-manager build --flake 'path:.#dbueno@example' --override-input dotfiles path:$HOME/dotfiles
```

Build with `home-manager build --flake 'path:.#<username>@<host>'`; `switch`
activates it.
