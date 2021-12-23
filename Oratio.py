import sys
import os
import pathlib
from PySide6.QtCore import QAbstractNativeEventFilter, QCoreApplication, Qt, QUrl
from PySide6.QtGui import QFontDatabase, QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine
from http.server import SimpleHTTPRequestHandler
from socketserver import TCPServer
import threading
import pywin32_system32
import pywintypes
import ctypes
import ctypes.wintypes as cwin
from win32con import WM_HOTKEY, MOD_CONTROL, SW_SHOWMINIMIZED, SW_MINIMIZE, SW_NORMAL, SW_SHOW
user32 = ctypes.windll.user32
import win32gui

import qml_rc

class MyNativeEventFilter(QAbstractNativeEventFilter):
    def __init__(self, window):
        self.hwnd = window
        super().__init__()

    def nativeEventFilter(self, eventType, message):
        msg = cwin.MSG.from_address(message.__int__())
        if eventType == 'windows_generic_MSG':
            if msg.message == WM_HOTKEY:
                # HotKey Pressed
                wp = win32gui.GetWindowPlacement(self.hwnd)
                ismini = wp[1] == SW_SHOWMINIMIZED
                isfocus = win32gui.GetForegroundWindow() == self.hwnd
                if ismini:
                    nwp = (wp[0],) + (SW_NORMAL,) + wp[2:]
                    win32gui.SetWindowPlacement(self.hwnd, nwp)
                else:
                    if isfocus:
                        nwp = (wp[0],) + (SW_MINIMIZE,) + wp[2:]
                        win32gui.SetWindowPlacement(self.hwnd, nwp)
                    else:
                        win32gui.ShowWindow(self.hwnd, SW_SHOW)
                        win32gui.SetForegroundWindow(self.hwnd)
                return True
        return False
        
if __name__ == "__main__":
    sys.stdout = open('out.log', 'w')
    sys.stderr = sys.stdout

    QCoreApplication.setAttribute(Qt.AA_EnableHighDpiScaling)
    QCoreApplication.setAttribute(Qt.AA_UseHighDpiPixmaps)

    class handler(SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory='displayserver', **kwargs)

    displayserver = TCPServer(('localhost',7777), handler)
    ds = threading.Thread(target=displayserver.serve_forever)
    ds.daemon = True
    ds.start()

    app = QGuiApplication()
    app.setWindowIcon(QIcon(':/assets/icon.ico'))
    app.setApplicationName("Oratio")
    app.setOrganizationName("DeafChips")
    app.setOrganizationDomain("com.DeafChips")

    QFontDatabase.addApplicationFont(':/assets/MaterialIcons-Regular.ttf')
    engine = QQmlApplicationEngine()
    
    engine.quit.connect(app.quit)
    engine.rootContext().setContextProperty("appDirPath", pathlib.PurePath(os.getcwd()).as_uri())
    engine.load(QUrl.fromLocalFile(":/main.qml"))

    if not engine.rootObjects():
        print('error')
        sys.exit(-1)


    window = app.topLevelWindows()[0].winId()
    # Set Control+O as the hotkey
    user32.RegisterHotKey(None, 1, MOD_CONTROL, 0x4F)
    nef = MyNativeEventFilter(window)
    app.installNativeEventFilter(nef)
    app.exec()
    user32.UnregisterHotKey(None, 1)
    sys.exit(0)
