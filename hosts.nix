# One entry per machine, keyed by its short hostname (`uname -n` up to the
# first dot) or "sha256-<hex SHA-256 of that name, without a newline>". The
# output is named "<username>@<host>". Every host gets dotfiles' module list
# and overrides.nix, then its own modules.
#
# `defaults` apply to any host that doesn't set them. homeDirectory defaults
# to /Users/<username> on Darwin and /home/<username> otherwise; set it on a
# host whose home is elsewhere.
{
  defaults = {
    username = "dbueno";
    stateVersion = "24.11";
  };

  hosts = {
    laptop = {
      system = "aarch64-darwin";
      modules = [ ./hosts/laptop.nix ];
    };
    linux-box = {
      system = "aarch64-linux";
      modules = [ ./hosts/linux-box.nix ];
    };
  };
}
