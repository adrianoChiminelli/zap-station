from PyQt6.QtWebEngineCore import QWebEnginePage
from PyQt6.QtGui import QDesktopServices

WHATSAPP_HOST = "web.whatsapp.com"


class LockedPage(QWebEnginePage):
    """Bloqueia qualquer navegação pra fora do domínio do WhatsApp Web.
    Links externos (ex: um link recebido numa conversa) abrem no navegador
    padrão do sistema em vez de navegar dentro do app."""

    def acceptNavigationRequest(self, url, nav_type, is_main_frame):
        if WHATSAPP_HOST in url.host():
            return True

        if is_main_frame:
            QDesktopServices.openUrl(url)
            return False

        return True

    def createWindow(self, window_type):
        # Quando o WhatsApp tenta abrir um link em nova janela/aba,
        # capturamos a URL e mandamos pro navegador padrão em vez de
        # deixar o Qt criar uma nova QWebEngineView
        temp_page = QWebEnginePage(self.profile(), self)
        temp_page.urlChanged.connect(
            lambda url: (QDesktopServices.openUrl(url), temp_page.deleteLater())
        )
        return temp_page
