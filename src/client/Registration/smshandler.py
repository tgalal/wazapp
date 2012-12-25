#from QtMobility.SystemInfo import QSystemDeviceInfo,QSystemNetworkInfo
from QtMobility.Messaging import QMessageManager, QMessage, QMessageFilter
from PySide.QtCore import QObject
from PySide import QtCore
from wadebug import WADebug
class SMSHandler(QObject):
    
    gotCode = QtCore.Signal(str)
    
    def __init__(self):
        WADebug.attach(self)

        super(SMSHandler, self).__init__()
        
    def messageAdded(self, messageId, matchingFilterIds):
        self._d("GOT A MESSAGE!")
        self._d(matchingFilterIds)
        
        print self.manager.message(messageId).textContent()
    
    
    def initManager(self):
        self.manager = QMessageManager();
        self.manager.messageAdded.connect(self.messageAdded)
        
        
        self.filters = [self.manager.registerNotificationFilter(
                    QMessageFilter.byType(QMessage.Sms) & QMessageFilter.byStandardFolder(QMessage.InboxFolder)
                    )]
        
        self._d(self.filters)

    def stopListener(self):
        pass
    
    def run(self):
        pass