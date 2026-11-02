# Proxy and CA-bundle environment variables for login shells.
{
  config,
  lib,
  ...
}:
let
  cfg = config.overrides.network;
in
{
  options.overrides.network = {
    proxy = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "http://proxy.example.com:3128";
      description = "HTTP(S) and FTP proxy; null sets no proxy variables.";
    };
    noProxy = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      example = [ ".corp.example.com" ];
      description = ''
        Hosts and domains reached without the proxy. Entries add to
        localhost, 127.0.0.1 and ::1.
      '';
    };
    caBundle = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/etc/ssl/certs/ca-bundle-with-corp.pem";
      description = ''
        Path on the machine to a CA bundle, e.g. for a TLS-intercepting
        proxy. Most of the variables it sets replace the trust store, so it
        must hold the usual public CAs as well as any local ones. It reaches
        the Nix client in a login shell, not a multi-user nix-daemon.
      '';
    };
  };

  config = {
    # A definition, not the option's default, so other modules' entries add
    # to it rather than replace it.
    overrides.network.noProxy = [
      "localhost"
      "127.0.0.1"
      "::1"
    ];

    home.sessionVariables = lib.mkMerge [
      # Both spellings: curl reads only lowercase http_proxy, other tools
      # only uppercase.
      (lib.mkIf (cfg.proxy != null) (
        let
          noProxy = lib.concatStringsSep "," cfg.noProxy;
        in
        {
          http_proxy = cfg.proxy;
          https_proxy = cfg.proxy;
          ftp_proxy = cfg.proxy;
          no_proxy = noProxy;
          HTTP_PROXY = cfg.proxy;
          HTTPS_PROXY = cfg.proxy;
          FTP_PROXY = cfg.proxy;
          NO_PROXY = noProxy;
        }
      ))
      (lib.mkIf (cfg.caBundle != null) (
        lib.genAttrs [
          "NIX_SSL_CERT_FILE"
          "SSL_CERT_FILE"
          "CURL_CA_BUNDLE"
          "REQUESTS_CA_BUNDLE"
          "NODE_EXTRA_CA_CERTS"
          "CARGO_HTTP_CAINFO"
          "GIT_SSL_CAINFO"
        ] (_: cfg.caBundle)
      ))
    ];
  };
}
