{ config, lib, pkgs, ... }:

let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  venvDir = "${home}/Models/.venv";
  venvPython = "${venvDir}/bin/python";
  venvBin = "${venvDir}/bin/vllm-mlx";
  hfHome = "${home}/Models/huggingface";
  vllmMlxVersion = "0.2.9";
  model = "mlx-community/gemma-4-e4b-it-4bit";
  port = "8000";
in {
  # Ensure venv with vllm-mlx is created
  system.activationScripts.setupMlxVenv.text = lib.mkAfter ''
    echo >&2 "setting up MLX venv..."
    MISE_DATA_DIR="${home}/.local/share/mise"
    MISE_PYTHON="$(find "$MISE_DATA_DIR/installs/python" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | head -1)"
    if [ -n "$MISE_PYTHON" ] && [ -x "$MISE_PYTHON/bin/python" ]; then
      if [ ! -f "${venvDir}/bin/python" ]; then
        sudo --user=${user} "$MISE_PYTHON/bin/python" -m venv "${venvDir}"
      fi
      sudo --user=${user} "${venvDir}/bin/pip" install -q --disable-pip-version-check "vllm-mlx==${vllmMlxVersion}" 2>/dev/null
    else
      echo >&2 "warning: mise python not found, skipping MLX venv setup"
    fi
  '';

  launchd.user.agents.mlx-server = {
    serviceConfig = {
      ProgramArguments = [
        "${venvBin}"
        "serve" model
        "--host" "0.0.0.0"
        "--port" port
        "--continuous-batching"
      ];
      EnvironmentVariables = {
        HF_HOME = hfHome;
      };
      KeepAlive = false;
      RunAtLoad = false;
      StandardOutPath = "/tmp/mlx-server.log";
      StandardErrorPath = "/tmp/mlx-server.err";
    };
  };
}
