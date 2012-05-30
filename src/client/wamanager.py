'''
Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>

This file is part of Wazapp, an IM application for Meego Harmattan platform that
allows communication with Whatsapp users

Wazapp is free software: you can redistribute it and/or modify it under the 
terms of the GNU General Public License as published by the Free Software 
Foundation, either version 2 of the License, or (at your option) any later 
version.

Wazapp is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with 
Wazapp. If not, see http://www.gnu.org/licenses/.
'''
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
		
		gui.populateConversations();
		
		gui.showFullScreen();
		
		
		
		
		

		gui.initConnection();
		#splash.finish(gui);
		
		self.gui = gui;
		
		self.gui.whatsapp.eventHandler.initialConnCheck()
		
