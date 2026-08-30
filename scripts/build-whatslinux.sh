#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
APP_NAME="WhatsLinux"
BUILD_DIR="$ROOT_DIR/dist"
VENV_DIR="$ROOT_DIR/.venv"

if [[ ! -d "$ROOT_DIR" ]]; then
  echo "Project directory not found: $ROOT_DIR"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 not found in PATH."
  exit 1
fi

if [[ ! -f "$ROOT_DIR/requirements.txt" ]]; then
  echo "requirements.txt not found in $ROOT_DIR"
  exit 1
fi

if [[ ! -d "$VENV_DIR" ]]; then
  echo "Creating virtual environment in $VENV_DIR"
  python3 -m venv "$VENV_DIR"
fi

PYTHON_BIN="$VENV_DIR/bin/python"
PIP_BIN="$VENV_DIR/bin/pip"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Invalid virtual environment: $PYTHON_BIN"
  exit 1
fi

"$PIP_BIN" install --upgrade pip >/dev/null
"$PIP_BIN" install -r "$ROOT_DIR/requirements.txt"

rm -rf "$BUILD_DIR"
"$PYTHON_BIN" -m PyInstaller \
  --noconfirm \
  --clean \
  --name "$APP_NAME" \
  --icon "$ROOT_DIR/assets/icon.png" \
  --onedir \
  --contents-directory "." \
  --collect-all PyQt6 \
  --add-data "$ROOT_DIR/assets:assets" \
  "$ROOT_DIR/WhatsLinux.py"

echo "Build completed."
echo "Bundle generated in: $BUILD_DIR/$APP_NAME"
echo ""
echo "Before installing, test the binary directly:"
echo "  $BUILD_DIR/$APP_NAME/$APP_NAME"
echo "If a QtWebEngineProcess error appears or the window opens blank,"
echo "check the logs — --collect-all PyQt6 covers most cases."
echo ""
echo "Once the build is validated, run the installation script:"
echo "  ./scripts/install-whatslinux.sh"