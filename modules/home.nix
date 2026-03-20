{ config, lib, ... }:

{
  home.stateVersion = "24.11";

  # WezTerm config
  home.file.".config/wezterm/wezterm.lua".source = ../config/wezterm/wezterm.lua;
  home.file.".config/wezterm/keybinds.lua".source = ../config/wezterm/keybinds.lua;

  # Hammerspoon config
  home.file.".hammerspoon/init.lua".source = ../config/hammerspoon/init.lua;

  # Git config
  home.file.".gitconfig".source = ../config/git/config;

  # SSH config
  home.file.".ssh/config".source = ../config/ssh/config;

  # 1Password SSH Agent config
  home.file.".config/1Password/ssh/agent.toml".source = ../config/1password/ssh/agent.toml;

  # gh config (copy, not symlink — gh needs write access)
  # SSH config.local (create empty if not exists)
  # SSH directory permissions
  home.activation.deployMutable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # gh config (copy, not symlink — gh needs to write to this file)
    mkdir -p "$HOME/.config/gh"
    if [ ! -e "$HOME/.config/gh/config.yml" ] || [ -L "$HOME/.config/gh/config.yml" ]; then
      rm -f "$HOME/.config/gh/config.yml"
      cp ${../config/gh/config.yml} "$HOME/.config/gh/config.yml"
      chmod 644 "$HOME/.config/gh/config.yml"
    fi

    # SSH directory and config.local permissions
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    if [ ! -e "$HOME/.ssh/config.local" ]; then
      install -m 0600 /dev/null "$HOME/.ssh/config.local"
    fi
    chmod 600 "$HOME/.ssh/config.local"
  '';
}
