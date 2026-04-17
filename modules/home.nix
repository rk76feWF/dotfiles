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

  # GitHub CLI (config.yml is managed declaratively; hosts.yml stays mutable for gh auth login)
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = false; # managed manually in config/git/config
    settings = {
      git_protocol = "ssh";
    };
  };

  # SSH directory permissions and config.local (create empty if not exists)
  home.activation.deploySsh = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.ssh/config.local" ]; then
      install -m 0600 /dev/null "$HOME/.ssh/config.local"
    else
      # Ensure permissions are correct even if file exists
      chmod 0600 "$HOME/.ssh/config.local"
    fi
  '';
}
