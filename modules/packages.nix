{ pkgs, ... }:

{
  # CLI tools from Nix store
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    jq
    ripgrep
    fd
    htop
  ];

  # Default shell
  programs.zsh.enable = true;
}
