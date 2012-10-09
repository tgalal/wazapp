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
#from InterfaceHandlers.DBus.DBusInterfaceHandler import DBusInterfaceHandler
from InterfaceHandlers.Lib.LibInterfaceHandler import LibInterfaceHandler

from PySide import QtCore
from PySide.QtCore import Qt, QObject, QTimer
from PySide.QtGui import QApplication, QImage, QPixmap, QTransform
from connmon import ConnMonitor
from constants import WAConstants
from messagestore import Key
from notifier import Notifier
from time import sleep
from wadebug import WADebug
from wamediahandler import WAMediaHandler
from waupdater import WAUpdater
import base64
import hashlib
import os
import shutil, datetime
import thread
import Image
from PIL.ExifTags import TAGS



class WAEventHandler(QObject):
	
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
	groupSubjectChanged = QtCore.Signal(str);
	getPictureIds = QtCore.Signal(str);
	profilePictureUpdated = QtCore.Signal(str);
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
		self.disconnectRequested = False

		#self.interfaceHandler = LibInterfaceHandler()
		
		self.jid = self.conn.jid
		
		self.username = self.jid.split('@')[0]

		self.interfaceHandler = LibInterfaceHandler(self.username)
		self.registerInterfaceSignals()

		
		self.listJids = [];

		self.mediaHandlers = []
		self.sendTyping.connect(lambda *args: self.interfaceHandler.call("typing_send", args));
		self.sendPaused.connect(lambda *args: self.interfaceHandler.call("typing_paused",args));
		self.getLastOnline.connect(lambda *args: self.interfaceHandler.call("presence_request", args));
		self.getGroupInfo.connect(lambda *args: self.interfaceHandler.call("group_getInfo", args));
		self.createGroupChat.connect(lambda *args: self.interfaceHandler.call("group_create", args));
		self.addParticipants.connect(lambda *args: self.interfaceHandler.call("group_addParticipants", args));
		self.removeParticipants.connect(lambda *args: self.interfaceHandler.call("group_removeParticipants", args));
		self.getGroupParticipants.connect(lambda *args: self.interfaceHandler.call("group_getParticipants", args));
		self.endGroupChat.connect(lambda *args: self.interfaceHandler.call("group_end", args));
		self.setGroupSubject.connect(lambda *args: self.interfaceHandler.call("group_setSubject", args));
		self.getPictureIds.connect(lambda *args: self.interfaceHandler.call("picture_getIds", args));
		self.changeStatus.connect(lambda *args: self.interfaceHandler.call("profile_setStatus", args));

		self.state = 0
		
		
	############### NEW BACKEND STUFF

	def authSuccess(self, username):
		self.state = 2
		self.connected.emit()
		print "AUTH SUCCESS"
		print username

		#self.interfaceHandler.initSignals(connId)
		#self.interfaceHandler.initMethods(connId)

		#self.registerInterfaceSignals()

		self.interfaceHandler.call("ready")

		self.resendUnsent()

	def authComplete(self):
		pass

	def authConnFail(self,username, err):
		self.state = 0
		print "Auth connection failed"
		print err
		if self.connMonitor.isOnline():
			QTimer.singleShot(5000, lambda: self.networkAvailable() if self.connMonitor.isOnline() else False)


	def authFail(self, username, err):
		self.state = 0
		print "AUTH FAILED FOR %s!!" % username


	def registerInterfaceSignals(self):
		self.interfaceHandler.connectToSignal("message_received", self.onMessageReceived)
		self.interfaceHandler.connectToSignal("group_messageReceived", self.onMessageReceived)
		#self.registerSignal("status_dirty", self.statusDirtyReceived) #ignored by whatsapp?
		self.interfaceHandler.connectToSignal("receipt_messageSent", self.onMessageSent)
		self.interfaceHandler.connectToSignal("receipt_messageDelivered", self.onMessageDelivered)
		self.interfaceHandler.connectToSignal("receipt_visible", self.onMessageDelivered) #@@TODO check
		self.interfaceHandler.connectToSignal("presence_available", self.presence_available_received)
		self.interfaceHandler.connectToSignal("presence_unavailable", self.presence_unavailable_received)
		self.interfaceHandler.connectToSignal("presence_updated", self.onLastSeen)

		self.interfaceHandler.connectToSignal("contact_gotProfilePictureId", self.onProfilePictureIdReceived)
		self.interfaceHandler.connectToSignal("contact_gotProfilePicture", self.onGetPictureDone)

		self.interfaceHandler.connectToSignal("group_gotParticipants", self.onGroupParticipants)
		self.interfaceHandler.connectToSignal("group_createSuccess", self.onGroupCreated)
		self.interfaceHandler.connectToSignal("group_endSuccess", self.onGroupEnded)
		self.interfaceHandler.connectToSignal("group_gotInfo", self.onGroupInfo)
		self.interfaceHandler.connectToSignal("group_infoError", self.onGroupInfoError)
		
		self.interfaceHandler.connectToSignal("group_addParticipantsSuccess", self.onAddedParticipants)
		self.interfaceHandler.connectToSignal("group_removeParticipantsSuccess", self.onRemovedParticipants)
		self.interfaceHandler.connectToSignal("group_setPictureSuccess",self.onSetGroupPicture)
		self.interfaceHandler.connectToSignal("group_setPictureError",self.onSetGroupPictureError)
		self.interfaceHandler.connectToSignal("group_gotPicture", self.onGetPictureDone)
		self.interfaceHandler.connectToSignal("group_subjectReceived", self.onGroupSubjectReceived)
		self.interfaceHandler.connectToSignal("group_setSubjectSuccess", self.onGroupSetSubjectSuccess)


		self.interfaceHandler.connectToSignal("notification_contactProfilePictureUpdated", self.onContactProfilePictureUpdatedNotification)
		self.interfaceHandler.connectToSignal("notification_groupParticipantAdded", self.onGroupParticipantAddedNotification)
		self.interfaceHandler.connectToSignal("notification_groupParticipantRemoved", self.onGroupParticipantRemovedNotification)
		self.interfaceHandler.connectToSignal("notification_groupPictureUpdated", self.onGroupPictureUpdatedNotification)
		
		self.interfaceHandler.connectToSignal("disconnected", self.onDisconnected)


		self.interfaceHandler.connectToSignal("image_received", self.onImageReceived)
		self.interfaceHandler.connectToSignal("group_imageReceived", self.onImageReceived)

		self.interfaceHandler.connectToSignal("audio_received", self.onAudioReceived)
		self.interfaceHandler.connectToSignal("group_audioReceived", self.onAudioReceived)

		self.interfaceHandler.connectToSignal("video_received", self.onVideoReceived)
		self.interfaceHandler.connectToSignal("group_videoReceived", self.onVideoReceived)

		self.interfaceHandler.connectToSignal("location_received", self.onLocationReceived)
		self.interfaceHandler.connectToSignal("group_locationReceived", self.onLocationReceived)
		
		self.interfaceHandler.connectToSignal("vcard_received", self.onVCardReceived)
		self.interfaceHandler.connectToSignal("group_vcardReceived", self.onVCardReceived)
		
		self.interfaceHandler.connectToSignal("message_error", self.onMessageError)
		
		self.interfaceHandler.connectToSignal("profile_setPictureSuccess", self.onSetProfilePicture)
		self.interfaceHandler.connectToSignal("profile_setPictureError", self.onSetProfilePictureError)
		
		self.interfaceHandler.connectToSignal("profile_setStatusSuccess", self.onProfileSetStatusSuccess)
		
		self.interfaceHandler.connectToSignal("auth_success", self.authSuccess)
		self.interfaceHandler.connectToSignal("auth_fail", self.authFail)


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
			jid = m.getConversation().getJid()
			if media is not None:
				if media.transfer_status == 2:
					if media.mediatype_id == 6:
						vcard = self.readVCard(m.content)
						if vcard:
							resultId = self.interfaceHandler.call("message_vcardSend", (jid, vcard, m.content))
							k = Key(jid, True, resultId)
							m.key = k.toString()
							m.save()
										
					elif media.mediatype_id == 5:
						
							latitude,longitude = media.local_path.split(',')
							
							resultId = self.interfaceHandler.call("message_locationSend", (jid, latitude, longitude, media.preview))
							k = Key(jid, True, resultId)
							m.key = k.toString()
							m.save()
					else:
						media.transfer_status = 1
						media.save()
			else:
				try:
					msgId = self.interfaceHandler.call("message_send", (jid, m.content.encode('utf-8')))
					m.key = Key(jid, True, msgId).toString()
					m.save()
				except UnicodeDecodeError:
					self._d("skipped sending an old message because UnicodeDecodeError")

		self._d("Resending old messages done")

	def getDisplayPicture(self, jid = None):
		picture = "/opt/waxmppplugin/bin/wazapp/UI/common/images/user.png"
		if jid is None:
			return picture

		try:
			jid.index('-')
			jid = jid.replace("@g.us","")
			if os.path.isfile(WAConstants.CACHE_PATH+"/contacts/" + jid + ".png"):
				picture = WAConstants.CACHE_PATH+"/contacts/" + jid + ".png"
			else:
				picture = "/opt/waxmppplugin/bin/wazapp/UI/common/images/group.png"

		except ValueError:
			if jid is not None:
				picture = WAConstants.CACHE_PATH+"/contacts/" + jid.replace("@s.whatsapp.net","") + ".png"

		return picture



	##SECTION MESSAGERECEPTION##
	def preMessageReceived(fn):

		def wrapped(self, *args):
			messageId = args[0]
			jid = args[1]
			if WAXMPP.message_store.messageExists(jid, messageId):
				self.interfaceHandler.call("message_ack", (jid, messageId))
				return



			key = Key(jid,False,messageId);
			msg = WAXMPP.message_store.createMessage(jid)

			author = jid
			isGroup = WAXMPP.message_store.isGroupJid(jid)
			if isGroup:
				author = args[2]

			msgContact =  WAXMPP.message_store.store.Contact.getOrCreateContactByJid(author)

			msg.Contact = msgContact
			msg.setData({"status":0,"key":key.toString(),"type":WAXMPP.message_store.store.Message.TYPE_RECEIVED});
			msg.contact_id = msgContact.id

			return fn(self,msg, *args[2:]) if author == jid else fn(self,msg, *args[3:]) #omits author as well if group

		return wrapped

	def postMessageReceived(fn):
		def wrapped(self, *args):
			message = fn(self, *args)
			contact = message.getContact()
			conversation = message.getConversation()

			try:
				contact = WAXMPP.message_store.store.getCachedContacts()[contact.number];
			except:
				pass


			msgPicture = self.getDisplayPicture(conversation.getJid())
			WAXMPP.message_store.pushMessage(conversation.getJid(), message)
			conversation.incrementNew()


			if conversation.isGroup():
				self.notifier.newGroupMessage(conversation.getJid(), "%s - %s"%(contact.name or contact.number,conversation.subject.decode("utf8") if conversation.subject else ""), message.content, msgPicture.encode('utf-8'),callback = self.notificationClicked);
			else:
				self.notifier.newSingleMessage(contact.jid, contact.name or contact.number, message.content, msgPicture.encode('utf-8'),callback = self.notificationClicked);

			if message.wantsReceipt:
				self.interfaceHandler.call("message_ack", (conversation.getJid(), eval(message.key).id))

		return wrapped
	
	@preMessageReceived
	def onMessageError(self,message,errorCode):
		self._d("Message Error {0}\n Error Code: {1}".format(message,str(errorCode)));
	
	@preMessageReceived
	@postMessageReceived
	def onMessageReceived(self, message, content, timestamp, wantsReceipt, pushName=""):

		if content is not None:

			content = content#.encode('utf-8')
			message.timestamp = timestamp
			message.content = content

		message.wantsReceipt = wantsReceipt
		return message

	@preMessageReceived
	@postMessageReceived
	def onImageReceived(self, message, preview, url, size, wantsReceipt = True):
		
		self._d("MEDIA SIZE IS "+str(size))
		mediaItem = WAXMPP.message_store.store.Media.create()
		mediaItem.remote_url = url
		mediaItem.preview = preview
		mediaItem.mediatype_id = WAConstants.MEDIA_TYPE_IMAGE
		mediaItem.size = size

		message.content = QtCore.QCoreApplication.translate("WAEventHandler", "Image")
		message.Media = mediaItem
		message.wantsReceipt = wantsReceipt

		return message


	@preMessageReceived
	@postMessageReceived
	def onVideoReceived(self, message, preview, url, size, wantsReceipt = True):

		mediaItem = WAXMPP.message_store.store.Media.create()
		mediaItem.remote_url = url
		mediaItem.preview = preview
		mediaItem.mediatype_id = WAConstants.MEDIA_TYPE_VIDEO
		mediaItem.size = size

		message.content = QtCore.QCoreApplication.translate("WAEventHandler", "Video")
		message.Media = mediaItem
		message.wantsReceipt = wantsReceipt

		return message

	@preMessageReceived
	@postMessageReceived
	def onAudioReceived(self, message, url, size, wantsReceipt = True):

		mediaItem = WAXMPP.message_store.store.Media.create()
		mediaItem.remote_url = url
		mediaItem.mediatype_id = WAConstants.MEDIA_TYPE_AUDIO
		mediaItem.size = size

		message.content = QtCore.QCoreApplication.translate("WAEventHandler", "Audio")
		message.Media = mediaItem
		message.wantsReceipt = wantsReceipt

		return message

	@preMessageReceived
	@postMessageReceived
	def onLocationReceived(self, message, name, preview, latitude, longitude, wantsReceipt = True):

		mediaItem = WAXMPP.message_store.store.Media.create()
		mediaItem.remote_url = None
		mediaItem.preview = preview
		mediaItem.mediatype_id = WAConstants.MEDIA_TYPE_LOCATION

		mediaItem.local_path ="%s,%s"%(latitude, longitude)
		mediaItem.transfer_status = 2

		message.content = name or QtCore.QCoreApplication.translate("WAEventHandler", "Location")
		message.Media = mediaItem
		message.wantsReceipt = wantsReceipt

		return message

	@preMessageReceived
	@postMessageReceived
	def onVCardReceived(self, message, name, data, wantsReceipt = True):

		targetPath = WAConstants.VCARD_PATH + "/" + name + ".vcf"
		vcardImage = None

		vcardFile = open(targetPath, "w")
		vcardFile.write(data)
		vcardFile.close()

		mediaItem = WAXMPP.message_store.store.Media.create()
		mediaItem.mediatype_id = WAConstants.MEDIA_TYPE_VCARD
		mediaItem.transfer_status = 2
		mediaItem.local_path = targetPath

		if "PHOTO;BASE64" in data:
			print "GETTING BASE64 PICTURE"
			n = data.find("PHOTO;BASE64") +13
			vcardImage = data[n:]
			vcardImage = vcardImage.replace("END:VCARD","")


		elif "PHOTO;TYPE=JPEG" in data:
			n = data.find("PHOTO;TYPE=JPEG") +27
			vcardImage = data[n:]
			vcardImage = vcardImage.replace("END:VCARD","")

		elif "PHOTO;TYPE=PNG" in data:
			n = data.find("PHOTO;TYPE=PNG") +26
			vcardImage = data[n:]
			vcardImage = vcardImage.replace("END:VCARD","")

		mediaItem.preview = vcardImage

		message.content = name
		message.Media = mediaItem
		message.wantsReceipt = wantsReceipt

		return message


	## ENDSECTION MESSAGERECEPTION ##
	
	## MEDIA SEND/ RECEIVE ##
	
	def getPicture(self, jid):
		if WAXMPP.message_store.isGroupJid(jid):
			self.interfaceHandler.call("group_getPicture", (jid,))
		else:
			self.interfaceHandler.call("contact_getProfilePicture", (jid,))
	
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

	## END MEDIA SEND/ RECEIVE ##

	## SECTION: NOTIFICATIONS ##
	
	def onNotificationReceiptRequested(self, jid, notificationId):
		self.interfaceHandler.call("notification_ack", (jid, notificationId))


	def onContactProfilePictureUpdatedNotification(self, jid, timestamp, messageId, wantsReceipt = True):
		if wantsReceipt:
			self.onNotificationReceiptRequested(jid, messageId)


		if WAXMPP.message_store.messageExists(jid, messageId):
			return
		
		self.interfaceHandler.call("contact_getProfilePicture", (jid,))

	def onGroupPictureUpdatedNotification(self, jid, author, timestamp, messageId, wantsReceipt = True):
		if wantsReceipt:
			self.onNotificationReceiptRequested(jid, messageId)

		if WAXMPP.message_store.messageExists(jid, messageId):
			return

		
		key = Key(jid, False, messageId)
		msg = WAXMPP.message_store.createMessage(jid)
		msg.setData({"timestamp": timestamp,"status":0,"key":key.toString(),"content":jid,"type":23})


		contact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(author)
		msg.contact_id = contact.id

		msg.Conversation = WAXMPP.message_store.getOrCreateConversationByJid(jid)

		msg.content = author#QtCore.QCoreApplication.translate("WAEventHandler", "%1 changed the group picture")

		selfChange = contact.number == self.account
		msg.content = msg.content.replace("%1", (contact.name or contact.number) if not selfChange else "You")

		WAXMPP.message_store.pushMessage(jid, msg)

		if not selfChange:
			self.interfaceHandler.call("contact_getProfilePicture", (jid,)) #@@TODO CHECK NAMING FOR GROUPS


	def onGroupParticipantAddedNotification(self, gJid, jid, author, timestamp, messageId, wantsReceipt = True):
		if wantsReceipt:
			self.onNotificationReceiptRequested(gJid, messageId)

		if WAXMPP.message_store.messageExists(jid, messageId):
			return

		key = Key(gJid, False, messageId)

		if jid == self.account:
			print "THIS IS ME! GETTING OWNER..."
			jid = gJid.split('-')[0]+"@s.whatsapp.net"
		self._d("Contact added: " + jid)

		msg = WAXMPP.message_store.createMessage(gJid)
		msg.setData({"timestamp": timestamp,"status":0,"key":key.toString(),"content":jid,"type":20})

		contact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(jid)
		msg.contact_id = contact.id
		msg.content = jid
				
		msg.Conversation = WAXMPP.message_store.getOrCreateConversationByJid(gJid)
		msg.Conversation.subject = "" if msg.Conversation.subject is None else msg.Conversation.subject

		if author == jid:
			notifyContent = QtCore.QCoreApplication.translate("WAEventHandler", "%1 joined the group")
			notifyContent = msg.content.replace("%1", contact.name or contact.number)
		else:
			authorContact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(author)
			notifyContent = QtCore.QCoreApplication.translate("WAEventHandler", "%1 added %2 to the group")
			notifyContent.replace("%1", authorContact.name or authorContact.number)
			notifyContent = msg.content.replace("%2", contact.name or contact.number)
			msg.contact_id = authorContact.id

		WAXMPP.message_store.pushMessage(gJid,msg)

		self.notifier.newGroupMessage(gJid, "%s - %s"%(contact.name or contact.number, msg.Conversation.subject.decode("utf8")), notifyContent, self.getDisplayPicture(gJid).encode('utf-8'),callback = self.notificationClicked);
		

	def onGroupParticipantRemovedNotification(self, gJid, jid, author, timestamp, messageId, wantsReceipt = True):
		if wantsReceipt:
			self.onNotificationReceiptRequested(gJid, messageId)

		if WAXMPP.message_store.messageExists(jid, messageId):
			return

		key = Key(gJid, False, messageId)

		if jid == self.account:
			print "THIS IS ME! GETTING OWNER..."
			jid = gJid.split('-')[0]+"@s.whatsapp.net"
		self._d("Contact removed: " + jid)

		msg = WAXMPP.message_store.createMessage(gJid)
		msg.setData({"timestamp": timestamp,"status":0,"key":key.toString(),"content":jid,"type":21});
		contact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(jid)
		msg.contact_id = contact.id
		msg.content = jid

		msg.Conversation = WAXMPP.message_store.getOrCreateConversationByJid(gJid)
		msg.Conversation.subject = "" if msg.Conversation.subject is None else msg.Conversation.subject

		if author == jid:
			notifyContent = QtCore.QCoreApplication.translate("WAEventHandler", "%1 left the group")
			notifyContent = msg.content.replace("%1", contact.name or contact.number)
		else:
			authorContact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(author)
			notifyContent = QtCore.QCoreApplication.translate("WAEventHandler", "%1 removed %2 from the group")
			notifyContent.replace("%1", authorContact.name or authorContact.number)
			notifyContent = msg.content.replace("%2", contact.name or contact.number)
			msg.contact_id = authorContact.id

		WAXMPP.message_store.pushMessage(gJid,msg)

		self.notifier.newGroupMessage(gJid, "%s - %s"%(contact.name or contact.number, msg.Conversation.subject.decode("utf8")), notifyContent, self.getDisplayPicture(gJid).encode('utf-8'),callback = self.notificationClicked);
		
	##ENDSECTION NOTIFICATIONS##
	
	def onGroupSetSubjectSuccess(self, jid):
		self.groupSubjectChanged.emit(jid);
	
	def onGroupSubjectReceived(self,  msgId, jid, author, newSubject, timestamp, receiptRequested):

		self._d("Got group subject update")
		g = WAXMPP.message_store.getOrCreateConversationByJid(jid);
		contact = g.getOwner();
		cjid = contact.jid if contact is not 0 else "";
		
		self.onGroupInfo(jid,cjid,newSubject,author,timestamp,g.created);

	
		if receiptRequested:
			self.interfaceHandler.call("message_ack", (jid, msgId))

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
		
	
	def wtf(self,what):
		self._d("%s, WTF SHOULD I DO NOW???"%(what))
	
		
	
	def networkAvailable(self):
		if self.state != 0:
			return
		self._d("NET AVAILABLE")
		self.updater = WAUpdater()
		self.updater.updateAvailable.connect(self.updateAvailable)
		
		
		self.connecting.emit();
		self.disconnectRequested = False
		
		#thread.start_new_thread(self.conn.changeState, (2,))
		self.state = 1
		#self.authenticate("4915225256022", "6a65a936b8caa360ac1d8f983087ebd2")
		#self.interfaceHandler.call("auth_login", ("4915225256022", "6a65a936b8caa360ac1d8f983087ebd2"))
		self.interfaceHandler.call("auth_login", (self.conn.user, self.conn.password))
		
		self._d("AUTH CALLED")
		
		#self.updater.run()
		
		#self.conn.disconnect()
		
		
	def onDisconnected(self, reason):
		self._d("Got disconnected because %s"%reason)
		self.state = 0
		self.disconnected.emit()

		if reason == "":
			return
		elif reason == "closed" or reason == "dns" or reason == "network":
			if self.connMonitor.isOnline():
				self.networkAvailable()
			elif reason == "network":
				self.sleeping.emit()
		#@@TODO ADD reason another connection
		
	def networkDisconnected(self):
		self.state = 0
		#self.interfaceHandler.call("disconnect")
		'''if self.connMonitor.isOnline():
			self.networkAvailable()
			return
		'''
		self.sleeping.emit();
		
		#thread.start_new_thread(self.conn.changeState, (0,))
		#self.conn.disconnect();
		if not self.disconnectRequested:
			self.disconnectRequested = True
			thread.start_new_thread(lambda: self.interfaceHandler.call("disconnect", ("network",)), ())
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

		fmsg.key = Key(jid, True, msgId).toString()
		fmsg.save()
		#self.conn.sendMessageWithBody(fmsg);

	def sendLocation(self, jid, latitude, longitude, rotate):
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
		
		
		resultId = self.interfaceHandler.call("message_locationSend", (jid, latitude, longitude, stream))
		k = Key(jid, True, resultId)
		fmsg.key = k.toString()
		fmsg.save()


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

	
	def readVCard(self, contactName):
		
		path = WAConstants.VCARD_PATH + "/"+contactName+".vcf"
		stream = ""
		if os.path.exists(path):
			try:
				while not "END:VCARD" in stream:
					f = open(path, 'r')
					stream = f.read()
					f.close()
					sleep(0.1)
					
				
				if len(stream) > 65536:
					print "Vcard too large! Removing photo..."
					n = stream.find("PHOTO")
					stream = stream[:n] + "END:VCARD"
					f = open(path, 'w')
					f.write(stream)
					f.close()
			except:
				pass
		
		return stream
	
	def sendVCard(self,jid,contactName):
		contactName = contactName.encode('utf-8')
		self._d("Sending vcard: " + WAConstants.VCARD_PATH + "/" + contactName + ".vcf")

		
		stream = self.readVCard(contactName)
		if not stream:
			return
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

		mediaItem.preview = vcardImage

		fmsg.content = contactName
		fmsg.Media = mediaItem

		if fmsg.Conversation.type == "group":
			contact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(self.conn.jid)
			fmsg.setContact(contact);
		
		fmsg.setData({"status":0,"content":fmsg.content,"type":1})
		WAXMPP.message_store.pushMessage(jid,fmsg)
		
		resultId = self.interfaceHandler.call("message_vcardSend", (jid, stream, contactName))
		k = Key(jid, True, resultId)
		fmsg.key = k.toString()
		fmsg.save()

		
	def setGroupPicture(self, jid, filepath):
		path = self._getPictureForSending(jid, filepath)
		self.interfaceHandler.call("group_setPicture", (jid, path))
		
	def setProfilePicture(self, filepath):
		path = self._getPictureForSending(self.jid, filepath)
		self.interfaceHandler.call("profile_setPicture", (path,))
	
	def _getPictureForSending(self, jid, filepath):
		print "Preparing picture " + filepath + " for " + jid
		image = filepath.replace("file://","")
		rotation = 0

		ret = {}
		im = Image.open(image)
		try:
			info = im._getexif()
			for tag, value in info.items():
				decoded = TAGS.get(tag, value)
				ret[decoded] = value
			if ret['Orientation'] == 6:
				rotation = 90
		except:
			rotation = 0

		user_img = QImage(image)

		if rotation == 90:
			rot = QTransform()
			rot = rot.rotate(90)
			user_img = user_img.transformed(rot)


		if user_img.height() > user_img.width():
			preimg = user_img.scaledToWidth(480, Qt.SmoothTransformation)
			preimg = preimg.copy( 0, preimg.height()/2-240, 480, 480);
		elif user_img.height() < user_img.width():
			preimg = user_img.scaledToHeight(480, Qt.SmoothTransformation)
			preimg = preimg.copy( preimg.width()/2-240, 0, 480, 480);
		else:
			preimg = user_img.scaled(480, 480, Qt.KeepAspectRatioByExpanding, Qt.SmoothTransformation)

		preimg.save(WAConstants.CACHE_PATH+"/temp.jpg", "JPG")

		''''f = open(WAConstants.CACHE_PATH+"/temp.jpg", 'r')
		stream = f.read()
		stream = bytearray(stream)
		f.close()
		'''
		
		return WAConstants.CACHE_PATH+"/temp.jpg"
		


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
		try:
			mediaItem.size = os.path.getsize(mediaItem.local_path)
		except:
			pass

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
		
		try:
			mediaItem.size = os.path.getsize(mediaItem.local_path)
		except:
			pass

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
		
		try:
			mediaItem.size = os.path.getsize(mediaItem.local_path)
		except:
			pass

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
		
		
		if media.mediatype_id == WAConstants.MEDIA_TYPE_IMAGE:
			returnedId = self.interfaceHandler.call("message_imageSend", (jid, url, name, size, media.preview))
		elif media.mediatype_id == WAConstants.MEDIA_TYPE_AUDIO:
			returnedId = self.interfaceHandler.call("message_audioSend", (jid, url, name, size))
		elif media.mediatype_id == WAConstants.MEDIA_TYPE_VIDEO:
			returnedId = self.interfaceHandler.call("message_videoSend", (jid, url, name, size, media.preview))

		
		key = Key(jid, True, returnedId)
		message.key = key.toString()
		message.save()
		
		
	
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


	


	def onMessageSent(self, jid, msgId):
		self._d("IN MESSAGE SENT")
		k = Key(jid, True, msgId)
		
		self._d("KEY: %s"%k.toString())


		waMessage =  WAXMPP.message_store.get(k);
			
			
		self._d(waMessage)

		if waMessage:
			WAXMPP.message_store.updateStatus(waMessage,WAXMPP.message_store.store.Message.STATUS_SENT)
			self.messageSent.emit(waMessage.id, jid)

	def onMessageDelivered(self, jid, msgId):
		k = Key(jid, True, msgId)

		waMessage =  WAXMPP.message_store.get(k);

		if waMessage:
			WAXMPP.message_store.updateStatus(waMessage,WAXMPP.message_store.store.Message.STATUS_DELIVERED)
			self.messageDelivered.emit(waMessage.id, jid)
			
		self._d("IN DELIVERED")
		self._d(waMessage)

		self.interfaceHandler.call("delivered_ack", (jid, msgId))
	

	def onGroupCreated(self,jid,group_id):
		self._d("Got group created " + group_id)
		jname = jid.replace("@g.us","")
		img = QImage("/opt/waxmppplugin/bin/wazapp/UI/common/images/group.png")
		img.save(WAConstants.CACHE_PATH+"/contacts/" + jname + ".png")
		self.groupCreated.emit(group_id);
		
	

	def onAddedParticipants(self, jid):
		self._d("participants added!")
		self.addedParticipants.emit();

	def onRemovedParticipants(self, jid):
		self._d("participants removed!")
		self.removedParticipants.emit();

	def onGroupEnded(self, jid):
		self._d("group deleted!")
		#@@TODO use the fucking jid
		self.groupEnded.emit();
		
	def onGroupInfoError(self, jid, code):
		self.groupInfoUpdated.emit(jid,"ERROR")
	
	def onGroupInfo(self,jid,ownerJid,subject,subjectOwnerJid,subjectT,creation):
		self._d("Got group info")
	
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
		
	
	def onProfileSetStatusSuccess(self, jid, messageId):
		self.statusChanged.emit()
		self.interfaceHandler.call("delivered_ack", (jid, messageId))

	def onProfilePictureIdReceived(self,jid, pictureId):
		contact = WAXMPP.message_store.store.Contact.getOrCreateContactByJid(jid)

		if contact.pictureid != str(pictureId):
			contact.pictureid = pictureId
			contact.save()
			self.interfaceHandler.call("contact_getProfilePicture", (jid,))


		self.getPicturesFinished.emit()

	def onGetPictureDone(self, jid, tmpfile):

		if os.path.exists(tmpfile):
			
			cjid = jid.replace("@s.whatsapp.net","").replace("@g.us","")
			shutil.move(tmpfile, WAConstants.CACHE_PATH+"/contacts/" + cjid + ".jpg")
	
			if os.path.isfile(WAConstants.CACHE_PATH+"/contacts/" + cjid + ".png"):
				os.remove(WAConstants.CACHE_PATH+"/contacts/" + cjid + ".png")

			self.profilePictureUpdated.emit(jid);
	
		self.getPicturesFinished.emit()
		
	def onSetProfilePicture(self):
		self._d("GETTING MY PICTURE")
		self.interfaceHandler.call("profile_getPicture")#@@TODO DON'T REFETCH?


	def onSetProfilePictureError(self, errorCode):
		self.profilePictureUpdated.emit(self.jid);


	def onSetGroupPicture(self,jid):
		self.interfaceHandler.call("group_getPicture", (jid,))


	def onSetGroupPictureError(self, jid, errorCode):
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
		self.retry = True
		self.eventHandler = WAEventHandler(self);	
		
		
		self.disconnectRequested = False
		
		self.connTries = 0;
		
		self.verbose = True
		self.iqId = 0;
	
		
		self.waiting = 0;
		
		#super(WAXMPP,self).__init__();
		
		#self.eventHandler.initialConnCheck();
		
		#self.do_login();
	def setContactsManager(self,contactsManager):
		self.contactsManager = contactsManager
		


	

