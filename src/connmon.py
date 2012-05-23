from PySide.QtCore import *
from PySide.QtGui import *
from PySide import QtCore
from PySide.QtNetwork import QNetworkSession, QNetworkConfigurationManager,QNetworkConfiguration, QNetworkAccessManager 
import sys
import PySide

class ConnMonitor(QObject):

	connectionSwitched = QtCore.Signal();
	connected = QtCore.Signal()
	disconnected = QtCore.Signal()
	
	def __init__(self):
		super(ConnMonitor,self).__init__();
		
		self.session = None
		self.online = False
		self.manager = QNetworkConfigurationManager()
		self.config = self.manager.defaultConfiguration() if self.manager.isOnline() else None
		
		self.manager.onlineStateChanged.connect(self.onOnlineStateChanged)
		self.manager.configurationChanged.connect(self.onConfigurationChanged)
		
		self.connected.connect(self.onOnline)
		self.disconnected.connect(self.onOffline)
		self.session =  QNetworkSession(self.manager.defaultConfiguration());
		self.session.stateChanged.connect(self.sessionStateChanged)
		self.session.closed.connect(self.disconnected);
		#self.session.opened.connect(self.connected);
		#self.createSession();
		#self.session.waitForOpened(-1)
	
	
	def sessionStateChanged(self,state):
		print "state changed "+str(state);
	
	def createSession(self):
		
		#self.session.setSessionProperty("ConnectInBackground", True);
		self.session.open();
	
	def isOnline(self):
		return self.manager.isOnline()
	
	def onConfigurationChanged(self,config):
		if self.manager.isOnline() and config.state() == PySide.QtNetwork.QNetworkConfiguration.StateFlag.Active:
			if self.config is None:
				self.config = config
			else:
				self.connected.emit()
				self.createSession();
		
	def onOnlineStateChanged(self,state):
		self.online = state
		if state:
			self.connected.emit()
		else:
			self.config = None
			self.disconnected.emit()
	
	def onOnline(self):
		print "ONLINE"
		#self.session = QNetworkSession(self.config)
	
	def onOffline(self):
		print "OFFLINE";
	

		
		

if __name__=="__main__":
	app = QApplication(sys.argv)
	cm = ConnMon()
	
	
	sys.exit(app.exec_())
