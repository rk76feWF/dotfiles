{ ... }:

{
  # nix-homebrew configuration
  nix-homebrew = {
    enable = true;
    user = "rk76fewf";
    autoMigrate = true;
  };

  # Homebrew packages managed by nix-darwin
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall"; # remove formulae/casks not declared here
    };

    taps = [];

    # GUI apps via Homebrew Cask
    casks = [
      "balenaetcher"
      "discord"
      "orbstack"
      "raspberry-pi-imager"
      "utm"
      "wezterm"
      "zed"
    ];

    # Mac App Store apps via mas
    masApps = {
      "Bitwarden" = 1352778147;
      "Tailscale" = 1475387142;
      "Windows App" = 1295203466;
      "WireGuard" = 1451685025;
    };
  };
}
