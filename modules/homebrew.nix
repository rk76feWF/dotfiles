{ config, lib, ... }:

let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  # Build list of allowed App Store app IDs from masApps
  allowedMasIds = map toString (lib.attrValues config.homebrew.masApps);
  allowedIdsStr = lib.concatStringsSep " " allowedMasIds;
in {
  # nix-homebrew configuration
  nix-homebrew = {
    enable = true;
    user = user;
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
      "font-meslo-lg-nerd-font"
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
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo >&2 "cleaning up undeclared App Store apps..."
    ALLOWED_IDS=" ${allowedIdsStr} "
    MAS_BIN="$(command -v mas || true)"
    if [ -n "$MAS_BIN" ] && [ -x "$MAS_BIN" ]; then
      MAS_TMPFILE=$(/usr/bin/mktemp)
      sudo --user=${user} /usr/bin/env HOME="${home}" "$MAS_BIN" list 2>/dev/null | tee "$MAS_TMPFILE" >/dev/null || true
      while IFS= read -r line; do
        APP_ID=$(echo "$line" | awk '{print $1}')
        [ -n "$APP_ID" ] || continue
        case "$APP_ID" in
          *[!0-9]*)
            echo >&2 "Skipping invalid App Store app id: $APP_ID"
            continue
            ;;
        esac
        if ! echo "$ALLOWED_IDS" | grep -q " $APP_ID "; then
          echo >&2 "Removing undeclared App Store app: $line"
          sudo --user=${user} /usr/bin/env HOME="${home}" "$MAS_BIN" uninstall "$APP_ID" 2>&1 || true
        fi
      done < "$MAS_TMPFILE"
      rm -f "$MAS_TMPFILE"
    fi
  '';
}
