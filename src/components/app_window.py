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


class ZapWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("ZapStation")
        icon_path = resource_path("assets/icon.png")
        if os.path.exists(icon_path):
            self.setWindowIcon(QIcon(icon_path))
        self.resize(1000, 700)

        # Directory where the session will be stored
        storage_path = os.path.expanduser("~/.local/share/zap-station")
        os.makedirs(storage_path, exist_ok=True)

        # Named profile, no parent (lifetime managed manually to avoid the
        # uncertain destruction order that triggered the warning
        # "Release of profile requested but WebEnginePage still not deleted")
        self.profile = QWebEngineProfile("zapstation-session")
        self.profile.setPersistentStoragePath(storage_path)
        self.profile.setCachePath(storage_path + "/cache")
        self.profile.setHttpUserAgent(
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/140.0.7339.225 Safari/537.36"
        )
        self.profile.setPersistentCookiesPolicy(
            QWebEngineProfile.PersistentCookiesPolicy.ForcePersistentCookies
        )

        # The page is a child of the profile, not the window — ensures Qt
        # destroys it before the profile. Uses LockedPage to keep navigation
        # always inside the WhatsApp Web domain.
        self.page_obj = LockedPage(self.profile, self.profile)
        self.browser = QWebEngineView()
        self.browser.setPage(self.page_obj)
        self.browser.setUrl(QUrl("https://web.whatsapp.com"))
        self.setCentralWidget(self.browser)

        # Forward WhatsApp Web notifications to notify-send (native on Linux)
        self.profile.setNotificationPresenter(self.handle_notification)

        # F5 refreshes the page
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
            # notify-send is not installed on the system; avoids crashing the app
            print("notify-send not found — install libnotify-bin/libnotify")

    def closeEvent(self, event):
        # Detach the page from the view and delete it explicitly before the
        # profile is destroyed, in the correct order.
        self.browser.setPage(None)
        self.page_obj.deleteLater()
        self.page_obj = None
        event.accept()
