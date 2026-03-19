{ config, lib, ... }:

let
  # Build list of allowed App Store app IDs from masApps
  allowedMasIds = map toString (lib.attrValues config.homebrew.masApps);
  allowedIdsStr = lib.concatStringsSep " " allowedMasIds;
in {
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

  # Remove App Store apps not declared in masApps
  # Scans /Applications for App Store apps and removes those not in the allowed list
  system.activationScripts.masCleanup.text = ''
    ALLOWED_IDS=" ${allowedIdsStr} "
    for app in /Applications/*.app; do
      [ -d "$app" ] || continue
      # Check if this is an App Store app
      RECEIPT=$(/usr/bin/mdls -name kMDItemAppStoreHasReceipt "$app" 2>/dev/null | awk '{print $3}')
      [ "$RECEIPT" = "1" ] || continue
      # Get the App Store ID
      APP_ID=$(/usr/bin/mdls -name kMDItemAppStoreAdamID "$app" 2>/dev/null | awk '{print $3}')
      [ -n "$APP_ID" ] || continue
      # Remove if not in allowed list
      if ! echo "$ALLOWED_IDS" | grep -q " $APP_ID "; then
        echo "Removing undeclared App Store app: $(basename "$app") ($APP_ID)"
        rm -rf "$app"
      fi
    done
  '';
}
