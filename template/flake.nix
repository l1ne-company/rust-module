{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-module.url = "github:l1ne-company/rust-module";
  };

  outputs = { self, nixpkgs, rust-module, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Define your constants
      PNAME = "dumb-server";
      PORT = "6969";

      # Build your project
      project = rust-module.lib.mkRustProject {
        inherit pkgs;
        src = ./.;
        inherit PNAME;

        # Optional: add extra packages, CI checks, etc.
        devPackages = [ pkgs.cargo-watch ];
      };
    in {
      # Standard outputs
      packages.${system}.default = project.package;
      devShells.${system}.default = project.devShell;
      checks.${system} = project.checks;

      # Optional: systemd service
      nixosConfigurations.default = {
        imports = [
          (rust-module.lib.mkRustSystemdService {
            inherit (pkgs) lib;
            inherit pkgs;
            inherit PNAME PORT;
            config = { packages.default = project.package; };
            binaryName = "server";  # if different from PNAME
          })
        ];
      };
    };
}