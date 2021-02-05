# vim: ai expandtab
{ config, pkgs, lib, ... }:
{
  options = with lib.types; {
    boot.scaleway = with lib.types; lib.mkOption {
      description = "Automatically configure the system from scaleway's metadata";
      type = bool;
      default = false;
    };
  };

  config = lib.mkIf config.boot.scaleway {
    boot.kernelParams = [ "console=ttyS0,115200n8" ];
    boot.loader.grub.extraConfig = ''
      serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
      terminal_input console
      terminal_output console
    '';


    networking.useDHCP = false;
    networking.useNetworkd = true;
    networking.interfaces.ens2 = {
      useDHCP = true;
      ipv4.routes = [
        { address = "169.254.42.42"; prefixLength = 32; }
      ];
    };

    services.openssh.authorizedKeysFiles = [
      "/run/scw-autoconf/ssh-keys/%u"
    ];

    systemd.services.scw-autoconfig = {
      serviceConfig.Type = "oneshot";
      after = [ "network.target" ];
      script = ''
        install -o 0 -g 0 -m 755 -d /run/scw-autoconf
        install -o 0 -g 0 -m 755 -d /run/scw-autoconf/ssh-keys
        ${pkgs.curl}/bin/curl --local-port 1-1024 http://169.254.42.42/conf?format=json >/run/scw-autoconf/config.json
        ${pkgs.jq}/bin/jq -r '.ssh_public_keys | .[] | .key' </run/scw-autoconf/config.json >/run/scw-autoconf/ssh-keys/root
      '';
      wantedBy = [ "multi-user.target" ];
    };
  };
  

}
