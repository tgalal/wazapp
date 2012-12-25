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

from PySide.QtGui import QApplication

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
		os.system("exec /usr/bin/invoker -w --type=e --single-instance /usr/lib/AccountSetup/bin/waxmppplugin &")
		
	def processVersionTriggers(self):
		'''
			ONLY FOR MASTER VERSIONS, NO TRIGGERS FOR ANY DEV VERSIONS
			Triggers are executed in ascending order of versions.
			Versions added to triggerables, must have a corresponding function in this format:
				version x.y.z corresponds to function name: t_x_y_z
		'''

		def t_0_9_12():
			#clear cache
			if os.path.isdir(WAConstants.CACHE_PATH):
				shutil.rmtree(WAConstants.CACHE_PATH, True)
				self.createDirs()		
		
		
		triggerables = ["0.9.12", Utilities.waversion]
		
		self._d("Processing version triggers")
		for v in triggerables:
			if not self.isPreviousVersion(v):
				self._d("Running triggers for %s"%v)
				try:
					fname = "t_%s" % v.replace(".","_")
					eval("%s()"%fname)
					self.touchVersion(v)
				except NameError:
					self._d("Couldn't find associated function, skipping triggers for %s"%v)
					pass
			else:
				self._d("Nothing to do for %s"%v)

	
	def isPreviousVersion(self, v):

		checkPath = WAConstants.VHISTORY_PATH+"/"+v
		return os.path.isfile(checkPath)
			
	def touchVersion(self, v):
		f = open(WAConstants.VHISTORY_PATH+"/"+v, 'w')
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
			self.regFallback()
			sys.exit()
			return
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
		
		gui = WAUI(account.jid);
		gui.setAccountPushName(account.pushName)
		#url = QUrl('/opt/waxmppplugin/bin/wazapp/UI/main.qml')
		#gui.setSource(url)
		gui.initConnections(store);
	
		self.app.focusChanged.connect(gui.focusChanged)
		gui.engine().quit.connect(QApplication.instance().quit);

		#gui.populatePhoneContacts();
		
		
		print "SHOW FULL SCREEN"
		gui.showFullScreen();
		
		gui.onProcessEventsRequested()
		
				
		self.createDirs()
		
		
		self.processVersionTriggers()

		gui.populateContacts("ALL");
		
		gui.populateConversations();
		
		gui.populatePhoneContacts()
		
		gui.initializationDone = True
		gui.initialized.emit()
		
		
		print "INIT CONNECTION"
		gui.initConnection();
		#splash.finish(gui);
		gui.setMyAccount(account.jid);

		self.gui = gui;
		
		self.gui.whatsapp.eventHandler.setMyAccount(account.jid)
		
