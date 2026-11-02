# bootstrap

One-off scripts to run by hand on a machine before Home Manager works there,
e.g. installing a CA bundle so Nix can fetch through a TLS-intercepting proxy,
or exporting a Nix store to copy to an offline machine.

They are not part of the build: nothing in the flake imports or runs them.
