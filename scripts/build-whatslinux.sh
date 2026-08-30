#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
APP_NAME="WhatsLinux"
BUILD_DIR="$ROOT_DIR/dist"
VENV_DIR="$ROOT_DIR/.venv"

if [[ ! -d "$ROOT_DIR" ]]; then
  echo "Diretório do projeto não encontrado: $ROOT_DIR"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 não encontrado no PATH."
  exit 1
fi

if [[ ! -f "$ROOT_DIR/requirements.txt" ]]; then
  echo "requirements.txt não encontrado em $ROOT_DIR"
  exit 1
fi

if [[ ! -d "$VENV_DIR" ]]; then
  echo "Criando ambiente virtual em $VENV_DIR"
  python3 -m venv "$VENV_DIR"
fi

PYTHON_BIN="$VENV_DIR/bin/python"
PIP_BIN="$VENV_DIR/bin/pip"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Ambiente virtual inválido: $PYTHON_BIN"
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

echo "Build concluído."
echo "Bundle gerado em: $BUILD_DIR/$APP_NAME"
echo ""
echo "Antes de instalar, teste rodando o binário direto:"
echo "  $BUILD_DIR/$APP_NAME/$APP_NAME"
echo "Se aparecer erro relacionado a QtWebEngineProcess ou a janela abrir em branco,"
echo "confira os logs — o --collect-all PyQt6 já cobre a maioria dos casos."
echo ""
echo "Quando o build estiver validado, rode o script de instalação:"
echo "  ./scripts/install-whatslinux.sh"