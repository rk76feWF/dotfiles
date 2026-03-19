{
  description = "nix-darwin dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, nix-homebrew }: {
    darwinConfigurations."macmini" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        nix-homebrew.darwinModules.nix-homebrew
        ./hosts/macmini
      ];
    };
  };
}
