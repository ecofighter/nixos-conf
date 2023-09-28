{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
    };
    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, emacs-overlay, NixOS-WSL, vscode-server, home-manager, ... }@attrs: {
    nixosConfigurations.waltraute = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        { nix.registry.nixpkgs.flake = nixpkgs; }
        NixOS-WSL.nixosModules.wsl
        vscode-server.nixosModules.default
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        ({ config, pkgs, ... }:
          { 
            nixpkgs.overlays = [ emacs-overlay.overlays.emacs ]; 
            nix.settings.system-features = [ "benchmark" "big-parallel" "kvm" "nixos-test" "gccarch-tigerlake" ];
            services.vscode-server.enable = true;
          }
        )
        ./configuration.nix
      ];
    };
  };
}
