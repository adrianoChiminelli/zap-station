#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
APP_NAME="WhatsLinux"
BUILD_DIR="$ROOT_DIR/dist"
APP_BUNDLE_DIR="$BUILD_DIR/$APP_NAME"

INSTALL_ROOT="${WHATSAPP_INSTALL_ROOT:-$HOME/.local/opt/whatslinux}"
BIN_DIR="${WHATSAPP_BIN_DIR:-$HOME/.local/bin}"
DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

TARGET_BUNDLE_DIR="$INSTALL_ROOT"
TARGET_BIN="$BIN_DIR/whatslinux"
TARGET_DESKTOP="$DESKTOP_DIR/whatslinux.desktop"

if [[ ! -d "$APP_BUNDLE_DIR" ]]; then
  echo "Bundle not found in $APP_BUNDLE_DIR"
  echo "Run the build script first:"
  echo "  ./scripts/build-whatslinux.sh"
  exit 1
fi

if [[ ! -x "$APP_BUNDLE_DIR/$APP_NAME" ]]; then
  echo "Executable not found or not executable in $APP_BUNDLE_DIR/$APP_NAME"
  exit 1
fi

mkdir -p "$BIN_DIR" "$DESKTOP_DIR" "$(dirname "$INSTALL_ROOT")"

rm -rf "$TARGET_BUNDLE_DIR"
cp -a "$APP_BUNDLE_DIR" "$TARGET_BUNDLE_DIR"
# assets are already embedded in the bundle (copied during build via --add-data),
# no need to copy them again here

cat > "$TARGET_BIN" <<EOF
#!/usr/bin/env bash
exec "$TARGET_BUNDLE_DIR/$APP_NAME" "\$@"
EOF
chmod +x "$TARGET_BIN"

cat > "$TARGET_DESKTOP" <<EOF
[Desktop Entry]
Type=Application
Name=WhatsLinux
Comment=WhatsApp Web wrapper para Linux
Exec=$TARGET_BIN
Icon=$TARGET_BUNDLE_DIR/assets/icon.png
Terminal=false
Categories=Network;InstantMessaging;
StartupWMClass=whatslinux
EOF

chmod 644 "$TARGET_DESKTOP"

echo "Installation completed."
echo "Executable: $TARGET_BIN"
echo "Bundle: $TARGET_BUNDLE_DIR"
echo "App menu shortcut: $TARGET_DESKTOP"
echo ""
echo "Remember that WhatsLinux.py should contain, right after creating the QApplication:"
echo "  app.setDesktopFileName(\"whatslinux\")"
echo "so that the .desktop StartupWMClass matches the real window of the application."
echo ""
echo "To run it:"
echo "  whatslinux"
echo ""
echo "To install in another folder, define WHATSAPP_INSTALL_ROOT and WHATSAPP_BIN_DIR"
echo "before running this script."