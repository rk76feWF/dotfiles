{ config, lib, pkgs, ... }:

let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  venvDir = "${home}/Models/.venv";
  venvPython = "${venvDir}/bin/python";
  model = "mlx-community/gemma-4-e4b-it-4bit";
  port = "8081";
in {
  # Ensure venv with mlx-lm is created
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo >&2 "setting up MLX venv..."
    MISE_PYTHON="$(sudo --user=${user} ${pkgs.mise}/bin/mise where python 2>/dev/null || true)"
    if [ -n "$MISE_PYTHON" ] && [ -x "$MISE_PYTHON/bin/python" ]; then
      if [ ! -f "${venvDir}/bin/python" ]; then
        sudo --user=${user} "$MISE_PYTHON/bin/python" -m venv "${venvDir}"
      fi
      sudo --user=${user} "${venvDir}/bin/pip" install -q --upgrade mlx-lm 2>/dev/null
    else
      echo >&2 "warning: mise python not found, skipping MLX venv setup"
    fi
  '';

  launchd.user.agents.mlx-server = {
    serviceConfig = {
      ProgramArguments = [
        "${venvPython}"
        "-m" "mlx_lm.server"
        "--model" model
        "--port" port
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/mlx-server.log";
      StandardErrorPath = "/tmp/mlx-server.err";
    };
  };
}
