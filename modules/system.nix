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
      ];
    };
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "Nlsv"; # list view
    };
    screensaver = {
      askForPassword = false;
      askForPasswordDelay = 0;
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };

  # Starship config
  environment.etc."starship.toml".source = ../config/starship.toml;

  # Deploy dotfiles to user home (must use extraActivation, not custom names)
  system.activationScripts.extraActivation.text = lib.mkAfter ''
    echo >&2 "deploying dotfiles..."

    # WezTerm config
    install -d -m 0755 -o ${user} -g staff "${home}/.config/wezterm"
    ln -sfn /etc/dotfiles/wezterm/wezterm.lua "${home}/.config/wezterm/wezterm.lua"
    ln -sfn /etc/dotfiles/wezterm/keybinds.lua "${home}/.config/wezterm/keybinds.lua"
    chown -h ${user}:staff "${home}/.config/wezterm/wezterm.lua" "${home}/.config/wezterm/keybinds.lua"

    # Hammerspoon config
    install -d -m 0755 -o ${user} -g staff "${home}/.hammerspoon"
    ln -sfn /etc/dotfiles/hammerspoon/init.lua "${home}/.hammerspoon/init.lua"
    chown -h ${user}:staff "${home}/.hammerspoon/init.lua"

    # Git config (~/.gitconfig — Nix git ignores /etc/gitconfig)
    ln -sfn /etc/dotfiles/git/config "${home}/.gitconfig"
    chown -h ${user}:staff "${home}/.gitconfig"

    # gh config (copy, not symlink — gh needs to write to this file)
    install -d -m 0755 -o ${user} -g staff "${home}/.config/gh"
    if [ ! -e "${home}/.config/gh/config.yml" ] || [ -L "${home}/.config/gh/config.yml" ]; then
      rm -f "${home}/.config/gh/config.yml"
      install -m 0644 -o ${user} -g staff /etc/dotfiles/gh/config.yml "${home}/.config/gh/config.yml"
    fi

    # 1Password SSH Agent config
    install -d -m 0755 -o ${user} -g staff "${home}/.config/1Password/ssh"
    ln -sfn /etc/dotfiles/1password/ssh/agent.toml "${home}/.config/1Password/ssh/agent.toml"
    chown -h ${user}:staff "${home}/.config/1Password/ssh/agent.toml"

    # SSH config (1Password SSH Agent + OrbStack + local overrides)
    install -d -m 0700 -o ${user} -g staff "${home}/.ssh"
    ln -sfn /etc/dotfiles/ssh/config "${home}/.ssh/config"
    chown -h ${user}:staff "${home}/.ssh/config"
    if [ ! -e "${home}/.ssh/config.local" ]; then
      install -m 0600 -o ${user} -g staff /dev/null "${home}/.ssh/config.local"
    fi
    chmod 600 "${home}/.ssh/config.local"
    chown ${user}:staff "${home}/.ssh/config.local"

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

    # Install Rosetta 2 if not present
    if ! /usr/sbin/pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
      /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    fi
  '';
  environment.etc."dotfiles/wezterm/wezterm.lua".source = ../config/wezterm/wezterm.lua;
  environment.etc."dotfiles/wezterm/keybinds.lua".source = ../config/wezterm/keybinds.lua;
  environment.etc."dotfiles/ssh/config".source = ../config/ssh/config;
  environment.etc."dotfiles/git/config".source = ../config/git/config;
  environment.etc."dotfiles/gh/config.yml".source = ../config/gh/config.yml;
  environment.etc."dotfiles/hammerspoon/init.lua".source = ../config/hammerspoon/init.lua;
  environment.etc."dotfiles/1password/ssh/agent.toml".source = ../config/1password/ssh/agent.toml;

  # System state version
  system.stateVersion = 6;
}
