# -*- coding: utf-8 -*-
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
import time, threading, select, os, urllib, hashlib;
from utilities import Utilities, S40MD5Digest
from protocoltreenode import BinTreeNodeWriter,BinTreeNodeReader,ProtocolTreeNode
from connengine import MySocketConnection
from walogin import WALogin;
#from funstore import FunStore
from waeventbase import WAEventBase
#from contacts import WAContacts;
from messagestore import Key;
from notifier import Notifier
from connmon import ConnMonitor
import sys
from constants import WAConstants
from waexceptions import *
from PySide import QtCore
from PySide.QtCore import QThread, QTimer, Qt
from PySide.QtGui import QApplication, QImage, QPixmap, QPainter, QTransform
from waupdater import WAUpdater
from wamediahandler import WAMediaHandler, WAVCardHandler
from wadebug import WADebug
import thread
from watime import WATime
from time import sleep
import base64
import shutil, datetime
import Image
from PIL.ExifTags import TAGS
import subprocess

import dbus
import dbus.service

from InterfaceHandlers.DBus.DBusInterfaceHandler import DBusInterfaceHandler




class WAEventHandler(WAEventBase):
	
	connecting = QtCore.Signal()
	connected = QtCore.Signal();
	sleeping = QtCore.Signal();
	disconnected = QtCore.Signal();
	loginFailed = QtCore.Signal()
	######################################
	new_message = QtCore.Signal(dict);
	typing = QtCore.Signal(str);
	paused = QtCore.Signal(str);
	available = QtCore.Signal(str);
	unavailable = QtCore.Signal(str);
	showUI = QtCore.Signal(str);
	messageSent = QtCore.Signal(int,str);
	messageDelivered = QtCore.Signal(int,str);
	lastSeenUpdated = QtCore.Signal(str,int);
	updateAvailable = QtCore.Signal(dict);
	
	##############Media#####################
	mediaTransferSuccess = QtCore.Signal(int,str)
	mediaTransferError = QtCore.Signal(int)
	mediaTransferProgressUpdated = QtCore.Signal(int,int)
	#########################################
	
	sendTyping = QtCore.Signal(str);
	sendPaused = QtCore.Signal(str);
	getLastOnline = QtCore.Signal(str);
	getGroupInfo = QtCore.Signal(str);
	createGroupChat = QtCore.Signal(str);
	groupCreated = QtCore.Signal(str);
	groupInfoUpdated = QtCore.Signal(str,str)
	addParticipants = QtCore.Signal(str, str);
	addedParticipants = QtCore.Signal();
	removeParticipants = QtCore.Signal(str, str);
	removedParticipants = QtCore.Signal();
	getGroupParticipants = QtCore.Signal(str);
	groupParticipants = QtCore.Signal(str);
	endGroupChat = QtCore.Signal(str);
	groupEnded = QtCore.Signal();
	setGroupSubject = QtCore.Signal(str, str);
	groupSubjectChanged = QtCore.Signal();
	getPictureIds = QtCore.Signal(str);
	getPicture = QtCore.Signal(str, str);
	profilePictureUpdated = QtCore.Signal(str);
	setPicture = QtCore.Signal(str, str);
	setPushName = QtCore.Signal(str, str);
	imageRotated = QtCore.Signal(str);
	getPicturesFinished = QtCore.Signal();
	changeStatus = QtCore.Signal(str);
	statusChanged = QtCore.Signal();
	doQuit = QtCore.Signal();


	def __init__(self,conn):
		
		WADebug.attach(self);
		self.conn = conn;
		super(WAEventHandler,self).__init__();
		
		self.notifier = Notifier();
		self.connMonitor = ConnMonitor();
		
		self.connMonitor.connected.connect(self.networkAvailable);
		self.connMonitor.disconnected.connect(self.networkDisconnected);
		
		self.account = "";

		self.blockedContacts = "";

		self.resizeImages = False;

		self.interfaceHandler = DBusInterfaceHandler()

		
		#self.connMonitor.sleeping.connect(self.networkUnavailable);
		#self.connMonitor.checked.connect(self.checkConnection);
		
		self.listJids = [];

		self.mediaHandlers = []
		self.sendTyping.connect(lambda *args: self.interfaceHandler.call("typing_send", args));
		self.sendPaused.connect(lambda *args: self.interfaceHandler.call("typing_paused",args));
		self.getLastOnline.connect(lambda *args: self.interfaceHandler.call("presence_request", args));
		self.getGroupInfo.connect(lambda *args: self.interfaceHandler.call("group_getInfo", args));
		self.createGroupChat.connect(lambda *args: self.interfaceHandler.call("group_create", args));
		self.addParticipants.connect(lambda *args: self.interfaceHandler.call("group_addParticipants", args));
		self.removeParticipants.connect(lambda *args: self.interfaceHandler.call("group_remoteParticipants", args));
		self.getGroupParticipants.connect(lambda *args: self.interfaceHandler.call("group_getParticipants", args));
		self.endGroupChat.connect(lambda *args: self.interfaceHandler.call("group_end", args));
		self.setGroupSubject.connect(lambda *args: self.interfaceHandler.call("group_setSubject", args));
		self.getPictureIds.connect(lambda *args: self.interfaceHandler.call("picture_getIds", args));
		self.getPicture.connect(lambda *args: self.interfaceHandler.call("picture_get", args));
		self.setPicture.connect(lambda *args: self.interfaceHandler.call("sendSetPicture", args));
		self.changeStatus.connect(lambda *args: self.interfaceHandler.call("status_update", args));

		#self.connected.connect(self.resendUnsent);



		self.state = 0
		
		#self.pingTimer = QTimer();
		#self.pingTimer.timeout.connect(self.sendPing)
		#self.pingTimer.start(180000);
		
		#self.connMonitor.start();

		

	'''def sendTyping(self, jid):
		pass

	def sendPaused(self, jid):
		pass

	def getLastOnline(self, jid):
		pass

	def getGroupInfo(self, jid):
		pass

	def createGroupChat(self, jid):
		pass

	def addParticipants(self, jid, unknown):
		pass

	def removeParticipants(self, jid, unknown):
		pass

	def getGroupParticipants(self, jid):
		pass

	def endGroupChat(self, jid):
		pass

	def setGroupSubject(self, jid, subject): #@@TODO check order
		pass

	def getPictureIds(
	'''


		#### new backend stuff ###

		
	############### NEW BACKEND STUFF



	def authenticate(self, username, password):
		self.state = 1
		bus = dbus.Bus()
		authMethods = bus.get_object('com.yowsup.methods', '/com/yowsup/methods')
		auth = authMethods.get_dbus_method('auth', 'com.yowsup.methods')

		authSignals = bus.get_object('com.yowsup.signals', '/com/yowsup/signals')
		authSignals.connect_to_signal("auth_success", self.authSuccess)
		authSignals.connect_to_signal("auth_fail", self.authFail)
		auth(username, password, reply_handler = self.authComplete, error_handler = self.authConnFail)
		print "CALLED AUTH KHLAS"

	def authSuccess(self, username, connId):
		self.state = 2
		self.connected.emit()
		print "AUTH SUCCESS"
		print connId

		self.interfaceHandler.initSignals(connId)
		self.interfaceHandler.initMethods(connId)

		self.registerInterfaceSignals()

		self.resendUnsent()

	def authComplete(self, connId):
		pass

	def authConnFail(self,err):
		self.state = 0
		print "Auth connection failed"
		print err


	def authFail(self, username, err):
		self.state = 0
		print "AUTH FAILED FOR %s!!" % username


	def registerInterfaceSignals(self):
		self.interfaceHandler.connectToSignal("message_received", self.messageReceived)
		self.interfaceHandler.connectToSignal("group_messageReceived", self.groupMessageReceived)
		#self.registerSignal("status_dirty", self.statusDirtyReceived) #ignored by whatsapp?
		self.interfaceHandler.connectToSignal("receipt_messageSent", self.onMessageSent)
		self.interfaceHandler.connectToSignal("receipt_messageDelivered", self.onMessageDelivered)
		self.interfaceHandler.connectToSignal("receipt_visible", self.onMessageDelivered) #@@TODO check
		self.interfaceHandler.connectToSignal("presence_available", self.presence_available_received)
		self.interfaceHandler.connectToSignal("presence_unavailable", self.presence_unavailable_received)
		self.interfaceHandler.connectToSignal("presence_updated", self.onLastSeen)
		
		self.interfaceHandler.connectToSignal("disconnected", self.onDisconnected)



	################################################################
	
	def quit(self):
		
		#self.connMonitor.exit()
		#self.conn.disconnect()
		
		'''del self.connMonitor
		del self.conn.inn
		del self.conn.out
		del self.conn.login
		del self.conn.stanzaReader'''
		#del self.conn

		self.interfaceHandler.call("disconnect")
		self.doQuit.emit();
		
	
	def initialConnCheck(self):
		if self.connMonitor.isOnline():
			self.connMonitor.connected.emit()
		else:
			self.connMonitor.createSession();
	
	def setMyAccount(self, account):
		self.account = account
	
	def onFocus(self):
		'''self.notifier.disable()'''
		
	def onUnfocus(self):
		'''self.notifier.enable();'''
	
	def checkConnection(self):
		try:
			if self.conn.state == 0:
				raise Exception("Not connected");
			elif self.conn.state == 2:
				self.conn.sendPing();
		except:
			self._d("Connection crashed, reason: %s"%sys.exc_info()[1])
			self.networkDisconnected()
			self.networkAvailable();
			
		
	
	def onLoginFailed(self):
		self.loginFailed.emit()
	
	def onLastSeen(self,jid,seconds):
		self._d("GOT LAST SEEN ON FROM %s"%(jid))
		
		if seconds is not None:
			self.lastSeenUpdated.emit(jid,int(seconds));


	def resendUnsent(self):
		'''
			Resends all unsent messages, should invoke on connect
		'''


		messages = WAXMPP.message_store.getUnsent();
		self._d("Resending %i old messages"%(len(messages)))
		for m in messages:
			media = m.getMedia()
			if media is not None:
				if media.transfer_status == 2:
					if media.mediatype_id == 6:
						self.sendMessageWithVCard(m)
					elif media.mediatype_id == 5:
						self.sendMessageWithLocation(m)
					else:
						media.transfer_status == 1
						media.save()
			else:
				try:
					jid = m.getConversation().getJid()
					msgId = self.interfaceHandler.call("message_send", (jid, m.content.encode('utf-8')))
					m.key = Key(jid, False, msgId).toString() #@@TODO check offline send time correctness
					m.save()
				except UnicodeDecodeError:
					self._d("skipped sending an old message because UnicodeDecodeError")

		self._d("Resending old messages done")
	
	def fetchVCard(self,messageId):
		mediaMessage = WAXMPP.message_store.store.Message.create()
		message = mediaMessage.findFirst({"media_id":mediaId})
		jid = message.getConversation().getJid()
		media = message.getMedia()
		
		mediaHandler = WAVCardHandler(jid,message.id,contactData)
		
		mediaHandler.success.connect(self._mediaTransferSuccess)
		mediaHandler.error.connect(self._mediaTransferError)
		mediaHandler.progressUpdated.connect(self.mediaTransferProgressUpdated)
		
		mediaHandler.pull();
		
		self.mediaHandlers.append(mediaHandler);
	
	def fetchMedia(self,mediaId):
		
		mediaMessage = WAXMPP.message_store.store.Message.create()
		message = mediaMessage.findFirst({"media_id":mediaId})
		jid = message.getConversation().getJid()
		media = message.getMedia()
		
		mediaHandler = WAMediaHandler(jid,message.id,media.remote_url,media.mediatype_id,media.id,self.account)
		
		mediaHandler.success.connect(self._mediaTransferSuccess)
		mediaHandler.error.connect(self._mediaTransferError)
		mediaHandler.progressUpdated.connect(self.mediaTransferProgressUpdated)
		
		mediaHandler.pull();
		
		self.mediaHandlers.append(mediaHandler);
		
	def fetchGroupMedia(self,mediaId):
		
		mediaMessage = WAXMPP.message_store.store.Groupmessage.create()
		message = mediaMessage.findFirst({"media_id":mediaId})
		jid = message.getConversation().getJid()
		media = message.getMedia()
		
		mediaHandler = WAMediaHandler(jid,message.id,media.remote_url,media.mediatype_id,media.id,self.account)
		
		mediaHandler.success.connect(self._mediaTransferSuccess)
		mediaHandler.error.connect(self._mediaTransferError)
		mediaHandler.progressUpdated.connect(self.mediaTransferProgressUpdated)
		
		mediaHandler.pull();
		
		self.mediaHandlers.append(mediaHandler);
	

	def uploadMedia(self,mediaId):
		mediaMessage = WAXMPP.message_store.store.Message.create()
		message = mediaMessage.findFirst({"media_id":mediaId})
		jid = message.getConversation().getJid()
		media = message.getMedia()
		
		mediaHandler = WAMediaHandler(jid,message.id,media.local_path,media.mediatype_id,media.id,self.account,self.resizeImages)
		
		mediaHandler.success.connect(self._mediaTransferSuccess)
		mediaHandler.error.connect(self._mediaTransferError)
		mediaHandler.progressUpdated.connect(self.mediaTransferProgressUpdated)
		
		mediaHandler.push();
		
		self.mediaHandlers.append(mediaHandler);
		
	def uploadGroupMedia(self,mediaId):
		mediaMessage = WAXMPP.message_store.store.Groupmessage.create()
		message = mediaMessage.findFirst({"media_id":mediaId})
		jid = message.getConversation().getJid()
		media = message.getMedia()
		
		mediaHandler = WAMediaHandler(jid,message.id,media.local_path,media.mediatype_id,media.id,self.account,self.resizeImages)
		
		mediaHandler.success.connect(self._mediaTransferSuccess)
		mediaHandler.error.connect(self._mediaTransferError)
		mediaHandler.progressUpdated.connect(self.mediaTransferProgressUpdated)
		
		mediaHandler.push();
		
		self.mediaHandlers.append(mediaHandler);
	
	
	def _mediaTransferSuccess(self, jid, messageId, data, action, mediaId):
		try:
			jid.index('-')
			message = WAXMPP.message_store.store.Groupmessage.create()
		
		except ValueError:
			message = WAXMPP.message_store.store.Message.create()
		
		message = message.findFirst({'id':messageId});
		
		if(message.id):
			print "MULTIMEDIA HANDLING DONE! ACTION: " + action
			media = message.getMedia()
			if (action=="download"):
				#media.preview = data if media.mediatype_id == WAConstants.MEDIA_TYPE_IMAGE else None
				media.local_path = data
			else:
				media.remote_url = data
			media.transfer_status = 2
			media.save()
			self._d(media.getModelData())
			self.mediaTransferSuccess.emit(mediaId,media.local_path)
			if (action=="upload"):
				self.sendMediaMessage(jid,messageId,data)

		
	def _mediaTransferError(self, jid, messageId, mediaId):
		print "MULTIMEDIA HANDLING ERROR!!!"
		try:
			jid.index('-')
			message = WAXMPP.message_store.store.Groupmessage.create()
		
		except ValueError:
			message = WAXMPP.message_store.store.Message.create()
		
		message = message.findFirst({'id':messageId});
		
		if(message.id):
			media = message.getMedia()
			media.transfer_status = 1
			media.save()
			self.mediaTransferError.emit(mediaId)
	
	
	def onDirty(self,categories):
		self._d(categories)
		#ignored by whatsapp?
	
	def onAccountChanged(self,account_kind,expire):
		#nothing to do here
		return;
		
	def onRelayRequest(self,pin,timeoutSeconds,idx):
		#self.wtf("RELAY REQUEST");
		return
	
	def sendPing(self):
		self._d("Pinging")
		if self.connMonitor.isOnline() and self.conn.state == 2:
			self.conn.sendPing();
		else:
			self.connMonitor.createSession();
	
	def onPing(self,idx):
		self._d("Sending PONG")
		self.conn.sendPong(idx)
		
	
	def wtf(self,what):
		self._d("%s, WTF SHOULD I DO NOW???"%(what))
	
		
	
	def networkAvailable(self):
		if self.state != 0:
			return
		self._d("NET AVAILABLE")
		self.updater = WAUpdater()
		self.updater.updateAvailable.connect(self.updateAvailable)
		
		
		self.connecting.emit();
		
		#thread.start_new_thread(self.conn.changeState, (2,))
		
		self.authenticate("4915225256022", "6a65a936b8caa360ac1d8f983087ebd2")
		
		#self.updater.run()
		
		#self.conn.disconnect()
		
		
	def onDisconnected(self, reason):
		self.state = 0
		self.disconnected.emit()

		if reason == "":
			return
		elif reason == "closed":
			if self.connMonitor.isOnline():
				self.networkAvailable()
		
	def networkDisconnected(self):
		self.sleeping.emit();
		self.state = 0
		#thread.start_new_thread(self.conn.changeState, (0,))
		#self.conn.disconnect();
		self._d("NET SLEEPING")
		
	def networkUnavailable(self):
		self.disconnected.emit();
		self.interfaceHandler.call("disconnect")
		self._d("NET UNAVAILABLE");
		
		
	def onUnavailable(self):
		self._d("SEND UNAVAILABLE")
		self.interfaceHandler.call("presence_sendUnavailable")
	
	
	def conversationOpened(self,jid):
		self.notifier.hideNotification(jid);
	
	def onAvailable(self):
		if self.state == 2:
			self.interfaceHandler.call("presence_sendAvailable")
		
	
	def sendMessage(self,jid,msg_text):
		self._d("sending message now")
		fmsg = WAXMPP.message_store.createMessage(jid);
		
		
		if fmsg.Conversation.type == "group":
			contact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(self.conn.jid)
			fmsg.setContact(contact);
		
		msg_text = msg_text.replace("&quot;","\"")
		msg_text = msg_text.replace("&amp;", "&");
		msg_text = msg_text.replace("&lt;", "<");
		msg_text = msg_text.replace("&gt;", ">");
		msg_text = msg_text.replace("<br />", "\n");

		fmsg.setData({"status":0,"content":msg_text.encode('utf-8'),"type":1})
		WAXMPP.message_store.pushMessage(jid,fmsg)

		msgId = self.interfaceHandler.call("message_send", (jid, msg_text.encode('utf-8')))

		fmsg.key = Key(jid, False, msgId).toString()
		fmsg.save()
		#self.conn.sendMessageWithBody(fmsg);

	def sendLocation(self,jid,latitude,longitude,rotate):
		latitude = latitude[:10]
		longitude = longitude[:10]

		self._d("Capturing preview...")
		QPixmap.grabWindow(QApplication.desktop().winId()).save(WAConstants.CACHE_PATH+"/tempimg.png", "PNG")
		img = QImage(WAConstants.CACHE_PATH+"/tempimg.png")

		if rotate == "true":
			rot = QTransform()
			rot = rot.rotate(90)
			img = img.transformed(rot)

		if img.height() > img.width():
			result = img.scaledToWidth(320,Qt.SmoothTransformation);
			result = result.copy(result.width()/2-50,result.height()/2-50,100,100);
		elif img.height() < img.width():
			result = img.scaledToHeight(320,Qt.SmoothTransformation);
			result = result.copy(result.width()/2-50,result.height()/2-50,100,100);
		#result = img.scaled(96, 96, Qt.KeepAspectRatioByExpanding, Qt.SmoothTransformation);

		result.save( WAConstants.CACHE_PATH+"/tempimg2.jpg", "JPG" );

		f = open(WAConstants.CACHE_PATH+"/tempimg2.jpg", 'r')
		stream = base64.b64encode(f.read())
		f.close()


		os.remove(WAConstants.CACHE_PATH+"/tempimg.png")
		os.remove(WAConstants.CACHE_PATH+"/tempimg2.jpg")

		fmsg = WAXMPP.message_store.createMessage(jid);
		
		mediaItem = WAXMPP.message_store.store.Media.create()
		mediaItem.mediatype_id = WAConstants.MEDIA_TYPE_LOCATION
		mediaItem.remote_url = None
		mediaItem.preview = stream
		mediaItem.local_path ="%s,%s"%(latitude,longitude)
		mediaItem.transfer_status = 2

		fmsg.content = QtCore.QCoreApplication.translate("WAEventHandler", "Location")
		fmsg.Media = mediaItem

		if fmsg.Conversation.type == "group":
			contact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(self.conn.jid)
			fmsg.setContact(contact);
		
		fmsg.setData({"status":0,"content":fmsg.content,"type":1})
		WAXMPP.message_store.pushMessage(jid,fmsg)
		
		self.conn.sendMessageWithLocation(fmsg);


	def setBlockedContacts(self,contacts):
		self._d("Blocked contacts: " + contacts)
		self.blockedContacts = contacts;

	
	def setResizeImages(self,resize):
		self._d("Resize images: " + str(resize))
		self.resizeImages = resize;

	def setPersonalRingtone(self,value):
		self._d("Personal Ringtone: " + str(value))
		self.notifier.personalRingtone = value;

	def setPersonalVibrate(self,value):
		self._d("Personal Vibrate: " + str(value))
		self.notifier.personalVibrate = value;

	def setGroupRingtone(self,value):
		self._d("Group Ringtone: " + str(value))
		self.notifier.groupRingtone = value;

	def setGroupVibrate(self,value):
		self._d("Group Vibrate: " + str(value))
		self.notifier.groupVibrate = value;


	def sendVCard(self,jid,contactName):
		contactName = contactName.encode('utf-8')
		self._d("Sending vcard: " + WAConstants.VCARD_PATH + "/" + contactName + ".vcf")

		stream = ""
		while not "END:VCARD" in stream:
			f = open(WAConstants.VCARD_PATH + "/"+contactName+".vcf", 'r')
			stream = f.read()
			f.close()
			sleep(0.1)
			
		#print "DATA: " + stream

		fmsg = WAXMPP.message_store.createMessage(jid);
		
		mediaItem = WAXMPP.message_store.store.Media.create()
		mediaItem.mediatype_id = 6
		mediaItem.remote_url = None
		mediaItem.local_path = WAConstants.VCARD_PATH + "/"+contactName+".vcf"
		mediaItem.transfer_status = 2

		vcardImage = ""

		if "PHOTO;BASE64" in stream:
			n = stream.find("PHOTO;BASE64") +13
			vcardImage = stream[n:]
			vcardImage = vcardImage.replace("END:VCARD","")
			#mediaItem.preview = vcardImage

		if "PHOTO;TYPE=JPEG" in stream:
			n = stream.find("PHOTO;TYPE=JPEG") +27
			vcardImage = stream[n:]
			vcardImage = vcardImage.replace("END:VCARD","")
			#mediaItem.preview = vcardImage

		if "PHOTO;TYPE=PNG" in stream:
			n = stream.find("PHOTO;TYPE=PNG") +26
			vcardImage = stream[n:]
			vcardImage = vcardImage.replace("END:VCARD","")
			#mediaItem.preview = vcardImage

		print "VCARD SIZE: " + str(len(stream))

		if len(stream) > 65536:
			print "Vcard too large! Removing photo..."
			n = stream.find("PHOTO")
			stream = stream[:n] + "END:VCARD"
			f = open(WAConstants.VCARD_PATH + "/"+contactName+".vcf", 'w')
			f.write(stream)
			f.close()

		mediaItem.preview = vcardImage

		fmsg.content = contactName
		fmsg.Media = mediaItem

		if fmsg.Conversation.type == "group":
			contact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(self.conn.jid)
			fmsg.setContact(contact);
		
		fmsg.setData({"status":0,"content":fmsg.content,"type":1})
		WAXMPP.message_store.pushMessage(jid,fmsg)
		
		self.conn.sendMessageWithVCard(fmsg);




	def sendMediaImageFile(self,jid,image):
		image = image.replace("file://","")

		user_img = QImage(image)

		if user_img.height() > user_img.width():
			preimg = QPixmap.fromImage(QImage(user_img.scaledToWidth(64, Qt.SmoothTransformation)))
		elif user_img.height() < user_img.width():
			preimg = QPixmap.fromImage(QImage(user_img.scaledToHeight(64, Qt.SmoothTransformation)))
		else:
			preimg = QPixmap.fromImage(QImage(user_img.scaled(64, 64, Qt.KeepAspectRatioByExpanding, Qt.SmoothTransformation)))

		preimg.save(WAConstants.CACHE_PATH+"/temp2.png", "PNG")
		f = open(WAConstants.CACHE_PATH+"/temp2.png", 'r')
		stream = base64.b64encode(f.read())
		f.close()

		self._d("creating PICTURE MMS for " +jid + " - file: " + image)
		fmsg = WAXMPP.message_store.createMessage(jid);
		
		mediaItem = WAXMPP.message_store.store.Media.create()
		mediaItem.mediatype_id = 2
		mediaItem.local_path = image
		mediaItem.transfer_status = 0
		mediaItem.preview = stream

		fmsg.content = QtCore.QCoreApplication.translate("WAEventHandler", "Image")
		fmsg.Media = mediaItem

		if fmsg.Conversation.type == "group":
			contact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(self.conn.jid)
			fmsg.setContact(contact);
		
		fmsg.setData({"status":0,"content":fmsg.content,"type":1})
		WAXMPP.message_store.pushMessage(jid,fmsg)
		

	def sendMediaVideoFile(self,jid,video,image):
		self._d("creating VIDEO MMS for " +jid + " - file: " + video)
		fmsg = WAXMPP.message_store.createMessage(jid);

		if image == "NOPREVIEW":
			m = hashlib.md5()
			url = QtCore.QUrl(video).toEncoded()
			m.update(url)
			image = WAConstants.THUMBS_PATH + "/screen/" + m.hexdigest() + ".jpeg"
		else:
			image = image.replace("file://","")

		user_img = QImage(image)
		if user_img.height() > user_img.width():
			preimg = QPixmap.fromImage(QImage(user_img.scaledToWidth(64, Qt.SmoothTransformation)))
		elif user_img.height() < user_img.width():
			preimg = QPixmap.fromImage(QImage(user_img.scaledToHeight(64, Qt.SmoothTransformation)))
		else:
			preimg = QPixmap.fromImage(QImage(user_img.scaled(64, 64, Qt.KeepAspectRatioByExpanding, Qt.SmoothTransformation)))
		preimg.save(WAConstants.CACHE_PATH+"/temp2.png", "PNG")

		f = open(WAConstants.CACHE_PATH+"/temp2.png", 'r')
		stream = base64.b64encode(f.read())
		f.close()

		mediaItem = WAXMPP.message_store.store.Media.create()
		mediaItem.mediatype_id = 4
		mediaItem.local_path = video.replace("file://","")
		mediaItem.transfer_status = 0
		mediaItem.preview = stream

		fmsg.content = QtCore.QCoreApplication.translate("WAEventHandler", "Video")
		fmsg.Media = mediaItem

		if fmsg.Conversation.type == "group":
			contact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(self.conn.jid)
			fmsg.setContact(contact);
		
		fmsg.setData({"status":0,"content":fmsg.content,"type":1})
		WAXMPP.message_store.pushMessage(jid,fmsg)


	def sendMediaRecordedFile(self,jid):	
		recfile = WAConstants.CACHE_PATH+'/temprecord.wav'
		now = datetime.datetime.now()
		destfile = WAConstants.AUDIO_PATH+"/REC_"+now.strftime("%Y%m%d_%H%M")+".wav"
		shutil.copy(recfile, destfile)

		# Convert to MP3 using lame
		#destfile = WAConstants.AUDIO_PATH+"/REC_"+now.strftime("%Y%m%d_%H%M")+".mp3"
		#pipe=subprocess.Popen(['/usr/bin/lame', recfile, destfile])
		#pipe.wait()
		#os.remove(recfile)
 
		self._d("creating Audio Recorded MMS for " +jid)
		fmsg = WAXMPP.message_store.createMessage(jid);
		
		mediaItem = WAXMPP.message_store.store.Media.create()
		mediaItem.mediatype_id = 3
		mediaItem.local_path = destfile
		mediaItem.transfer_status = 0

		fmsg.content = QtCore.QCoreApplication.translate("WAEventHandler", "Audio")
		fmsg.Media = mediaItem

		if fmsg.Conversation.type == "group":
			contact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(self.conn.jid)
			fmsg.setContact(contact);
		
		fmsg.setData({"status":0,"content":fmsg.content,"type":1})
		WAXMPP.message_store.pushMessage(jid,fmsg)
		


	def sendMediaAudioFile(self,jid,audio):
		self._d("creating MMS for " +jid + " - file: " + audio)
		fmsg = WAXMPP.message_store.createMessage(jid);
		
		mediaItem = WAXMPP.message_store.store.Media.create()
		mediaItem.mediatype_id = 3
		mediaItem.local_path = audio.replace("file://","")
		mediaItem.transfer_status = 0

		fmsg.content = QtCore.QCoreApplication.translate("WAEventHandler", "Audio")
		fmsg.Media = mediaItem

		if fmsg.Conversation.type == "group":
			contact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(self.conn.jid)
			fmsg.setContact(contact);
		
		fmsg.setData({"status":0,"content":fmsg.content,"type":1})
		WAXMPP.message_store.pushMessage(jid,fmsg)



	def sendMediaMessage(self,jid,messageId,data):
		try:
			jid.index('-')
			message = WAXMPP.message_store.store.Groupmessage.create()
		except ValueError:
			message = WAXMPP.message_store.store.Message.create()
		
		message = message.findFirst({'id':messageId});
		media = message.getMedia()
		url = data.split(',')[0]
		name = data.split(',')[1]
		size = data.split(',')[2]
		self._d("sending media message to " + jid + " - file: " + url)
		self.conn.sendNewMMSMessage(message, url, name, size, media.preview, media.mediatype_id);

	
	def rotateImage(self,filepath):
		print "ROTATING FILE: " + filepath
		img = QImage(filepath)
		rot = QTransform()
		rot = rot.rotate(90)
		img = img.transformed(rot)
		img.save(filepath)
		self.imageRotated.emit(filepath)



	def notificationClicked(self,jid):
		self._d("SHOW UI for "+jid)
		self.showUI.emit(jid);


	def groupMessageReceived(self,msgId, jid, author, content, timestamp, wantsReceipt, pushName=""):

		key = Key(jid,False,msgId);
		ret = WAXMPP.message_store.get(key);

		if ret is not None:
			return #Duplicate Message

		if content is not None:
			content = content.encode('utf-8')
			msgContact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(author)

			waMessage = WAXMPP.message_store.createMessage(jid);
			waMessage.setData({"status":0,"key":key.toString(),"contact_id":msgContact.id, "content":content,"type":WAXMPP.message_store.store.Message.TYPE_RECEIVED});

			conversation = WAXMPP.message_store.getOrCreateConversationByJid(jid)
			WAXMPP.message_store.pushMessage(jid, waMessage)
			conversation.incrementNew();

			

			try:
				msgContact = WAXMPP.message_store.store.getCachedContacts()[msgContact.number];
			except:
				pass

			contactName = msgContact.name

			if contactName is None or contactName == "":
				contactName = pushName

			jjid = conversation.jid.replace("@g.us","")
			if msgContact.jid is not None and os.path.isfile(WAConstants.CACHE_PATH+"/contacts/" + jjid + ".png"):
				msgPicture = WAConstants.CACHE_PATH+"/contacts/" + jjid + ".png"
			else:
				msgPicture = "/opt/waxmppplugin/bin/wazapp/UI/common/images/group.png"

			self.notifier.newGroupMessage(conversation.jid, "%s - %s"%(contactName,conversation.subject.decode("utf8") if conversation.subject else ""), content, msgPicture.encode('utf-8'),callback = self.notificationClicked);


		if(wantsReceipt):
			print "GROUP MESSAGE WANTS RECEIPT!!!"
			self.interfaceHandler.call("message_ack", (jid, msgId))

	
	def messageReceived(self,msgId, jid, content, timestamp, wantsReceipt, pushName=""):
		
		key = Key(jid,False,msgId);
		ret = WAXMPP.message_store.get(key);

		if ret is not None:
			return #Duplicate Message

		if content is not None:
			content = content.encode('utf-8')
			waMessage = WAXMPP.message_store.createMessage(jid);
			waMessage.setData({"status":0,"key":key.toString(),"content":content,"type":WAXMPP.message_store.store.Message.TYPE_RECEIVED});

			conversation = WAXMPP.message_store.getOrCreateConversationByJid(jid)
			WAXMPP.message_store.pushMessage(jid, waMessage)
			conversation.incrementNew();

			msgContact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(jid)

			try:
				msgContact = WAXMPP.message_store.store.getCachedContacts()[msgContact.number];
			except:
				pass

			contactName = msgContact.name

			if contactName is None or contactName == "":
				contactName = pushName

						
			
			if msgContact.jid is not None:
				msgPicture = WAConstants.CACHE_PATH+"/contacts/" + msgContact.jid.replace("@s.whatsapp.net","") + ".png"
			else:
				msgPicture = "/opt/waxmppplugin/bin/wazapp/UI/common/images/user.png"



			self.notifier.newSingleMessage(msgContact.jid, contactName, content, msgPicture.encode('utf-8'),callback = self.notificationClicked);

		if(wantsReceipt):
			print "MESSAGE WANTS RECEIPT!!!"
			self.interfaceHandler.call("message_ack", (jid, msgId))
	
	def subjectReceiptRequested(self,to,idx):
		self.conn.sendSubjectReceived(to,idx);
			
	def presence_available_received(self,fromm):
		if(fromm == self.conn.jid):
			return
		self.available.emit(fromm)
		self._d("{Friend} is now available".format(Friend = fromm));
	
	def presence_unavailable_received(self,fromm):
		if(fromm == self.conn.jid):
			return
		self.unavailable.emit(fromm)
		self._d("{Friend} is now unavailable".format(Friend = fromm));
	
	def typing_received(self,fromm):
		self._d("{Friend} is typing ".format(Friend = fromm))
		self.typing.emit(fromm);

	def paused_received(self,fromm):
		self._d("{Friend} has stopped typing ".format(Friend = fromm))
		self.paused.emit(fromm);


	def message_error(self,fmsg,errorCode):
		self._d("Message Error {0}\n Error Code: {1}".format(fmsg,str(errorCode)));


	def onMessageSent(self, jid, msgId):
		k = Key(jid, False, msgId)
		

		try:
			jid.index('-')
			waMessage = WAXMPP.message_store.store.Groupmessage.findFirst({"key":k.toString()})
		except ValueError:
			
			waMessage = WAXMPP.message_store.store.Message.findFirst({"key":k.toString()})

		if waMessage:
			WAXMPP.message_store.updateStatus(waMessage,WAXMPP.message_store.store.Message.STATUS_SENT)
			self.messageSent.emit(waMessage.id, jid)

	def onMessageDelivered(self, jid, msgId):
		k = Key(jid, False, msgId)

		try:
			jid.index('-')
			waMessage = WAXMPP.message_store.store.Groupmessage.findFirst({"key":k.toString()})
		except ValueError:
			waMessage = WAXMPP.message_store.store.Message.findFirst({"key":k.toString()})

		if waMessage:
			WAXMPP.message_store.updateStatus(waMessage,WAXMPP.message_store.store.Message.STATUS_DELIVERED)
			self.messageDelivered.emit(waMessage.id, jid)
	

	def onGroupCreated(self,jid,group_id):
		self._d("Got group created " + group_id)
		jname = jid.replace("@g.us","")
		img = QImage("/opt/waxmppplugin/bin/wazapp/UI/common/images/group.png")
		img.save(WAConstants.CACHE_PATH+"/contacts/" + jname + ".png")
		self.groupCreated.emit(group_id);

	def onAddedParticipants(self):
		self._d("participants added!")
		self.addedParticipants.emit();

	def onRemovedParticipants(self):
		self._d("participants removed!")
		self.removedParticipants.emit();

	def onGroupEnded(self):
		self._d("group deleted!")
		self.groupEnded.emit();

	def onGroupSubjectChanged(self):
		self._d("group subject changed!")
		self.groupSubjectChanged.emit();
	
	def onGroupInfo(self,jid,ownerJid,subject,subjectOwnerJid,subjectT,creation):
		self._d("Got group info")
		if jid == "ERROR":
			self.groupInfoUpdated.emit(jid,"ERROR")
		else:
			self.groupInfoUpdated.emit(jid,jid+"<<->>"+str(ownerJid)+"<<->>"+subject+"<<->>"+subjectOwnerJid+"<<->>"+str(subjectT)+"<<->>"+str(creation))
			WAXMPP.message_store.updateGroupInfo(jid,ownerJid,subject,subjectOwnerJid,subjectT,creation)
		#self.conn.sendGetPicture("g.us",jid,"group")
		
	def onGroupParticipants(self,jid,jids):
		self._d("GOT group participants")
		self.groupParticipants.emit(",".join(jids));
		conversation = WAXMPP.message_store.getOrCreateConversationByJid(jid);
		
		# DO WE REALLY NEED TO ADD EVERY CONTACT ?
		for j in jids:
			contact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(j)
			conversation.addContact(contact.id);
		
		WAXMPP.message_store.sendConversationReady(jid);
		
	def groupSubjectUpdated(self, jid,author,newSubject,timestamp):
		self._d("Got group subject update")
		g = WAXMPP.message_store.getOrCreateConversationByJid(jid);
		contact = g.getOwner();
		cjid = contact.jid if contact is not 0 else "";
     
		self.onGroupInfo(jid,cjid,newSubject,author,timestamp,g.created);
		
	def onGetPictureIds(self,jids):
		self._d("Got picture ids")
		self.listJids = jids
		if len(self.listJids)>0:
			self.conn.sendGetPicture(self.listJids[0],"image")
		else:
			self.getPicturesFinished.emit()

	def onGetPictureDone(self, jid):
		self.profilePictureUpdated.emit(jid);
		if len(self.listJids)>0:
			self.listJids.pop(0);
			if len(self.listJids)>0:
				self.conn.sendGetPicture(self.listJids[0],"image")
			else:
				self.getPicturesFinished.emit()

	def onSetPicture(self,jid,res):
		self._d("Getting Picture "+res +" for "+jid)
		if res == "done":
			self.conn.sendGetPicture(jid,"image")
		else:
			self.profilePictureUpdated.emit(jid);


