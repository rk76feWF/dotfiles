{ pkgs, ... }:

{
  # CLI tools from Nix store
  environment.systemPackages = with pkgs; [
    git
    git-lfs
    vim
    curl
    wget
    jq
    dig
    ffmpeg
    htop
    iperf3
    mise
    nmap
    rclone
    starship
    tree
    whisper-cpp
    llama-cpp
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
      eval "$(mise activate zsh)"
    '';
  };
}
