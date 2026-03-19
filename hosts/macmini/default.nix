{ pkgs, ... }:

{
  imports = [
    ../../modules/system.nix
    ../../modules/homebrew.nix
    ../../modules/packages.nix
  ];

  networking.hostName = "macmini";
  system.primaryUser = "rk76fewf";

  users.users.rk76fewf = {
    name = "rk76fewf";
    home = "/Users/rk76fewf";
  };
}
