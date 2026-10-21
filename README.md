# dotfiles-overrides

A Home Manager config that takes everything from
[dbueno/dotfiles](https://github.com/dbueno/dotfiles) and layers local changes
on top. Homes are built with dotfiles' `lib.mkHomeConfigurations` and
`homeModules.default`; the switch app comes from `lib.mkSwitchApps`. Homes use
dotfiles' nixpkgs, overlay and hm-login-shell-helper;
`nix flake update dotfiles` updates these dependencies and shared helpers together.

- `flake.nix`: the `hosts` set gives each machine's username, home directory,
  system, stateVersion and host modules; outputs are named `<username>@<host>`.
  Name each host after its short hostname (`uname -n` up to the first dot),
  or use `sha256-<digest>` as described below. Shared modules run before each
  host's modules; dotfiles also supplies the `dotfiles` module argument used
  by overrides and host modules.
- `overrides.nix`: additions and overrides for every host. Plain definitions
  merge with dotfiles'; `lib.mkForce` replaces; `disabledModules` drops a
  dotfiles module.
- `hosts/<host>.nix`: changes for one host, on top of `overrides.nix`.
- `home-files/`: files linked into the home directory, laid out like dotfiles'
  `home-files/` (`home-files/.config/foo/bar.toml` becomes
  `~/.config/foo/bar.toml`). `overrides.nix` adds this directory, when present,
  to dotfiles' `dotfiles.homeFileDirs` option. Dotfiles handles the links; a
  file at the same path as one of dotfiles' replaces it. New files must be
  `git add`-ed before Nix sees them.

## Switching

```sh
nix run .#switch                 # the home for this machine's hostname
nix run .#switch -- linux-box    # a named host
nix run .#switch -- laptop -n    # extra arguments go to home-manager
```

The shared switch app tries `<username>@<hostname>` first, then
`<username>@sha256-<digest>`. The digest is the lowercase hexadecimal SHA-256
of the short hostname, without a trailing newline; names are case-sensitive.
To compute a host key on macOS or Linux:

```sh
host=$(uname -n)
printf 'sha256-'; printf '%s' "${host%%.*}" | shasum -a 256 | cut -d ' ' -f 1
```

An explicit host argument accepts a hostname, a `sha256-<digest>` key, or
either prefixed with `<username>@`. With no match, it lists this system's
homes and asks which to switch to; without a terminal, it fails with the list.
Hashes obscure readable hostnames, but guesses can still be checked against
them, and renaming a host does not remove its old name from Git history.

To try uncommitted changes in a local dotfiles checkout:

```sh
home-manager build --flake 'path:.#dbueno@laptop' --override-input dotfiles path:$HOME/dotfiles
```

(`nix run .#switch` ignores `--override-input`: it switches to the flake as
locked.)

`home-manager build --flake 'path:.#<username>@<host>'` builds a home without
activating it.
