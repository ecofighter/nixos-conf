{ config, pkgs, ... }:
{ nix = {
    settings = {
      auto-optimise-store = true;
      cores = 0;
      max-jobs = "auto";
    };
    nixPath = [
        "/etc/nixos"
        "nixos-config=/etc/nixos/configuration.nix"
      ];
  };
}
