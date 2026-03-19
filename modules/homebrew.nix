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
  # Appended to extraActivation so it runs after Homebrew bundle
  system.activationScripts.extraActivation.text = lib.mkAfter ''
    echo >&2 "cleaning up undeclared App Store apps..."
    ALLOWED_IDS=" ${allowedIdsStr} "
    if [ -x /opt/homebrew/bin/mas ]; then
      MAS_TMPFILE=$(/usr/bin/mktemp)
      /opt/homebrew/bin/mas list > "$MAS_TMPFILE" 2>/dev/null || true
      while IFS= read -r line; do
        APP_ID=$(echo "$line" | awk '{print $1}')
        [ -n "$APP_ID" ] || continue
        if ! echo "$ALLOWED_IDS" | grep -q " $APP_ID "; then
          echo >&2 "Removing undeclared App Store app: $line"
          /opt/homebrew/bin/mas uninstall "$APP_ID" 2>&1 || true
        fi
      done < "$MAS_TMPFILE"
      rm -f "$MAS_TMPFILE"
    fi
  '';
}
