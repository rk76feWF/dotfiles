{ ... }:

{
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

  # Install Rosetta 2 if not present
  system.activationScripts.rosetta.text = ''
    if ! /usr/bin/pgrep -q oahd; then
      /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    fi
  '';

  # System state version
  system.stateVersion = 6;
}
