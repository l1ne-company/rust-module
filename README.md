# rust-module

Generic Rust module library for building, developing, and deploying Rust projects with Nix.

Provides reusable crane-based infrastructure with standard CI checks (clippy, fmt, doc) and optional systemd service deployment.

## Quick Start

Initialize a new project with the template:

```bash
nix flake init -t github:l1ne-company/rust-module
```

Or add to an existing flake:

```nix
inputs.rust-module.url = "github:l1ne-company/rust-module";
```

See [template/README.md](template/README.md) for details.

## Features

- **Standard CI:** clippy, fmt, doc checks built-in
- **Extensible:** Add custom checks, build inputs, dev packages
- **Dev shell:** Pre-configured development environment
- **SystemD service:** Optional deployment helper
- **Pure library:** No assumptions about your project structure

## Usage Patterns

### 1. Basic Project

```nix
project = rust-module.lib.mkRustProject {
  inherit pkgs;
  src = ./.;
  PNAME = "my-app";
};

# Use: project.package, project.devShell, project.checks
```

### 2. Extended CI

```nix
project = rust-module.lib.mkRustProject {
  inherit pkgs;
  src = ./.;
  PNAME = "my-app";
};

checks = project.defaultChecks // {
  nextest = project.craneLib.cargoNextest { inherit src; pname = PNAME; };
};
```

### 3. SystemD Service

```nix
rust-module.lib.mkRustSystemdService {
  inherit (pkgs) lib;
  inherit pkgs;
  PNAME = "my-app";
  PORT = "8080";
  config = { packages.default = project.package; };
}
```

## Architecture

Flow: systemd → Nix store script → your Rust binary → listens on PORT

The library uses [crane](https://github.com/ipetkov/crane) for efficient Rust builds with Nix.

See [template/](template/) for a complete example.