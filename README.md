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

Hammerspoon requires one-time setup:

1. Open Hammerspoon from Launchpad
2. Preferences で以下を設定:
   - **ON:** Launch Hammerspoon at login, Show menu icon
   - **OFF:** Check for updates, Show dock icon, Keep Console window on top, Send crash data
3. "Enable Accessibility" をクリック → System Settings → Privacy & Security → Accessibility → Hammerspoon を ON
4. メニューバーの Hammerspoon アイコン → Reload Config

1Password requires one-time setup:

1. Open 1Password from Launchpad and sign in
2. Settings > Security → **Touch ID** を ON
3. Settings > Developer → **Set Up SSH Agent** を ON
   - 「SSHキー名をディスクに保存」→「キー名の使用」を選択
4. Settings > Developer → **Integrate with 1Password CLI** を ON
5. Settings > General → **Start at login** を ON
6. Safari → Settings → Extensions → **1Password** を ON
7. SSH鍵を1Passwordで作成し、GitHubに公開鍵を登録

iCloud Private Relay を有効にする: System Settings → Apple ID → iCloud → Private Relay → ON → IP Address Location を「Country and time zone」に変更

```bash
# GitHub CLI login (SSH protocol is pre-configured)
gh auth login
```

## Update

```bash
cd ~/dotfiles
git pull
sudo darwin-rebuild switch --flake .#macmini
```

> **Note:** `flake.lock` must be committed to the repository to ensure reproducible builds across machines.
