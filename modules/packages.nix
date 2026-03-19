{ pkgs, ... }:

{
  # CLI tools from Nix store
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    jq
    dig
    htop
    claude-code
    codex
    (texlive.combine {
      inherit (texlive) scheme-medium latexmk;
    })
  ];

  # Default shell
  programs.zsh.enable = true;
}
