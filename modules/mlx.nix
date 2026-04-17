{ pkgs, ... }:

let
  mlxPython = (pkgs.python312.override {
    packageOverrides = final: prev: {
      joblib = prev.joblib.overridePythonAttrs { doCheck = false; };
    };
  }).withPackages (ps: with ps; [
    mlx
    mlx-lm
  ]);
in {
  environment.systemPackages = [ mlxPython ];

  launchd.user.agents.mlx-server = {
    serviceConfig = {
      ProgramArguments = [
        "${mlxPython}/bin/python"
        "-m"
        "mlx_lm.server"
        "--model" "mlx-community/gemma-4-e4b-it-4bit"
        "--port" "8081"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/mlx-server.log";
      StandardErrorPath = "/tmp/mlx-server.err";
    };
  };
}
