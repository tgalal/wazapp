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
import sys,os, shutil
from PySide.QtCore import *
from PySide.QtGui import *
from PySide.QtDeclarative import QDeclarativeView

from ui import WAUI;
from litestore import LiteStore as DataStore
from accountsmanager import AccountsManager;
import dbus
from utilities import Utilities
from wadebug import WADebug
from constants import WAConstants

class WAManager():

	def __init__(self,app):
		self.app = app;
		WADebug.attach(self)
		
		self._d("wazapp %s"%Utilities.waversion)
		
		
		try:
			bus = dbus.SessionBus()
			remote_object = bus.get_object("com.tgalal.meego.Wazapp.WAService", "/")
			self._d("Found a running instance. I will show it instead of relaunching.")
			remote_object.show();
			sys.exit();
		except dbus.exceptions.DBusException as e:
			self._d("No running instance found. Proceeding with relaunch")
			self.proceed()
			
		
		
	def regFallback(self):		
		os.system("exec /usr/bin/invoker -w --type=d --single-instance /usr/lib/AccountSetup/bin/waxmppplugin &")
		sys.exit()
		
	def quit(self):
		self._d("Quitting")
		self.app.exit();
		
	def isFirstRun(self):
		checkPath = WAConstants.VHISTORY_PATH+"/"+Utilities.waversion
		
		return not os.path.isfile(checkPath)
			
	def touchVersion(self):
		f = open(WAConstants.VHISTORY_PATH+"/"+Utilities.waversion, 'w')
		f.close()

	def createDirs(self):
		
		dirs = [
			WAConstants.STORE_PATH,
			WAConstants.VHISTORY_PATH,
			WAConstants.APP_PATH,
			WAConstants.MEDIA_PATH,
			WAConstants.AUDIO_PATH,
			WAConstants.IMAGE_PATH,
			WAConstants.VIDEO_PATH,
			WAConstants.VCARD_PATH,

			WAConstants.CACHE_PATH,
			WAConstants.CACHE_PROFILE,
			WAConstants.CACHE_CONTACTS,
			WAConstants.CACHE_CONV,
			
			WAConstants.THUMBS_PATH
			]
		
		for d in dirs:
			self.createDir(d)
		
		
	def createDir(self, d):
		if not os.path.exists(d):
			os.makedirs(d)
		
	
	def proceed(self):
		account = AccountsManager.getCurrentAccount();
		self._d(account)
	
	
		if(account is None):
			#self.d("Forced reg");
			return self.regFallback()
			#gui.forceRegistration();
			#self.app.exit();
			
		imsi = Utilities.getImsi();
		store = DataStore(imsi);
		
		if store.status == False:
			#or exit
			store.reset();
			
		
		store.prepareGroupConversations();
		store.prepareMedia()
		store.updateDatabase()
		store.initModels()
		
		gui = WAUI(account.jid, account.pushName);
		#url = QUrl('/opt/waxmppplugin/bin/wazapp/UI/main.qml')
		#gui.setSource(url)
		gui.initConnections(store);
	
		self.app.focusChanged.connect(gui.focusChanged)
		gui.quit.connect(self.quit);

		#gui.populatePhoneContacts();
		
		
		print "SHOW FULL SCREEN"
		gui.showFullScreen();
		
		gui.onProcessEventsRequested()
		
		firstRun = self.isFirstRun()
		
		if firstRun:
			if os.path.isdir(WAConstants.CACHE_PATH):
				shutil.rmtree(WAConstants.CACHE_PATH, True)
				
		self.createDirs()

		gui.populateContacts("ALL");
		
		gui.populateConversations();
		
		gui.populatePhoneContacts()
		
		gui.initializationDone = True
		gui.initialized.emit()
		
		if firstRun:
			self.touchVersion()
		
		print "INIT CONNECTION"
		gui.initConnection();
		#splash.finish(gui);
		gui.setMyAccount(account.jid);

		self.gui = gui;
		
		self.gui.whatsapp.eventHandler.setMyAccount(account.jid)
		
