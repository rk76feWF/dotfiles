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

  # System state version
  system.stateVersion = 6;
}
