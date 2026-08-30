# WhatsLinux
Native WhatsApp Web client for Linux, built with PyQt6 and PyQt6-WebEngine. A dedicated window that loads only WhatsApp Web, with persistent session, dark theme, native notifications, and restricted domain access — no address bar, no tabs, no browser distractions.

## Features

- desktop interface in PyQt6
- WebEngine navigation restricted to `web.whatsapp.com`
- session and cookie persistence in the user's local directory
- system notification integration via `notify-send`

## Requirements

- Python 3.10+
- pip
- `libnotify` library for system notifications (`notify-send`), when available

## Installation

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Running in development

```bash
source .venv/bin/activate
python WhatsLinux.py
```

## Linux packaging

Packaging is done in two steps, each with its own script inside `scripts/`:

1. **`build-whatslinux.sh`** — creates the virtual environment if needed, installs dependencies, and generates the PyInstaller bundle (`--onedir`) in `dist/WhatsLinux/` inside the project root.
2. **`install-whatslinux.sh`** — copies the generated bundle to `~/.local/opt`, creates the terminal command in `~/.local/bin`, and adds the `.desktop` shortcut to the application menu.

Separating the two phases allows testing the generated binary before installing it on the system.

### 1. Build the app

```bash
chmod +x scripts/build-whatslinux.sh
./scripts/build-whatslinux.sh
```

The bundle is generated in `dist/WhatsLinux/`. Before proceeding with installation, test the executable directly:

```bash
dist/WhatsLinux/WhatsLinux
```

If the window opens and loads WhatsApp Web normally, the build is validated.

### 2. Install on the system

```bash
chmod +x scripts/install-whatslinux.sh
./scripts/install-whatslinux.sh
```

The script fails with a clear message if the build does not exist yet, telling you to run `build-whatslinux.sh` first.

### Expected result

- application installed in:
  - `$HOME/.local/opt/whatslinux`
- terminal command in:
  - `$HOME/.local/bin/whatslinux`
- app-menu shortcut in:
  - `$HOME/.local/share/applications/whatslinux.desktop`

### Optional variables

Both variables are read by the installation script (`install-whatslinux.sh`):

```bash
WHATSAPP_INSTALL_ROOT="$HOME/.local/opt/whatslinux" \
WHATSAPP_BIN_DIR="$HOME/.local/bin" \
./scripts/install-whatslinux.sh
```

### Running after installation

```bash
whatslinux
```

### Rebuilding

Whenever the source code changes, run `build-whatslinux.sh` again before `install-whatslinux.sh` so the installation reflects the latest bundle version.

## Uninstallation

The `uninstall-whatslinux.sh` script removes exactly what `install-whatslinux.sh` installed: the bundle in `~/.local/opt/whatslinux`, the command in `~/.local/bin/whatslinux`, and the `.desktop` shortcut.

```bash
chmod +x scripts/uninstall-whatslinux.sh
./scripts/uninstall-whatslinux.sh
```

By default, session data (`~/.local/share/whatsapp-app`) is preserved — so if you reinstall later, you won't need to scan the QR code again. To remove the saved session as well:

```bash
./scripts/uninstall-whatslinux.sh --purge
```

If you installed in a custom path (using `WHATSAPP_INSTALL_ROOT`/`WHATSAPP_BIN_DIR`), define the same variables before uninstalling:

```bash
WHATSAPP_INSTALL_ROOT="/custom/path" \
WHATSAPP_BIN_DIR="/another/path" \
./scripts/uninstall-whatslinux.sh
```

## Where the session is stored

Session data (cookies, localStorage, cache) is stored in:

```
~/.local/share/whatsapp-app
```

## Notes

- This project was created for educational purposes and personal use.
- Since there is no official public API for third-party clients, WhatsLinux works as a wrapper around WhatsApp Web and may stop working if Meta changes something that breaks this access pattern.
- Session data stored locally does not have additional encryption beyond what WhatsApp Web itself already implements — this is the same level of exposure as saving a session in a regular browser.

## License
MIT