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
      cleanup = "zap"; # remove everything not declared here
    };

    taps = [];

    # GUI apps via Homebrew Cask
    casks = [
      "wezterm"
      "zed"
    ];

    # Mac App Store apps via mas
    masApps = {
      # "App Name" = APP_ID;
    };
  };
}
