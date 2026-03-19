{ config, ... }:

let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
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

  # Deploy dotfiles to user home
  system.activationScripts.dotfiles.text = ''
    install -d -m 0755 -o ${user} -g staff "${home}/.config/wezterm"
    ln -sfn /etc/dotfiles/wezterm/wezterm.lua "${home}/.config/wezterm/wezterm.lua"
    ln -sfn /etc/dotfiles/wezterm/keybinds.lua "${home}/.config/wezterm/keybinds.lua"
    chown -h ${user}:staff "${home}/.config/wezterm/wezterm.lua" "${home}/.config/wezterm/keybinds.lua"

    # SSH config for Bitwarden SSH Agent
    install -d -m 0700 -o ${user} -g staff "${home}/.ssh"
    ln -sfn /etc/dotfiles/ssh/config "${home}/.ssh/config"
    chown -h ${user}:staff "${home}/.ssh/config"
  '';
  environment.etc."dotfiles/wezterm/wezterm.lua".source = ../config/wezterm/wezterm.lua;
  environment.etc."dotfiles/wezterm/keybinds.lua".source = ../config/wezterm/keybinds.lua;
  environment.etc."dotfiles/ssh/config".source = ../config/ssh/config;

  # Remove App Store version of Bitwarden (replaced by Cask for SSH Agent support)
  system.activationScripts.removeAppStoreBitwarden.text = ''
    if [ -d "/Applications/Bitwarden.app" ] && /usr/bin/mdls -name kMDItemAppStoreHasReceipt "/Applications/Bitwarden.app" 2>/dev/null | grep -q "1"; then
      /bin/rm -rf "/Applications/Bitwarden.app"
    fi
  '';

  # Install Rosetta 2 if not present
  system.activationScripts.rosetta.text = ''
    if ! /usr/sbin/pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
      /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    fi
  '';

  # System state version
  system.stateVersion = 6;
}