class WAXMPP():
	message_store = None
	def __init__(self,domain,resource,user,push_name,password):
		
		WADebug.attach(self);
		
		self.domain = domain;
		self.resource = resource;
		self.user=user;
		self.push_name=push_name;
		self.password = password;
		self.jid = user+'@'+domain
		self.fromm = user+'@'+domain+'/'+resource;
		self.supports_receipt_acks = False;
		self.state = 0 #0 disconnected 1 connecting 2 connected
		self.retry = True
		self.eventHandler = WAEventHandler(self);
		self.conn =MySocketConnection();		
		self.stanzaReader = None
		self.login = None;
		
		self.disconnectRequested = False
		
		self.connTries = 0;
		
		self.verbose = True
		self.iqId = 0;
		self.lock = threading.Lock()
		
		self.waiting = 0;
		
		#super(WAXMPP,self).__init__();
		
		#self.eventHandler.initialConnCheck();
		
		#self.do_login();
		
	
	
	
	def setContactsManager(self,contactsManager):
		self.contactsManager = contactsManager
		
	def setReceiptAckCapable(self,can):
		#print "Switching to True"
		self.supports_receipt_acks = True;
		#print self.supports_receipt_acks

		
	
	
	
	def onLoginSuccess(self):
		self.changeState(4)
		
		self.connectionTries = 0
		c = StanzaReader(self);
		
		c.setEventHandler(self.eventHandler);
		
		#initial presence
		self.stanzaReader = c
		
		self.stanzaReader.start();
		
		
		self.sendClientConfig('','',False,'');
		self.sendAvailableForChat();
		self.eventHandler.connected.emit();
	
	def disconnect(self):
		self.conn.close()
	
	def retryLogin(self):
		self.changeState(3);
	


	def do_login(self):
		
		self.conn = conn = MySocketConnection();
		#conn.connect((HOST, PORT));

		self.inn = BinTreeNodeReader(conn,WALogin.dictYappari);
		self.out = BinTreeNodeWriter(conn,WALogin.dictYappari);
		
		
		self.login = WALogin(conn,self.inn,self.out,S40MD5Digest());
		
		
		self.login.setConnection(self);
		
		self.login.loginSuccess.connect(self.onLoginSuccess)
		self.login.loginFailed.connect(self.eventHandler.onLoginFailed);
		
		self.login.connectionError.connect(self.onConnectionError)
		self.login.start();
	
	

