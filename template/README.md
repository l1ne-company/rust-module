# Rust Module Template

This is a template for using the `rust-module` library in your Rust projects.

## Quick Start

1. **Edit the constants in flake.nix:**
   ```nix
   PNAME = "your-app-name";  # Your package name
   PORT = "8080";            # Your service port
   ```

2. **Customize (optional):**
   - Add `devPackages` for dev tools
   - Override `binaryName` if different from PNAME
   - Add `extraBuildInputs` for system libraries
   - Extend CI checks via `project.defaultChecks // { your-check = ...; }`

## What You Get

- **Standard CI:** clippy, fmt, doc checks
- **Dev shell:** with cargo-watch and your tools
- **Package build:** using crane
- **SystemD service:** (optional) for deployment

## Example Usage

```bash
# Enter dev shell
nix develop

# Build package
nix build

# Run checks
nix flake check
```