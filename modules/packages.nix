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
    gh
    htop
    starship
    claude-code
    codex
    (texlive.combine {
      inherit (texlive) scheme-medium latexmk;
    })
  ];

  # Git config
  environment.etc."gitconfig".text = ''
    [user]
      name = FUKUMOTO Yuki
      email = rk76fewf@gmail.com
  '';

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
