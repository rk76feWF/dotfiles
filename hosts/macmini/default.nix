{ pkgs, ... }:

{
  imports = [
    ../../modules/system.nix
    ../../modules/homebrew.nix
    ../../modules/packages.nix
  ];

  networking.hostName = "macmini";

  users.users.rk76fewf = {
    name = "rk76fewf";
    home = "/Users/rk76fewf";
  };
}
