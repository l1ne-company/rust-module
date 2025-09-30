{
  description = ''
    Generic Rust module library for building, developing, and deploying Rust projects.
    Provides reusable crane-based infrastructure for Rust projects.
  '';

  inputs.crane.url = "github:ipetkov/crane";

  outputs = { self, crane }:
    {
      lib = {
        # Main function to create Rust project outputs
        # Usage: rust-module.lib.mkRustProject { pkgs, src, PNAME, ... }
        mkRustProject = { pkgs, src, PNAME, extraBuildInputs ? [], cargoExtraArgs ? "", ... }@args:
          let
            craneLib = crane.mkLib pkgs;

            # Default CI checks - can be overridden or extended
            defaultChecks = {
              clippy = craneLib.cargoClippy {
                inherit src;
                pname = PNAME;
                cargoClippyExtraArgs = args.cargoClippyExtraArgs or "--all-targets -- --deny warnings";
              };
              fmt = craneLib.cargoFmt { inherit src; };
              doc = craneLib.cargoDoc {
                inherit src;
                pname = PNAME;
              };
            };
          in {
            # Expose craneLib so consumers can extend
            inherit craneLib;

            # Standard package output
            package = craneLib.buildPackage ({
              inherit src;
              pname = PNAME;
              buildInputs = extraBuildInputs;
              inherit cargoExtraArgs;
            } // (args.packageOverrides or {}));

            # Development shell
            devShell = craneLib.devShell ({
              packages = extraBuildInputs ++ (args.devPackages or []);
              shellHook = args.shellHook or "";
            } // (args.devShellOverrides or {}));

            # CI checks - use defaults or provide custom ones
            checks = if args.checks or null != null
              then args.checks
              else defaultChecks;

            # Expose defaults so they can be extended
            defaultChecks = defaultChecks;
          };

        # Helper to create a systemd service for a Rust binary
        # Usage: rust-module.lib.mkRustSystemdService { lib, pkgs, config, PNAME, PORT, ... }
        mkRustSystemdService = { lib, pkgs, config, PNAME, PORT, binaryName ? PNAME, extraEnv ? {}, ... }@args:
          {
            systemd.services.${PNAME} = {
              description = args.description or "${PNAME} service";
              wantedBy = [ "multi-user.target" ];
              after = [ "network-online.target" ];
              wants = [ "network-online.target" ];
              environment = extraEnv // { PORT = PORT; };
              serviceConfig = {
                Type = "simple";
                DynamicUser = args.dynamicUser or true;
                ExecStart = lib.getExe (pkgs.writeShellApplication {
                  name = "start-${PNAME}";
                  runtimeInputs = [ config.packages.default ];
                  text = args.startCommand or "${binaryName} --port \"$PORT\"";
                });
              } // (args.extraServiceConfig or {});
            };
          };
      };
    };
}
