#!/usr/bin/env bash
set -euo pipefail

INSTALL_ROOT="${WHATSAPP_INSTALL_ROOT:-$HOME/.local/opt/whatslinux}"
BIN_DIR="${WHATSAPP_BIN_DIR:-$HOME/.local/bin}"
DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

TARGET_BUNDLE_DIR="$INSTALL_ROOT"
TARGET_BIN="$BIN_DIR/whatslinux"
TARGET_DESKTOP="$DESKTOP_DIR/whatslinux.desktop"

REMOVE_SESSION=0
for arg in "$@"; do
  case "$arg" in
    --purge)
      REMOVE_SESSION=1
      ;;
    *)
      echo "Unknown argument: $arg"
      echo "Usage: $0 [--purge]"
      exit 1
      ;;
  esac
done

removed_anything=0

if [[ -d "$TARGET_BUNDLE_DIR" ]]; then
  rm -rf "$TARGET_BUNDLE_DIR"
  echo "Removed: $TARGET_BUNDLE_DIR"
  removed_anything=1
else
  echo "Nothing found in: $TARGET_BUNDLE_DIR"
fi

if [[ -f "$TARGET_BIN" ]]; then
  rm -f "$TARGET_BIN"
  echo "Removed: $TARGET_BIN"
  removed_anything=1
else
  echo "Nothing found in: $TARGET_BIN"
fi

if [[ -f "$TARGET_DESKTOP" ]]; then
  rm -f "$TARGET_DESKTOP"
  echo "Removed: $TARGET_DESKTOP"
  removed_anything=1
else
  echo "Nothing found in: $TARGET_DESKTOP"
fi

SESSION_DIR="$HOME/.local/share/whatsapp-app"
if [[ "$REMOVE_SESSION" -eq 1 ]]; then
  if [[ -d "$SESSION_DIR" ]]; then
    rm -rf "$SESSION_DIR"
    echo "Removed (session): $SESSION_DIR"
  else
    echo "Nothing found in: $SESSION_DIR"
  fi
else
  if [[ -d "$SESSION_DIR" ]]; then
    echo ""
    echo "Session data preserved in: $SESSION_DIR"
    echo "To remove it as well, run: $0 --purge"
  fi
fi

echo ""
if [[ "$removed_anything" -eq 1 ]]; then
  echo "Uninstallation completed."
else
  echo "Nothing was found to remove — the app appears to already be uninstalled."
fi