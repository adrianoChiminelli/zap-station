# ZapStation
ZapStation is a native WhatsApp Web client for Linux, built with Python and PyQt6 (PyQt6-WebEngine). It provides a focused, windowed experience for WhatsApp Web with session persistence and native notifications.

## Features

- Minimal desktop window for WhatsApp Web (no address bar, no tabs)
- Persistent session and cookies stored locally
- Navigation locked to `web.whatsapp.com`
- Native system notifications via `notify-send`

## Requirements

- Python 3.10+
- pip
- `libnotify` (for `notify-send`) — optional but recommended

## Installation (development)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Run in development

```bash
source .venv/bin/activate
python ZapStation.py
```

## Packaging for Linux

Packaging is split into two scripts under `scripts/`:

1. `build-zapstation.sh` — creates the virtualenv (if needed), installs dependencies, and builds a PyInstaller `--onedir` bundle under `dist/ZapStation/`.
2. `install-zapstation.sh` — copies the validated bundle to the user's local opt directory, creates a terminal launcher, and installs a `.desktop` shortcut.

This separation lets you test the bundle before installing it system-wide.

### 1) Build

```bash
chmod +x scripts/build-zapstation.sh
./scripts/build-zapstation.sh
```

The bundle will be created at `dist/ZapStation/`. Test it directly before installing:

```bash
dist/ZapStation/ZapStation
```

If the window opens and WhatsApp Web loads, the build is considered validated.

### 2) Install

```bash
chmod +x scripts/install-zapstation.sh
./scripts/install-zapstation.sh
```

If the build is missing, the installer will prompt you to run the build script first.

### Expected locations after install

- Bundle: `$HOME/.local/opt/zapstation`
- Terminal command: `$HOME/.local/bin/zapstation` (call `zapstation`)
- Application shortcut: `$HOME/.local/share/applications/zapstation.desktop`

### Optional environment variables

```bash
ZAP_STATION_INSTALL_ROOT="$HOME/.local/opt/zapstation" \
ZAP_STATION_BIN_DIR="$HOME/.local/bin" \
./scripts/install-zapstation.sh
```

### Rebuild

Whenever you change the source, run the build script again before installing to pick up the changes.

## Uninstall

```bash
chmod +x scripts/uninstall-zapstation.sh
./scripts/uninstall-zapstation.sh
```

To remove saved session data as well:

```bash
./scripts/uninstall-zapstation.sh --purge
```

If you used custom install paths, pass the same `ZAP_STATION_INSTALL_ROOT` / `ZAP_STATION_BIN_DIR` values when uninstalling.

## Where session data is stored

Session data (cookies, localStorage, cache) is stored at:

```
~/.local/share/zap-station
```

## Notes

- This project was created for educational purposes and personal use and is published as open source for learning and experimentation.
- Because there is no official public API for third-party clients, ZapStation works by wrapping WhatsApp Web and may stop working if Meta changes the web client.
- Local session data is only protected by the same mechanisms WhatsApp Web uses; there is no additional encryption applied by this project.

## License

MIT
