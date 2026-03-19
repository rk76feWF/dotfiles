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
    [credential "https://github.com"]
      helper = !/run/current-system/sw/bin/gh auth git-credential
    [credential "https://gist.github.com"]
      helper = !/run/current-system/sw/bin/gh auth git-credential
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
