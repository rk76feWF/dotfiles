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
    starship
    claude-code
    codex
    (texlive.combine {
      inherit (texlive) scheme-medium latexmk;
    })
  ];

  # Default shell
  programs.zsh = {
    enable = true;
    promptInit = "";
    interactiveShellInit = ''
      export STARSHIP_CONFIG=/etc/starship.toml
      eval "$(starship init zsh)"
    '';
  };
}
