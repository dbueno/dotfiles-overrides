# dotfiles-overrides

A Home Manager config that takes everything from
[dbueno/dotfiles](https://github.com/dbueno/dotfiles) and layers local changes
on top. Homes are built with dotfiles' `lib.mkHomeConfig` and
`homeModules.default`, so they use dotfiles' nixpkgs, overlay and
hm-login-shell-helper; `nix flake update dotfiles` moves them together.

- `flake.nix`: the `hosts` set gives each machine's username, home directory,
  system, stateVersion and host modules; outputs are named `<username>@<host>`.
  Name each host after its short hostname (`uname -n` up to the first dot).
- `overrides.nix`: additions and overrides for every host. Plain definitions
  merge with dotfiles'; `lib.mkForce` replaces; `disabledModules` drops a
  dotfiles module.
- `hosts/<host>.nix`: changes for one host, on top of `overrides.nix`.
- `home-files/`: files linked into the home directory, laid out like dotfiles'
  `home-files/` (`home-files/.config/foo/bar.toml` becomes
  `~/.config/foo/bar.toml`). A file at the same path as one of dotfiles'
  replaces it. New files must be `git add`-ed before Nix sees them.

## Switching

```sh
nix run .#switch                 # the home for this machine's hostname
nix run .#switch -- linux-box    # a named host
nix run .#switch -- laptop -n    # extra arguments go to home-manager
```

With no host matching this machine, it lists the hosts configured for this
system and asks which to switch to.

To try uncommitted changes in a local dotfiles checkout:

```sh
home-manager build --flake 'path:.#dbueno@laptop' --override-input dotfiles path:$HOME/dotfiles
```

(`nix run .#switch` ignores `--override-input`: it switches to the flake as
locked.)

`home-manager build --flake 'path:.#<username>@<host>'` builds a home without
activating it.
