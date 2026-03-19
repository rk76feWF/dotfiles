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

    # CLI tools via Homebrew
    brews = [
      "mas"
    ];

    # GUI apps via Homebrew Cask
    casks = [
      "bitwarden"
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
      "Tailscale" = 1475387142;
      "Windows App" = 1295203466;
      "WireGuard" = 1451685025;
    };
  };
}
