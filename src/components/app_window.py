import sys
import os
import subprocess
import tempfile
from PyQt6.QtWidgets import QMainWindow
from PyQt6.QtGui import QShortcut, QKeySequence, QIcon
from PyQt6.QtWebEngineWidgets import QWebEngineView
from PyQt6.QtWebEngineCore import QWebEngineProfile
from PyQt6.QtCore import QUrl

from src.navigation.locked_page import LockedPage


def resource_path(relative_path):
    base_path = getattr(
        sys,
        "_MEIPASS",
        os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")),
    )
    return os.path.join(base_path, relative_path)


class WhatsAppWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("WhatsApp Linux")
        icon_path = resource_path("assets/icon.png")
        if os.path.exists(icon_path):
            self.setWindowIcon(QIcon(icon_path))
        self.resize(1000, 700)

        # Diretório onde a sessão será salva
        storage_path = os.path.expanduser("~/.local/share/whatsapp-app")
        os.makedirs(storage_path, exist_ok=True)

        # Perfil NOMEADO, SEM parent (vida controlada manualmente por nós,
        # evita a ordem de destruição incerta que gerava o aviso
        # "Release of profile requested but WebEnginePage still not deleted")
        self.profile = QWebEngineProfile("whatsapp-session")
        self.profile.setPersistentStoragePath(storage_path)
        self.profile.setCachePath(storage_path + "/cache")
        self.profile.setHttpUserAgent(
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/140.0.7339.225 Safari/537.36"
        )
        self.profile.setPersistentCookiesPolicy(
            QWebEngineProfile.PersistentCookiesPolicy.ForcePersistentCookies
        )

        # Page é FILHA do profile, não da janela — garante que o Qt
        # a destrua antes do profile. Usa LockedPage pra travar a
        # navegação sempre dentro do domínio do WhatsApp Web
        self.page_obj = LockedPage(self.profile, self.profile)
        self.browser = QWebEngineView()
        self.browser.setPage(self.page_obj)
        self.browser.setUrl(QUrl("https://web.whatsapp.com"))
        self.setCentralWidget(self.browser)

        # Repassa notificações do WhatsApp Web pro notify-send (nativo do Linux)
        self.profile.setNotificationPresenter(self.handle_notification)

        # F5 dá refresh na página
        self.refresh_shortcut = QShortcut(QKeySequence("F5"), self)
        self.refresh_shortcut.activated.connect(self.browser.reload)

    def handle_notification(self, notification):
        title = notification.title() or "WhatsApp"
        message = notification.message()
 
        icon_path = None
        icon = notification.icon()
        if icon and not icon.isNull():
            tmp = tempfile.NamedTemporaryFile(suffix=".png", delete=False)
            icon.save(tmp.name)
            icon_path = tmp.name
 
        cmd = ["notify-send", "--app-name=WhatsApp"]
        if icon_path:
            cmd += ["-i", icon_path]
        cmd += [title, message]
 
        try:
            subprocess.Popen(cmd)
        except FileNotFoundError:
            # notify-send não instalado no sistema; evita crashar o app
            print("notify-send não encontrado — instale libnotify-bin/libnotify")

    def closeEvent(self, event):
        # Desvincula a page da view e deleta explicitamente ANTES do
        # profile ser destruído, na ordem certa
        self.browser.setPage(None)
        self.page_obj.deleteLater()
        self.page_obj = None
        event.accept()
