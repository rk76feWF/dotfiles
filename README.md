# dotfiles

nix-darwin dotfiles for macOS.

## Prerequisites

```bash
# Xcode Command Line Tools
xcode-select --install

# Nix
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes
echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

## Install

```bash
git clone https://github.com/rk76feWF/dotfiles.git
cd dotfiles
nix run nix-darwin -- switch --flake .#macmini
```

## Update

```bash
cd ~/dotfiles
git pull
darwin-rebuild switch --flake .#macmini
```
