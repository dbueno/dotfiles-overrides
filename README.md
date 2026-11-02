# dotfiles-overrides

A Home Manager config that takes everything from
[dbueno/dotfiles](https://github.com/dbueno/dotfiles) and layers local changes
on top. Homes are built with dotfiles' `lib.mkHomeConfigurations` and
`homeModules.default`; the `switch`, `diff` and `repl` apps come from
`lib.mkSwitchApps`. Homes use dotfiles' nixpkgs and overlay;
`nix flake update dotfiles` updates these dependencies and shared helpers
together.

A private copy changes only these, so template updates merge cleanly:

- `hosts.nix`: one entry per machine with its system and host modules, plus
  `defaults` (username, stateVersion) for any host that doesn't set them.
  `homeDirectory` defaults to `/Users/<username>` on Darwin and
  `/home/<username>` otherwise. Outputs are named `<username>@<host>`. Name
  each host after its short hostname (`uname -n` up to the first dot), or use
  `sha256-<digest>` as described below.
- `overrides.nix`: additions and overrides for every host. Plain definitions
  merge with dotfiles'; `lib.mkForce` replaces. Dotfiles' README lists its
  options (`dotfiles.loginShell.enable`, `dotfiles.gui.enable`,
  `dotfiles.cdpath`, `dotfiles.python.dontCheckPackages`, ...) and the local
  files its configs read.
- `hosts/<host>.nix`: changes for one host, on top of `overrides.nix`.
- `home-files/`: files linked into the home directory, laid out like dotfiles'
  `home-files/` (`home-files/.config/foo/bar.toml` becomes
  `~/.config/foo/bar.toml`). `overrides.nix` adds this directory, when present,
  to dotfiles' `dotfiles.homeFileDirs` option. A file at the same path as one
  of dotfiles' replaces it. New files must be `git add`-ed before Nix sees
  them. Prefer dotfiles' local files to replacing its configs:
  `home-files/.ssh/config.d/<name>` for ssh hosts (in ssh config syntax, not
  `programs.ssh`), `home-files/.config/git/config.local`,
  `home-files/.zshrc_local`, `home-files/.config/tmux/local.conf`. For shell
  code that needs store paths, use `programs.zsh.initContent`, which merges
  with dotfiles'.
- `flake.nix` inputs, only to add one. Modules get them as the `inputs`
  argument, e.g. `nix.registry.otherpkgs.flake = inputs.otherpkgs;`.

Other files:

- `modules/network.nix`: `overrides.network.proxy`, `.noProxy` and `.caBundle`
  set the proxy and CA-bundle variables for login shells. Set them in
  `overrides.nix`, or in `hosts/<host>.nix` for one host. `caBundle` must be a
  full bundle (public CAs plus any local ones), since most of the variables
  replace the trust store.
- `bootstrap/`: one-off scripts run by hand before Home Manager works on a
  machine. Not part of the build.

Keep real proxy hosts, internal domains, CA paths, hostnames, usernames and
internal URLs out of the public template; only a private copy should have them.

## Switching

```sh
nix run .#diff                   # what switching would change; changes nothing
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
activating it. `nix run .#repl` opens `nix repl` on this flake.
