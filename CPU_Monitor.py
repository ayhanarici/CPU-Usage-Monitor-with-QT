import os
import sys
import threading
import time
import psutil
from PySide2.QtCore import QObject, QUrl, Signal
from PySide2.QtGui import QGuiApplication
from PySide2.QtQuick import QQuickView

class Connections(QObject):
    valueChanged = Signal(float, arguments=["value"])
def changeData(connector):
    while True:
        #time.sleep(0.1)
        connector.valueChanged.emit(psutil.cpu_percent(1))
def main(args):
    app = QGuiApplication(args)
    guageView = QQuickView(title="CPU Usage Monitor", resizeMode=QQuickView.SizeRootObjectToView)
    connector = Connections()
    guageView.rootContext().setContextProperty("connector", connector)
    qmlFile = os.path.join(os.path.dirname(__file__), "Guage.qml")
    guageView.setSource(QUrl.fromLocalFile(os.path.abspath(qmlFile)))
    threading.Thread(target=changeData, args=(connector,)).start()
    if guageView.status() == QQuickView.Error:
        return -1
    guageView.show()
    ret = app.exec_()
    del guageView
    return ret
if __name__ == "__main__":
    sys.exit(main(sys.argv)) 
