import sys,os
from PySide.QtCore import *
from PySide.QtGui import *
from PySide.QtDeclarative import QDeclarativeView
from utilities import Utilities;
from ui import WAUI;
from litestore import LiteStore as DataStore
from accountsmanager import AccountsManager;
import dbus
from utilities import Utilities

class WAManager():

	def __init__(self,app):
		self.app = app;
		print "wazapp %s"%Utilities.waversion
		
		
		try:
			bus = dbus.SessionBus()
			remote_object = bus.get_object("com.tgalal.meego.Wazapp.WAService", "/")
			print "FOUND OBJ"
			remote_object.show();
			sys.exit();
		except dbus.exceptions.DBusException as e:
			print "CAUGHT EXCEPT"
			self.proceed()
			
		
		
	def regFallback(self):		
		os.system("exec /usr/bin/invoker -w --type=d --single-instance /usr/lib/AccountSetup/bin/waxmppplugin &")
		sys.exit()
		
	def quit(self):
		print "QUITINGGGGGG"
		self.app.exit();
	def proceed(self):
		
		
		
		
		
		#url = QUrl('/opt/waxmppplugin/bin/wazapp/UI/WASplash.qml')
		#gui.setSource(url)
		
		#check db_state
	
	
		#gui.initConnection();
		#pixmap = QPixmap("/opt/waxmppplugin/bin/wazapp/UI/pics/wasplash.png");
     		#splash = QSplashScreen(pixmap);
     		#splash.show();
     		
		account = AccountsManager.getCurrentAccount();
		
		
		print account;
		
		
	
	
		if(account is None):
			Utilities.debug("Forced reg");
			return self.regFallback()
			#gui.forceRegistration();
			#self.app.exit();
			
		
		
			
			
		imsi = Utilities.getImsi();
		store = DataStore(imsi);
		
		if store.status == False:
			#or exit
			store.reset();
		
		gui = WAUI();
		#url = QUrl('/opt/waxmppplugin/bin/wazapp/UI/main.qml')
		#gui.setSource(url)
		gui.initConnections(store);
	
		self.app.focusChanged.connect(gui.focusChanged)
		gui.quit.connect(self.quit);

		gui.populateContacts();
			
		
		
		gui.showFullScreen();
		
		
		
		
		

		gui.initConnection();
		#splash.finish(gui);
		
		self.gui = gui;
		
		self.gui.whatsapp.eventHandler.initialConnCheck()
		
