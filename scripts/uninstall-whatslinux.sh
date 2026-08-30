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
      echo "Argumento desconhecido: $arg"
      echo "Uso: $0 [--purge]"
      exit 1
      ;;
  esac
done

removed_anything=0

if [[ -d "$TARGET_BUNDLE_DIR" ]]; then
  rm -rf "$TARGET_BUNDLE_DIR"
  echo "Removido: $TARGET_BUNDLE_DIR"
  removed_anything=1
else
  echo "Nada encontrado em: $TARGET_BUNDLE_DIR"
fi

if [[ -f "$TARGET_BIN" ]]; then
  rm -f "$TARGET_BIN"
  echo "Removido: $TARGET_BIN"
  removed_anything=1
else
  echo "Nada encontrado em: $TARGET_BIN"
fi

if [[ -f "$TARGET_DESKTOP" ]]; then
  rm -f "$TARGET_DESKTOP"
  echo "Removido: $TARGET_DESKTOP"
  removed_anything=1
else
  echo "Nada encontrado em: $TARGET_DESKTOP"
fi

SESSION_DIR="$HOME/.local/share/whatsapp-app"
if [[ "$REMOVE_SESSION" -eq 1 ]]; then
  if [[ -d "$SESSION_DIR" ]]; then
    rm -rf "$SESSION_DIR"
    echo "Removido (sessão): $SESSION_DIR"
  else
    echo "Nada encontrado em: $SESSION_DIR"
  fi
else
  if [[ -d "$SESSION_DIR" ]]; then
    echo ""
    echo "Dados de sessão preservados em: $SESSION_DIR"
    echo "Para removê-los também, rode: $0 --purge"
  fi
fi

echo ""
if [[ "$removed_anything" -eq 1 ]]; then
  echo "Desinstalação concluída."
else
  echo "Nada foi encontrado para remover — o app já parece desinstalado."
fi