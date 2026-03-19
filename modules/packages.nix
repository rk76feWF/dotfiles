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
    (texlive.combine {
      inherit (texlive) scheme-medium latexmk;
    })
  ];

  # Default shell
  programs.zsh.enable = true;
}
