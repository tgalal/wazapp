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
import sys
from PySide import QtCore
from PySide.QtCore import *
from PySide.QtGui import *
from PySide.QtDeclarative import QDeclarativeView,QDeclarativeProperty
from contacts import WAContacts
from status import WAChangeStatus
from waxmpp import WAXMPP
from utilities import Utilities
#from registration import Registration
from contacts import ContactsSyncer
from messagestore import MessageStore
from threading import Timer
from waservice import WAService
import dbus


class WAUI(QDeclarativeView):
	quit = QtCore.Signal()
	
	def __init__(self):
	
	
		
		super(WAUI,self).__init__();
		url = QUrl('/opt/waxmppplugin/bin/wazapp/UI/main.qml')
		
		
		
		self.rootContext().setContextProperty("waversion", Utilities.waversion);
		self.setSource(url);
		self.focus = False
		self.whatsapp = None
		self.idleTimeout = None
		
	
	def preQuit(self):
		print "pre quit"
		del self.whatsapp
		del self.c
		self.quit.emit()
		
	def initConnections(self,store):
		self.store = store;
		#self.setOrientation(QmlApplicationViewer.ScreenOrientationLockPortrait);
		#self.rootObject().sendRegRequest.connect(self.sendRegRequest);
		self.c = WAContacts(self.store);
		self.c.contactsRefreshed.connect(self.populateContacts);
		self.c.contactsRefreshed.connect(self.rootObject().onRefreshSuccess);
		self.c.contactsRefreshFailed.connect(self.rootObject().onRefreshFail);
		self.c.contactsSyncStatusChanged.connect(self.rootObject().onContactsSyncStatusChanged);
		self.rootObject().refreshContacts.connect(self.c.resync)
		
		
		#self.rootObject().quit.connect(self.quit)
		
		self.messageStore = MessageStore(self.store);
		self.messageStore.messagesReady.connect(self.rootObject().messagesReady)
		
		
		
		self.rootObject().deleteConversation.connect(self.messageStore.deleteConversation)
		
		self.dbusService = WAService(self);
		
	
	def focusChanged(self,old,new):
		if new is None:
			self.onUnfocus();
		else:
			self.onFocus();
	
	def onUnfocus(self):
		self.focus = False
		self.rootObject().appFocusChanged(False);
		self.idleTimeout = Timer(5,self.whatsapp.eventHandler.onUnavailable)
		self.idleTimeout.start()
		self.whatsapp.eventHandler.onUnfocus();
		
	
	def onFocus(self):
		self.focus = True
		self.rootObject().appFocusChanged(True);
		if self.idleTimeout is not None:
			self.idleTimeout.cancel()
		
		self.whatsapp.eventHandler.onFocus();
		self.whatsapp.eventHandler.onAvailable();
	
	def closeEvent(self,e):
		print "HIDING"
		e.ignore();
		self.whatsapp.eventHandler.onUnfocus();
		
		
		self.hide();
		
		#self.showFullScreen();
	
	def forceRegistration(self):
		''' '''
		print "NO VALID ACCOUNT"
		exit();
		self.rootObject().forceRegistration(Utilities.getCountryCode());
		
	def sendRegRequest(self,number,cc):
		
		
		self.reg.do_register(number,cc);
		#reg =  ContactsSyncer();
		#reg.start();
		#reg.done.connect(self.blabla);

		#reg.reg_success.connect(self.rootObject().regSuccess);
		#reg.reg_fail.connect(self.rootObject().regFail);
		
		#reg.start();
		
	def blabla(self,tt):
		print tt
		
	def populateContacts(self):
		#syncer = ContactsSyncer(self.store);
		
		
		
		
		#self.c.refreshing.connect(syncer.onRefreshing);
		#syncer.done.connect(c.updateContacts);
		
		print "POPULATE";
		contacts = self.c.getContacts();
		
		#if len(contacts) == 0:
		#	syncer.start();

		self.rootObject().pushContacts(contacts);
		
		#if self.whatsapp is not None:
		#	self.whatsapp.eventHandler.networkDisconnected()
		
	def populateConversations(self):

		self.rootObject().onReloadingConversations()
		
		self.messageStore.loadConversations()
		
		#if self.whatsapp is not None and self.whatsapp.eventHandler.connMonitor.isOnline():
			#self.whatsapp.eventHandler.networkAvailable()

		
		#self.rootContext().setContextProperty("ContactsManager", c);
	
	def login(self):
		self.whatsapp.start();
	
	def showUI(self,jid):
		print "SHOULD SHOW"
		self.showFullScreen();
		self.rootObject().openConversation(jid)
		
	def getActiveConversation(self):
		
		if not self.focus:
			return 0
		
		print "GETTING ACTIVE CONV"
		
		activeConvJId = QDeclarativeProperty(self.rootObject(),"activeConvJId").read();
		
		#self.rootContext().contextProperty("activeConvJId");
		print "DONE"
		print activeConvJId
		
		return activeConvJId
		
	
	def initConnection(self):
		
		password = self.store.account.password;
		usePushName = self.store.account.pushName
		resource = "Symbian-2.6.61-443";
		chatUserID = self.store.account.username;
		domain ='s.whatsapp.net'
		
		
		
		whatsapp = WAXMPP(domain,resource,chatUserID,usePushName,password);
		
		WAXMPP.message_store = self.messageStore;
	
		whatsapp.setReceiptAckCapable(True);
		whatsapp.setContactsManager(self.c);
		
		whatsapp.eventHandler.typing.connect(self.rootObject().onTyping)
		whatsapp.eventHandler.paused.connect(self.rootObject().onPaused)
		whatsapp.eventHandler.showUI.connect(self.showUI)
		whatsapp.eventHandler.messageSent.connect(self.rootObject().onMessageSent);
		whatsapp.eventHandler.messageDelivered.connect(self.rootObject().onMessageDelivered);
		whatsapp.eventHandler.connecting.connect(self.rootObject().onConnecting);
		whatsapp.eventHandler.loginFailed.connect(self.rootObject().onLoginFailed);
		whatsapp.eventHandler.connected.connect(self.rootObject().onConnected);
		whatsapp.eventHandler.sleeping.connect(self.rootObject().onSleeping);
		whatsapp.eventHandler.disconnected.connect(self.rootObject().onDisconnected);
		whatsapp.eventHandler.available.connect(self.rootObject().onAvailable);
		whatsapp.eventHandler.unavailable.connect(self.rootObject().onUnavailable);
		whatsapp.eventHandler.lastSeenUpdated.connect(self.rootObject().onLastSeenUpdated);
		whatsapp.eventHandler.updateAvailable.connect(self.rootObject().onUpdateAvailable)
		whatsapp.eventHandler.doQuit.connect(self.preQuit);
		
		whatsapp.eventHandler.notifier.ui = self
		
		
		#whatsapp.eventHandler.new_message.connect(self.rootObject().newMessage)
		self.rootObject().sendMessage.connect(whatsapp.eventHandler.send_message)
		self.rootObject().sendTyping.connect(whatsapp.eventHandler.sendTyping)
		self.rootObject().sendPaused.connect(whatsapp.eventHandler.sendPaused);
		self.rootObject().conversationActive.connect(whatsapp.eventHandler.getLastOnline);
		self.rootObject().conversationActive.connect(whatsapp.eventHandler.conversationOpened);
		self.rootObject().quit.connect(whatsapp.eventHandler.quit)
		
		#self.reg = Registration();
		self.whatsapp = whatsapp;
		
		#change whatsapp status
		self.cs = WAChangeStatus(self.store);
		self.rootObject().changeStatus.connect(self.cs.sync)
		
		#print "el acks:"
		#print whatsapp.supports_receipt_acks
		
		#self.whatsapp.start();
		
		
		

		

