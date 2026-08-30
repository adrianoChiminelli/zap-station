import sys
from PyQt6.QtWidgets import QApplication
from src.components.app_window import WhatsAppWindow

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = WhatsAppWindow()
    window.show()
    sys.exit(app.exec())