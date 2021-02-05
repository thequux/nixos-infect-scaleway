{pkgs, ...}:
{
  imports = [
    ./scaleway.nix
    ./hardening.nix
  ];

  boot.scaleway = true;
  environment.systemPackages = with pkgs; [ neofetch vim rxvt-unicode-unwrapped.terminfo ];
}
