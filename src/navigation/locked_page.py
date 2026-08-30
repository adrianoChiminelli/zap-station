from PyQt6.QtWebEngineCore import QWebEnginePage
from PyQt6.QtGui import QDesktopServices

ZAP_STATION_HOST = "web.whatsapp.com"


class LockedPage(QWebEnginePage):
    """Blocks any navigation outside the WhatsApp Web domain.
    External links (for example, links received in a chat) open in the
    system's default browser instead of navigating inside the app."""

    def acceptNavigationRequest(self, url, nav_type, is_main_frame):
        if ZAP_STATION_HOST in url.host():
            return True

        if is_main_frame:
            QDesktopServices.openUrl(url)
            return False

        return True

    def createWindow(self, window_type):
        # When WhatsApp tries to open a link in a new window/tab, we capture the
        # URL and send it to the default browser instead of letting Qt create a
        # new QWebEngineView.
        temp_page = QWebEnginePage(self.profile(), self)
        temp_page.urlChanged.connect(
            lambda url: (QDesktopServices.openUrl(url), temp_page.deleteLater())
        )
        return temp_page
