# WhatsLinux
Cliente de WhatsApp Web nativo para Linux, construído com PyQt6 e PyQt6-WebEngine. Uma janela dedicada que carrega apenas o WhatsApp Web, com sessão persistente, tema escuro, notificações nativas e domínio travado — sem barra de endereço, sem abas, sem distrações de navegador.

## Funcionalidades

- interface desktop em PyQt6
- navegação por WebEngine restrita a `web.whatsapp.com`
- persistência de sessão e cookies no diretório local do usuário
- integração com notificações do sistema via `notify-send`

## Requisitos

- Python 3.10+
- pip
- biblioteca `libnotify` para notificações do sistema (`notify-send`), quando disponível

## Instalação

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Execução em desenvolvimento

```bash
source .venv/bin/activate
python WhatsLinux.py
```

## Empacotamento para Linux

O empacotamento é feito em duas etapas, cada uma com seu próprio script dentro de `scripts/`:

1. **`build-whatslinux.sh`** — cria o ambiente virtual (se necessário), instala as dependências e gera o bundle via PyInstaller (`--onedir`) em `dist/WhatsLinux/`, dentro do próprio projeto.
2. **`install-whatslinux.sh`** — copia o bundle já gerado para `~/.local/opt`, cria o comando de terminal em `~/.local/bin` e o atalho `.desktop` no menu de aplicativos.

Separar as duas etapas permite testar o binário gerado antes de instalá-lo no sistema.

### 1. Gerar o build

```bash
chmod +x scripts/build-whatslinux.sh
./scripts/build-whatslinux.sh
```

O bundle é gerado em `dist/WhatsLinux/`. Antes de seguir para a instalação, teste rodando o executável direto:

```bash
dist/WhatsLinux/WhatsLinux
```

Se a janela abrir e carregar o WhatsApp Web normalmente, o build está validado.

### 2. Instalar no sistema

```bash
chmod +x scripts/install-whatslinux.sh
./scripts/install-whatslinux.sh
```

O script falha com uma mensagem clara caso o build ainda não exista, indicando para rodar `build-whatslinux.sh` primeiro.

### Resultado esperado

- aplicativo instalado em:
  - `$HOME/.local/opt/whatslinux`
- comando no terminal em:
  - `$HOME/.local/bin/whatslinux`
- atalho do menu em:
  - `$HOME/.local/share/applications/whatslinux.desktop`

### Variáveis opcionais

Ambas as variáveis são lidas pelo script de instalação (`install-whatslinux.sh`):

```bash
WHATSAPP_INSTALL_ROOT="$HOME/.local/opt/whatslinux" \
WHATSAPP_BIN_DIR="$HOME/.local/bin" \
./scripts/install-whatslinux.sh
```

### Executando após a instalação

```bash
whatslinux
```

### Refazendo o build

Sempre que o código-fonte for alterado, rode `build-whatslinux.sh` novamente antes de `install-whatslinux.sh`, para que a instalação reflita a versão mais recente do bundle.

## Desinstalação

O script `uninstall-whatslinux.sh` remove exatamente o que `install-whatslinux.sh` instalou: o bundle em `~/.local/opt/whatslinux`, o comando em `~/.local/bin/whatslinux` e o atalho `.desktop`.

```bash
chmod +x scripts/uninstall-whatslinux.sh
./scripts/uninstall-whatslinux.sh
```

Por padrão, os dados de sessão (`~/.local/share/whatsapp-app`) são **preservados** — assim, se você reinstalar depois, não precisa escanear o QR Code de novo. Para remover também a sessão salva:

```bash
./scripts/uninstall-whatslinux.sh --purge
```

Se você instalou em um caminho customizado (via `WHATSAPP_INSTALL_ROOT`/`WHATSAPP_BIN_DIR`), defina as mesmas variáveis antes de desinstalar:

```bash
WHATSAPP_INSTALL_ROOT="/caminho/customizado" \
WHATSAPP_BIN_DIR="/outro/caminho" \
./scripts/uninstall-whatslinux.sh
```

## Onde a sessão fica salva

Os dados de sessão (cookies, localStorage, cache) ficam em:

```
~/.local/share/whatsapp-app
```


## Avisos

- Como não há API pública oficial para clientes de terceiros, o WhatsLinux funciona como um wrapper sobre o WhatsApp Web, e pode parar de funcionar caso a Meta faça mudanças que quebrem esse tipo de acesso.
- Os dados de sessão salvos localmente não possuem criptografia adicional além da que o próprio WhatsApp Web já implementa — o mesmo nível de exposição que existe ao salvar sessão em qualquer navegador comum.

## Licença
MIT