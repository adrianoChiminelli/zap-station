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
  echo "Bundle não encontrado em $APP_BUNDLE_DIR"
  echo "Rode o script de build primeiro:"
  echo "  ./scripts/build-whatslinux.sh"
  exit 1
fi

if [[ ! -x "$APP_BUNDLE_DIR/$APP_NAME" ]]; then
  echo "Executável não encontrado ou sem permissão em $APP_BUNDLE_DIR/$APP_NAME"
  exit 1
fi

mkdir -p "$BIN_DIR" "$DESKTOP_DIR" "$(dirname "$INSTALL_ROOT")"

rm -rf "$TARGET_BUNDLE_DIR"
cp -a "$APP_BUNDLE_DIR" "$TARGET_BUNDLE_DIR"
# assets já vêm embutidos no bundle (copiados no build via --add-data),
# não é necessário copiar de novo aqui

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

echo "Instalação concluída."
echo "Executável: $TARGET_BIN"
echo "Bundle: $TARGET_BUNDLE_DIR"
echo "Atalho do menu: $TARGET_DESKTOP"
echo ""
echo "Lembre-se de que WhatsLinux.py precisa conter, logo após criar o QApplication:"
echo "  app.setDesktopFileName(\"whatslinux\")"
echo "para o StartupWMClass do .desktop bater com a janela real da aplicação."
echo ""
echo "Para executar:"
echo "  whatslinux"
echo ""
echo "Para instalar em outra pasta, defina WHATSAPP_INSTALL_ROOT e WHATSAPP_BIN_DIR"
echo "antes de rodar este script."