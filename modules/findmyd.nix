{ config, lib, pkgs, inputs, ... }:

let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  findmyd = inputs.findmyd.packages.${pkgs.system}.default;
  cacheDir = "${home}/Library/Caches/com.apple.findmy.fmipcore";
  dbDir = "${home}/.local/share/findmyd";
  dbPath = "${dbDir}/findmyd.db";
  keyPath = "${dbDir}/fmip.key";
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
          ${op}/bin/op read --out-file "${keyPath}" --force "op://Personal/findmy/FMIPDataManager.bplist"
          chmod 600 "${keyPath}"
          export FMIP_KEY_FILE="${keyPath}"
          export CACHE_DIR="${cacheDir}"
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
}
