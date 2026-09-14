{ config, lib, pkgs, ... }:

let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  venvDir = "${home}/Models/.venv";
  venvPython = "${venvDir}/bin/python";
  hfHome = "${home}/Models/huggingface";
  mlxVlmVersion = "0.7.0";
  model = "ornith-ai/Ornith-1.5-9B-MLX-4bit";
  port = "8081";
in {
  # Ensure venv with mlx-vlm is created
  system.activationScripts.setupMlxVenv.text = lib.mkAfter ''
    echo >&2 "setting up MLX venv..."
    MISE_DATA_DIR="${home}/.local/share/mise"
    MISE_PYTHON="$(find "$MISE_DATA_DIR/installs/python" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | head -1)"
    if [ -n "$MISE_PYTHON" ] && [ -x "$MISE_PYTHON/bin/python" ]; then
      if [ ! -f "${venvDir}/bin/python" ]; then
        sudo --user=${user} "$MISE_PYTHON/bin/python" -m venv "${venvDir}"
      fi
      sudo --user=${user} "${venvDir}/bin/pip" install -q --disable-pip-version-check "mlx-vlm==${mlxVlmVersion}" 2>/dev/null
    else
      echo >&2 "warning: mise python not found, skipping MLX venv setup"
    fi
  '';

  launchd.user.agents.mlx-server = {
    serviceConfig = {
      ProgramArguments = [
        "${venvPython}"
        "-m" "mlx_vlm.server"
        "--model" model
        "--host" "0.0.0.0"
        "--port" port
        "--max-tokens" "4096"
        "--enable-thinking"
        "--thinking-budget" "512"
        "--kv-bits" "3.5"
        "--kv-quant-scheme" "turboquant"
        "--max-kv-size" "32768"
        "--max-num-seqs" "1"
      ];
      EnvironmentVariables = {
        APC_ENABLED = "1";
        HF_HOME = hfHome;
      };
      KeepAlive = false;
      RunAtLoad = false;
      StandardOutPath = "/tmp/mlx-server.log";
      StandardErrorPath = "/tmp/mlx-server.err";
    };
  };
}
