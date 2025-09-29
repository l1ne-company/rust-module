{
  description = ''
    module for dummy-serve (poc-only).

    build and runtime dependencies and deploy dumb-server 
  '';

  inputs.crane.url = "github:ipetkov/crane";

  outputs = { self, crane }: {
    garnixModules.default = { pkgs, lib, config, ... }:
      let
        craneLib = crane.mkLib pkgs;
        src = ./.; 
      in {
        options = { };

        config = {
          # Package build
          packages.default = craneLib.buildPackage {
            inherit src;
          };

          # CI checks
          checks = {
            cargo-clippy = craneLib.cargoClippy {
              inherit src;
              cargoClippyExtraArgs = "--all-targets -- --deny warnings";
            };
            cargo-fmt = craneLib.cargoFmt { inherit src; };
            cargo-doc = craneLib.cargoDoc { inherit src; };
          };

          devShells.default = craneLib.devShell { packages = [ ]; };

          # NixOS config for the webserver
          nixosConfigurations.default = [
            {
              services.nginx = {
                enable = true;
                recommendedProxySettings = true;
                recommendedOptimisation = true;
                virtualHosts.default = {
                  default = true;
                  locations."/".proxyPass = "http://localhost:6969";
                };
              };

              networking.firewall.allowedTCPPorts = [ 80 ];

              systemd.services.dumb-server = {
                description = "dumb-server (poc-only)";
                wantedBy = [ "multi-user.target" ];
                after = [ "network-online.target" ];
                wants = [ "network-online.target" ];
                environment.PORT = "6969";
                serviceConfig = {
                  Type = "simple";
                  DynamicUser = true;
                  ExecStart = lib.getExe (pkgs.writeShellApplication {
                    name = "start-rust-server";
                    runtimeInputs = [ config.packages.default ];
                    text = "server --port \"$PORT\""; 
                  });
                };
              };
            }
          ];
        };
      };
  };
}
