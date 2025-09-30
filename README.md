# Nix lib for dumb-service (POC only)

Flow: systemd -> script in Nix store -> your Rust binary -> listens on port

### Service Unit File (example)

```ini
[Unit]
Description=Rust Module Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/nix/store/...-start-rust-server/bin/start-rust-server
Restart=on-failure
RestartSec=5s
User=rust-module
PrivateTmp=true
ProtectSystem=strict
Environment=PORT=6969

[Install]
WantedBy=multi-user.target
```

[Special systemd units](https://www.freedesktop.org/software/systemd/man/latest/systemd.special.html)
