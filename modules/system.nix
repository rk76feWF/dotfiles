{ config, lib, pkgs, ... }:

let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  whisperModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin";
    hash = "sha256-H8cPd0046xaZk6w5Huo1fvR8iHV+9y7llDh5t+jivGk=";
  };
  whisperCoreML = pkgs.fetchzip {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-encoder.mlmodelc.zip";
    hash = "sha256-363/FR6kbq3j2eapZuLBPOSu5Efx1ixCj+o+9LRnTs4=";
    stripRoot = false;
  };
in {
  # Nix settings
  nix.gc.automatic = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # macOS system preferences
  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false;
      persistent-apps = [
        "/System/Applications/Launchpad.app"
        "/System/Cryptexes/App/System/Applications/Safari.app"
        "/Applications/Discord.app"
        "/Applications/WezTerm.app"
        "/Applications/1Password.app"
      ];
      persistent-others = [];
    };
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
      FXPreferredViewStyle = "Nlsv"; # list view
      _FXSortFoldersFirst = true;
      FXDefaultSearchScope = "SCcf"; # search current folder
      FXEnableExtensionChangeWarning = false;
      NewWindowTarget = "Home";
    };
    screensaver = {
      askForPassword = false;
      askForPasswordDelay = 0;
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
    };
  };

  # Starship config
  environment.etc."starship.toml".source = ../config/starship.toml;

  # System-level activation (whisper models, Rosetta 2)
  system.activationScripts.extraActivation.text = lib.mkAfter ''
    # whisper.cpp model (large-v3-turbo, managed by Nix store)
    WHISPER_MODEL_DIR="${home}/.local/share/whisper-cpp"
    install -d -m 0755 -o ${user} -g staff "$WHISPER_MODEL_DIR"
    ln -sfn "${whisperModel}" "$WHISPER_MODEL_DIR/ggml-large-v3-turbo.bin"
    chown -h ${user}:staff "$WHISPER_MODEL_DIR/ggml-large-v3-turbo.bin"

    # whisper.cpp Core ML encoder model (copy, not symlink — ANE may write cache)
    if [ ! -d "$WHISPER_MODEL_DIR/ggml-large-v3-turbo-encoder.mlmodelc" ]; then
      cp -R "${whisperCoreML}/ggml-large-v3-turbo-encoder.mlmodelc" "$WHISPER_MODEL_DIR/"
      chown -R ${user}:staff "$WHISPER_MODEL_DIR/ggml-large-v3-turbo-encoder.mlmodelc"
    fi

    # Set audio volume and unmute
    /usr/bin/osascript -e 'set volume output volume 50 without output muted'

    # Install Rosetta 2 if not present
    if ! /usr/sbin/pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
      /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    fi
  '';

  # System state version
  system.stateVersion = 6;
}
