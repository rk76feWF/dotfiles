{ config, lib, pkgs, inputs, ... }:

let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  findmyd = inputs.findmyd.packages.${pkgs.system}.default;
  cacheDir = "${home}/Library/Caches/com.apple.findmy.fmipcore";
  fmfCacheDir = "${home}/Library/Caches/com.apple.findmy.fmfcore";
  dbDir = "${home}/.local/share/findmyd";
  dbPath = "${dbDir}/findmyd.db";
  fmipKeyPath = "${dbDir}/fmip.key";
  fmfKeyPath = "${dbDir}/fmf.key";
  op = pkgs._1password-cli;
in {
  system.activationScripts.setupFindmyd.text = lib.mkAfter ''
    install -d -m 0700 -o ${user} -g staff "${dbDir}"
  '';

  launchd.user.agents.findmyd = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/bash" "-c"
        ''
          ${op}/bin/op read --out-file "${fmipKeyPath}" --force "op://Personal/findmy/FMIPDataManager.bplist"
          chmod 600 "${fmipKeyPath}"
          ${op}/bin/op read --out-file "${fmfKeyPath}" --force "op://Personal/findmy/FMFDataManager.bplist"
          chmod 600 "${fmfKeyPath}"
          export FMIP_KEY_FILE="${fmipKeyPath}"
          export FMF_KEY_FILE="${fmfKeyPath}"
          export CACHE_DIR="${cacheDir}"
          export FMF_CACHE_DIR="${fmfCacheDir}"
          export DB_PATH="${dbPath}"
          export POLL_INTERVAL=2
          export PORT=8080
          exec ${findmyd}/bin/findmyd
        ''
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/findmyd.log";
      StandardErrorPath = "/tmp/findmyd.err";
    };
  };

  launchd.user.agents.findmy-keepalive = {
    serviceConfig = {
      ProgramArguments = [
        "/usr/bin/osascript" "-e"
        ''tell application "FindMy" to activate''
      ];
      StartInterval = 5;
      RunAtLoad = true;
    };
  };
}
