{ ... }:

let
  username = "rk76fewf";
in
{
  imports = [
    ../../modules/system.nix
    ../../modules/homebrew.nix
    ../../modules/packages.nix
    ../../modules/mlx.nix
    ../../modules/findmyd.nix
  ];

  # Home Manager global settings
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  networking.hostName = "macmini";
  system.primaryUser = username;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  home-manager.users.${username} = import ../../modules/home.nix;
}
