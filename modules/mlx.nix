{ config, lib, pkgs, ... }:

let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  venvDir = "${home}/Models/spark-venv";
  optiq = "${venvDir}/bin/optiq";
  hfHome = "${home}/.cache/huggingface";
  kvConfig = "${home}/Models/spark-kv-config.json";
  optiqVersion = "0.5.7";
  model = "mlx-community/Spark-X2.5-4B-OptiQ-4bit";
  port = "8082";
in {
  # Ensure the MLX OptiQ environment and Spark KV profile are present.
  system.activationScripts.setupMlxVenv.text = lib.mkAfter ''
    echo >&2 "setting up Spark OptiQ venv..."
    MISE_DATA_DIR="${home}/.local/share/mise"
    MISE_PYTHON="$(find "$MISE_DATA_DIR/installs/python" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | head -1)"
    if [ -n "$MISE_PYTHON" ] && [ -x "$MISE_PYTHON/bin/python" ]; then
      if [ ! -f "${venvDir}/bin/python" ]; then
        sudo --user=${user} "$MISE_PYTHON/bin/python" -m venv "${venvDir}"
      fi
      sudo --user=${user} "${venvDir}/bin/pip" install -q --disable-pip-version-check "mlx-optiq==${optiqVersion}" 2>/dev/null
      sudo --user=${user} ${pkgs.curl}/bin/curl -fsSL \
        "https://huggingface.co/${model}/resolve/main/kv_config.json" \
        -o "${kvConfig}"
    else
      echo >&2 "warning: mise python not found, skipping MLX venv setup"
    fi
  '';

  launchd.user.agents.mlx-server = {
    serviceConfig = {
      ProgramArguments = [
        optiq
        "serve"
        "--model" model
        "--host" "0.0.0.0"
        "--port" port
        "--max-tokens" "1024"
        "--chat-template-args" ''{"enable_thinking":false}''
        "--kv-config" kvConfig
        "--max-concurrent" "1"
        "--max-context" "32768"
        "--prompt-cache-bytes" "2147483648"
        "--no-auth"
      ];
      EnvironmentVariables = {
        HF_HOME = hfHome;
      };
      KeepAlive = false;
      RunAtLoad = false;
      StandardOutPath = "/tmp/spark-server.log";
      StandardErrorPath = "/tmp/spark-server.err";
    };
  };
}
