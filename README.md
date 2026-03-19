# dotfiles

nix-darwin dotfiles for macOS.

## Prerequisites

```bash
# Xcode Command Line Tools
xcode-select --install

# Nix
sh <(curl -L https://nixos.org/nix/install) --daemon

# Rename files that conflict with nix-darwin
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
```

## Install

```bash
git clone https://github.com/rk76feWF/dotfiles.git
cd dotfiles
# Initial install (flakes not yet enabled, so pass flags explicitly)
sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake .#macmini
```

## Post-install

OrbStack requires a one-time GUI setup. Open OrbStack from Launchpad and complete the initial setup dialog.

## Update

```bash
cd ~/dotfiles
git pull
sudo darwin-rebuild switch --flake .#macmini
```

> **Note:** `flake.lock` must be committed to the repository to ensure reproducible builds across machines.
