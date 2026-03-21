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
      autoUpdate = false;
      cleanup = "uninstall"; # remove formulae/casks not declared here
    };

    taps = [];

    # CLI tools via Homebrew
    brews = [
      "mas"
    ];

    # GUI apps via Homebrew Cask
    casks = [
      "1password"
      "1password-cli"
      "affinity"
      "antigravity"
      "bitwarden"
      "balenaetcher"
      "discord"
      "orbstack"
      "raspberry-pi-imager"
      "utm"
      "wezterm"
      "wireshark-app"
      "zed"
      "font-meslo-lg-nerd-font"
      "hammerspoon"
    ];

    # Mac App Store apps via mas
    masApps = {
      "1Password for Safari" = 1569813296;
      "Slack" = 803453959;
      "Tailscale" = 1475387142;
      "Windows App" = 1295203466;
      "WireGuard" = 1451685025;
      "OneDrive" = 823766827;
    };
  };

  # Remove App Store apps not declared in masApps
  # Runs in postActivation (after Homebrew bundle)
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo >&2 "cleaning up undeclared App Store apps..."
    (
      set -euo pipefail

      MAS_BIN="$(command -v mas || true)"
      [ -n "$MAS_BIN" ] && [ -x "$MAS_BIN" ] || exit 0

      ALLOWED_IDS=" ${allowedIdsStr} "
      MAS_TMPFILE=$(/usr/bin/mktemp)
      trap 'rm -f "$MAS_TMPFILE"' EXIT

      if ! sudo --user=${user} /usr/bin/env HOME="${home}" "$MAS_BIN" list 2>/dev/null | tee "$MAS_TMPFILE" >/dev/null; then
        echo >&2 "warning: mas list failed; skipping App Store cleanup"
        exit 0
      fi

      while IFS= read -r line; do
        APP_ID="$(printf '%s\n' "$line" | awk '{print $1}')"
        [ -n "$APP_ID" ] || continue
        case "$APP_ID" in
          *[!0-9]*)
            echo >&2 "Skipping invalid App Store app id: $APP_ID"
            continue
            ;;
        esac
        if ! printf '%s\n' "$ALLOWED_IDS" | grep -q " $APP_ID "; then
          echo >&2 "Removing undeclared App Store app: $line"
          sudo --user=${user} /usr/bin/env HOME="${home}" "$MAS_BIN" uninstall "$APP_ID"
        fi
      done < "$MAS_TMPFILE"
    )
  '';
}
